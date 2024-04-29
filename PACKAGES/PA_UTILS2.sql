--------------------------------------------------------
--  DDL for Package PA_UTILS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_UTILS2" AUTHID CURRENT_USER AS
/* $Header: PAXGUT2S.pls 120.3.12010000.2 2009/04/03 08:25:24 dlella ship $*/

/* For Archive purge MRC, these are global variable */

ARPUR_Commit_Size      NUMBER := 0;
ARPUR_MRC_Commit_Size  NUMBER := 0;
MRC_ROW_COUNT          NUMBER := 0;


/* CBGA
 * The following variable TempTab is defined - to be used as a default value
 * for the table parameter expnd_id.
 */
    TempIDTab    PA_PLSQL_DATATYPES.IDTabTyp ;
    TempRowIDTab PA_PLSQL_DATATYPES.Char30TabTyp ;
/**CBGA**/

    /**Global variables related to pa_date and recvr_pa_date caching **/
    /*
     * EPP.
     * Modified variable names.
     */
    /*
     * Provider.
     */
    g_prvdr_org_id                  pa_cost_distribution_lines_all.org_id%TYPE;
    g_p_earliest_pa_start_date      pa_cost_distribution_lines_all.pa_date%TYPE;
    g_p_earliest_pa_end_date        pa_cost_distribution_lines_all.pa_date%TYPE;
    g_p_earliest_pa_period_name     pa_cost_distribution_lines_all.pa_period_name%TYPE;

    g_prvdr_pa_start_date           pa_cost_distribution_lines_all.pa_date%TYPE;
    g_prvdr_pa_end_date             pa_cost_distribution_lines_all.pa_date%TYPE;
    g_prvdr_pa_date                 pa_cost_distribution_lines_all.pa_date%TYPE;
    g_prvdr_pa_period_name          pa_cost_distribution_lines_all.pa_period_name%TYPE;

    /*
     * Receiver.
     */
    g_recvr_org_id                 pa_cost_distribution_lines_all.org_id%TYPE;
    g_r_earliest_pa_start_date     pa_cost_distribution_lines_all.pa_date%TYPE;
    g_r_earliest_pa_end_date       pa_cost_distribution_lines_all.pa_date%TYPE;
    g_r_earliest_pa_period_name    pa_cost_distribution_lines_all.pa_period_name%TYPE;

    g_recvr_pa_start_date          pa_cost_distribution_lines_all.pa_date%TYPE;
    g_recvr_pa_end_date            pa_cost_distribution_lines_all.pa_date%TYPE;
    g_recvr_pa_date                pa_cost_distribution_lines_all.pa_date%TYPE;
    g_recvr_pa_period_name         pa_cost_distribution_lines_all.recvr_pa_period_name%TYPE;

    G_Business_Group_Id   NUMBER;
    G_Return_Status       VARCHAR2(30);
    G_Application_Id      NUMBER; /*Added for bug 7638790 */

    /*
     * Provider.
     */
    g_p_earliest_gl_start_date    pa_cost_distribution_lines_all.gl_date%TYPE;
    g_p_earliest_gl_end_date      pa_cost_distribution_lines_all.gl_date%TYPE;
    g_p_earliest_gl_period_name   pa_cost_distribution_lines_all.gl_period_name%TYPE;

    g_prvdr_set_of_books_id       pa_implementations_all.set_of_books_id%TYPE;
    g_prvdr_gl_start_date         pa_cost_distribution_lines_all.gl_date%TYPE;
    g_prvdr_gl_end_date           pa_cost_distribution_lines_all.gl_date%TYPE;
    g_prvdr_gl_period_name        pa_cost_distribution_lines_all.gl_period_name%TYPE ;
    g_prvdr_gl_date               pa_cost_distribution_lines_all.gl_date%TYPE;

    /*
     * Receiver.
     */
    g_r_earliest_gl_start_date    pa_cost_distribution_lines_all.gl_date%TYPE;
    g_r_earliest_gl_end_date      pa_cost_distribution_lines_all.gl_date%TYPE;
    g_r_earliest_gl_period_name   pa_cost_distribution_lines_all.gl_period_name%TYPE;

    g_recvr_set_of_books_id       pa_implementations_all.set_of_books_id%TYPE;
    g_recvr_gl_start_date         pa_cost_distribution_lines_all.gl_date%TYPE;
    g_recvr_gl_end_date           pa_cost_distribution_lines_all.gl_date%TYPE;
    g_recvr_gl_period_name        pa_cost_distribution_lines_all.recvr_gl_period_name%TYPE ;
    g_recvr_gl_date               pa_cost_distribution_lines_all.gl_date%TYPE;

    /*
     * EPP.
     */
    g_prev_expenditure_id          pa_expenditure_items_all.expenditure_id%TYPE;
    g_prev_prvdr_gl_date           pa_cost_distribution_lines_all.gl_date%TYPE;
    g_prev_prvdr_gl_period_name    pa_cost_distribution_lines_all.gl_period_name%TYPE;
    g_prev_recvr_gl_period_name    pa_cost_distribution_lines_all.recvr_gl_period_name%TYPE;
    g_prev_recvr_gl_date           pa_cost_distribution_lines_all.recvr_gl_date%TYPE;

    /*
     * These global variables are used by function get_gl_period_name.
     */
    g_org_id pa_cost_distribution_lines_all.org_id%TYPE ;
    g_gl_period_start_date pa_cost_distribution_lines_all.gl_date%TYPE ;
    g_gl_period_end_date pa_cost_distribution_lines_all.gl_date%TYPE ;
    g_gl_period_name pa_cost_distribution_lines_all.gl_period_name%TYPE ;

  /* Period End Accruals */
   g_p_org_accr_start_date          pa_expenditure_items_all.prvdr_accrual_date%TYPE := NULL;
   g_p_org_accr_end_date            pa_expenditure_items_all.prvdr_accrual_date%TYPE := NULL;
   g_p_rev_accr_nxt_st_dt           pa_expenditure_items_all.prvdr_accrual_date%TYPE := NULL;
   g_p_rev_accr_nxt_end_dt          pa_expenditure_items_all.prvdr_accrual_date%TYPE := NULL;
   g_p_rev_gl_period_name           pa_cost_distribution_lines_all.gl_period_name%TYPE;

   g_r_org_accr_start_date          pa_expenditure_items_all.prvdr_accrual_date%TYPE := NULL;
   g_r_org_accr_end_date            pa_expenditure_items_all.prvdr_accrual_date%TYPE := NULL;
   g_r_rev_accr_nxt_st_dt           pa_expenditure_items_all.prvdr_accrual_date%TYPE := NULL;
   g_r_rev_accr_nxt_end_dt          pa_expenditure_items_all.prvdr_accrual_date%TYPE := NULL;
   g_r_rev_gl_period_name           pa_cost_distribution_lines_all.gl_period_name%TYPE;

   g_p_accr_gl_per_st_dt            pa_cost_distribution_lines_all.gl_date%TYPE := NULL;
   g_p_accr_gl_per_end_dt           pa_cost_distribution_lines_all.gl_date%TYPE := NULL;
   g_p_accr_gl_per_name             pa_cost_distribution_lines_all.pa_period_name%TYPE := NULL;

   g_r_accr_gl_per_st_dt            pa_cost_distribution_lines_all.gl_date%TYPE := NULL;
   g_r_accr_gl_per_end_dt           pa_cost_distribution_lines_all.gl_date%TYPE := NULL;
   g_r_accr_gl_per_name             pa_cost_distribution_lines_all.pa_period_name%TYPE := NULL;

   g_prv_accr_prvdr_pa_start_date   pa_cost_distribution_lines_all.pa_date%TYPE := NULL;
   g_prv_accr_prvdr_pa_date         pa_cost_distribution_lines_all.pa_date%TYPE := NULL;
   g_prv_accr_prvdr_pa_end_date     pa_cost_distribution_lines_all.pa_date%TYPE := NULL;
   g_prv_accr_recvr_pa_start_date   pa_cost_distribution_lines_all.pa_date%TYPE := NULL;
   g_prv_accr_recvr_pa_end_date     pa_cost_distribution_lines_all.pa_date%TYPE := NULL;
   g_p_accr_rev_pa_date             pa_cost_distribution_lines_all.pa_date%TYPE := NULL;
   g_r_accr_rev_pa_date             pa_cost_distribution_lines_all.pa_date%TYPE := NULL;
   g_prv_accr_prvdr_pa_period       pa_cost_distribution_lines_all.pa_period_name%TYPE := NULL;
   g_prv_accr_recvr_pa_period       pa_cost_distribution_lines_all.pa_period_name%TYPE := NULL;
   g_prv_accr_prvdr_gl_period       pa_cost_distribution_lines_all.gl_period_name%TYPE := NULL;
   g_prv_accr_recvr_gl_period       pa_cost_distribution_lines_all.gl_period_name%TYPE := NULL;

   g_p_accr_rev_pa_period           pa_cost_distribution_lines_all.pa_period_name%TYPE := NULL;
   g_r_accr_rev_pa_period           pa_cost_distribution_lines_all.pa_period_name%TYPE := NULL;
   g_p_gl_period                    pa_cost_distribution_lines_all.pa_period_name%TYPE := NULL;
   g_r_gl_period                    pa_cost_distribution_lines_all.pa_period_name%TYPE := NULL;
   g_prof_new_gldate_derivation     VARCHAR2(1) := NULL;   --EPP global variable


   /* added the following two global variables for BUG# 3384892 */

    g_profile_cache_first_time      varchar2(2) :='Y';
    g_profile_value                 varchar2(2);


 /* Bug 5374282  */
   g_gl_dt_period_str_dt           pa_draft_revenues_all.gl_date%TYPE        := NULL;
   g_gl_dt_period_end_dt           pa_draft_revenues_all.gl_date%TYPE        := NULL;
   g_gl_dt_period_name             pa_draft_revenues_all.gl_period_name%TYPE := NULL;

