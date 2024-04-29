--------------------------------------------------------
--  DDL for Package IBE_DELIVERABLE_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_DELIVERABLE_GRP_W" AUTHID CURRENT_USER as
  /* $Header: IBEGRDLS.pls 115.1 2002/12/18 07:08:26 schak ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy ibe_deliverable_grp.deliverable_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_2000
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t ibe_deliverable_grp.deliverable_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p3(t out nocopy ibe_deliverable_grp.dlv_ath_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_2000
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p3(t ibe_deliverable_grp.dlv_ath_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_2000
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_300
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p5(t out nocopy ibe_deliverable_grp.dlv_id_ver_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p5(t ibe_deliverable_grp.dlv_id_ver_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p6(t out nocopy ibe_deliverable_grp.number_table, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p6(t ibe_deliverable_grp.number_table, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p7(t out nocopy ibe_deliverable_grp.varchar2_table_100, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p7(t ibe_deliverable_grp.varchar2_table_100, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p8(t out nocopy ibe_deliverable_grp.varchar2_table_300, a0 JTF_VARCHAR2_TABLE_300);
  procedure rosetta_table_copy_out_p8(t ibe_deliverable_grp.varchar2_table_300, a0 out nocopy JTF_VARCHAR2_TABLE_300);

  procedure rosetta_table_copy_in_p9(t out nocopy ibe_deliverable_grp.varchar2_table_2000, a0 JTF_VARCHAR2_TABLE_2000);
  procedure rosetta_table_copy_out_p9(t ibe_deliverable_grp.varchar2_table_2000, a0 out nocopy JTF_VARCHAR2_TABLE_2000);

  procedure list_deliverable(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_item_type  VARCHAR2
    , p_item_applicable_to  VARCHAR2
    , p_search_type  VARCHAR2
    , p_search_value  VARCHAR2
    , p_start_id  NUMBER
    , p_batch_size  NUMBER
    , x_row_count out nocopy  NUMBER
    , x_dlv_id_tbl out nocopy JTF_NUMBER_TABLE
    , x_acc_name_tbl out nocopy JTF_VARCHAR2_TABLE_100
    , x_dsp_name_tbl out nocopy JTF_VARCHAR2_TABLE_300
    , x_item_type_tbl out nocopy JTF_VARCHAR2_TABLE_100
    , x_appl_to_tbl out nocopy JTF_VARCHAR2_TABLE_100
    , x_keyword_tbl out nocopy JTF_VARCHAR2_TABLE_300
    , x_desc_tbl out nocopy JTF_VARCHAR2_TABLE_2000
    , x_version_tbl out nocopy JTF_NUMBER_TABLE
    , x_file_name_tbl out nocopy JTF_VARCHAR2_TABLE_300
    , x_file_id_tbl out nocopy JTF_NUMBER_TABLE
  );
  procedure list_deliverable(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_category_id  NUMBER
    , p_item_type  VARCHAR2
    , p_item_applicable_to  VARCHAR2
    , p_search_type  VARCHAR2
    , p_search_value  VARCHAR2
    , p_start_id  NUMBER
    , p_batch_size  NUMBER
    , x_row_count out nocopy  NUMBER
    , x_dlv_id_tbl out nocopy JTF_NUMBER_TABLE
    , x_acc_name_tbl out nocopy JTF_VARCHAR2_TABLE_100
    , x_dsp_name_tbl out nocopy JTF_VARCHAR2_TABLE_300
    , x_item_type_tbl out nocopy JTF_VARCHAR2_TABLE_100
    , x_appl_to_tbl out nocopy JTF_VARCHAR2_TABLE_100
    , x_keyword_tbl out nocopy JTF_VARCHAR2_TABLE_300
    , x_desc_tbl out nocopy JTF_VARCHAR2_TABLE_2000
    , x_version_tbl out nocopy JTF_NUMBER_TABLE
    , x_file_name_tbl out nocopy JTF_VARCHAR2_TABLE_300
    , x_file_id_tbl out nocopy JTF_NUMBER_TABLE
  );
  procedure save_deliverable(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 in out nocopy  NUMBER
    , p6_a1 in out nocopy  VARCHAR2
    , p6_a2 in out nocopy  VARCHAR2
    , p6_a3 in out nocopy  VARCHAR2
    , p6_a4 in out nocopy  VARCHAR2
    , p6_a5 in out nocopy  VARCHAR2
    , p6_a6 in out nocopy  VARCHAR2
    , p6_a7 in out nocopy  NUMBER
    , p6_a8 in out nocopy  VARCHAR2
  );
  procedure save_deliverable(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 in out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 in out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a6 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a7 in out nocopy JTF_NUMBER_TABLE
    , p6_a8 in out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure save_deliverable(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 in out nocopy  NUMBER
    , p6_a1 in out nocopy  VARCHAR2
    , p6_a2 in out nocopy  VARCHAR2
    , p6_a3 in out nocopy  VARCHAR2
    , p6_a4 in out nocopy  VARCHAR2
    , p6_a5 in out nocopy  VARCHAR2
    , p6_a6 in out nocopy  VARCHAR2
    , p6_a7 in out nocopy  NUMBER
    , p6_a8 in out nocopy  VARCHAR2
    , p6_a9 in out nocopy  VARCHAR2
    , p6_a10 in out nocopy  NUMBER
    , p6_a11 in out nocopy  VARCHAR2
  );
  procedure save_deliverable(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 in out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 in out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a6 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a7 in out nocopy JTF_NUMBER_TABLE
    , p6_a8 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 in out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a10 in out nocopy JTF_NUMBER_TABLE
    , p6_a11 in out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure delete_deliverable(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 in out nocopy JTF_NUMBER_TABLE
    , p6_a1 in out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a2 in out nocopy JTF_NUMBER_TABLE
    , p6_a3 in out nocopy JTF_VARCHAR2_TABLE_100
  );
end ibe_deliverable_grp_w;

 

/
