--------------------------------------------------------
--  DDL for Package JTF_FM_REQUEST_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_FM_REQUEST_GRP_W" AUTHID CURRENT_USER as
  /* $Header: jtfgfmws.pls 120.2 2005/12/27 00:34 anchaudh ship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy jtf_fm_request_grp.g_varchar_tbl_type, a0 JTF_VARCHAR2_TABLE_1000);
  procedure rosetta_table_copy_out_p3(t jtf_fm_request_grp.g_varchar_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_1000);

  procedure rosetta_table_copy_in_p5(t out nocopy jtf_fm_request_grp.g_number_tbl_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p5(t jtf_fm_request_grp.g_number_tbl_type, a0 out nocopy JTF_NUMBER_TABLE);

  procedure get_content_xml(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_content_id  NUMBER
    , p_content_nm  VARCHAR2
    , p_document_type  VARCHAR2
    , p_quantity  NUMBER
    , p_media_type  VARCHAR2
    , p_printer  VARCHAR2
    , p_email  VARCHAR2
    , p_fax  VARCHAR2
    , p_file_path  VARCHAR2
    , p_user_note  VARCHAR2
    , p_content_type  VARCHAR2
    , p_bind_var JTF_VARCHAR2_TABLE_1000
    , p_bind_val JTF_VARCHAR2_TABLE_1000
    , p_bind_var_type JTF_VARCHAR2_TABLE_1000
    , p_request_id  NUMBER
    , x_content_xml out nocopy  VARCHAR2
  );
  procedure get_content_xml(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_content_id  NUMBER
    , p_content_nm  VARCHAR2
    , p_document_type  VARCHAR2
    , p_quantity  NUMBER
    , p_media_type  VARCHAR2
    , p_printer  VARCHAR2
    , p_email  VARCHAR2
    , p_fax  VARCHAR2
    , p_file_path  VARCHAR2
    , p_user_note  VARCHAR2
    , p_content_type  VARCHAR2
    , p_bind_var JTF_VARCHAR2_TABLE_1000
    , p_bind_val JTF_VARCHAR2_TABLE_1000
    , p_bind_var_type JTF_VARCHAR2_TABLE_1000
    , p_request_id  NUMBER
    , x_content_xml out nocopy  VARCHAR2
    , p_content_source  VARCHAR2
    , p_version  NUMBER
  );
  procedure cancel_request(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_request_id  NUMBER
    , p_submit_dt_tm  date
  );
  procedure get_multiple_content_xml(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_request_id  NUMBER
    , p_content_type JTF_VARCHAR2_TABLE_1000
    , p_content_id JTF_NUMBER_TABLE
    , p_content_nm JTF_VARCHAR2_TABLE_1000
    , p_document_type JTF_VARCHAR2_TABLE_1000
    , p_media_type JTF_VARCHAR2_TABLE_1000
    , p_printer JTF_VARCHAR2_TABLE_1000
    , p_email JTF_VARCHAR2_TABLE_1000
    , p_fax JTF_VARCHAR2_TABLE_1000
    , p_file_path JTF_VARCHAR2_TABLE_1000
    , p_user_note JTF_VARCHAR2_TABLE_1000
    , p_quantity JTF_NUMBER_TABLE
    , x_content_xml out nocopy  VARCHAR2
  );
  procedure submit_batch_request(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_template_id  NUMBER
    , p_subject  VARCHAR2
    , p_user_id  NUMBER
    , p_source_code_id  NUMBER
    , p_source_code  VARCHAR2
    , p_object_type  VARCHAR2
    , p_object_id  NUMBER
    , p_order_id  NUMBER
    , p_doc_id  NUMBER
    , p_doc_ref  VARCHAR2
    , p_list_type  VARCHAR2
    , p_view_nm  VARCHAR2
    , p_party_id JTF_NUMBER_TABLE
    , p_party_name JTF_VARCHAR2_TABLE_1000
    , p_printer JTF_VARCHAR2_TABLE_1000
    , p_email JTF_VARCHAR2_TABLE_1000
    , p_fax JTF_VARCHAR2_TABLE_1000
    , p_file_path JTF_VARCHAR2_TABLE_1000
    , p_server_id  NUMBER
    , p_queue_response  VARCHAR2
    , p_extended_header  VARCHAR2
    , p_content_xml  VARCHAR2
    , p_request_id  NUMBER
    , p_per_user_history  VARCHAR2
  );
  procedure submit_mass_request(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_template_id  NUMBER
    , p_subject  VARCHAR2
    , p_user_id  NUMBER
    , p_source_code_id  NUMBER
    , p_source_code  VARCHAR2
    , p_object_type  VARCHAR2
    , p_object_id  NUMBER
    , p_order_id  NUMBER
    , p_doc_id  NUMBER
    , p_doc_ref  VARCHAR2
    , p_list_type  VARCHAR2
    , p_view_nm  VARCHAR2
    , p_server_id  NUMBER
    , p_queue_response  VARCHAR2
    , p_extended_header  VARCHAR2
    , p_content_xml  VARCHAR2
    , p_request_id  NUMBER
    , p_per_user_history  VARCHAR2
    , p_mass_query_id  NUMBER
    , p_mass_bind_var JTF_VARCHAR2_TABLE_1000
    , p_mass_bind_var_type JTF_VARCHAR2_TABLE_1000
    , p_mass_bind_val JTF_VARCHAR2_TABLE_1000
  );
  procedure new_cancel_request(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_request_id  NUMBER
    , p_submit_dt_tm  date
  );
  procedure correct_malformed(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_request_id  NUMBER
    , p_job JTF_NUMBER_TABLE
    , p_corrected_address JTF_VARCHAR2_TABLE_1000
    , x_return_status out nocopy  VARCHAR2
  );
  procedure resubmit_malformed(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_request_id  NUMBER
    , x_request_id out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
  );
end jtf_fm_request_grp_w;

 

/
