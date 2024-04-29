--------------------------------------------------------
--  DDL for Package AR_CMGT_DATA_POINTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CMGT_DATA_POINTS_PKG" AUTHID CURRENT_USER AS
/*  $Header: ARCMGDPS.pls 120.1 2005/07/28 21:57:21 bsarkar noship $ */

g_data_case_folder_id               ar_cmgt_case_folders.case_folder_id%type;
g_data_case_folder_exists           VARCHAR2(1);

g_source_name 			            VARCHAR2(30);
g_source_id			                VARCHAR2(50);

TYPE curr_array_type                IS varray(10) of VARCHAR2(15);

PROCEDURE GATHER_DATA_POINTS(
            p_party_id              IN   NUMBER,
            p_cust_account_id       IN   NUMBER,
            p_cust_acct_site_id     IN   NUMBER,
            p_trx_currency          IN   VARCHAR2,
            p_org_id                IN   NUMBER default null,
            p_check_list_id         IN   NUMBER default null,
            p_credit_request_id     IN   NUMBER default null,
            p_score_model_id        IN   NUMBER default null,
            p_credit_classification IN   VARCHAR2 default null,
            p_review_type           IN   VARCHAR2 default null,
            p_case_folder_number    IN   VARCHAR2 default NULL,
            p_mode                  IN   VARCHAR2 default 'CREATE',
            p_limit_currency        OUT  NOCOPY VARCHAR2,
            p_case_folder_id        IN OUT  NOCOPY NUMBER,
            p_error_msg             OUT  NOCOPY VARCHAR2,
            p_resultout             OUT  NOCOPY VARCHAR2);

PROCEDURE GetFinancialData (
        p_credit_request_id         IN              NUMBER,
        p_case_folder_id            IN              NUMBER,
        p_mode                      IN              VARCHAR2 default 'CREATE',
        p_resultout                 OUT NOCOPY      VARCHAR2,
        p_errmsg                    OUT NOCOPY      VARCHAR2);
END AR_CMGT_DATA_POINTS_PKG;

 

/
