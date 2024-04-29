--------------------------------------------------------
--  DDL for Package JTF_DELIVERABLE_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_DELIVERABLE_GRP_W" AUTHID CURRENT_USER as
  /* $Header: JTFGRDLS.pls 115.9 2004/07/09 18:50:40 applrt ship $ */
  procedure rosetta_table_copy_in_p1(t out jtf_deliverable_grp.deliverable_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_2000
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t jtf_deliverable_grp.deliverable_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_VARCHAR2_TABLE_100
    , a2 out JTF_VARCHAR2_TABLE_300
    , a3 out JTF_VARCHAR2_TABLE_100
    , a4 out JTF_VARCHAR2_TABLE_100
    , a5 out JTF_VARCHAR2_TABLE_300
    , a6 out JTF_VARCHAR2_TABLE_2000
    , a7 out JTF_NUMBER_TABLE
    , a8 out JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p3(t out jtf_deliverable_grp.dlv_ath_tbl_type, a0 JTF_NUMBER_TABLE
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
  procedure rosetta_table_copy_out_p3(t jtf_deliverable_grp.dlv_ath_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_VARCHAR2_TABLE_100
    , a2 out JTF_VARCHAR2_TABLE_300
    , a3 out JTF_VARCHAR2_TABLE_100
    , a4 out JTF_VARCHAR2_TABLE_100
    , a5 out JTF_VARCHAR2_TABLE_300
    , a6 out JTF_VARCHAR2_TABLE_2000
    , a7 out JTF_NUMBER_TABLE
    , a8 out JTF_VARCHAR2_TABLE_100
    , a9 out JTF_VARCHAR2_TABLE_300
    , a10 out JTF_NUMBER_TABLE
    , a11 out JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p5(t out jtf_deliverable_grp.dlv_id_ver_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p5(t jtf_deliverable_grp.dlv_id_ver_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_VARCHAR2_TABLE_300
    , a2 out JTF_NUMBER_TABLE
    , a3 out JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p6(t out jtf_deliverable_grp.number_table, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p6(t jtf_deliverable_grp.number_table, a0 out JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p7(t out jtf_deliverable_grp.varchar2_table_100, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p7(t jtf_deliverable_grp.varchar2_table_100, a0 out JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p8(t out jtf_deliverable_grp.varchar2_table_300, a0 JTF_VARCHAR2_TABLE_300);
  procedure rosetta_table_copy_out_p8(t jtf_deliverable_grp.varchar2_table_300, a0 out JTF_VARCHAR2_TABLE_300);

  procedure rosetta_table_copy_in_p9(t out jtf_deliverable_grp.varchar2_table_2000, a0 JTF_VARCHAR2_TABLE_2000);
  procedure rosetta_table_copy_out_p9(t jtf_deliverable_grp.varchar2_table_2000, a0 out JTF_VARCHAR2_TABLE_2000);

  procedure list_deliverable(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p_item_type  VARCHAR2
    , p_item_applicable_to  VARCHAR2
    , p_search_type  VARCHAR2
    , p_search_value  VARCHAR2
    , p_start_id  NUMBER
    , p_batch_size  NUMBER
    , x_row_count out  NUMBER
    , x_dlv_id_tbl out JTF_NUMBER_TABLE
    , x_acc_name_tbl out JTF_VARCHAR2_TABLE_100
    , x_dsp_name_tbl out JTF_VARCHAR2_TABLE_300
    , x_item_type_tbl out JTF_VARCHAR2_TABLE_100
    , x_appl_to_tbl out JTF_VARCHAR2_TABLE_100
    , x_keyword_tbl out JTF_VARCHAR2_TABLE_300
    , x_desc_tbl out JTF_VARCHAR2_TABLE_2000
    , x_version_tbl out JTF_NUMBER_TABLE
    , x_file_name_tbl out JTF_VARCHAR2_TABLE_300
    , x_file_id_tbl out JTF_NUMBER_TABLE
  );
  procedure list_deliverable(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p_category_id  NUMBER
    , p_item_type  VARCHAR2
    , p_item_applicable_to  VARCHAR2
    , p_search_type  VARCHAR2
    , p_search_value  VARCHAR2
    , p_start_id  NUMBER
    , p_batch_size  NUMBER
    , x_row_count out  NUMBER
    , x_dlv_id_tbl out JTF_NUMBER_TABLE
    , x_acc_name_tbl out JTF_VARCHAR2_TABLE_100
    , x_dsp_name_tbl out JTF_VARCHAR2_TABLE_300
    , x_item_type_tbl out JTF_VARCHAR2_TABLE_100
    , x_appl_to_tbl out JTF_VARCHAR2_TABLE_100
    , x_keyword_tbl out JTF_VARCHAR2_TABLE_300
    , x_desc_tbl out JTF_VARCHAR2_TABLE_2000
    , x_version_tbl out JTF_NUMBER_TABLE
    , x_file_name_tbl out JTF_VARCHAR2_TABLE_300
    , x_file_id_tbl out JTF_NUMBER_TABLE
  );
  procedure save_deliverable(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p6_a0 in out  NUMBER
    , p6_a1 in out  VARCHAR2
    , p6_a2 in out  VARCHAR2
    , p6_a3 in out  VARCHAR2
    , p6_a4 in out  VARCHAR2
    , p6_a5 in out  VARCHAR2
    , p6_a6 in out  VARCHAR2
    , p6_a7 in out  NUMBER
    , p6_a8 in out  VARCHAR2
  );
  procedure save_deliverable(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p6_a0 in out JTF_NUMBER_TABLE
    , p6_a1 in out JTF_VARCHAR2_TABLE_100
    , p6_a2 in out JTF_VARCHAR2_TABLE_300
    , p6_a3 in out JTF_VARCHAR2_TABLE_100
    , p6_a4 in out JTF_VARCHAR2_TABLE_100
    , p6_a5 in out JTF_VARCHAR2_TABLE_300
    , p6_a6 in out JTF_VARCHAR2_TABLE_2000
    , p6_a7 in out JTF_NUMBER_TABLE
    , p6_a8 in out JTF_VARCHAR2_TABLE_100
  );
  procedure save_deliverable(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p6_a0 in out  NUMBER
    , p6_a1 in out  VARCHAR2
    , p6_a2 in out  VARCHAR2
    , p6_a3 in out  VARCHAR2
    , p6_a4 in out  VARCHAR2
    , p6_a5 in out  VARCHAR2
    , p6_a6 in out  VARCHAR2
    , p6_a7 in out  NUMBER
    , p6_a8 in out  VARCHAR2
    , p6_a9 in out  VARCHAR2
    , p6_a10 in out  NUMBER
    , p6_a11 in out  VARCHAR2
  );
  procedure save_deliverable(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p6_a0 in out JTF_NUMBER_TABLE
    , p6_a1 in out JTF_VARCHAR2_TABLE_100
    , p6_a2 in out JTF_VARCHAR2_TABLE_300
    , p6_a3 in out JTF_VARCHAR2_TABLE_100
    , p6_a4 in out JTF_VARCHAR2_TABLE_100
    , p6_a5 in out JTF_VARCHAR2_TABLE_300
    , p6_a6 in out JTF_VARCHAR2_TABLE_2000
    , p6_a7 in out JTF_NUMBER_TABLE
    , p6_a8 in out JTF_VARCHAR2_TABLE_100
    , p6_a9 in out JTF_VARCHAR2_TABLE_300
    , p6_a10 in out JTF_NUMBER_TABLE
    , p6_a11 in out JTF_VARCHAR2_TABLE_100
  );
  procedure delete_deliverable(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p6_a0 in out JTF_NUMBER_TABLE
    , p6_a1 in out JTF_VARCHAR2_TABLE_300
    , p6_a2 in out JTF_NUMBER_TABLE
    , p6_a3 in out JTF_VARCHAR2_TABLE_100
  );
end jtf_deliverable_grp_w;

 

/
