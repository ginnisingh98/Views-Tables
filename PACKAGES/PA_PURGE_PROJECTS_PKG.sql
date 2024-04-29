--------------------------------------------------------
--  DDL for Package PA_PURGE_PROJECTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PURGE_PROJECTS_PKG" AUTHID CURRENT_USER as
/* $Header: PAXARPPS.pls 120.1 2005/08/05 00:48:56 rgandhi noship $ */
 procedure insert_row (x_rowid				 in out NOCOPY VARCHAR2,/*File.sql.39*/
                       x_purge_batch_id                  in out NOCOPY NUMBER,/*File.sql.39*/
                       x_project_id       		 in NUMBER,
                       x_last_project_status_code        in VARCHAR2,
                       x_purge_summary_flag              in VARCHAR2,
                       x_archive_summary_flag            in VARCHAR2,
                       x_purge_budgets_flag              in VARCHAR2,
                       x_archive_budgets_flag            in VARCHAR2,
                       x_purge_capital_flag              in VARCHAR2,
                       x_archive_capital_flag            in VARCHAR2,
                       x_purge_actuals_flag              in VARCHAR2,
                       x_archive_actuals_flag            in VARCHAR2,
                       x_txn_to_date                     in DATE,
                       x_purge_project_status_code       in VARCHAR2,
                       x_next_pp_project_status_code     in VARCHAR2,
                       x_next_p_project_status_code      in VARCHAR2,
                       x_purged_date              	 in DATE,
                       x_user_id                         in NUMBER ) ;

 procedure update_row (x_rowid				 in VARCHAR2,
                       x_purge_batch_id                  in NUMBER,
                       x_project_id       		 in NUMBER,
                       x_last_project_status_code        in VARCHAR2,
                       x_purge_summary_flag              in VARCHAR2,
                       x_archive_summary_flag            in VARCHAR2,
                       x_purge_budgets_flag              in VARCHAR2,
                       x_archive_budgets_flag            in VARCHAR2,
                       x_purge_capital_flag              in VARCHAR2,
                       x_archive_capital_flag            in VARCHAR2,
                       x_purge_actuals_flag              in VARCHAR2,
                       x_archive_actuals_flag            in VARCHAR2,
                       x_txn_to_date                     in DATE,
                       x_purge_project_status_code       in VARCHAR2,
                       x_next_pp_project_status_code     in VARCHAR2,
                       x_next_p_project_status_code      in VARCHAR2,
                       x_purged_date              	 in DATE,
                       x_user_id                         in NUMBER ) ;

 procedure delete_row (x_rowid	in  VARCHAR2) ;

 procedure lock_row    (x_rowid				  in VARCHAR2,
                        x_purge_batch_id                  in NUMBER,
                        x_project_id       		  in NUMBER,
                        x_last_project_status_code        in VARCHAR2,
                        x_purge_summary_flag              in VARCHAR2,
                        x_archive_summary_flag            in VARCHAR2,
                        x_purge_budgets_flag              in VARCHAR2,
                        x_archive_budgets_flag            in VARCHAR2,
                        x_purge_capital_flag              in VARCHAR2,
                        x_archive_capital_flag            in VARCHAR2,
                        x_purge_actuals_flag              in VARCHAR2,
                        x_archive_actuals_flag            in VARCHAR2,
                        x_txn_to_date                     in DATE,
                        x_purge_project_status_code       in VARCHAR2,
                        x_next_pp_project_status_code     in VARCHAR2,
                        x_next_p_project_status_code      in VARCHAR2,
                        x_purged_date              	  in DATE) ;

END pa_purge_projects_pkg;

 

/