PROCEDURE get_gl_dt_period  (p_reference_date IN  DATE,
                             x_gl_period_name OUT NOCOPY pa_draft_revenues_all.gl_period_name%TYPE,
                             x_gl_dt          OUT NOCOPY pa_draft_revenues_all.gl_date%TYPE,
                             x_return_status  OUT NOCOPY NUMBER,
                             x_error_code     OUT NOCOPY VARCHAR2,
                             x_error_stage    OUT NOCOPY VARCHAR2
                            );
 /* 5374282  ends */


---------------------------------------------------------------
-- This function returns 'Y'  if a given org is a Exp organization ,
-- otherwise , it returns 'N'
---------------------------------------------------------------
FUNCTION get_period_name return pa_cost_distribution_lines_all.pa_period_name%TYPE;/*2835063*/

/* added the following two functions for bug 3384892  for caching a the profile value.*/

FUNCTION pa_date_profile(exp_item_date IN DATE, accounting_date IN DATE, org_id IN NUMBER)
RETURN DATE;

FUNCTION pa_period_name_profile RETURN VARCHAR2;

FUNCTION CheckExpOrg (x_org_id IN NUMBER,
		      x_txn_date in date default trunc(sysdate)) RETURN VARCHAR2 ;
--pragma RESTRICT_REFERENCES ( CheckExpOrg, WNDS, WNPS);

