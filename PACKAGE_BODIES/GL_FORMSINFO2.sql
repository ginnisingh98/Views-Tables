--------------------------------------------------------
--  DDL for Package Body GL_FORMSINFO2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_FORMSINFO2" AS
/* $Header: gligcf2b.pls 120.5 2005/05/05 01:07:55 kvora ship $ */

  PROCEDURE get_coa_info (x_chart_of_accounts_id    IN     NUMBER,
                          x_segment_delimiter       IN OUT NOCOPY VARCHAR2,
                          x_enabled_segment_count   IN OUT NOCOPY NUMBER,
                          x_segment_order_by        IN OUT NOCOPY VARCHAR2,
                          x_accseg_segment_num      IN OUT NOCOPY NUMBER,
                          x_accseg_app_col_name     IN OUT NOCOPY VARCHAR2,
                          x_accseg_left_prompt      IN OUT NOCOPY VARCHAR2,
                          x_balseg_segment_num      IN OUT NOCOPY NUMBER,
                          x_balseg_app_col_name     IN OUT NOCOPY VARCHAR2,
                          x_balseg_left_prompt      IN OUT NOCOPY VARCHAR2,
                          x_ieaseg_segment_num      IN OUT NOCOPY NUMBER,
                          x_ieaseg_app_col_name     IN OUT NOCOPY VARCHAR2,
                          x_ieaseg_left_prompt      IN OUT NOCOPY VARCHAR2) IS

    CURSOR seg_count IS
      SELECT segment_num, application_column_name
      FROM fnd_id_flex_segments
      WHERE application_id = 101
      AND   id_flex_code   = 'GL#'
      AND   enabled_flag   = 'Y'
      AND   id_flex_num    = x_chart_of_accounts_id
      ORDER BY segment_num;
    dumdum BOOLEAN := FALSE;

    x_seg_name VARCHAR2(30);
    x_value_set VARCHAR2(60);
  BEGIN

    -- Identify the natural account and balancing segments
    dumdum := FND_FLEX_APIS.get_qualifier_segnum(
                101, 'GL#', x_chart_of_accounts_id,
                'GL_ACCOUNT', x_accseg_segment_num);
    dumdum := FND_FLEX_APIS.get_qualifier_segnum(
                101, 'GL#', x_chart_of_accounts_id,
                'GL_BALANCING', x_balseg_segment_num);
    dumdum := FND_FLEX_APIS.get_qualifier_segnum(
                101, 'GL#', x_chart_of_accounts_id,
                'GL_INTERCOMPANY', x_ieaseg_segment_num);

    -- Get the segment delimiter
    x_segment_delimiter := FND_FLEX_APIS.get_segment_delimiter(
                             101, 'GL#', x_chart_of_accounts_id);

    -- Count 'em up and string 'em together
    x_enabled_segment_count := 0;
    FOR r IN seg_count LOOP
      -- How many enabled segs are there?
      x_enabled_segment_count := seg_count%ROWCOUNT;
      -- Record the order by string
      IF seg_count%ROWCOUNT = 1 THEN
        x_segment_order_by      := r.application_column_name;
      ELSE
        x_segment_order_by      := x_segment_order_by||
                                   ','||
                                   r.application_column_name;
      END IF;
      -- If this is either the accseg or balseg, get more info
      IF    r.segment_num = x_accseg_segment_num THEN
        IF (FND_FLEX_APIS.get_segment_info(
              101, 'GL#', x_chart_of_accounts_id,
              r.segment_num, x_accseg_app_col_name,
              x_seg_name, x_accseg_left_prompt, x_value_set)) THEN
          null;
        END IF;
      ELSIF r.segment_num = x_balseg_segment_num THEN
        IF (FND_FLEX_APIS.get_segment_info(
              101, 'GL#', x_chart_of_accounts_id,
              r.segment_num, x_balseg_app_col_name,
              x_seg_name, x_balseg_left_prompt, x_value_set)) THEN
          null;
        END IF;
      ELSIF r.segment_num = x_ieaseg_segment_num THEN
        IF (FND_FLEX_APIS.get_segment_info(
              101, 'GL#', x_chart_of_accounts_id,
              r.segment_num, x_ieaseg_app_col_name,
              x_seg_name, x_ieaseg_left_prompt, x_value_set)) THEN
          null;
        END IF;
      END IF;
    END LOOP;

  EXCEPTION
   WHEN OTHERS THEN
     app_exception.raise_exception;
  END get_coa_info;


  PROCEDURE get_sob_info ( X_set_of_books_id		IN     NUMBER,
                   X_chart_of_accounts_id   		IN OUT NOCOPY NUMBER,
		   X_name				IN OUT NOCOPY VARCHAR2,
		   X_short_name				IN OUT NOCOPY VARCHAR2,
                   X_currency_code	 		IN OUT NOCOPY VARCHAR2,
                   X_period_set_name	 		IN OUT NOCOPY VARCHAR2,
                   X_accounted_period_type 		IN OUT NOCOPY VARCHAR2,
                   X_suspense_allowed_flag		IN OUT NOCOPY VARCHAR2,
                   X_allow_intercompany_post_flag	IN OUT NOCOPY VARCHAR2,
                   X_require_budget_journals_flag	IN OUT NOCOPY VARCHAR2,
		   X_enable_bc_flag			IN OUT NOCOPY VARCHAR2,
                   X_latest_opened_period_name 		IN OUT NOCOPY VARCHAR2,
                   X_latest_encumbrance_year 		IN OUT NOCOPY NUMBER,
		   X_future_enterable_periods  		IN OUT NOCOPY NUMBER,
 		   X_cum_trans_ccid			IN OUT NOCOPY NUMBER,
 		   X_ret_earn_ccid			IN OUT NOCOPY NUMBER,
 		   X_res_encumb_ccid 			IN OUT NOCOPY NUMBER,
		   X_enable_average_balances_flag       IN OUT NOCOPY VARCHAR2,
		   X_transaction_calendar_id		IN OUT NOCOPY NUMBER,
 		   X_net_income_ccid			IN OUT NOCOPY NUMBER,
                   X_consolidation_sob_flag             IN OUT NOCOPY VARCHAR2,
                   X_daily_translation_rate_type        IN OUT NOCOPY VARCHAR2,
		   X_enable_automatic_tax_flag		IN OUT NOCOPY VARCHAR2,
		   X_mrc_sob_type_code			IN OUT NOCOPY VARCHAR2,
                   X_enable_je_approval_flag            IN OUT NOCOPY VARCHAR2 )
  IS

    CURSOR gsi IS
      SELECT
	     chart_of_accounts_id,
	     name,
	     short_name,
	     currency_code,
	     period_set_name,
	     accounted_period_type,
	     suspense_allowed_flag,
	     allow_intercompany_post_flag,
	     require_budget_journals_flag,
	     enable_budgetary_control_flag,
	     latest_opened_period_name,
	     latest_encumbrance_year,
	     future_enterable_periods_limit,
	     cum_trans_code_combination_id,
	     ret_earn_code_combination_id,
	     res_encumb_code_combination_id,
             enable_average_balances_flag,
             transaction_calendar_id,
             net_income_code_combination_id,
             consolidation_sob_flag,
             daily_translation_rate_type,
	     enable_automatic_tax_flag,
	     mrc_sob_type_code,
             enable_je_approval_flag
      FROM
	     GL_SETS_OF_BOOKS
      WHERE
	     set_of_books_id = X_set_of_books_id;

  BEGIN
    OPEN gsi;
    FETCH gsi INTO X_chart_of_accounts_id,
		   X_name,
		   X_short_name,
		   X_currency_code,
		   X_period_set_name,
		   X_accounted_period_type,
		   X_suspense_allowed_flag,
		   X_allow_intercompany_post_flag,
		   X_require_budget_journals_flag,
		   X_enable_bc_flag,
		   X_latest_opened_period_name,
		   X_latest_encumbrance_year,
		   X_future_enterable_periods,
		   X_cum_trans_ccid,
		   X_ret_earn_ccid,
		   X_res_encumb_ccid,
		   X_enable_average_balances_flag,
		   X_transaction_calendar_id,
		   X_net_income_ccid,
                   X_consolidation_sob_flag,
                   X_daily_translation_rate_type,
		   X_enable_automatic_tax_flag,
		   X_mrc_sob_type_code,
                   X_enable_je_approval_flag;
    CLOSE gsi;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_message.set_name('SQLGL', 'GL_SHRD_INVALID_SOBID');
      fnd_message.set_token('SOBID', to_char(X_set_of_books_id), FALSE);
      app_exception.raise_exception;
    WHEN OTHERS THEN
      app_exception.raise_exception;

  END get_sob_info;


  FUNCTION multi_org RETURN BOOLEAN IS
    CURSOR is_multi IS
      SELECT nvl(multi_org_flag, 'N')
      FROM fnd_product_groups;
    dummy VARCHAR2(1);
  BEGIN
    OPEN is_multi;
    FETCH is_multi INTO dummy;

    IF is_multi%FOUND THEN
      CLOSE is_multi;

      IF (dummy = 'N') THEN
        RETURN (FALSE);
      ELSE
        RETURN (TRUE);
      END IF;

    ELSE
      CLOSE is_multi;
      RETURN(FALSE);
    END IF;
  END multi_org;

  FUNCTION install_info(appl_id		IN NUMBER,
			dep_appl_id	IN NUMBER,
			status		OUT NOCOPY VARCHAR2,
			industry	OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    RETURN(fnd_installation.get(appl_id, dep_appl_id, status, industry));
  END install_info;

  PROCEDURE get_iea_info(x_subsidiary_id		   NUMBER,
			 x_name		    	    IN OUT NOCOPY VARCHAR2,
			 x_chart_of_accounts_id     IN OUT NOCOPY NUMBER,
			 x_set_of_books_id	    IN OUT NOCOPY NUMBER,
 			 x_enabled_flag	    	    IN OUT NOCOPY VARCHAR2,
			 x_subsidiary_type_code     IN OUT NOCOPY VARCHAR2,
                         x_company_value	    IN OUT NOCOPY VARCHAR2,
                         x_currency_code	    IN OUT NOCOPY VARCHAR2,
		         x_autoapprove_flag	    IN OUT NOCOPY VARCHAR2,
			 x_view_partner_lines_flag  IN OUT NOCOPY VARCHAR2,
			 x_conversion_type_code	    IN OUT NOCOPY VARCHAR2,
			 x_conversion_type	    IN OUT NOCOPY VARCHAR2,
			 x_remote_instance_flag	    IN OUT NOCOPY VARCHAR2,
			 x_transfer_set_of_books_id IN OUT NOCOPY NUMBER,
			 x_transfer_currency_code   IN OUT NOCOPY VARCHAR2,
			 x_contact		    IN OUT NOCOPY VARCHAR2,
			 x_notification_threshold   IN OUT NOCOPY NUMBER) IS
  BEGIN
  /* GL_IEA_SUBSIDIARY_PKG dropped in Ledger Architecture.
   gl_iea_subsidiary_pkg.select_columns(
      x_subsidiary_id,
      x_name,
      x_chart_of_accounts_id,
      x_set_of_books_id,
      x_enabled_flag,
      x_subsidiary_type_code,
      x_company_value,
      x_currency_code,
      x_autoapprove_flag,
      x_view_partner_lines_flag,
      x_conversion_type_code,
      x_conversion_type,
      x_remote_instance_flag,
      x_transfer_set_of_books_id,
      x_transfer_currency_code,
      x_contact,
      x_notification_threshold);
  */

  x_chart_of_accounts_id := NULL;

  END get_iea_info;

  PROCEDURE get_usage_info(
              x_average_balances_flag		IN OUT NOCOPY  VARCHAR2,
              x_consolidation_ledger_flag  	IN OUT NOCOPY  VARCHAR2) IS
  BEGIN
    gl_system_usages_pkg.select_columns(x_average_balances_flag,
                                        x_consolidation_ledger_flag);
  END get_usage_info;

  PROCEDURE get_business_days_pattern(X_transaction_cal_id     IN NUMBER,
 		              X_start_date             IN DATE,
                              X_end_date               IN DATE,
		              X_bus_days_pattern       IN OUT NOCOPY VARCHAR2
                                     ) IS
  BEGIN
    gl_trans_dates_pkg.get_business_days_pattern(
      X_transaction_cal_id,
      X_start_date,
      X_end_date,
      X_bus_days_pattern);
  END get_business_days_pattern;

  FUNCTION iea_disabled_subsidiary(X_Subsidiary_Id IN NUMBER) RETURN BOOLEAN IS
     dummy VARCHAR2(1);
  BEGIN
     IF X_Subsidiary_Id IS NOT NULL THEN
           SELECT 'x' INTO dummy
           FROM gl_iea_subsidiaries
           WHERE  subsidiary_id = X_Subsidiary_Id
           AND    enabled_flag = 'Y';
     END IF;

     return(FALSE);
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
          return(TRUE);
     WHEN OTHERS THEN
         fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
         fnd_message.set_token('PROCEDURE',
             'GL_FORMSINFO2.iea_disabled_subsidiary');
         APP_EXCEPTION.Raise_Exception;
  END iea_disabled_subsidiary;


  FUNCTION get_industry_message(Message_Name           IN VARCHAR2,
                                Application_Shortname  IN VARCHAR2)
    RETURN VARCHAR2 IS
  BEGIN
    RETURN(gl_public_sector.get_message_name(Message_Name,
                                             Application_Shortname));
  END get_industry_message;


END GL_FORMSINFO2;

/
