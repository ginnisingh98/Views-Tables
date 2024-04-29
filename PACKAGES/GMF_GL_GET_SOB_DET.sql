--------------------------------------------------------
--  DDL for Package GMF_GL_GET_SOB_DET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_GL_GET_SOB_DET" AUTHID CURRENT_USER AS
/* $Header: gmfsobds.pls 115.1 2002/11/11 00:43:57 rseshadr ship $ */
PROCEDURE proc_gl_get_sob_det(
 st_date  in out  NOCOPY date,
 en_date    in out  NOCOPY date,
 sob_name    in out  NOCOPY varchar2,
 sob_id  in out 	NOCOPY number,
 /*last_update_date                out date, */
 last_updated_by                 out NOCOPY number,
 currency_code                   out NOCOPY varchar2,
 chart_of_accounts_id            out NOCOPY number,
 period_set_name                 out NOCOPY varchar2,
 suspense_allowed_flag           out NOCOPY varchar2,
 allow_posting_warning_flag      out NOCOPY varchar2,
 accounted_period_type           out NOCOPY varchar2,
 short_name                      out NOCOPY varchar2,
 require_budget_journals_flag    out NOCOPY varchar2,
 enable_budgetary_control_flag   out NOCOPY varchar2,
 allow_intercompany_post_flag    out NOCOPY varchar2,
 creation_date                   out      NOCOPY date,
 created_by                      out      NOCOPY number,
 last_update_login               out      NOCOPY number,
 latest_encumbrance_year         out      NOCOPY number,
 earliest_untrans_period_name    out      NOCOPY varchar2,
 cum_trans_code_combination_id   out      NOCOPY number,
 future_enterable_periods_limit  out      NOCOPY number,
 latest_opened_period_name       out      NOCOPY varchar2,
 ret_earn_code_combination_id    out      NOCOPY number,
 res_encumb_code_combination_id  out      NOCOPY number,
 row_to_fetch in number,
 error_status out 	NOCOPY number);
END GMF_GL_GET_SOB_DET;

 

/