FUNCTION CheckSysLinkFuncActive(x_exp_type IN VARCHAR2,
				x_ei_date IN DATE,
				x_sys_link_func IN VARCHAR2) RETURN BOOLEAN ;
-- pa_lookups purity level has been changed to WNDS only, so modifying
-- functions that use pa_lookups to purity level WNDS, however in 8i
-- there is no need to explicitly define purity level, so removing the
-- purity level all togeather.
-- PRAGMA RESTRICT_REFERENCES (CheckSysLinkFuncActive, WNDS, WNPS);

FUNCTION CheckAdjFlag (x_exp_item_id In Number) RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (CheckAdjFlag, WNDS, WNPS) ;


---------------------------------------------------------------
--=================================================================================
-- These are the new procedures and functions added for Archive / Purge
--=================================================================================

  FUNCTION  IsProjectClosed ( X_project_system_status_code  IN VARCHAR2 ) RETURN VARCHAR2 ;
  PRAGMA RESTRICT_REFERENCES ( IsProjectClosed, WNDS, WNPS ) ;

  FUNCTION  IsProjectInPurgeStatus ( X_project_system_status_code  IN VARCHAR2 ) RETURN VARCHAR2 ;
  PRAGMA RESTRICT_REFERENCES ( IsProjectInPurgeStatus, WNDS, WNPS ) ;

  FUNCTION  IsDestPurged ( X_exp_id  IN NUMBER ) RETURN VARCHAR2 ;
  PRAGMA RESTRICT_REFERENCES ( IsDestPurged, WNDS, WNPS ) ;

  FUNCTION  IsSourcePurged ( X_exp_id  IN NUMBER ) RETURN VARCHAR2 ;
  PRAGMA RESTRICT_REFERENCES ( IsSourcePurged, WNDS, WNPS ) ;

  PROCEDURE IsActivePrjTxnsPurged(p_project_id          IN NUMBER,
                                  x_message_code    IN OUT NOCOPY VARCHAR2,
                                  x_token           IN OUT NOCOPY DATE) ;

  function IsProjectTxnsPurged(p_project_id  IN NUMBER) RETURN BOOLEAN ;

  function IsProjectCapitalPurged(p_project_id  IN NUMBER) RETURN BOOLEAN ;

  function IsProjectBudgetsPurged(p_project_id  IN NUMBER) RETURN BOOLEAN ;

  function IsProjectSummaryPurged(p_project_id  IN NUMBER) RETURN BOOLEAN ;

  FUNCTION  GetProductRelease  RETURN VARCHAR2 ;
  PRAGMA RESTRICT_REFERENCES ( GetProductRelease, WNDS, WNPS ) ;

