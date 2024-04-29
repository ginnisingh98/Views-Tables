--------------------------------------------------------
--  DDL for Package OCM_ADD_DATA_POINTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OCM_ADD_DATA_POINTS" AUTHID CURRENT_USER AS
/*  $Header: OCMGTDPS.pls 120.4 2005/12/30 20:55:18 bsarkar noship $ */
/*=======================================================================+
 |  Declare PUBLIC Data Types and Variables
 +=======================================================================*/

TYPE OCM_ADD_DP_PARAM_REC_TYPE IS RECORD
     (
        p_credit_request_id               NUMBER,
        p_case_folder_id                  NUMBER,
        p_application_number              VARCHAR2(30),
        p_TRX_CURRENCY                    VARCHAR2(30),
        p_LIMIT_CURRENCY                  VARCHAR2(30),
        p_party_id                        NUMBER,
        p_cust_account_id                 NUMBER,
        p_site_use_id                     NUMBER,
        p_requestor_id                    NUMBER,
        p_credit_analyst_id               NUMBER,
        p_review_type                     VARCHAR2(30),
        p_credit_classification           VARCHAR2(30),
        p_check_list_id                   NUMBER,
        p_score_model_id                  NUMBER,
        p_credit_type                     VARCHAR2(30),
        p_source_name                     VARCHAR2(30),
        p_source_user_id                  NUMBER,
        p_source_resp_id                  NUMBER,
        p_source_resp_appln_id            NUMBER,
        p_source_security_group_id        NUMBER,
        p_source_org_id                   NUMBER,
        p_source_column1                  VARCHAR2(150),
        p_source_column2                  VARCHAR2(150),
        p_source_column3                  VARCHAR2(150),
        p_data_point_application_id       NUMBER,
        p_data_point_id                   NUMBER ,
        p_parent_data_point_id            NUMBER,
        p_data_point_value                VARCHAR2(240),
        p_exchange_rate_type			  VARCHAR2(30),
        p_data_point_value_id			  NUMBER,
        p_return_data_type                VARCHAR2(30),
        p_return_date_format              VARCHAR2(60)
    );


pg_ocm_add_dp_param_rec OCM_ADD_DP_PARAM_REC_TYPE;

TYPE ocm_dp_values_rec_type IS RECORD
     (
        p_data_point_id                   NUMBER,
        p_parent_data_point_id            NUMBER,
        p_sequence_number                 NUMBER,
        p_data_point_value                VARCHAR2(240),
        p_data_point_value_id			  NUMBER
     );

TYPE ocm_dp_values_tbl_type IS TABLE OF ocm_dp_values_rec_type
                        INDEX BY BINARY_INTEGER;

pg_ocm_dp_values_tbl OCM_DP_VALUES_TBL_TYPE;

PROCEDURE GetAdditionalDataPoints (
	p_credit_request_id		IN		NUMBER,
	p_case_folder_id		IN		NUMBER,
	p_mode					IN		VARCHAR2 DEFAULT 'CREATE',
	p_error_msg				OUT NOCOPY VARCHAR2,
	p_resultout				OUT	NOCOPY VARCHAR2 );

END OCM_ADD_DATA_POINTS;

 

/
