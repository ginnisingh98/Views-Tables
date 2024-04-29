--------------------------------------------------------
--  DDL for Package Body GMF_GL_GET_SOB_DET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_GL_GET_SOB_DET" AS
/* $Header: gmfsobdb.pls 115.1 2002/11/11 00:43:46 rseshadr ship $ */
	CURSOR cur_gl_get_sob_det(st_date date, en_date date,
	sob_name varchar2, sob_id number)  IS
	SELECT 	set_of_books_id,
           name,
           last_updated_by              ,
           currency_code                ,
           chart_of_accounts_id           ,
           period_set_name              ,
           suspense_allowed_flag        ,
           allow_posting_warning_flag   ,
           accounted_period_type          ,
           short_name                   ,
           require_budget_journals_flag   ,
           enable_budgetary_control_flag,
           allow_intercompany_post_flag ,
           creation_date                ,
           created_by                  ,
           last_update_login            ,
           latest_encumbrance_year      ,
           earliest_untrans_period_name ,
           cum_trans_code_combination_id,
           future_enterable_periods_limit,
           latest_opened_period_name     ,
           ret_earn_code_combination_id  ,
           res_encumb_code_combination_id
		     	FROM	   gl_sets_of_books
			WHERE    name LIKE sob_name   AND
                          set_of_books_id = nvl(sob_id, set_of_books_id) and
			   creation_date BETWEEN
				nvl(st_date, creation_date)
                            AND nvl(en_date, creation_date);

PROCEDURE proc_gl_get_sob_det(
 st_date  in out  NOCOPY date,
 en_date    in out  NOCOPY date,
 sob_name    in out  NOCOPY varchar2,
 sob_id  in out NOCOPY number,
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
 error_status out 	NOCOPY number) IS

 BEGIN

 IF NOT cur_gl_get_sob_det%ISOPEN THEN
	OPEN cur_gl_get_sob_det(st_date, en_date, sob_name, sob_id);
 END IF;

 FETCH cur_gl_get_sob_det
	INTO 	sob_id,
           sob_name,
           last_updated_by              ,
           currency_code                ,
           chart_of_accounts_id           ,
           period_set_name              ,
           suspense_allowed_flag        ,
           allow_posting_warning_flag   ,
           accounted_period_type          ,
           short_name                   ,
           require_budget_journals_flag   ,
           enable_budgetary_control_flag,
           allow_intercompany_post_flag ,
           creation_date                ,
           created_by                  ,
           last_update_login            ,
           latest_encumbrance_year      ,
           earliest_untrans_period_name ,
           cum_trans_code_combination_id,
           future_enterable_periods_limit,
           latest_opened_period_name     ,
           ret_earn_code_combination_id  ,
           res_encumb_code_combination_id;

 if cur_gl_get_sob_det%NOTFOUND then
         error_status := 100;
 end if;
 if (cur_gl_get_sob_det%NOTFOUND) or row_to_fetch = 1 THEN
	CLOSE cur_gl_get_sob_det;
 end if;

 exception

     when others then
      	error_status := SQLCODE;

 END;	/* End of procedure proc_gl_get_sob_det */

END GMF_GL_GET_SOB_DET;	-- END GMF_GL_GET_SOB_DET

/
