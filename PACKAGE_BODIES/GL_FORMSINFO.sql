--------------------------------------------------------
--  DDL for Package Body GL_FORMSINFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_FORMSINFO" AS
/* $Header: gligcfib.pls 120.19 2005/07/29 16:58:51 djogg ship $ */

  PROCEDURE get_coa_info (x_chart_of_accounts_id    IN     NUMBER,
                          x_segment_delimiter       IN OUT NOCOPY VARCHAR2,
                          x_enabled_segment_count   IN OUT NOCOPY NUMBER,
                          x_segment_order_by        IN OUT NOCOPY VARCHAR2,
                          x_accseg_segment_num      IN OUT NOCOPY NUMBER,
                          x_accseg_app_col_name     IN OUT NOCOPY VARCHAR2,
                          x_accseg_left_prompt      IN OUT NOCOPY VARCHAR2,
                          x_balseg_segment_num      IN OUT NOCOPY NUMBER,
                          x_balseg_app_col_name     IN OUT NOCOPY VARCHAR2,
                          x_balseg_left_prompt     IN OUT NOCOPY VARCHAR2,
                          x_mgtseg_segment_num      IN OUT NOCOPY NUMBER,
                          x_mgtseg_app_col_name     IN OUT NOCOPY VARCHAR2,
                          x_mgtseg_left_prompt      IN OUT NOCOPY VARCHAR2,
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
                'GL_MANAGEMENT', x_mgtseg_segment_num);
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
      ELSIF r.segment_num = x_mgtseg_segment_num THEN
        IF (FND_FLEX_APIS.get_segment_info(
              101, 'GL#', x_chart_of_accounts_id,
              r.segment_num, x_mgtseg_app_col_name,
              x_seg_name, x_mgtseg_left_prompt, x_value_set)) THEN
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


  PROCEDURE get_access_info (x_access_set_id              IN     NUMBER,
                             x_name                       IN OUT NOCOPY VARCHAR2,
			     x_enabled_flag               IN OUT NOCOPY VARCHAR2,
                             x_security_segment_code      IN OUT NOCOPY VARCHAR2,
			     x_chart_of_accounts_id       IN OUT NOCOPY NUMBER,
			     x_period_set_name            IN OUT NOCOPY VARCHAR2,
                             x_accounted_period_type      IN OUT NOCOPY VARCHAR2,
	                     x_automatically_created_flag IN OUT NOCOPY VARCHAR2 ) IS
    CURSOR access_info_curr IS
      SELECT
	     name,
  	     enabled_flag,
             security_segment_code,
             chart_of_accounts_id,
             period_set_name,
             accounted_period_type,
             automatically_created_flag
      FROM
	     GL_ACCESS_SETS
      WHERE
	     access_set_id = X_access_set_id;
  BEGIN
    OPEN access_info_curr;
    FETCH access_info_curr INTO
	X_name,
	X_enabled_flag,
        X_security_segment_code,
	X_chart_of_accounts_id,
	X_period_set_name,
	X_accounted_period_type,
	X_automatically_created_flag;
    CLOSE access_info_curr;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_message.set_name('SQLGL', 'GL_SHRD_INVALID_ACCESSID');
      fnd_message.set_token('ACCESSID', to_char(X_access_set_id), FALSE);
      app_exception.raise_exception;
    WHEN OTHERS THEN
      app_exception.raise_exception;

  END;

  FUNCTION check_access ( X_access_set_id IN NUMBER,
                          X_ledger_id     IN NUMBER,
                          X_segment_value IN VARCHAR2,
                          X_edate         IN DATE) RETURN VARCHAR2 IS

    CURSOR check_access_ledger IS
      SELECT access_privilege_code
      FROM   gl_access_set_ledgers
      WHERE  access_set_id = X_access_set_id
      AND    ledger_id = X_ledger_id
      AND    (   (X_edate IS NULL)
              OR (trunc(X_edate) BETWEEN nvl(trunc(start_date), trunc(X_edate)-1)
                                 AND nvl(trunc(end_date), trunc(X_edate)+1)));

    CURSOR check_access_segment IS
      SELECT decode(max(decode(access_privilege_code, 'B', 2, 1)), 1, 'R', 2, 'B', 'N')
      FROM   gl_access_set_assignments
      WHERE  access_set_id = X_access_set_id
      AND    segment_value = X_segment_value
      AND    (   (X_edate IS NULL)
              OR (trunc(X_edate) BETWEEN nvl(trunc(start_date), trunc(X_edate)-1)
                                 AND nvl(trunc(end_date), trunc(X_edate)+1)));

    CURSOR check_access_ls IS
      SELECT access_privilege_code
      FROM   gl_access_set_assignments
      WHERE  access_set_id = X_access_set_id
      AND    ledger_id = X_ledger_id
      AND    segment_value = X_segment_value
      AND    (   (X_edate IS NULL)
              OR (trunc(X_edate) BETWEEN nvl(trunc(start_date), trunc(X_edate)-1)
                                 AND nvl(trunc(end_date), trunc(X_edate)+1)));

    X_access_privilege_code    VARCHAR2(1);

  BEGIN
    IF (X_ledger_id IS NULL) THEN
      IF (X_segment_value IS NULL) THEN
        RETURN('B');
      ELSE
        OPEN check_access_segment;
        FETCH check_access_segment INTO X_access_privilege_code;
        IF NOT check_access_segment%FOUND THEN
          X_access_privilege_code := gl_formsinfo.NO_ACCESS;
        END IF;
        CLOSE check_access_segment;
      END IF;
    ELSIF (X_segment_value IS NULL) THEN
      OPEN check_access_ledger;
      FETCH check_access_ledger INTO X_access_privilege_code;
      IF NOT check_access_ledger%FOUND THEN
        X_access_privilege_code := gl_formsinfo.NO_ACCESS;
      END IF;
      CLOSE check_access_ledger;
    ELSE
      OPEN check_access_ls;
      FETCH check_access_ls INTO X_access_privilege_code;
      IF NOT check_access_ls%FOUND THEN
        X_access_privilege_code := gl_formsinfo.NO_ACCESS;
      END IF;
      CLOSE check_access_ls;
    END IF;

    return( X_access_privilege_code);

  EXCEPTION
    WHEN OTHERS THEN
      app_exception.raise_exception;
  END check_access;


  FUNCTION get_ledger_type ( X_ledger_id IN NUMBER ) RETURN VARCHAR2 IS

    CURSOR gsi IS
      SELECT object_type_code
      FROM   gl_ledgers
      WHERE  ledger_id = X_ledger_id;

    X_ledger_type  VARCHAR2(1);

  BEGIN
    OPEN gsi;
    FETCH gsi INTO X_ledger_type;
    CLOSE gsi;

    return( X_ledger_type );

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_message.set_name('SQLGL', 'GL_SHRD_INVALID_LEDGERID');
      fnd_message.set_token('LEDGERID', to_char(X_ledger_id), FALSE);
      app_exception.raise_exception;
    WHEN OTHERS THEN
      app_exception.raise_exception;
  END;


  FUNCTION get_default_ledger ( X_access_set_id         IN NUMBER,
                                X_access_privilege_code IN VARCHAR2,
                                X_edate                 IN DATE) RETURN NUMBER IS

     -- This cursor is used to find out if the default ledger specified in the
     -- access set satisfies the access privilege and date requested.
     CURSOR sdl IS
      SELECT asl.ledger_id
      FROM   gl_access_set_ledgers asl
      WHERE  asl.access_set_id = X_access_set_id
      AND    asl.ledger_id = (select gas.default_ledger_id
                              from   gl_access_sets gas
	                      where  gas.access_set_id = asl.access_set_id)
      AND    (   (    (X_access_privilege_code = 'F')
                  AND (asl.access_privilege_code = 'F'))
              OR (    (X_access_privilege_code = 'B')
                  AND (asl.access_privilege_code IN ('F', 'B')))
              OR ( X_access_privilege_code = 'R'))
      AND    (   (X_edate IS NULL)
              OR (trunc(X_edate) BETWEEN nvl(trunc(asl.start_date),trunc(X_edate)-1)
                                 AND nvl(trunc(asl.end_date), trunc(X_edate)+1)));

    CURSOR gdl IS
      SELECT distinct ledger_id
      FROM   gl_access_set_ledgers
      WHERE  access_set_id = X_access_set_id
      AND    (   (    (X_access_privilege_code = 'F')
                  AND (access_privilege_code = 'F'))
              OR (    (X_access_privilege_code = 'B')
                  AND (access_privilege_code IN ('F', 'B')))
              OR ( X_access_privilege_code = 'R'))
      AND    (   (X_edate IS NULL)
              OR (trunc(X_edate) BETWEEN nvl(trunc(start_date), trunc(X_edate)-1)
                                 AND nvl(trunc(end_date), trunc(X_edate)+1)));

    X_ledger_id    NUMBER;
    X_ledger_id2   NUMBER;

  BEGIN
    IF (X_access_privilege_code NOT IN
          (gl_formsinfo.FULL_ACCESS,
           gl_formsinfo.WRITE_ACCESS,
           gl_formsinfo.READ_ACCESS)) THEN
      RETURN(-1);
    END IF;

    -- First check if there is a default ledger assigned to the access set
    -- that satisfies the given access privilege level.  If a default ledger
    -- is found here, we can return the default ledger ID.
    OPEN sdl;
    FETCH sdl INTO X_ledger_id;
    IF sdl%FOUND THEN
      CLOSE sdl;
      return( X_ledger_id );
    END IF;

    CLOSE sdl;

    -- Since there is no default ledger set up for this access set
    -- or the default ledger specified does not satisfy the access privilege
    --    or date requested,
    -- now check if there is one and only one ledger assigned to this access
    -- set that satisfies the access prilege level and date requested
    OPEN gdl;
    FETCH gdl INTO X_ledger_id;
    IF gdl%FOUND THEN
      FETCH gdl INTO X_ledger_id2;
      IF gdl%FOUND THEN
        X_ledger_id := -1;
      END IF;
    ELSE
      X_ledger_id := -1;
    END IF;

    CLOSE gdl;

    return( X_ledger_id );

  EXCEPTION
    WHEN OTHERS THEN
      app_exception.raise_exception;
  END get_default_ledger;

  FUNCTION has_single_ledger ( X_access_set_id IN NUMBER ) RETURN BOOLEAN IS
    CURSOR ledger_curr IS
      SELECT count(*)
      FROM   gl_access_set_ledgers
      WHERE  access_set_id = X_access_set_id
      AND    rownum < 3;

    ledger_count   NUMBER;
  BEGIN
    OPEN ledger_curr;
    FETCH ledger_curr INTO ledger_count;
    IF (ledger_count = 1) THEN
      return(TRUE);
    ELSE
      return(FALSE);
    END IF;
  END has_single_ledger;

  FUNCTION write_any_ledger ( X_access_set_id IN NUMBER ) RETURN BOOLEAN IS
    CURSOR ledger_access_curr IS
      SELECT nvl(max(1),0)
      FROM   gl_access_set_ledgers
      WHERE  access_set_id = X_access_set_id
      AND    access_privilege_code in ('W', 'F')
      AND    rownum < 2;

      ledger_access NUMBER;
  BEGIN
    OPEN ledger_access_curr;
    FETCH ledger_access_curr INTO ledger_access;
    IF (ledger_access = 1) THEN
      return(TRUE);
    ELSE
      return(FALSE);
    END IF;
  END write_any_ledger;

  PROCEDURE get_ledger_info (
                    X_ledger_id			        IN     NUMBER,
  	            X_name				IN OUT NOCOPY VARCHAR2,
	            X_short_name			IN OUT NOCOPY VARCHAR2,
                    X_chart_of_accounts_id   		IN OUT NOCOPY NUMBER,
                    X_currency_code	 		IN OUT NOCOPY VARCHAR2,
                    X_period_set_name	 		IN OUT NOCOPY VARCHAR2,
                    X_accounted_period_type 		IN OUT NOCOPY VARCHAR2,
 		    X_ret_earn_ccid			IN OUT NOCOPY NUMBER,
                    X_suspense_allowed_flag		IN OUT NOCOPY VARCHAR2,
                    X_allow_intercompany_post_flag	IN OUT NOCOPY VARCHAR2,
		    X_enable_average_balances_flag      IN OUT NOCOPY VARCHAR2,
		    X_enable_bc_flag			IN OUT NOCOPY VARCHAR2,
                    X_require_budget_journals_flag	IN OUT NOCOPY VARCHAR2,
                    X_enable_je_approval_flag           IN OUT NOCOPY VARCHAR2,
		    X_enable_automatic_tax_flag		IN OUT NOCOPY VARCHAR2,
                    X_consolidation_ledger_flag         IN OUT NOCOPY VARCHAR2,
		    X_translate_eod_flag                IN OUT NOCOPY VARCHAR2,
 		    X_translate_qatd_flag               IN OUT NOCOPY VARCHAR2,
		    X_translate_yatd_flag               IN OUT NOCOPY VARCHAR2,
                    X_automatically_created_flag        IN OUT NOCOPY VARCHAR2,
		    X_track_rnd_imbalance_flag          IN OUT NOCOPY VARCHAR2,
	 	    X_alc_ledger_type_code		IN OUT NOCOPY VARCHAR2,
	 	    X_reconciliation_flag		IN OUT NOCOPY VARCHAR2,
		    X_object_type_code                  IN OUT NOCOPY VARCHAR2,
		    X_le_ledger_type_code               IN OUT NOCOPY VARCHAR2,
		    X_bal_seg_value_option_code         IN OUT NOCOPY VARCHAR2,
		    X_bal_seg_column_name               IN OUT NOCOPY VARCHAR2,
		    X_mgt_seg_value_option_code         IN OUT NOCOPY VARCHAR2,
		    X_mgt_seg_column_name		IN OUT NOCOPY VARCHAR2,
		    X_description                       IN OUT NOCOPY VARCHAR2,
                    X_latest_opened_period_name 	IN OUT NOCOPY VARCHAR2,
                    X_latest_encumbrance_year 		IN OUT NOCOPY NUMBER,
		    X_future_enterable_periods  	IN OUT NOCOPY NUMBER,
 		    X_cum_trans_ccid			IN OUT NOCOPY NUMBER,
 		    X_res_encumb_ccid 			IN OUT NOCOPY NUMBER,
 		    X_net_income_ccid			IN OUT NOCOPY NUMBER,
                    X_rounding_ccid                     IN OUT NOCOPY NUMBER,
		    X_transaction_calendar_id		IN OUT NOCOPY NUMBER,
                    X_daily_translation_rate_type       IN OUT NOCOPY VARCHAR2,
		    X_legal_entity_id                   IN OUT NOCOPY NUMBER,
                    X_period_average_rate_type          IN OUT NOCOPY VARCHAR2,
                    X_period_end_rate_type              IN OUT NOCOPY VARCHAR2,
                    X_ledger_Category_code              IN OUT NOCOPY VARCHAR2) IS

    CURSOR gsi IS
      SELECT
	     name,
	     short_name,
	     chart_of_accounts_id,
	     currency_code,
	     period_set_name,
	     accounted_period_type,
	     ret_earn_code_combination_id,
	     suspense_allowed_flag,
	     allow_intercompany_post_flag,
             enable_average_balances_flag,
	     enable_budgetary_control_flag,
	     require_budget_journals_flag,
             enable_je_approval_flag,
	     enable_automatic_tax_flag,
             consolidation_ledger_flag,
             translate_eod_flag,
             translate_qatd_flag,
             translate_yatd_flag,
             automatically_created_flag,
	     track_rounding_imbalance_flag,
             enable_reconciliation_flag,
	     alc_ledger_type_code,
             object_type_code,
             le_ledger_type_code,
             bal_seg_value_option_code,
             bal_seg_column_name,
             mgt_seg_value_option_code,
             mgt_seg_column_name,
	     description,
	     latest_opened_period_name,
	     latest_encumbrance_year,
	     future_enterable_periods_limit,
	     cum_trans_code_combination_id,
	     res_encumb_code_combination_id,
             net_income_code_combination_id,
             rounding_code_combination_id,
             transaction_calendar_id,
             daily_translation_rate_type,
             period_average_rate_type,
             period_end_rate_type,
             ledger_category_code
      FROM
	     GL_LEDGERS
      WHERE
	     ledger_id = X_ledger_id;

  BEGIN
    OPEN gsi;
    FETCH gsi INTO
  	            X_name,
	            X_short_name,
                    X_chart_of_accounts_id,
                    X_currency_code,
                    X_period_set_name,
                    X_accounted_period_type,
 		    X_ret_earn_ccid,
                    X_suspense_allowed_flag,
                    X_allow_intercompany_post_flag,
		    X_enable_average_balances_flag,
		    X_enable_bc_flag,
                    X_require_budget_journals_flag,
                    X_enable_je_approval_flag,
		    X_enable_automatic_tax_flag,
                    X_consolidation_ledger_flag,
		    X_translate_eod_flag,
 		    X_translate_qatd_flag,
		    X_translate_yatd_flag,
                    X_automatically_created_flag,
		    X_track_rnd_imbalance_flag,
                    X_reconciliation_flag,
		    X_alc_ledger_type_code,
		    X_object_type_code,
		    X_le_ledger_type_code,
		    X_bal_seg_value_option_code,
		    X_bal_seg_column_name,
		    X_mgt_seg_value_option_code,
		    X_mgt_seg_column_name,
		    X_description,
                    X_latest_opened_period_name,
                    X_latest_encumbrance_year,
		    X_future_enterable_periods,
 		    X_cum_trans_ccid,
 		    X_res_encumb_ccid,
 		    X_net_income_ccid,
                    X_rounding_ccid,
		    X_transaction_calendar_id,
                    X_daily_translation_rate_type,
                    X_period_average_rate_type,
                    X_period_end_rate_type,
                    X_ledger_category_code;
    CLOSE gsi;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_message.set_name('SQLGL', 'GL_SHRD_INVALID_LEDGERID');
      fnd_message.set_token('LEDGERID', to_char(X_ledger_id), FALSE);
      app_exception.raise_exception;
    WHEN OTHERS THEN
      app_exception.raise_exception;

  END get_ledger_info;



  FUNCTION valid_bsv ( X_ledger_id IN NUMBER,
                       X_bsv       IN VARCHAR2,
                       X_edate     IN DATE) RETURN VARCHAR2 IS

    CURSOR has_all IS
      SELECT bal_seg_value_option_code
      FROM gl_ledgers
      WHERE ledger_id = X_ledger_id;

    CURSOR is_valid IS
      SELECT 'Valid'
      FROM   gl_ledger_segment_values
      WHERE  ledger_id = X_ledger_id
      AND    segment_type_code = 'B'
      AND    segment_value = X_bsv
      AND    (   (X_edate IS NULL)
              OR (trunc(X_edate) BETWEEN nvl(trunc(start_date), trunc(X_edate)-1)
                                 AND nvl(trunc(end_date), trunc(X_edate)+1)));

    Dummy          VARCHAR2(30);
    bsv_option     VARCHAR2(1);
  BEGIN
    OPEN has_all;
    FETCH has_all INTO bsv_option;
    CLOSE has_all;

    -- If all bsvs are allowed, then return Yes
    IF (nvl(bsv_option,'I') = 'A') THEN
      RETURN('Y');
    ELSE
      OPEN is_valid;
      FETCH is_valid INTO Dummy;
      IF is_valid%FOUND THEN
        CLOSE is_valid;
        RETURN('Y');
      ELSE
        CLOSE is_valid;
        RETURN('N');
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      app_exception.raise_exception;
  END valid_bsv;


  FUNCTION valid_msv ( X_ledger_id IN NUMBER,
                       X_msv       IN VARCHAR2,
                       X_edate     IN DATE) RETURN VARCHAR2 IS

    CURSOR has_all IS
      SELECT mgt_seg_value_option_code
      FROM gl_ledgers
      WHERE ledger_id = X_ledger_id;

    CURSOR is_valid IS
      SELECT 'Valid'
      FROM   gl_ledger_segment_values
      WHERE  ledger_id = X_ledger_id
      AND    segment_type_code = 'M'
      AND    segment_value = X_msv
      AND    (   (X_edate IS NULL)
              OR (trunc(X_edate) BETWEEN nvl(trunc(start_date), trunc(X_edate)-1)
                                 AND nvl(trunc(end_date), trunc(X_edate)+1)));

    Dummy          VARCHAR2(30);
    msv_option     VARCHAR2(1);
  BEGIN
    OPEN has_all;
    FETCH has_all INTO msv_option;
    CLOSE has_all;

    -- If all bsvs are allowed, then return Yes
    IF (nvl(msv_option,'I') = 'A') THEN
      RETURN('Y');
    ELSE
      OPEN is_valid;
      FETCH is_valid INTO Dummy;
      IF is_valid%FOUND THEN
        CLOSE is_valid;
        RETURN('Y');
      ELSE
        CLOSE is_valid;
        RETURN('N');
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      app_exception.raise_exception;
  END valid_msv;

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
			status		OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS
    industry VARCHAR2(1);
  BEGIN
    RETURN(fnd_installation.get(appl_id, dep_appl_id, status, industry));
  END install_info;

  PROCEDURE get_iea_info(x_subsidiary_id		   NUMBER,
			 x_name		    	    IN OUT NOCOPY VARCHAR2,
			 x_chart_of_accounts_id     IN OUT NOCOPY NUMBER,
			 x_ledger_id		    IN OUT NOCOPY NUMBER,
 			 x_enabled_flag	    	    IN OUT NOCOPY VARCHAR2,
			 x_subsidiary_type_code     IN OUT NOCOPY VARCHAR2,
                         x_company_value	    IN OUT NOCOPY VARCHAR2,
                         x_currency_code	    IN OUT NOCOPY VARCHAR2,
		         x_autoapprove_flag	    IN OUT NOCOPY VARCHAR2,
			 x_view_partner_lines_flag  IN OUT NOCOPY VARCHAR2,
			 x_conversion_type_code	    IN OUT NOCOPY VARCHAR2,
			 x_conversion_type	    IN OUT NOCOPY VARCHAR2,
			 x_remote_instance_flag	    IN OUT NOCOPY VARCHAR2,
			 x_transfer_ledger_id IN OUT NOCOPY NUMBER,
			 x_transfer_currency_code   IN OUT NOCOPY VARCHAR2,
			 x_contact		    IN OUT NOCOPY VARCHAR2,
			 x_notification_threshold   IN OUT NOCOPY NUMBER) IS
  BEGIN


  /* GL_IEA_SUBSIDIARY_PKG dropped in Ledger Architecture.
    gl_iea_subsidiary_pkg.select_columns(
      x_subsidiary_id,
      x_name,
      x_chart_of_accounts_id,
      x_ledger_id,
      x_enabled_flag,
      x_subsidiary_type_code,
      x_company_value,
      x_currency_code,
      x_autoapprove_flag,
      x_view_partner_lines_flag,
      x_conversion_type_code,
      x_conversion_type,
      x_remote_instance_flag,
      x_transfer_ledger_id,
      x_transfer_currency_code,
      x_contact,
      x_notification_threshold);
  */

  x_chart_of_accounts_id := NULL;

  END get_iea_info;

  PROCEDURE get_usage_info(
              x_average_balances_flag		IN OUT NOCOPY  VARCHAR2,
              x_consolidation_ledger_flag       IN OUT NOCOPY  VARCHAR2) IS
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
/*
     IF X_Subsidiary_Id IS NOT NULL THEN
           SELECT 'x' INTO dummy
           FROM gl_iea_subsidiaries
           WHERE  subsidiary_id = X_Subsidiary_Id
           AND    enabled_flag = 'Y';
     END IF;
*/

     return(FALSE);
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
          return(TRUE);
     WHEN OTHERS THEN
         fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
         fnd_message.set_token('PROCEDURE',
             'GL_FORMSINFO.iea_disabled_subsidiary');
         APP_EXCEPTION.Raise_Exception;
  END iea_disabled_subsidiary;

  FUNCTION get_industry_message(Message_Name           IN VARCHAR2,
                                Application_Shortname  IN VARCHAR2)
    RETURN VARCHAR2 IS
  BEGIN
    RETURN(gl_public_sector.get_message_name(Message_Name,
                                             Application_Shortname));
  END get_industry_message;

  FUNCTION session_id RETURN NUMBER IS
    sid NUMBER;
  BEGIN
    SELECT s.sid
    INTO sid
    FROM v$session s, v$process p
    WHERE s.paddr = p.addr
    AND   audsid = USERENV('SESSIONID');

    RETURN sid;
  END session_id;

  FUNCTION serial_id RETURN NUMBER IS
    sid NUMBER;
  BEGIN
    SELECT s.serial#
    INTO sid
    FROM v$session s, v$process p
    WHERE s.paddr = p.addr
    AND   audsid = USERENV('SESSIONID');

    RETURN sid;
  END serial_id;

END GL_FORMSINFO;

/
