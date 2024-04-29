--------------------------------------------------------
--  DDL for Package PA_BUDGET_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BUDGET_CORE" AUTHID CURRENT_USER AS
-- $Header: PAXBUBCS.pls 120.3.12000000.3 2007/07/13 12:01:12 vgovvala ship $

  g_project_start_date    date;

  procedure baseline (x_draft_version_id  	in     number,
                      x_mark_as_original  		in     varchar2,
		      x_verify_budget_rules	in	varchar2 default 'Y',
	              x_err_code          		in out NOCOPY number, --File.Sql.39 bug 4440895
                      x_err_stage         		in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                      x_err_stack         		in out NOCOPY varchar2); --File.Sql.39 bug 4440895

  procedure copy_without_delete (p_src_version_id       in     number,
                                  p_amount_change_pct   in     number,
                                  p_rounding_precision  in     number,
                                  p_dest_project_id     in     number,
                                  p_dest_budget_type_code    in     varchar2,
                                  x_err_code            in out NOCOPY number,   -- added NOCOPY to pass GSCC errors for bug 5838587
                                  x_err_stage           in out NOCOPY varchar2, -- added NOCOPY to pass GSCC errors for bug 5838587
                                  x_err_stack           in out NOCOPY varchar2); -- added NOCOPY to pass GSCC errors for bug 5838587

  procedure copy (x_src_version_id      in     number,
                  x_amount_change_pct   in     number,
                  x_rounding_precision  in     number,
                  x_shift_days          in     number,
                  x_dest_project_id     in     number,
                  x_dest_budget_type_code    in     varchar2,
                  x_err_code            in out NOCOPY number, --File.Sql.39 bug 4440895
                  x_err_stage           in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                  x_err_stack           in out NOCOPY varchar2); --File.Sql.39 bug 4440895

  procedure verify (x_budget_version_id   in     number,
                    x_err_code            in out NOCOPY number, --File.Sql.39 bug 4440895
                    x_err_stage           in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                    x_err_stack           in out NOCOPY varchar2); --File.Sql.39 bug 4440895

  procedure copy_lines (x_src_version_id      in     number,
                        x_amount_change_pct   in     number,
                        x_rounding_precision  in     number,
                        x_shift_days          in     number,
                        x_dest_version_id     in     number,
                        x_err_code            in out NOCOPY number, --File.Sql.39 bug 4440895
                        x_err_stage           in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                        x_err_stack           in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                        x_pm_flag             in varchar2 default 'N') ;

  procedure shift_periods(x_start_period_date in date,
                          x_periods      in  number,
                          x_period_name  in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                          x_period_type  in varchar2,
                          x_start_date   in out NOCOPY date, --File.Sql.39 bug 4440895
                          x_end_date     in out NOCOPY date, --File.Sql.39 bug 4440895
                          x_err_code     in out NOCOPY number, --File.Sql.39 bug 4440895
                          x_err_stage    in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                          x_err_stack    in out NOCOPY varchar2); --File.Sql.39 bug 4440895

 procedure get_periods(x_start_date1 in date,
                       x_start_date2 in date,
                       x_period_type  in varchar2,
                       x_periods   in out  NOCOPY number, --File.Sql.39 bug 4440895
                       x_err_code          in out NOCOPY number, --File.Sql.39 bug 4440895
                       x_err_stage         in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                       x_err_stack         in out NOCOPY varchar2); --File.Sql.39 bug 4440895

END pa_budget_core;
 

/