---------------------------------------------------------------
  function GetLaborCostMultiplier (x_task_id In Number) RETURN VARCHAR2;
--  PRAGMA RESTRICT_REFERENCES (GetLaborCostMultiplier, WNDS, WNPS) ;

--=================================================================================

FUNCTION  GetPrjOrgId(p_project_id  NUMBER,
                      p_task_id     NUMBER ) RETURN NUMBER ;
--PRAGMA RESTRICT_REFERENCES (GetPrjOrgId, WNDS, WNPS) ;
---------------------------------------------------------------

--function  : get_pa_date
--	Derive PA Date from GL date and ei date .
-- This function accepts the expenditure item date ,GL date and org id
-- and derives the PA date based on this. The function has been modified
-- to not use the gl_Date (though it is still accepted as a parameter
-- just in case the logic changes in the future to use the gl_Date).
-- This is mainly used for AP invoices and transactions imported from
-- other systems where the GL date is known in advance and the PA date
-- has to be determined.
-- This function is also modified to use caching.
------------------------------------------------------------------------
FUNCTION get_pa_date( p_ei_date  IN date, p_gl_date IN date, p_org_id IN number) return date ;
PRAGMA RESTRICT_REFERENCES ( get_pa_date, WNDS ) ;            /**CBGA - removed WNPS**/

----------------------------------------------------------------------

--function  : get_recvr_pa_date
-- Introduced for CBGA changes.
--	Derive PA Date for recvr Org.
-- This function accepts the expenditure item date,the GL date and org_id and
-- derives the PA date based on this. The function has been modified
-- to not use the gl_Date (though it is still accepted as a parameter
-- just in case the logic changes in the future to use the gl_Date).
-- This is mainly used for AP invoices and transactions imported from
-- other systems where the GL date is known in advance and the PA date
-- has to be determined.
------------------------------------------------------------------------
FUNCTION get_recvr_pa_date(p_ei_date  IN date, p_gl_date IN date, p_org_id IN number) return date;
PRAGMA RESTRICT_REFERENCES ( get_recvr_pa_date, WNDS ) ;


---------------------------------------------------------------
-- Procedure : refresh_pa_cache
--    This procedure is used for DB access and is called by get_pa_date and get_recvr_pa_date.
---------------------------------------------------------------

