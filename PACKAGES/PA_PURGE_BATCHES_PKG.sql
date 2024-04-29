--------------------------------------------------------
--  DDL for Package PA_PURGE_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PURGE_BATCHES_PKG" AUTHID CURRENT_USER as
/* $Header: PAXARPBS.pls 120.2 2005/08/05 00:45:10 rgandhi noship $ */

 procedure insert_row(x_rowid				in out NOCOPY VARCHAR2,/*file.sql.39*/
                      x_purge_batch_id                  in out NOCOPY NUMBER,/*file.sql.39*/
                      x_batch_name       		in VARCHAR2,
                      x_description			in VARCHAR2,
                      x_batch_status_code       	in VARCHAR2,
                      x_active_closed_flag              in VARCHAR2,
                      x_purge_summary_flag              in VARCHAR2,
                      x_archive_summary_flag            in VARCHAR2,
                      x_purge_budgets_flag              in VARCHAR2,
                      x_archive_budgets_flag            in VARCHAR2,
                      x_purge_capital_flag              in VARCHAR2,
                      x_archive_capital_flag            in VARCHAR2,
                      x_purge_actuals_flag              in VARCHAR2,
                      x_archive_actuals_flag            in VARCHAR2,
                      x_admin_proj_flag 	        in VARCHAR2,
                      x_txn_to_date                     in DATE,
                      x_next_pp_project_status_code     in VARCHAR2,
                      x_next_p_project_status_code      in VARCHAR2,
                      x_purged_date              	in DATE,
                      x_purge_release                   in VARCHAR2,
                      x_user_id                         in NUMBER,
		      x_org_id                          in NUMBER) ;

 procedure update_row  (x_rowid				  in VARCHAR2,
                        x_purge_batch_id                  in out NOCOPY NUMBER,/*File.sql.39*/
                        x_batch_name       		  in VARCHAR2,
                        x_description			  in VARCHAR2,
                        x_batch_status_code       	  in VARCHAR2,
                        x_active_closed_flag              in VARCHAR2,
                        x_purge_summary_flag              in VARCHAR2,
                        x_archive_summary_flag            in VARCHAR2,
                        x_purge_budgets_flag              in VARCHAR2,
                        x_archive_budgets_flag            in VARCHAR2,
                        x_purge_capital_flag              in VARCHAR2,
                        x_archive_capital_flag            in VARCHAR2,
                        x_purge_actuals_flag              in VARCHAR2,
                        x_archive_actuals_flag            in VARCHAR2,
                        x_admin_proj_flag 	          in VARCHAR2,
                        x_txn_to_date                     in DATE,
                        x_next_pp_project_status_code     in VARCHAR2,
                        x_next_p_project_status_code      in VARCHAR2,
                        x_purged_date              	  in DATE,
                        x_purge_release              	  in VARCHAR2,
                        x_user_id                         in NUMBER) ;

 procedure delete_row (x_rowid	in VARCHAR2);

 procedure lock_row    (x_rowid				  in VARCHAR2,
                        x_purge_batch_id                  in out NOCOPY NUMBER,/*File.sql.39*/
                        x_batch_name       		  in VARCHAR2,
                        x_description			  in VARCHAR2,
                        x_batch_status_code       	  in VARCHAR2,
                        x_active_closed_flag              in VARCHAR2,
                        x_purge_summary_flag              in VARCHAR2,
                        x_archive_summary_flag            in VARCHAR2,
                        x_purge_budgets_flag              in VARCHAR2,
                        x_archive_budgets_flag            in VARCHAR2,
                        x_purge_capital_flag              in VARCHAR2,
                        x_archive_capital_flag            in VARCHAR2,
                        x_purge_actuals_flag              in VARCHAR2,
                        x_archive_actuals_flag            in VARCHAR2,
                        x_admin_proj_flag 	          in VARCHAR2,
                        x_txn_to_date                     in DATE,
                        x_next_pp_project_status_code     in VARCHAR2,
                        x_next_p_project_status_code      in VARCHAR2,
                        x_purge_release                   in VARCHAR2,
                        x_purged_date              	  in DATE) ;


END pa_purge_batches_pkg;

 

/
