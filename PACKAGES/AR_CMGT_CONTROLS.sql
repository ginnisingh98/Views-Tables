--------------------------------------------------------
--  DDL for Package AR_CMGT_CONTROLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CMGT_CONTROLS" AUTHID CURRENT_USER AS
/* $Header: ARCMGCCS.pls 120.9 2005/11/30 23:08:02 bsarkar noship $ */
PROCEDURE POPULATE_DNB_DATA (
        p_case_folder_id            IN      NUMBER,
        p_source_table_name         IN      VARCHAR2,
        p_source_key                IN      VARCHAR2,
        p_source_key_type           IN      VARCHAR2 default NULL,
        p_source_key_column_name    IN      VARCHAR2,
        p_source_key_column_type    IN      VARCHAR2 default NULL,
        p_errmsg                    OUT NOCOPY     VARCHAR2,
        p_resultout                 OUT NOCOPY     VARCHAR2);

PROCEDURE POPULATE_CASE_FOLDER (
        p_case_folder_id                IN      NUMBER,
        p_case_folder_number            IN      VARCHAR2    default NULL,
        p_credit_request_id             IN      NUMBER      default NULL,
        p_check_list_id                 IN      NUMBER      default NULL,
        p_status                        IN      VARCHAR2    default NULL,
        p_party_id                      IN      NUMBER,
        p_cust_account_id               IN      NUMBER,
        p_cust_acct_site_id             IN      NUMBER,
        p_score_model_id                IN      NUMBER      default NULL,
        p_credit_classification         IN      VARCHAR2    default NULL,
        p_review_type                   IN      VARCHAR2    default NULL,
        p_limit_currency                IN      VARCHAR2,
        p_exchange_rate_type            IN      VARCHAR2,
        p_type                          IN      VARCHAR2,
        p_errmsg                        OUT NOCOPY     VARCHAR2,
        p_resultout                     OUT NOCOPY     VARCHAR2);

PROCEDURE POPULATE_CASE_FOLDER_DETAILS (
        p_case_folder_id                IN      NUMBER,
        p_data_point_id                 IN      NUMBER,
        p_data_point_value              IN      VARCHAR2,
        p_included_in_check_list        IN      VARCHAR2,
        p_score                         IN      NUMBER default NULL,
        p_errmsg                        OUT NOCOPY     VARCHAR2,
        p_resultout                     OUT NOCOPY     VARCHAR2);

PROCEDURE UPDATE_CASE_FOLDER_DETAILS (
        p_case_folder_id                IN      NUMBER,
        p_data_point_id                 IN      NUMBER,
        p_data_point_value              IN      VARCHAR2,
        p_score                         IN      NUMBER default NULL,
        p_errmsg                        OUT NOCOPY     VARCHAR2,
        p_resultout                     OUT NOCOPY     VARCHAR2);

procedure populate_recommendation(
        p_case_folder_id            IN      NUMBER,
        p_credit_request_id         IN      NUMBER,
        p_score                     IN      NUMBER,
        p_recommended_credit_limit  IN      NUMBER,
        p_credit_review_date        IN      DATE,
        p_credit_recommendation     IN      VARCHAR2,
        p_recommendation_value1     IN      VARCHAR2,
        p_recommendation_value2     IN      VARCHAR2,
        p_status                    IN      VARCHAR2,
        p_credit_type               IN      VARCHAR2,
        p_errmsg                    OUT NOCOPY     VARCHAR2,
        p_resultout                 OUT NOCOPY     VARCHAR2 );

procedure populate_data_points
        ( p_data_point_name             IN              VARCHAR2,
          p_data_point_category         IN              VARCHAR2,
          p_user_defined_flag           IN              VARCHAR2,
          p_scorable_flag               IN              VARCHAR2,
          p_display_on_checklist        IN              VARCHAR2,
	      p_created_by			        IN		        NUMBER,
          p_data_point_code             IN              VARCHAR2,
          p_data_point_id               OUT NOCOPY             NUMBER);

