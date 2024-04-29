--------------------------------------------------------
--  DDL for Package PA_FP_CI_IMPLEMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_CI_IMPLEMENT_PKG" AUTHID CURRENT_USER as
/* $Header: PAFPCOMS.pls 120.1 2005/08/19 16:25:45 mwasowic noship $ */
--3 new parameters are added as part of rounding changes.
---->p_impl_txn_rev_amt : contain the amount in agreement currency for which funding lines should be created
---->p_impl_pc_rev_amt  : contain the amount in project currency for which funding lines should be created
---->p_impl_pfc_rev_amt : contain the amount in project functional currency for which funding lines should be created
--The calling API should round these parameters before calling the APi
PROCEDURE create_ci_impact_fund_lines(
                         p_project_id             IN  NUMBER,
                         p_ci_id                  IN  NUMBER,
                         x_msg_data               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                         x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                         x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                         p_update_agr_amount_flag IN  VARCHAR2,
                         p_funding_category       IN  VARCHAR2 ,
                         p_partial_factor         IN  NUMBER,
                         p_impl_txn_rev_amt       IN  NUMBER,
                         p_impl_pc_rev_amt        IN  NUMBER,
                         p_impl_pfc_rev_amt       IN  NUMBER);


/* added for bug P3 2735741 */
PROCEDURE chk_plan_ver_for_merge
       (
            p_project_id                 IN NUMBER,
            p_target_fp_version_id_tbl   IN PA_PLSQL_DATATYPES.IdTabTyp,
               x_msg_data   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
               x_msg_count  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
               x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         );

END pa_fp_ci_implement_pkg;

 

/
