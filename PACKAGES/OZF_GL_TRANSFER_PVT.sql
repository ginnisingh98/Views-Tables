--------------------------------------------------------
--  DDL for Package OZF_GL_TRANSFER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_GL_TRANSFER_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvgtrs.pls 120.0.12010000.2 2010/03/09 11:12:19 kpatro ship $ */

---------------------------------------------------------------------
-- FUNCTION
--    OZF_MC_CHECK
--
-- PURPOSE
-- Verifies if the given set of book has any reporting sets of books associated.
--
---------------------------------------------------------------------

--FUNCTION ozf_mc_check ( p_psob_id NUMBER ) RETURN VARCHAR2;


---------------------------------------------------------------------
-- PROCEDURE
--    OZF_GL_TRANSFER
--
-- PURPOSE
-- Trnasfer accrual liability and claims accounting records to GL
--
-- HISTORY
-- 09-Mar-2010  KPATRO   UPDATED  ER#9382547 ChRM-SLA Uptake
--                                GL Transfer Program is no longer used
--                                and we can post the Accrual and promotional
--                                claim accounting through SLA Create Accounting
--                                program.
---------------------------------------------------------------------

/*PROCEDURE  OZF_GL_TRANSFER (
                            p_errbuf                      OUT NOCOPY  VARCHAR2
                           ,p_retcode                     OUT NOCOPY  NUMBER

                           ,p_selection_type                   NUMBER
                           ,p_set_of_books_id                  NUMBER
                           ,p_include_reporting_sob            VARCHAR2
                           ,p_batch_name                       VARCHAR2
                           ,p_start_date                       VARCHAR2
                           ,p_end_date                         VARCHAR2
                           ,p_accounting_method                VARCHAR2
                           ,p_document_class                   VARCHAR2 DEFAULT NULL
                           ,p_journal_category                 VARCHAR2
                           ,p_validate_account                 VARCHAR2
                           ,p_gl_transfer_mode                 VARCHAR2
                           ,p_submit_journal_import            VARCHAR2
                           ,p_summary_journal_entry            VARCHAR2
                           ,p_process_days                     NUMBER
                           ,p_debug_flag                       VARCHAR2
                           ,p_trace_flag                       VARCHAR2
                           );

*/
---------------------------------------------------------------------
-- PROCEDURE
--    CreateAccounting
--
-- PURPOSE
-- It will trigger the SLA Create Accounting Program
--
-- NOTES
--
-- HISTORY
-- 09-Mar-2010       KPATRO  Created   ER#9382547 ChRM-SLA Uptake
---------------------------------------------------------------------

PROCEDURE CreateAccounting(
                            errbuf                      OUT NOCOPY VARCHAR2,
			    retcode                     OUT NOCOPY NUMBER,

			    p_org_id                       IN NUMBER,
			    p_source_application_id        IN NUMBER,
			    p_application_id               IN NUMBER,
			    p_dummy                        IN VARCHAR2,
			    p_ledger_id                    IN NUMBER,
			    P_PROCESS_CATEGORY_CODE        IN VARCHAR2,
			    P_END_DATE                     IN VARCHAR2,
			    P_CREATE_ACCOUNTING_FLAG       IN VARCHAR2,
			    P_DUMMY_PARAM_1                IN VARCHAR2,
			    P_ACCOUNTING_MODE              IN VARCHAR2,
			    P_DUMMY_PARAM_2                IN VARCHAR2,
			    P_ERRORS_ONLY_FLAG             IN VARCHAR2,
			    P_REPORT_STYLE                 IN VARCHAR2,
			    P_TRANSFER_TO_GL_FLAG          IN VARCHAR2,
			    P_DUMMY_PARAM_3                IN VARCHAR2,
			    P_POST_IN_GL_FLAG              IN VARCHAR2,
			    P_GL_BATCH_NAME                IN VARCHAR2,
			    P_MIN_PRECISION                IN NUMBER,
			    P_INCLUDE_ZERO_AMOUNT_LINES    IN VARCHAR2,
			    P_REQUEST_ID                   IN NUMBER,
			    P_ENTITY_ID                    IN NUMBER,
			    P_SOURCE_APPLICATION_NAME      IN VARCHAR2,
			    P_APPLICATION_NAME             IN VARCHAR2,
			    P_LEDGER_NAME                  IN VARCHAR2,
			    P_PROCESS_CATEGORY_NAME        IN VARCHAR2,
			    P_CREATE_ACCOUNTING            IN VARCHAR2,
			    P_ACCOUNTING_MODE_NAME         IN VARCHAR2,
			    P_ERRORS_ONLY                  IN VARCHAR2,
			    P_ACCOUNTING_REPORT_LEVEL      IN VARCHAR2,
			    P_TRANSFER_TO_GL               IN VARCHAR2,
			    P_POST_IN_GL                   IN VARCHAR2,
			    P_INCLUDE_ZERO_AMT_LINES       IN VARCHAR2,
			    P_VALUATION_METHOD_CODE        IN VARCHAR2,
			    P_SECURITY_INT_1               IN NUMBER,
			    P_SECURITY_INT_2               IN NUMBER,
			    P_SECURITY_INT_3               IN NUMBER,
			    P_SECURITY_CHAR_1              IN VARCHAR2,
			    P_SECURITY_CHAR_2              IN VARCHAR2,
			    P_SECURITY_CHAR_3              IN VARCHAR2,
			    P_CONC_REQUEST_ID              IN NUMBER,
			    P_INCLUDE_USER_TRX_ID_FLAG     IN VARCHAR2,
			    P_INCLUDE_USER_TRX_IDENTIFIERS IN VARCHAR2,
			    P_DebugFlag                    IN VARCHAR2,
			    P_USER_ID                      IN NUMBER
			  );

END OZF_GL_TRANSFER_PVT;

/
