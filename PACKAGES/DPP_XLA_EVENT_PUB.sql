--------------------------------------------------------
--  DDL for Package DPP_XLA_EVENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DPP_XLA_EVENT_PUB" AUTHID CURRENT_USER AS
/* $Header: dppxlaes.pls 120.0.12010000.2 2008/08/05 05:20:28 sanagar ship $ */
 /*============================================================================
  API name     : DPP_XLA_EVENT_PUB.CreateAccounting
  Type         : private
  Pre-reqs     : Create events and execute SLA create accounting program
  Description  : This API will do the following:
                     1) For inventory material transactions present in the Price
                        Protection extract table, raise exception for
                        records that have not been accounted in mtl_transaction accounts
                     2) Derive default code combinations for each account depending
                     	on the type of transaction
       		     3)	Create events for eligible records present in the extract
       		        table

   Version     :  Current Version 1.0
                  Initial Version 1.0
   Parameters  :

   OUT         :  retcode OUT NUMBER
                  errbuf  OUT VARCHAR2
 ============================================================================*/


PROCEDURE CreateAccounting(	errbuf  OUT NOCOPY VARCHAR2,
				retcode OUT NOCOPY NUMBER,
				p_org_id IN NUMBER,
				p_source_application_id IN NUMBER,
				p_application_id IN NUMBER,
				p_dummy IN VARCHAR2,
				p_ledger_id IN NUMBER,
				P_PROCESS_CATEGORY_CODE IN VARCHAR2,
				P_END_DATE IN VARCHAR2,
				P_CREATE_ACCOUNTING_FLAG IN VARCHAR2,
				P_DUMMY_PARAM_1 IN VARCHAR2,
				P_ACCOUNTING_MODE IN VARCHAR2,
				P_DUMMY_PARAM_2 IN VARCHAR2,
				P_ERRORS_ONLY_FLAG IN VARCHAR2,
				P_REPORT_STYLE IN VARCHAR2,
				P_TRANSFER_TO_GL_FLAG IN VARCHAR2,
				P_DUMMY_PARAM_3 IN VARCHAR2,
				P_POST_IN_GL_FLAG IN VARCHAR2,
				P_GL_BATCH_NAME IN VARCHAR2,
				P_MIN_PRECISION IN NUMBER,
				P_INCLUDE_ZERO_AMOUNT_LINES IN VARCHAR2,
				P_REQUEST_ID IN NUMBER,
				P_ENTITY_ID IN NUMBER,
				P_SOURCE_APPLICATION_NAME IN VARCHAR2,
				P_APPLICATION_NAME IN VARCHAR2,
				P_LEDGER_NAME IN VARCHAR2,
				P_PROCESS_CATEGORY_NAME IN VARCHAR2,
				P_CREATE_ACCOUNTING IN VARCHAR2,
				P_ACCOUNTING_MODE_NAME IN VARCHAR2,
				P_ERRORS_ONLY IN VARCHAR2,
				P_ACCOUNTING_REPORT_LEVEL IN VARCHAR2,
				P_TRANSFER_TO_GL IN VARCHAR2,
				P_POST_IN_GL IN VARCHAR2,
				P_INCLUDE_ZERO_AMT_LINES IN VARCHAR2,
				P_VALUATION_METHOD_CODE IN VARCHAR2,
				P_SECURITY_INT_1 IN NUMBER,
				P_SECURITY_INT_2 IN NUMBER,
				P_SECURITY_INT_3 IN NUMBER,
				P_SECURITY_CHAR_1 IN VARCHAR2,
				P_SECURITY_CHAR_2 IN VARCHAR2,
				P_SECURITY_CHAR_3 IN VARCHAR2,
				P_CONC_REQUEST_ID IN NUMBER,
				P_INCLUDE_USER_TRX_ID_FLAG IN VARCHAR2,
				P_INCLUDE_USER_TRX_IDENTIFIERS IN VARCHAR2,
				P_DebugFlag   IN VARCHAR2,
                                P_USER_ID IN NUMBER --Bug#7280169
			       );


FUNCTION get_pp_accrual_ccid(p_org_id IN NUMBER,
			      p_vendor_id IN NUMBER,
			      p_vendor_site_id IN NUMBER
			   ) RETURN NUMBER;

FUNCTION get_pp_cost_adjustment_ccid(p_org_id IN NUMBER,
			      	      p_vendor_id IN NUMBER,
			      	      p_vendor_site_id IN NUMBER) RETURN NUMBER;

FUNCTION get_pp_ap_clearing_ccid(
				      p_claim_id IN NUMBER,
				      p_org_id IN NUMBER,
			      	      p_vendor_id IN NUMBER,
			      	      p_vendor_site_id IN NUMBER) RETURN NUMBER;

FUNCTION get_pp_ar_clearing_ccid(
				      p_claim_id IN NUMBER,
				      p_org_id IN NUMBER,
			      	      p_vendor_id IN NUMBER,
			      	      p_vendor_site_id IN NUMBER) RETURN NUMBER;

FUNCTION get_pp_contra_liab_ccid(

				      p_org_id IN NUMBER,
			      	      p_vendor_id IN NUMBER,
			      	      p_vendor_site_id IN NUMBER) RETURN NUMBER;
END;


/
