--------------------------------------------------------
--  DDL for Package PA_PURGE_PROJECTS_GEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PURGE_PROJECTS_GEN_PKG" AUTHID CURRENT_USER as
/* $Header: PAXPRGNS.pls 120.1 2005/08/19 17:17:30 mwasowic noship $ */
 procedure gen_projects ( x_purge_batch_id                 in NUMBER,
                          x_active_closed_flag             in VARCHAR2,
                          x_closed_thru_date               in DATE,
                          x_organization_id                in NUMBER,
                          x_project_type                   in VARCHAR2,
                          x_project_status_code            in VARCHAR2,
                          x_purge_summary_flag             in VARCHAR2,
                          x_archive_summary_flag           in VARCHAR2,
                          x_purge_budgets_flag             in VARCHAR2,
                          x_archive_budgets_flag           in VARCHAR2,
                          x_purge_capital_flag             in VARCHAR2,
                          x_archive_capital_flag           in VARCHAR2,
                          x_purge_actuals_flag             in VARCHAR2,
                          x_archive_actuals_flag           in VARCHAR2,
                          x_admin_proj_flag                in VARCHAR2,
                          x_txn_to_date                    in DATE,
                          x_next_pp_project_status_code    in VARCHAR2,
                          x_next_p_project_status_code     in VARCHAR2,
                          x_user_id                        in NUMBER,
                          x_no_recs    			   in OUT NOCOPY NUMBER) ; --File.Sql.39 bug 4440895

 Procedure Get_Purge_Options(p_project_id                IN NUMBER,
                             p_active_closed_flag        IN VARCHAR2,
                             x_txn_to_date           IN OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                             x_purge_actuals_flag    IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_purge_budgets_flag    IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_purge_capital_flag    IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_purge_summary_flag    IN OUT NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895
END pa_purge_projects_gen_pkg ;
 

/
