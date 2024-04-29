--------------------------------------------------------
--  DDL for Package PA_XLA_SWEEP_TXN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_XLA_SWEEP_TXN_PKG" AUTHID CURRENT_USER AS
--  $Header: PACCGLES.pls 120.1 2005/10/26 03:04:11 rshaik noship $


g_bulk_Size		Number := 500;
g_cdl_bulk_size		Number := 500;

g_currec                Number;
g_org_id                Number;

g_tran_type             pa_lookups.lookup_code%type;

g_new_period_name	Varchar2(100);
g_new_period_date	Date;
g_sob_id		pa_implementations_all.set_of_books_id%type;
g_app_id		Number := 101;

g_request_id		FND_CONCURRENT_REQUESTS.REQUEST_ID%TYPE;

g_event_tab		PA_PLSQL_DATATYPES.Num15TabTyp;
g_first_date		date;
g_last_date		date;

g_user_id               XLA_EVENTS.LAST_UPDATED_BY%type ;

g_expenditure_item_id			PA_PLSQL_DATATYPES.Num15TabTyp;
g_line_num				PA_PLSQL_DATATYPES.Num15TabTyp;
g_adjusted_expenditure_item_id		PA_PLSQL_DATATYPES.Num15TabTyp;
g_system_linkage_function		PA_PLSQL_DATATYPES.Char30TabTyp;
g_PERIOD_ACCRUAL_FLAG			PA_PLSQL_DATATYPES.Char1TabTyp;
g_cdl_rowid				PA_PLSQL_DATATYPES.Char30TabTyp;
g_gl_date_new_tab			PA_PLSQL_DATATYPES.DateTabTyp;
g_gl_period_new_tab			PA_PLSQL_DATATYPES.Char30TabTyp;

g_recvr_gl_date_new_tab			PA_PLSQL_DATATYPES.DateTabTyp;
g_recvr_gl_period_new_tab		PA_PLSQL_DATATYPES.Char30TabTyp;
g_recvr_sob_id				PA_PLSQL_DATATYPES.Num15TabTyp;
g_recvr_org_id				PA_PLSQL_DATATYPES.Num15TabTyp;
-- R12 Funds management uptake : Added below PLSQL variables
g_cdl_line_type                         PA_PLSQL_DATATYPES.Char1TabTyp;
g_liquidate_encum_flag                  PA_PLSQL_DATATYPES.Char1TabTyp;
g_buren_Sum_Dest_Run_Id                 PA_PLSQL_DATATYPES.Num15TabTyp;
g_document_header_Id                    PA_PLSQL_DATATYPES.Num15TabTyp;
g_document_distribution_id              PA_PLSQL_DATATYPES.Num15TabTyp;
g_expenditure_type                      PA_PLSQL_DATATYPES.Char30TabTyp;
g_cdl_acct_event_id                     PA_PLSQL_DATATYPES.Num15TabTyp;

Procedure SWEEP_TXNS  (P_ORG_ID    PA_IMPLEMENTATIONS_ALL.ORG_ID%TYPE,
                       P_GL_PERIOD GL_PERIOD_STATUSES.PERIOD_NAME%TYPE,
		       P_TRAN_TYPE VARCHAR2);

Procedure POPULATE_GL_DATE;


Procedure CHECK_MISC_TXNS;


END PA_XLA_SWEEP_TXN_PKG;

 

/
