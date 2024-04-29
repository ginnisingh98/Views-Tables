--------------------------------------------------------
--  DDL for Package PA_BUDGET_UTILS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BUDGET_UTILS2" AUTHID CURRENT_USER as
-- $Header: PAXBUTLS.pls 120.1 2005/08/19 17:10:49 mwasowic noship $

  function check_budget_at_compl_exists (x_project_id in number,
                                         x_task_id    in number)
                                         return varchar2;

  procedure submit_budget (x_budget_version_id in     number,
                          x_err_code          in out NOCOPY number, --File.Sql.39 bug 4440895
                          x_err_stage         in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                          x_err_stack         in out NOCOPY varchar2); --File.Sql.39 bug 4440895

  procedure rework_budget (x_budget_version_id in     number,
                          x_err_code          in out NOCOPY number, --File.Sql.39 bug 4440895
                          x_err_stage         in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                          x_err_stack         in out NOCOPY varchar2); --File.Sql.39 bug 4440895

/* Bug 2920954 - Added x_validation_mode parameter. This takes values  R or U.
   R - Restricted mode - Will return 1 when plannable element exists for x_task_id
   U - Unrestricted mode - Will return 0 when plannable element exists in baselined version or
                           plan amounts exists for x_task_id plannable element */

  function check_task_lowest_in_budgets (x_task_id     in number,
                                         x_top_task_id in number,
                                         x_validation_mode   in varchar2 default 'U' )
                                     return number;

end PA_BUDGET_UTILS2 ;

 

/
