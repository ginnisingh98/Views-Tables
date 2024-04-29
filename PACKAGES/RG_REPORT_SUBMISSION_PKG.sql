--------------------------------------------------------
--  DDL for Package RG_REPORT_SUBMISSION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RG_REPORT_SUBMISSION_PKG" AUTHID CURRENT_USER as
/* $Header: rgursubs.pls 120.8 2006/06/06 18:07:58 vtreiger ship $ */

    --
    -- Name
    --	  submit_report_set()
    -- Purpose
    --    Submit the whole report set
    -- ARGUMENTS
    --    1. concurrent request ids
    --    2. application short name
    --    3. data access set id
    -- 	  4. report set period
    -- 	  5. accounting_date
    --    6. default ledger id
    --    7. unit of measure id
    --    8. report set id
    --    9. page length
    --   10. report set request id
    -- CALLS
    --    submit_report: submit a report in the report set
    -- CALLED BY
    --    form RGXGRRST
    -- Note:  the last concurrent req id is returned
    --

    FUNCTION submit_report_set(
                       conc_req_ids     		IN OUT NOCOPY VARCHAR2,
		       appl_short_name			IN VARCHAR2,
		       data_access_set_id		IN NUMBER,
		       set_period_name			IN VARCHAR2,
		       accounting_date			IN DATE,
		       default_ledger_short_name	IN VARCHAR2,
		       unit_of_m_id			IN VARCHAR2,
             	       report_set_id			IN NUMBER,
		       page_len				IN NUMBER,
                       report_set_request_id		IN NUMBER DEFAULT NULL
)
    	RETURN 		BOOLEAN;


    -- Name
    --	   submit_report
    -- Purpose
    --	   Submit a report in the report set
    -- Arguments
    --          1. concurrent request id
    --		2. report set period name
    --		3. accounting date
    --          4. default ledger short name
    --		5. unit of measure id
    --		6. data access set id
    --		7. appl_short_name
    --		8. report id
    --		9. page length
    --	       10. report request id
    --         11. report set request id
    -- Calls
    --    FND_REQUEST.SUBMIT_REQUEST
    -- Call By
    --    submit_report_set
    --

   FUNCTION  submit_report(conc_req_id          	IN OUT NOCOPY NUMBER,
                           set_period_name		IN VARCHAR2,
                           accounting_date		IN DATE,
			   default_ledger_short_name	IN VARCHAR2,
			   unit_of_m_id	        	IN VARCHAR2,
			   data_access_set_id		IN NUMBER,
			   appl_short_name		IN VARCHAR2,
			   rep_id			IN NUMBER,
			   page_len			IN NUMBER,
			   rep_request_id		IN NUMBER,
			   report_set_request_id	IN NUMBER DEFAULT NULL
)
	RETURN		     BOOLEAN;

   FUNCTION  submit_request
	       (X_APPL_SHORT_NAME		IN 	VARCHAR2,
 		X_DATA_ACCESS_SET_ID    	IN      NUMBER,
		X_CONCURRENT_REQUEST_ID 	OUT NOCOPY NUMBER,
                X_PROGRAM               	OUT NOCOPY VARCHAR2,
		X_COA_ID			IN      NUMBER,
		X_ADHOC_PREFIX			IN	VARCHAR2,
		X_INDUSTRY			IN	VARCHAR2,
		X_FLEX_CODE			IN	VARCHAR2,
                X_DEFAULT_LEDGER_SHORT_NAME	IN      VARCHAR2,
		X_REPORT_ID			IN      NUMBER,
		X_ROW_SET_ID			IN      NUMBER,
		X_COLUMN_SET_ID			IN	NUMBER,
		X_PERIOD_NAME           	IN      VARCHAR2,
 		X_UNIT_OF_MEASURE_ID    	IN      VARCHAR2,
 		X_ROUNDING_OPTION       	IN      VARCHAR2,
 		X_SEGMENT_OVERRIDE      	IN      VARCHAR2,
 		X_CONTENT_SET_ID        	IN      NUMBER,
 		X_ROW_ORDER_ID          	IN	NUMBER,
 		X_REPORT_DISPLAY_SET_ID 	IN      NUMBER,
		X_OUTPUT_OPTION			IN	VARCHAR2,
 		X_EXCEPTIONS_FLAG       	IN      VARCHAR2,
		X_MINIMUM_DISPLAY_LEVEL 	IN	NUMBER,
		X_ACCOUNTING_DATE       	IN      DATE,
 		X_PARAMETER_SET_ID      	IN      NUMBER,
		X_PAGE_LENGTH			IN	NUMBER,
		X_SUBREQUEST_ID                 IN      NUMBER,
		X_APPL_DEFLT_NAME               IN      VARCHAR2)
	     RETURN	BOOLEAN;

   FUNCTION  submit_request_addparam
	       (X_APPL_SHORT_NAME	IN 	VARCHAR2,
 		X_DATA_ACCESS_SET_ID    	IN      NUMBER,
		X_CONCURRENT_REQUEST_ID 	OUT NOCOPY NUMBER,
                X_PROGRAM               	OUT NOCOPY VARCHAR2,
		X_COA_ID			IN      NUMBER,
		X_ADHOC_PREFIX			IN	VARCHAR2,
		X_INDUSTRY			IN	VARCHAR2,
		X_FLEX_CODE			IN	VARCHAR2,
                X_DEFAULT_LEDGER_SHORT_NAME	IN      VARCHAR2,
		X_REPORT_ID			IN      NUMBER,
		X_ROW_SET_ID			IN      NUMBER,
		X_COLUMN_SET_ID			IN	NUMBER,
		X_PERIOD_NAME           	IN      VARCHAR2,
 		X_UNIT_OF_MEASURE_ID    	IN      VARCHAR2,
 		X_ROUNDING_OPTION       	IN      VARCHAR2,
 		X_SEGMENT_OVERRIDE      	IN      VARCHAR2,
 		X_CONTENT_SET_ID        	IN      NUMBER,
 		X_ROW_ORDER_ID          	IN	NUMBER,
 		X_REPORT_DISPLAY_SET_ID 	IN      NUMBER,
		X_OUTPUT_OPTION			IN	VARCHAR2,
 		X_EXCEPTIONS_FLAG       	IN      VARCHAR2,
		X_MINIMUM_DISPLAY_LEVEL 	IN	NUMBER,
		X_ACCOUNTING_DATE       	IN      DATE,
 		X_PARAMETER_SET_ID      	IN      NUMBER,
		X_PAGE_LENGTH			IN	NUMBER,
		X_SUBREQUEST_ID                 IN      NUMBER,
		X_APPL_DEFLT_NAME               IN      VARCHAR2,
		X_GBL_PARAM01           IN      VARCHAR2,
		X_GBL_PARAM02           IN      VARCHAR2,
		X_GBL_PARAM03           IN      VARCHAR2,
		X_GBL_PARAM04           IN      VARCHAR2,
		X_GBL_PARAM05           IN      VARCHAR2,
		X_GBL_PARAM06           IN      VARCHAR2,
		X_GBL_PARAM07           IN      VARCHAR2,
		X_GBL_PARAM08           IN      VARCHAR2,
		X_GBL_PARAM09           IN      VARCHAR2,
		X_GBL_PARAM10           IN      VARCHAR2,
		X_CST_PARAM01           IN      VARCHAR2,
		X_CST_PARAM02           IN      VARCHAR2,
		X_CST_PARAM03           IN      VARCHAR2,
		X_CST_PARAM04           IN      VARCHAR2,
		X_CST_PARAM05           IN      VARCHAR2,
		X_CST_PARAM06           IN      VARCHAR2,
		X_CST_PARAM07           IN      VARCHAR2,
		X_CST_PARAM08           IN      VARCHAR2,
		X_CST_PARAM09           IN      VARCHAR2,
		X_CST_PARAM10           IN      VARCHAR2)
	     RETURN	BOOLEAN;

   FUNCTION  submit_xml_request
	       (X_APPL_SHORT_NAME	IN 	VARCHAR2,
 		X_IN_CONC_REQ_ID        IN      NUMBER,
		X_CONCURRENT_REQUEST_ID OUT NOCOPY  	NUMBER,
                X_PROGRAM               OUT NOCOPY     VARCHAR2,
 		X_TEMPLATE_CODE         IN      VARCHAR2,
 		X_APPLICATION_ID        IN      NUMBER)
	     RETURN	BOOLEAN;

END rg_report_submission_pkg;

 

/