PROCEDURE refresh_pa_cache (   p_org_id IN number ,
                            p_ei_date IN date ,
                            p_caller_flag IN varchar2
                        );
PRAGMA RESTRICT_REFERENCES ( refresh_pa_cache, WNDS ) ;

---------------------------------------------------------------
-- Procedure : refresh_gl_cache.
--    This procedure is called by both get_prvdr_gl_date and get_recvr_gl_date.
---------------------------------------------------------------

/*
 * EPP.
 * Modified the name of the first parameter.
 */
PROCEDURE refresh_gl_cache ( p_reference_date IN DATE,
                         p_application_id     IN NUMBER,
                         p_set_of_books_id    IN NUMBER,
                         p_caller_flag        IN VARCHAR2
                        );
---------------------------------------------------------------

---------------------------------------------------------------
-- Procedure : populate_gl_dates
--    This procedure is called by interface programs.
---------------------------------------------------------------

PROCEDURE populate_gl_dates( p_local_set_size           IN NUMBER,
                             p_application_id            IN PA_PLSQL_DATATYPES.IDTabTyp,
                             p_request_id                IN PA_PLSQL_DATATYPES.IDTabTyp,
                             p_cdl_rowid                 IN PA_PLSQL_DATATYPES.Char30TabTyp DEFAULT TempRowIDTab,
                             p_prvdr_sob_id              IN PA_PLSQL_DATATYPES.IDTabTyp,
                             p_recvr_sob_id              IN PA_PLSQL_DATATYPES.IDTabTyp,
                             p_expnd_id                  IN PA_PLSQL_DATATYPES.IDTabTyp DEFAULT TempIDTab,
                             p_sys_linkage_type          IN VARCHAR2 DEFAULT NULL
                           );

---------------------------------------------------------------
-- Function : get_prvdr_gl_date
--    This function is called by populate_gl_dates.
---------------------------------------------------------------
/*
 * EPP.
 * changed the name of the first parameter.
 */
FUNCTION get_prvdr_gl_date( p_reference_date   IN DATE,
                            p_application_id  IN NUMBER ,
                            p_set_of_books_id IN gl_sets_of_books.set_of_books_id%TYPE
                          ) return date ;


---------------------------------------------------------------
-- Function : get_recvr_gl_date
--    This function is called populate_gl_dates.
---------------------------------------------------------------
/*
 * EPP.
 * changed the name of the first parameter.
 */
FUNCTION get_recvr_gl_date( p_reference_date   IN DATE,
                            p_application_id  IN NUMBER ,
                            p_set_of_books_id IN gl_sets_of_books.set_of_books_id%TYPE
                          ) return DATE ;
---------------------------------------------------------------

-- Fixed Bug 1534973, 1581184
-- Added P_EiDate parameter and performing date check in the query
-- If adding new parameters please add before P_EiDate parameter
-- cwk changes: added parameter P_Person_Type
  PROCEDURE  GetEmpId ( P_Business_Group_Id     IN NUMBER
                      , P_Employee_Number       IN VARCHAR2
                      , X_Employee_Id          OUT NOCOPY VARCHAR2
		      , P_Person_Type IN VARCHAR2 default null
                      , P_EiDate                IN DATE default SYSDATE);

  FUNCTION  GetBusinessGroupId ( P_Business_Group_Name  IN VARCHAR2 ) RETURN NUMBER;
--  pragma  RESTRICT_REFERENCES ( GetBusinessGroupId, WNDS, WNPS );

---------------------------------------------------------------
-- Function : GetGlPeriodName
--    This function is called by Transaction Import to get the gl period name.
---------------------------------------------------------------
PROCEDURE GetGlPeriodNameDate( p_pa_date   IN DATE,
                              p_application_id  IN NUMBER ,
                              p_set_of_books_id IN gl_sets_of_books.set_of_books_id%TYPE,
                              x_gl_date     OUT NOCOPY DATE,
                              x_period_name  OUT NOCOPY VARCHAR2
                            ) ;

