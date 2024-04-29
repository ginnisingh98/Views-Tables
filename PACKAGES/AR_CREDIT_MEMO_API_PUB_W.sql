--------------------------------------------------------
--  DDL for Package AR_CREDIT_MEMO_API_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CREDIT_MEMO_API_PUB_W" AUTHID CURRENT_USER as
  /* $Header: ARICMWFS.pls 120.1.12010000.3 2008/09/22 12:21:05 nkanchan ship $ */

cm_line_tbl_type_cover arw_cmreq_cover.Cm_Line_Tbl_Type_Cover;

  procedure rosetta_table_copy_in_p1(t out nocopy cm_line_tbl_type_cover%type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p1(t cm_line_tbl_type_cover%type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p4(t out nocopy ar_credit_memo_api_pub.cm_notes_tbl_type_cover, a0 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p4(t ar_credit_memo_api_pub.cm_notes_tbl_type_cover, a0 out nocopy JTF_VARCHAR2_TABLE_300
    );

  procedure rosetta_table_copy_in_p7(t out nocopy ar_credit_memo_api_pub.cm_activity_tbl_type_cover, a0 JTF_DATE_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p7(t ar_credit_memo_api_pub.cm_activity_tbl_type_cover, a0 out nocopy JTF_DATE_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure create_request(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_customer_trx_id  NUMBER
    , p_line_credit_flag  VARCHAR2
    , p_line_amount  NUMBER
    , p_tax_amount  NUMBER
    , p_freight_amount  NUMBER
    , p_cm_reason_code  VARCHAR2
    , p_comments  VARCHAR2
    , p_orig_trx_number  VARCHAR2
    , p_tax_ex_cert_num  VARCHAR2
    , p_request_url  VARCHAR2
    , p_transaction_url  VARCHAR2
    , p_trans_act_url  VARCHAR2
    , p19_a0 JTF_NUMBER_TABLE
    , p_skip_workflow_flag VARCHAR2
    , p_credit_method_installments VARCHAR2
    , p_credit_method_rules VARCHAR2
    , p_batch_source_name VARCHAR2
    , p_org_id NUMBER
    , x_request_id out nocopy VARCHAR2
    , p19_a1 JTF_NUMBER_TABLE
    , p19_a2 JTF_NUMBER_TABLE
    , p19_a3 JTF_NUMBER_TABLE
    , p_dispute_date DATE
    , p_internal_comment VARCHAR2
  );
  procedure validate_request_parameters(p_customer_trx_id  NUMBER
    , p_line_credit_flag  VARCHAR2
    , p_line_amount  NUMBER
    , p_tax_amount  NUMBER
    , p_freight_amount  NUMBER
    , p_cm_reason_code  VARCHAR2
    , p_comments  VARCHAR2
    , p_request_url  VARCHAR2
    , p_transaction_url  VARCHAR2
    , p_trans_act_url  VARCHAR2
    , p10_a0 JTF_NUMBER_TABLE
    , p_org_id NUMBER
    , l_val_return_status out nocopy  VARCHAR2
    , p_skip_workflow_flag VARCHAR2
    , p_batch_source_name VARCHAR2
    , p10_a1 JTF_NUMBER_TABLE
    , p10_a2 JTF_NUMBER_TABLE
    , p10_a3 JTF_NUMBER_TABLE
    , p_dispute_date DATE
  );
end ar_credit_memo_api_pub_w;

/
