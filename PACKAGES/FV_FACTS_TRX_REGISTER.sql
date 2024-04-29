--------------------------------------------------------
--  DDL for Package FV_FACTS_TRX_REGISTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_FACTS_TRX_REGISTER" AUTHID CURRENT_USER AS
/* $Header: FVFCTRGS.pls 120.9.12010000.1 2008/07/28 06:30:58 appldev ship $ */
---- -------------------------------------------------------------------
--        PROCEDURE MAIN
-- ---------------------------------------------------------------------
-- Called from following procedures:
-- This is called from the concurrent program to execute FACTS
-- transaction register process
-- Purpose:
-- This calls all subsequent procedures
-- ---------------------------------------------------------------------
PROCEDURE main (p_errbuf              OUT NOCOPY VARCHAR2,
                p_retcode             OUT NOCOPY NUMBER,
                p_set_of_books_id         	 NUMBER,
                p_coa_id                  	 NUMBER,
           	p_currency_code           	 VARCHAR2,
                p_treasury_symbol_low     	 VARCHAR2,
                p_treasury_symbol_high    	 VARCHAR2,
                p_from_period_name        	 VARCHAR2,
                p_to_period_name          	 VARCHAR2,
		p_from_gl_posted_date		VARCHAR2,
		p_to_gl_posted_date		VARCHAR2,
           	p_source                  	 VARCHAR2 DEFAULT NULL,
           	p_category                	 VARCHAR2 DEFAULT NULL,
                p_report_id                      VARCHAR2,
                p_attribute_set                  VARCHAR2,
                p_output_format                  VARCHAR2
);

-- -------------------------------------------------------------
-- 		PROCEDURE PRCOESS PERIOD INFO
-- -------------------------------------------------------------
-- Process_Period_Info procedure is called from the Main procedure.
-- This procedure loads global variables 'g_period_num_low'
-- and 'g_period_num_high' with the derived period num range.
-- -------------------------------------------------------------

PROCEDURE process_period_info;

-- -------------------------------------------------------------
-- 		PROCEDURE GET QUALIFIER SEGMENTS
-- -------------------------------------------------------------
-- Get_QualIFier_Segments procedure is called from the Main
-- procedure.
-- This procedure gets the accounting and the balancing segments.
-- -------------------------------------------------------------
PROCEDURE get_qualifier_segments;

-- -------------------------------------------------------------------
--	         PROCEDURE JOURNAL_PROCESS
-- -------------------------------------------------------------------
-- Journal_Process procedure is called from the Main procedure.
-- Its primary purpose is to derive values to populate
-- 'FV_FACTS_TRX_TEMP' table from the rows derived from INVOICES,
-- PAYMENTS etc. It uses Dynamic SQL to dynamically set
-- the select statement for the cursor.
-- It uses the argument 'p_jrnl_type' to find whether the journal
-- type is Invoice or payment, etc. The valid journal type values
-- INV-Invoice, PMT-Payment, REC-Receivable, ORD-Purchase Order
-- -------------------------------------------------------------------

PROCEDURE journal_process;


-- -------------------------------------------------------------------
--                   PROCEDURE GET_DOC_USER
-- -------------------------------------------------------------------
-- Called from following procedures:
-- Journal_Process
-- Purpose:
-- Determine the user who created the journal line being processed
-- Also format the creation_date
-- -------------------------------------------------------------------

PROCEDURE get_doc_user (p_created_by                     NUMBER,
       		        p_entry_user          OUT NOCOPY VARCHAR2);

-- --------------------------------------------------------------------
--          PROCEDURE GET_FUND_GROUP_INFO
-- --------------------------------------------------------------------
-- Its primary purpose get the fund Group, Dept Id, bureau Id and
-- balancing segment from the fv_fund_parameters table for the
-- passed Code Combination Id.
-- --------------------------------------------------------------------

PROCEDURE get_fund_group_info (p_ccid      Gl_Balances.code_combination_id%TYPE,
			       p_fund_group   IN OUT NOCOPY VARCHAR2,
		  	       p_dept_id      IN OUT NOCOPY VARCHAR2,
		  	       p_bureau_id    IN OUT NOCOPY VARCHAR2,
		  	       p_bal_segment  IN OUT NOCOPY VARCHAR2);


-- -------------------------------------------------------------------
--		 PROCEDURE GET_SGL_PARENT
-- -------------------------------------------------------------------
--    Gets the SGL Parent Account for the passed account number
-- ------------------------------------------------------------------

PROCEDURE get_sgl_parent(
                        Acct_num                       VARCHAR2,
                        sgl_acct_num       OUT NOCOPY  VARCHAR2 ) ;

-- -------------------------------------------------------------------
--                       PROCEDURE GET_USSGL_INFO
-- -------------------------------------------------------------------
--    Gets the information like enabled flag and reporting type
--    for the passed account number.
-- -------------------------------------------------------------------

PROCEDURE get_ussgl_info (p_ussgl_acct_num     IN            VARCHAR2,
		          p_enabled_flag       IN OUT NOCOPY VARCHAR2,
		          p_reporting_type     IN OUT NOCOPY VARCHAR2);


-- ------------------------------------------------------------------
--			PROCEDURE GET_PERIOD_YEAR
-- ------------------------------------------------------------------
-- Get_Period_Year procedure is called from the Main procedure.
-- This procedure gets the accounting calender name(period set name)
-- based on the set of books parameter that is passed and then gets
-- the period year based on period from and period to parameters.
-- It then gets the start date of the from period and end date of the
-- to period, which are used in the Journal_Process Procedure.
-- ------------------------------------------------------------------

PROCEDURE get_period_year (p_period_from VARCHAR2,
                           p_period_to   VARCHAR2);

-- -------------------------------------------------------------------
--		 PROCEDURE GET_COHORT_INFO
-- -------------------------------------------------------------------
--    Gets the cohort segment name based on the Financing Acct value
-- ------------------------------------------------------------------

PROCEDURE get_cohort_info ;

-- -------------------------------------------------------------------
--		 PROCEDURE PURGE_FACTS_TRANSACTIONS
-- -------------------------------------------------------------------
--    Purges all FACTS transactions from the FV_FACTS_TRX_TEMP table for
--    the passed Treasaury Symbol.
-- ------------------------------------------------------------------

PROCEDURE purge_facts_transactions ;

-- -------------------------------------------------------------------
--		 PROCEDURE LOAD_FACTS_ATTRIBUTES
-- -------------------------------------------------------------------
-- This procedure selects the attributes for the Account number
-- segment from FV_FACTS_ATTRIBUTES table and load them into global
-- variables for usage in the FACTS Main process. It also calculates
-- one time pull up values for the account number that does not
-- require drill down into GL transactions.
-- ------------------------------------------------------------------

PROCEDURE load_facts_attributes (acct_num      VARCHAR2,
		      	 	 fund_val      VARCHAR2);

-- -------------------------------------------------------------------
--		 PROCEDURE RESET_ATTRIBUTES
--  The Process sets all the values of the FACTS Attributes to NULL
-- -------------------------------------------------------------------
-- ------------------------------------------------------------------

PROCEDURE  reset_facts_attributes ;

END fv_facts_trx_register;

/