---------------------------------------------------------------
-- Procedure : get_period_information
---------------------------------------------------------------
PROCEDURE get_period_information ( p_expenditure_item_date IN pa_expenditure_items_all.expenditure_item_date%TYPE
                                  ,p_expenditure_id IN pa_expenditure_items_all.expenditure_id%TYPE := NULL
                                  ,p_system_linkage_function IN pa_expenditure_items_all.system_linkage_function%TYPE := NULL
                                  ,p_line_type IN pa_cost_distribution_lines_all.line_type%TYPE := NULL
                                  ,p_prvdr_raw_pa_date IN pa_cost_distribution_lines_all.pa_date%TYPE := NULL
                                  ,p_recvr_raw_pa_date IN pa_cost_distribution_lines_all.pa_date%TYPE := NULL
                                  ,p_prvdr_raw_gl_date IN pa_cost_distribution_lines_all.gl_date%TYPE := NULL
                                  ,p_recvr_raw_gl_date IN pa_cost_distribution_lines_all.gl_date%TYPE := NULL
                                  ,p_prvdr_org_id IN pa_expenditure_items_all.org_id%TYPE
                                  ,p_recvr_org_id IN pa_expenditure_items_all.org_id%TYPE := NULL
                                  ,p_prvdr_sob_id IN pa_implementations_all.set_of_books_id%TYPE
                                  ,p_recvr_sob_id IN pa_implementations_all.set_of_books_id%TYPE := NULL
                                  ,p_calling_module IN VARCHAR2 := NULL
                                  ,p_ou_context IN VARCHAR2 DEFAULT 'N'
                                  ,x_prvdr_pa_date OUT NOCOPY pa_cost_distribution_lines_all.pa_date%TYPE
                                  ,x_prvdr_pa_period_name OUT NOCOPY pa_cost_distribution_lines_all.pa_period_name%TYPE
                                  ,x_prvdr_gl_date OUT NOCOPY pa_cost_distribution_lines_all.gl_date%TYPE
                                  ,x_prvdr_gl_period_name OUT NOCOPY pa_cost_distribution_lines_all.gl_period_name%TYPE
                                  ,x_recvr_pa_date OUT NOCOPY pa_cost_distribution_lines_all.recvr_pa_date%TYPE
                                  ,x_recvr_pa_period_name OUT NOCOPY pa_cost_distribution_lines_all.recvr_pa_period_name%TYPE
                                  ,x_recvr_gl_date OUT NOCOPY pa_cost_distribution_lines_all.recvr_gl_date%TYPE
                                  ,x_recvr_gl_period_name OUT NOCOPY pa_cost_distribution_lines_all.recvr_gl_period_name%TYPE
                                  ,x_return_status  OUT NOCOPY NUMBER
                                  ,x_error_code OUT NOCOPY VARCHAR2
                                  ,x_error_stage OUT NOCOPY NUMBER
                                 );
---------------------------------------------------------------
PROCEDURE get_OU_period_information ( p_reference_date IN pa_expenditure_items_all.expenditure_item_date%TYPE
                                     ,p_calling_module IN VARCHAR2 := NULL
                                     ,x_pa_date OUT NOCOPY pa_cost_distribution_lines_all.pa_date%TYPE
                                     ,x_pa_period_name OUT NOCOPY pa_cost_distribution_lines_all.pa_period_name%TYPE
                                     ,x_gl_date OUT NOCOPY pa_cost_distribution_lines_all.gl_date%TYPE
                                     ,x_gl_period_name OUT NOCOPY pa_cost_distribution_lines_all.gl_period_name%TYPE
                                     ,x_return_status  OUT NOCOPY NUMBER
                                     ,x_error_code OUT NOCOPY VARCHAR2
                                     ,x_error_stage OUT NOCOPY NUMBER
                                    );

---------------------------------------------------------------
  FUNCTION  get_gl_period_name ( p_gl_date  IN pa_cost_distribution_lines_all.gl_date%TYPE
                                ,p_org_id   IN pa_cost_distribution_lines_all.org_id%TYPE
                               )
  RETURN pa_cost_distribution_lines_all.gl_period_name%TYPE;