PROCEDURE populate_add_data_points
        ( p_data_point_code		IN		VARCHAR2,
   	  p_data_point_name             IN              VARCHAR2,
	  	  p_description                 IN              VARCHAR2,
	  	  p_data_point_sub_category     IN              VARCHAR2,
          p_data_point_category         IN              VARCHAR2,
          p_user_defined_flag           IN              VARCHAR2,
          p_scorable_flag               IN              VARCHAR2,
          p_display_on_checklist        IN              VARCHAR2,
          p_created_by                  IN              NUMBER,
	  	  p_application_id		IN		NUMBER,
	  	  p_parent_data_point_id	IN		NUMBER,
          p_enabled_flag               	IN              VARCHAR2,
	  	  p_package_name 		IN		VARCHAR2,
          p_function_name               IN              VARCHAR2,
          p_function_type				IN				VARCHAR2,
          p_return_data_type			IN				VARCHAR2,
          p_return_date_format			IN				VARCHAR2,
          x_data_point_id               OUT NOCOPY	NUMBER);

PROCEDURE populate_aging_dtls(
        p_case_folder_id        IN          NUMBER,
        p_aging_bucket_id       IN          NUMBER,
        p_aging_bucket_line_id  IN          NUMBER,
        p_amount                IN          NUMBER,
        p_error_msg             OUT NOCOPY  VARCHAR2,
        p_resultout             OUT NOCOPY  VARCHAR2);

PROCEDURE update_aging_dtls(
        p_case_folder_id            IN          NUMBER,
        p_aging_bucket_id           IN          NUMBER,
        p_aging_bucket_line_id      IN          NUMBER,
        p_amount                    IN          NUMBER,
        p_error_msg                 OUT NOCOPY  VARCHAR2,
        p_resultout                 OUT NOCOPY  VARCHAR2);

PROCEDURE POPULATE_CF_ADP_DETAILS  (
        p_case_folder_id                IN      NUMBER,
        p_data_point_id                 IN      NUMBER,
        p_sequence_number               IN      NUMBER,
        p_parent_data_point_id          IN      NUMBER,
        p_parent_cf_detail_id           IN      NUMBER,
        p_data_point_value              IN      VARCHAR2,
        p_score                         IN      NUMBER default NULL,
        p_included_in_checklist         IN      VARCHAR2 default NULL,
        p_data_point_value_id			IN		NUMBER default NULL,
        p_case_folder_detail_id         OUT NOCOPY      NUMBER,
        p_errmsg                        OUT NOCOPY     VARCHAR2,
        p_resultout                     OUT NOCOPY     VARCHAR2);

PROCEDURE UPDATE_CF_ADP_DETAILS (

        p_case_folder_id                IN      NUMBER,
        p_data_point_id                 IN      NUMBER,
        p_sequence_number               IN      NUMBER,
        p_parent_data_point_id          IN      NUMBER,
        p_parent_cf_detail_id           IN      NUMBER,
        p_data_point_value              IN      VARCHAR2,
        p_score                         IN      NUMBER default NULL,
        p_included_in_checklist         IN      VARCHAR2 default NULL,
        p_data_point_value_id			IN		NUMBER	default NULL,
        p_case_folder_detail_id         IN OUT NOCOPY     NUMBER,
        x_errmsg                        OUT NOCOPY     VARCHAR2,
        x_resultout                     OUT NOCOPY     VARCHAR2);

PROCEDURE DUPLICATE_CASE_FOLDER_TBL
	( p_parnt_case_folder_id		IN      NUMBER,
	  p_credit_request_id                   IN      NUMBER,
      p_errmsg                              OUT NOCOPY     VARCHAR2,
      p_resultout                           OUT NOCOPY     VARCHAR2
       );
