--------------------------------------------------------
--  DDL for Package PA_MC_FUNDINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_MC_FUNDINGS_PKG" AUTHID CURRENT_USER as
/* $Header: PAMRCFPS.pls 120.1 2005/08/05 00:24:00 rgandhi noship $ */


 TYPE FundingLineRecord IS RECORD
             (
                 project_funding_id                       pa_project_fundings.project_funding_id%TYPE,
                 last_update_date                         pa_project_fundings.last_update_date%TYPE,
                 last_updated_by                          pa_project_fundings.last_updated_by%TYPE,
                 creation_date                            pa_project_fundings.creation_date%TYPE,
                 created_by                               pa_project_fundings.created_by%TYPE,
                 last_update_login                        pa_project_fundings.last_update_login%TYPE,
                 agreement_id                             pa_project_fundings.agreement_id%TYPE,
                 project_id                               pa_project_fundings.project_id%TYPE,
                 task_id                                  pa_project_fundings.task_id%TYPE,
                 budget_type_code                         pa_project_fundings.budget_type_code%TYPE,
                 allocated_amount                         pa_project_fundings.allocated_amount%TYPE,
                 date_allocated                           pa_project_fundings.date_allocated%TYPE,
                 attribute_category                       pa_project_fundings.attribute_category%TYPE,
                 attribute1                               pa_project_fundings.attribute1%TYPE,
                 attribute2                               pa_project_fundings.attribute2%TYPE,
                 attribute3                               pa_project_fundings.attribute3%TYPE,
                 attribute4                               pa_project_fundings.attribute4%TYPE,
                 attribute5                               pa_project_fundings.attribute5%TYPE,
                 attribute6                               pa_project_fundings.attribute6%TYPE,
                 attribute7                               pa_project_fundings.attribute7%TYPE,
                 attribute8                               pa_project_fundings.attribute8%TYPE,
                 attribute9                               pa_project_fundings.attribute9%TYPE,
                 attribute10                              pa_project_fundings.attribute10%TYPE,
                 pa_project_fundings_project_id           pa_project_fundings.pa_project_fundings_project_id%TYPE,
                 pm_funding_reference                     pa_project_fundings.pm_funding_reference%TYPE,
                 pm_product_code                          pa_project_fundings.pm_product_code%TYPE,
                 funding_currency_code                    pa_project_fundings.funding_currency_code%TYPE,
                 project_currency_code                    pa_project_fundings.project_currency_code%TYPE,
                 project_rate_type                        pa_project_fundings.project_rate_type%TYPE,
                 project_rate_date                        pa_project_fundings.project_rate_date%TYPE,
                 project_exchange_rate                    pa_project_fundings.project_exchange_rate%TYPE,
                 project_allocated_amount                 pa_project_fundings.project_allocated_amount%TYPE,
                 projfunc_currency_code                   pa_project_fundings.projfunc_currency_code%TYPE,
                 projfunc_rate_type                       pa_project_fundings.projfunc_rate_type%TYPE,
                 projfunc_rate_date                       pa_project_fundings.projfunc_rate_date%TYPE,
                 projfunc_exchange_rate                   pa_project_fundings.projfunc_exchange_rate%TYPE,
                 projfunc_allocated_amount                pa_project_fundings.projfunc_allocated_amount%TYPE,
                 invproc_currency_code                    pa_project_fundings.invproc_currency_code%TYPE,
                 invproc_rate_type                        pa_project_fundings.invproc_rate_type%TYPE,
                 invproc_rate_date                        pa_project_fundings.invproc_rate_date%TYPE,
                 invproc_exchange_rate                    pa_project_fundings.invproc_exchange_rate%TYPE,
                 invproc_allocated_amount                 pa_project_fundings.invproc_allocated_amount%TYPE,
                 revproc_currency_code                    pa_project_fundings.revproc_currency_code%TYPE,
                 revproc_rate_type                        pa_project_fundings.revproc_rate_type%TYPE,
                 revproc_rate_date                        pa_project_fundings.revproc_rate_date%TYPE,
                 revproc_exchange_rate                    pa_project_fundings.revproc_exchange_rate%TYPE,
                 revproc_allocated_amount                 pa_project_fundings.revproc_allocated_amount%TYPE,
                 funding_category                         pa_project_fundings.funding_category%TYPE,
                 pji_summarized_flag                      pa_project_fundings.pji_summarized_flag%TYPE
                ,Revaluation_through_date                 pa_project_fundings.Revaluation_through_date%TYPE,
                 Revaluation_rate_date                    pa_project_fundings.Revaluation_rate_date%TYPE,
                 Revaluation_projfunc_rate_type           pa_project_fundings.Revaluation_projfunc_rate_TYPE%TYPE,
                 Revaluation_invproc_rate_type            pa_project_fundings.Revaluation_invproc_rate_type%TYPE,
                 Revaluation_projfunc_rate                pa_project_fundings.Revaluation_projfunc_rate%TYPE,
                 Revaluation_invproc_rate                 pa_project_fundings.Revaluation_invproc_rate%TYPE,
                 Funding_Inv_Applied_Amount               pa_project_fundings.Funding_Inv_Applied_Amount%TYPE,
                 Funding_Inv_Due_Amount                   pa_project_fundings.Funding_Inv_Due_Amount%TYPE,
                 Funding_backlog_amount                   pa_project_fundings.Funding_backlog_amount%TYPE,
                 ProjFunc_Realized_Gains_Amt              pa_project_fundings.ProjFunc_Realized_Gains_Amt%TYPE,
                 ProjFunc_Realized_Losses_Amt             pa_project_fundings.ProjFunc_Realized_Losses_Amt%TYPE,
                 ProjFunc_Inv_Applied_Amount              pa_project_fundings.ProjFunc_Inv_Applied_Amount%TYPE,
                 ProjFunc_Inv_Due_Amount                  pa_project_fundings.ProjFunc_Inv_Due_Amount%TYPE,
                 ProjFunc_backlog_amount                  pa_project_fundings.ProjFunc_backlog_amount%TYPE,
                 Projfunc_Reval_Amount                    pa_project_fundings.Projfunc_Reval_Amount%TYPE,
                 Projfunc_Revalued_Amount                 pa_project_fundings.Projfunc_Revalued_Amount%TYPE,
                 Non_Updateable_Flag                      pa_project_fundings.Non_Updateable_Flag%TYPE,
                 InvProc_backlog_amount                   pa_project_fundings.InvProc_backlog_amount%TYPE,
                 Funding_Reval_Amount                     pa_project_fundings.Funding_Reval_Amount%TYPE,
                 Invproc_Reval_Amount                     pa_project_fundings.Invproc_Reval_Amount%TYPE,
                 Invproc_Revalued_Amount                  pa_project_fundings.Invproc_Revalued_Amount%TYPE,
                 Funding_revaluation_factor               pa_project_fundings.Funding_revaluation_factor%TYPE,
                 Request_Id                               pa_project_fundings.Request_Id%TYPE,
                 program_application_id                   pa_project_fundings.program_application_id%TYPE,
                 program_id                               pa_project_fundings.program_id%TYPE,
                 program_update_date                      pa_project_fundings.program_update_date%TYPE
                );