---------------------------------------------------------------
 FUNCTION get_set_of_books_id (p_org_id IN pa_implementations_all.org_id%TYPE) RETURN NUMBER;
---------------------------------------------------------------
 /*
  * This function returns the end_date of the PA period in which the input date falls.
  */
 FUNCTION get_pa_period_end_date_OU ( p_date IN pa_periods_all.end_date%TYPE ) RETURN pa_periods_all.end_date%TYPE;
------------------------------------------------------------------------------------------------------------------
-- Procedure : get_accrual_gl_dt_period
------------------------------------------------------------------------------------------------------------------
PROCEDURE get_accrual_gl_dt_period(p_calling_module  IN  VARCHAR2,
                                p_reference_date      IN  DATE,
                                p_application_id      IN  NUMBER ,
                                p_set_of_books_id     IN  gl_sets_of_books.set_of_books_id%TYPE,
                                p_prvdr_recvr_flg     IN  VARCHAR2,
                                p_epp_flag            IN  VARCHAR2,
                                x_gl_accr_period_name OUT NOCOPY VARCHAR2,
                                x_gl_accr_dt          OUT NOCOPY DATE,
                                x_return_status       OUT NOCOPY VARCHAR2,
                                x_error_code          OUT NOCOPY VARCHAR2,
                                x_error_stage         OUT NOCOPY VARCHAR2
                              );
------------------------------------------------------------------------------------------------------------------
-- Procedure : get_accrual_period_information
------------------------------------------------------------------------------------------------------------------
PROCEDURE get_accrual_period_information(p_expenditure_item_date IN pa_expenditure_items_all.expenditure_item_date%TYPE
                                  ,x_prvdr_accrual_date IN OUT NOCOPY pa_cost_distribution_lines_all.gl_date%TYPE
                                  ,x_recvr_accrual_date IN OUT NOCOPY pa_cost_distribution_lines_all.gl_date%TYPE
                                  ,p_prvdr_org_id IN pa_expenditure_items_all.org_id%TYPE
                                  ,p_recvr_org_id IN pa_expenditure_items_all.org_id%TYPE
                                  ,p_prvdr_sob_id IN pa_implementations_all.set_of_books_id%TYPE
                                  ,p_recvr_sob_id IN pa_implementations_all.set_of_books_id%TYPE
                                  ,p_calling_module IN VARCHAR2
                                  ,x_prvdr_pa_date OUT NOCOPY pa_cost_distribution_lines_all.pa_date%TYPE
                                  ,x_prvdr_pa_period_name OUT NOCOPY pa_cost_distribution_lines_all.pa_period_name%TYPE
                                  ,x_prvdr_gl_date IN OUT NOCOPY pa_cost_distribution_lines_all.gl_date%TYPE
                                  ,x_prvdr_gl_period_name OUT NOCOPY pa_cost_distribution_lines_all.gl_period_name%TYPE
                                  ,x_recvr_pa_date OUT NOCOPY pa_cost_distribution_lines_all.recvr_pa_date%TYPE
                                  ,x_recvr_pa_period_name OUT NOCOPY pa_cost_distribution_lines_all.recvr_pa_period_name%TYPE
                                  ,x_recvr_gl_date OUT NOCOPY pa_cost_distribution_lines_all.recvr_gl_date%TYPE
                                  ,x_recvr_gl_period_name OUT NOCOPY pa_cost_distribution_lines_all.recvr_gl_period_name%TYPE
                                  ,p_adj_ei_id  IN  pa_expenditure_items_all.expenditure_item_id%type
                                  ,p_acct_flag  IN VARCHAR2
                                  ,x_return_status  OUT NOCOPY VARCHAR2
                                  ,x_error_code OUT NOCOPY VARCHAR2
                                  ,x_error_stage OUT NOCOPY VARCHAR2
                                 );