PROCEDURE DUPLICATE_CASE_FOLDER_DTLS(
      p_parnt_case_folder_id		IN      NUMBER,
	  p_credit_request_id                   IN      NUMBER,
      p_errmsg                              OUT NOCOPY     VARCHAR2,
      p_resultout                           OUT NOCOPY     VARCHAR2
	  );
PROCEDURE DUPLICATE_AGING_DATA(
          p_parnt_case_folder_id		IN      NUMBER,
	  	  p_credit_request_id                   IN      NUMBER,
          p_errmsg                              OUT NOCOPY     VARCHAR2,
          p_resultout                           OUT NOCOPY     VARCHAR2
	  );
PROCEDURE DUPLICATE_DNB_DATA(
          p_parnt_case_folder_id		IN      NUMBER,
	  	  p_credit_request_id                   IN      NUMBER,
          p_errmsg                              OUT NOCOPY     VARCHAR2,
          p_resultout                           OUT NOCOPY     VARCHAR2
	  );
PROCEDURE  DUPLICATE_FINANCIAL_DATA(
          p_parnt_credit_req_id  		IN      NUMBER,
	  	  p_credit_request_id                   IN      NUMBER,
          p_errmsg                              OUT NOCOPY     VARCHAR2,
          p_resultout                           OUT NOCOPY     VARCHAR2
         );
PROCEDURE  DUPLICATE_TRADE_DATA(
          p_parnt_credit_req_id  		IN      NUMBER,
	  	  p_credit_request_id                   IN      NUMBER,
          p_errmsg                              OUT NOCOPY     VARCHAR2,
          p_resultout                           OUT NOCOPY     VARCHAR2
        );
PROCEDURE  DUPLICATE_BANK_DATA(
          p_parnt_credit_req_id  		IN      NUMBER,
	  	  p_credit_request_id                   IN      NUMBER,
          p_errmsg                              OUT NOCOPY     VARCHAR2,
          p_resultout                           OUT NOCOPY     VARCHAR2
        );
PROCEDURE DUPLICATE_COLLATERAL_DATA(
          p_parnt_credit_req_id  		IN      NUMBER,
	  	  p_credit_request_id                   IN      NUMBER,
          p_errmsg                              OUT NOCOPY     VARCHAR2,
          p_resultout                           OUT NOCOPY     VARCHAR2
        );
PROCEDURE DUPLICATE_OTHER_DATA(
          p_parnt_credit_req_id  		IN      NUMBER,
	  	  p_credit_request_id                   IN      NUMBER,
          p_errmsg                              OUT NOCOPY     VARCHAR2,
          p_resultout                           OUT NOCOPY     VARCHAR2
        );
PROCEDURE DUPLICATE_RECO_DATA(
          p_parnt_case_folder_id  		IN      NUMBER,
	  	  p_credit_request_id                   IN      NUMBER,
          p_errmsg                              OUT NOCOPY     VARCHAR2,
          p_resultout                           OUT NOCOPY     VARCHAR2
        );
PROCEDURE DUPLICATE_NOTES_DATA(
          p_parnt_case_folder_id		IN      NUMBER,
	  	  p_credit_request_id                   IN      NUMBER,
          p_errmsg                              OUT NOCOPY     VARCHAR2,
          p_resultout                           OUT NOCOPY     VARCHAR2
	  );

PROCEDURE UPDATE_CASEFOLDER_DETAILS(
          P_DATA_POINT_ID		IN      NUMBER,
	  P_CASE_FOLDER_ID                   IN      NUMBER,
          P_RESULT                           OUT NOCOPY     NUMBER
	  );

PROCEDURE UPDATE_CF_DETAILS_NEGATION(
          P_DATA_POINT_ID               IN      NUMBER,
          P_CASE_FOLDER_ID                   IN      NUMBER,
          P_RESULT                           OUT NOCOPY     NUMBER
          );

END AR_CMGT_CONTROLS;

 

/
