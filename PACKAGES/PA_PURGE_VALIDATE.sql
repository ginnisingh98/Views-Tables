--------------------------------------------------------
--  DDL for Package PA_PURGE_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PURGE_VALIDATE" AUTHID CURRENT_USER as
/* $Header: PAXVALDS.pls 120.1 2005/08/19 17:22:23 mwasowic noship $ */
   -- These flags are globals variables that can be used in all the
   -- procedures to check which data is purged.
   g_project_type_class_code varchar2(30) ;

   g_purge_summary_flag      varchar2(1) ;

   g_purge_capital_flag      varchar2(1) ;

   g_purge_budgets_flag      varchar2(1) ;

   g_purge_actuals_flag      varchar2(1) ;

   g_txn_to_date             date        ;

   g_active_flag             varchar2(1) ;

   g_creation_date           date ;

   g_created_by              number ;

   g_last_update_date        date ;

   g_last_updated_by         number ;

   g_last_update_login       number ;

   g_user                    number ;

   g_request_id              number ;

   g_program_application_id  number ;

   g_program_id              number ;

   g_delete_errors           VARCHAR2(1);   /* Bug#2416385 Added for Phase - III Archive and Purge */

   procedure BatchVal(errbuf                    IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                      ret_code                  IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                      p_purge_batch_id          IN NUMBER) ;

   procedure insert_errors ( p_purge_batch_id            in NUMBER,
                             p_project_id                in NUMBER,
                             p_error_type                in VARCHAR2,
                             p_user                      in NUMBER,
                             X_err_stack                 in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             X_err_stage                 in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             X_err_code                  in OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                           ) ;

end ;
 

/