FUNCTION sum_mc_sob_cust_rdl_erdl(
                               p_project_id                   IN   NUMBER,
                               p_draft_revenue_num            IN   NUMBER,
                               p_draft_revenue_item_line_num  IN   NUMBER,
                               p_set_of_books_id              IN   NUMBER
 ) RETURN NUMBER;


--
-- Function             : sum_mc_sob_cust_rdl_erdl
-- Purpose              : This function returns the sum of RDL and ERDL for project, agreement, task
--                        and set of books id in reporting.
-- Parameters           :
--


FUNCTION check_mrc_install(
                           x_error_code OUT NOCOPY VARCHAR2 /*File.sql.39*/
) RETURN BOOLEAN;


--
-- Function             : check_mrc_install
-- Purpose              : This function will check that MRC is installed or not if installed it will
--                        return true otherwise false.
-- Parameters           :
--



PROCEDURE upgrade_fundings_mrc(
          p_upgrade_from_date    IN       DATE,
          x_return_status        OUT      NOCOPY VARCHAR2,/*File.sql.39*/
          x_msg_data             OUT      NOCOPY VARCHAR2,/*File.sql.39*/
          x_msg_count            OUT      NOCOPY NUMBER/*File.sql.39*/);

--
-- Procedure            : upgrade_fundings_mrc
-- Purpose              : This procedure will populate the mrc funding lines table and mrc summary table
--                        after converting all the records from primary. This procedure is being called
--                        from concurrent process.
-- Parameters           :
--

END PA_MC_FUNDINGS_PKG;


 

/