---------------------------------------------------------------------+
PROCEDURE get_accrual_pa_dt_period( p_gl_period      IN  VARCHAR2
                                   ,p_ei_date        IN  DATE
                                   ,p_org_id         IN  pa_expenditure_items_all.org_id%TYPE
                                   ,p_prvdr_recvr_flg IN  VARCHAR2
                                   ,p_epp_flag       IN  VARCHAR2
                                   ,p_org_rev_flg    IN  VARCHAR2
                                   ,x_pa_date        OUT NOCOPY DATE
                                   ,x_pa_period_name OUT NOCOPY VARCHAR2
                                   ,x_return_status  OUT NOCOPY VARCHAR2
                                   ,x_error_code     OUT NOCOPY VARCHAR2
                          );
---------------------------------------------------------------------+
FUNCTION get_rev_accrual_date( p_calling_module  IN  VARCHAR2,
                            p_reference_date     IN  DATE,
                            p_application_id     IN  NUMBER ,
                            p_set_of_books_id    IN  gl_sets_of_books.set_of_books_id%TYPE,
                            p_prvdr_recvr_flg    IN  VARCHAR2,
                            p_epp_flag           IN  VARCHAR2,
                            x_gl_period_name     OUT NOCOPY VARCHAR2,
                            x_return_status      OUT NOCOPY VARCHAR2,
                            x_error_code         OUT NOCOPY VARCHAR2,
                            x_error_stage        OUT NOCOPY VARCHAR2
                          )
RETURN DATE;
-----------------------------------------------------------------------
FUNCTION get_pa_period_name( p_txn_date IN pa_expenditure_items_all.expenditure_item_date%TYPE
                            ,p_org_id   IN pa_implementations_all.org_id%TYPE
                           )
RETURN pa_periods.period_name%TYPE;
-----------------------------------------------------------------------
--Start Bug 3069632
FUNCTION get_ts_allow_burden_flag( p_transaction_source IN pa_expenditure_items_all.transaction_source%TYPE)
RETURN pa_transaction_sources.allow_burden_flag%TYPE;
-----------------------------------------------------------------------
FUNCTION get_capital_cost_type_code( p_project_id IN pa_projects_all.project_id%TYPE)
RETURN pa_project_types_all.CAPITAL_COST_TYPE_CODE%TYPE;

G_CapCostTypProjID_Tab PA_PLSQL_DATATYPES.Char1TabTyp;
-----------------------------------------------------------------------
g_project_id             NUMBER;
g_project_type           pa_projects_all.project_type%type;
g_proj_org_id            pa_projects_all.org_id%type;
g_capital_cost_type_code pa_project_types_all.CAPITAL_COST_TYPE_CODE%TYPE;
g_ts_allow_burden_flag   pa_transaction_sources.allow_burden_flag%TYPE;
g_transaction_source     pa_expenditure_items_all.transaction_source%TYPE;
--End Bug 3069632

Function Get_Burden_Amt_Display_Method(P_Project_Id in Number) Return Varchar2;

G_BdMethodProjID_Tab PA_PLSQL_DATATYPES.Char1TabTyp;

/*S.N. Bug4746949 */
Function Proj_Type_Burden_Disp_Method(P_Project_Id in Number) Return Varchar2;
G_Bd_MethodProjID_Tab PA_PLSQL_DATATYPES.Char1TabTyp;
/*E.N. Bug4746949 */

   G_PREV_ORG_ID   NUMBER(15);
   G_PREV_TXN_DATE DATE;
   G_PREV_EXP_ORG  VARCHAR2(1);
   G_PREV_BUSGRP_ID NUMBER(15);
   G_PREV_EMP_NUM  VARCHAR2(30);
   G_PREV_EI_DATE  DATE;
   G_PREV_EMP_ID   NUMBER(15);
   G_PREV_TASK_ID  NUMBER(15);
   G_PREV_LCM_NAME  VARCHAR2(20);
   G_PREV_PROJ_ID  NUMBER(15);
   G_PREV_TASK_ID2 NUMBER(15);
   G_PREV_ORG_ID2  NUMBER(15);
   G_PREV_BUS_GRP_NAME VARCHAR2(60);
   G_PREV_BUS_GRP_ID NUMBER (15);
   G_PREV_PERSON_TYPE VARCHAR2(30);

FUNCTION IsEnhancedBurdeningEnabled RETURN VARCHAR2;

END PA_UTILS2;

/
