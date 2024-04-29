--------------------------------------------------------
--  DDL for Package Body GLXJEENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GLXJEENT_PKG" as
/* $Header: glfjeenb.pls 120.8 2004/07/14 21:54:08 djogg ship $ */

  PROCEDURE cache_data(	acc_id                                  NUMBER,
                        default_ledger_id                       NUMBER,
			form_mode				VARCHAR2,
			default_je_source		IN OUT NOCOPY	VARCHAR2,
			user_default_je_source		IN OUT NOCOPY  VARCHAR2,
			journal_approval_flag       	IN OUT NOCOPY	VARCHAR2,
			default_je_category		IN OUT NOCOPY	VARCHAR2,
			user_default_je_category	IN OUT NOCOPY  VARCHAR2,
			default_rev_change_sign_flag	IN OUT NOCOPY	VARCHAR2,
                        default_reversal_period         IN OUT NOCOPY  VARCHAR2,
                        default_reversal_date           IN OUT NOCOPY  DATE,
                        default_reversal_start_date     IN OUT NOCOPY  DATE,
                        default_reversal_end_date       IN OUT NOCOPY  DATE,
			default_period_name		IN OUT NOCOPY  VARCHAR2,
			default_start_date		IN OUT NOCOPY  DATE,
			default_end_date		IN OUT NOCOPY  DATE,
		        default_eff_date		IN OUT NOCOPY  DATE,
			default_period_year		IN OUT NOCOPY	NUMBER,
			default_period_num		IN OUT NOCOPY 	NUMBER,
			default_conversion_type		IN OUT NOCOPY  VARCHAR2,
			user_default_conversion_type	IN OUT NOCOPY	VARCHAR2,
		        user_fixed_conversion_type      IN OUT NOCOPY  VARCHAR2,
			start_active_date		IN OUT NOCOPY  DATE,
		        end_active_date			IN OUT NOCOPY  DATE) IS

    period_status 		VARCHAR2(1);
    period_year                 NUMBER;
    period_num                  NUMBER;
    effective_date_rule_code 	VARCHAR2(1);
    frozen_source_flag		VARCHAR2(1);
    tax_precision		NUMBER;
    tax_mau			NUMBER;
    period_code                 VARCHAR2(30);
    date_code                   VARCHAR2(30);
    autorev_flag                VARCHAR2(1);
    autopst_flag                VARCHAR2(1);
    rev_code                    VARCHAR2(30);
  BEGIN

    -- Get the source information
    IF (form_mode = 'A') THEN
      default_je_source := 'Manual';
    ELSE
      default_je_source := 'Encumbrance';
    END IF;
    gl_je_sources_pkg.select_columns(default_je_source,
				     user_default_je_source,
				     effective_date_rule_code,
				     frozen_source_flag,
				     journal_approval_flag);

    -- Get the period information
    IF (    (form_mode IN ('A', 'E'))
        AND (default_ledger_id IS NOT NULL)) THEN
      default_period_name := gl_period_statuses_pkg.default_actual_period(
			       acc_id, default_ledger_id);
      IF (default_period_name IS NOT NULL) THEN
        gl_period_statuses_pkg.select_columns(
	  101,
	  default_ledger_id,
          default_period_name,
	  period_status,
	  default_start_date,
	  default_end_date,
	  default_period_num,
	  default_period_year);
      END IF;
    END IF;

    IF (default_period_name IS NOT NULL) THEN
      IF (trunc(sysdate) <= default_start_date) THEN
        default_eff_date := default_start_date;
      ELSIF (trunc(sysdate) >= default_end_date) THEN
        default_eff_date := default_end_date;
      ELSE
        default_eff_date := trunc(sysdate);
      END IF;
    END IF;

    -- Get the category information
    IF (default_je_category IS NOT NULL) THEN
      gl_je_categories_pkg.select_columns(default_je_category,
				          user_default_je_category);

      IF (    (default_period_name IS NOT NULL)
          AND (default_ledger_id IS NOT NULL)) THEN
       BEGIN
        gl_autoreverse_date_pkg.get_reversal_period_date(
          X_Ledger_Id => default_ledger_id,
          X_Je_Category => default_je_category,
          X_Je_Source => 'Manual',
          X_Je_Period_Name => default_period_name,
          X_Je_Date => default_eff_date,
          X_Reversal_Method => default_rev_change_sign_flag,
          X_Reversal_Period => default_reversal_period,
          X_Reversal_Date => default_reversal_date);

          IF (default_reversal_period IS NOT NULL) THEN
            gl_period_statuses_pkg.select_columns(
              x_application_id => 101,
              x_ledger_id => default_ledger_id,
              x_period_name => default_reversal_period,
              x_closing_status => period_status,
              x_start_date => default_reversal_start_date,
              x_end_date => default_reversal_end_date,
              x_period_num => period_num,
              x_period_year => period_year);
          END IF;
       EXCEPTION
         WHEN OTHERS THEN
           default_rev_change_sign_flag := '';
           default_reversal_period := 'FAILED DEFAULT';
           default_reversal_date := '';
           default_reversal_start_date := '';
           default_reversal_end_date := '';
       END;
      END IF;

      IF (    (default_rev_change_sign_flag IS NULL)
          AND (default_ledger_id IS NOT NULL)) THEN

	 gl_autoreverse_date_pkg.get_default_reversal_method(
	 	X_Ledger_Id     	=> default_ledger_id,
	 	X_Category_Name 	=> default_je_category,
         	X_Reversal_Method_Code => rev_code);
          default_rev_change_sign_flag := rev_code;

      END IF;
    END IF;

    -- Get the conversion type information
    default_conversion_type := 'User';
    gl_daily_conv_types_pkg.select_columns(
      default_conversion_type,
      user_default_conversion_type);

    -- Get the fixed conversion type information
    gl_daily_conv_types_pkg.select_columns(
      'EMU FIXED',
      user_fixed_conversion_type);

    -- Get the range of valid dates
    IF (default_ledger_id IS NOT NULL) THEN
      gl_period_statuses_pkg.get_journal_range(
        default_ledger_id,
        start_active_date,
        end_active_date);
    END IF;
  END cache_data;

  PROCEDURE get_period(x_lgr_id				NUMBER,
		       x_accounting_date		DATE,
		       x_period_name			IN OUT NOCOPY	VARCHAR2,
		       x_period_status			IN OUT NOCOPY  VARCHAR2,
                       x_start_date			IN OUT NOCOPY  DATE,
		       x_end_date			IN OUT NOCOPY  DATE) IS

    acct_cal_name	VARCHAR2(15);
    acc_period_type     VARCHAR2(15);

  BEGIN

    -- Get the ledger information
    SELECT period_set_name, accounted_period_type
    INTO   acct_cal_name, acc_period_type
    FROM   gl_ledgers
    WHERE  ledger_id = x_lgr_id;

    SELECT ps.period_name, ps.closing_status, ps.start_date, ps.end_date
    INTO   x_period_name, x_period_status, x_start_date, x_end_date
    FROM   gl_date_period_map map, gl_period_statuses ps
    WHERE  map.period_set_name = acct_cal_name
    AND    map.period_type = acc_period_type
    AND    map.accounting_date = x_accounting_date
    AND    ps.application_id = 101
    AND    ps.ledger_id = x_lgr_id
    AND    ps.period_name = map.period_name;

  END get_period;

  FUNCTION is_prior_period(x_period_name	VARCHAR2,
			   x_arg_type		VARCHAR2,
			   x_arg_id		NUMBER) RETURN BOOLEAN IS
    dummy NUMBER;
  BEGIN
    IF (x_arg_type = 'L') THEN
      BEGIN
        SELECT 1
        INTO dummy
        FROM gl_period_statuses ps1
        WHERE ps1.application_id = 101
        AND   ps1.ledger_id = x_arg_id
        AND   ps1.period_name = x_period_name
        AND EXISTS
          (SELECT 'later open'
           FROM gl_period_statuses ps2
           WHERE ps2.application_id = 101
           AND   ps2.ledger_id = ps1.ledger_id
           AND   ps2.effective_period_num > ps1.effective_period_num
           AND   ps2.closing_status IN ('O', 'C', 'P'));

        return(TRUE);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RETURN(FALSE);
      END;
    ELSE
      BEGIN
      SELECT 1
      INTO dummy
      FROM dual
      WHERE EXISTS
      (SELECT 'not latest'
       FROM gl_period_statuses ps1, gl_period_statuses ps2
       WHERE ps1.application_id = 101
       AND   ps1.ledger_id IN (SELECT ledger_id
                               FROM gl_je_headers
                               WHERE je_batch_id = x_arg_id)
       AND   ps1.period_name = x_period_name
       AND   ps2.application_id = 101
       AND   ps2.ledger_id = ps1.ledger_id
       AND   ps2.effective_period_num > ps1.effective_period_num
       AND   ps2.closing_status IN ('O', 'C', 'P'));

      return(TRUE);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RETURN(FALSE);
      END;
    END IF;
  END is_prior_period;

  FUNCTION default_still_good(x_access_set_id           NUMBER,
                              x_ledger_id       	NUMBER,
                              x_period_name		VARCHAR2,
			      x_average_journal_flag	VARCHAR2
                             ) RETURN VARCHAR2 IS
    dummy VARCHAR2(100);
  BEGIN
    SELECT 'default good'
    INTO dummy
    FROM  gl_ledgers lgr, gl_period_statuses ps, gl_access_set_ledgers acc
    WHERE lgr.ledger_id = x_ledger_id
    AND   (   (x_average_journal_flag = 'N')
           OR (lgr.consolidation_ledger_flag = 'Y'))
    AND   ps.application_id = 101
    AND   ps.ledger_id = lgr.ledger_id
    AND   ps.period_name = x_period_name
    AND   ps.closing_status IN ('O', 'F')
    AND   acc.access_set_id = x_access_set_id
    AND   acc.ledger_id = lgr.ledger_id
    AND   acc.access_privilege_code IN ('B', 'F')
    AND   ps.end_date between nvl(acc.start_date, ps.end_date-1)
                      and nvl(acc.end_date, ps.end_date+1);

    RETURN('Y');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN('N');
  END default_still_good;


  PROCEDURE default_actual_period(x_period_set_name		VARCHAR2,
			 	  x_period_type			VARCHAR2,
				  x_je_batch_id		 	NUMBER,
				  period_name IN OUT NOCOPY	VARCHAR2,
				  start_date IN OUT NOCOPY	DATE,
				  end_date IN OUT NOCOPY	DATE,
				  period_year IN OUT NOCOPY     NUMBER,
				  period_num IN OUT NOCOPY	NUMBER) IS
    CURSOR get_latest_opened IS
      SELECT period_name, start_date, end_date, period_year, period_num
      FROM   gl_periods per
      WHERE  period_set_name = x_period_set_name
      AND    period_type = x_period_type
      AND    NOT EXISTS
        (SELECT 'unopened ledger'
         FROM gl_je_headers jeh,
              gl_period_statuses ps
         WHERE jeh.je_batch_id = x_je_batch_id
         AND   (jeh.display_alc_journal_flag IS NULL
                or jeh.display_alc_journal_flag = 'Y')
         AND   ps.application_id = 101
         AND   ps.ledger_id = jeh.ledger_id
         AND   ps.period_name = per.period_name
         AND   ps.closing_status <> 'O')
      ORDER BY period_year * 10000 + period_num DESC;

    CURSOR get_earliest_future_ent IS
      SELECT period_name, start_date, end_date, period_year, period_num
      FROM   gl_periods per
      WHERE  period_set_name = x_period_set_name
      AND    period_type = x_period_type
      AND    NOT EXISTS
        (SELECT 'unopened ledger'
         FROM gl_je_headers jeh,
              gl_period_statuses ps
         WHERE jeh.je_batch_id = x_je_batch_id
         AND   (jeh.display_alc_journal_flag IS NULL
                or jeh.display_alc_journal_flag = 'Y')
         AND   ps.application_id = 101
         AND   ps.ledger_id = jeh.ledger_id
         AND   ps.period_name = per.period_name
         AND   ps.closing_status NOT IN ('O', 'F'))
      ORDER BY period_year * 10000 + period_num ASC;
    default_period VARCHAR2(15);
  BEGIN
    OPEN get_latest_opened;
    FETCH get_latest_opened INTO period_name, start_date, end_date,
 				 period_year, period_num;

    IF get_latest_opened%FOUND THEN
      CLOSE get_latest_opened;
      return;
    ELSE
      CLOSE get_latest_opened;

      OPEN get_earliest_future_ent;
      FETCH get_earliest_future_ent INTO period_name, start_date, end_date,
					 period_year, period_num;

      IF get_earliest_future_ent%FOUND THEN
        CLOSE get_earliest_future_ent;
        return;
      ELSE
        CLOSE get_earliest_future_ent;
        return;
      END IF;
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_period_statuses_pkg.default_actual_period');
      RAISE;
  END default_actual_period;

  PROCEDURE set_find_window_state(w_state		VARCHAR2) IS

  PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    -- set the profile option
    IF (fnd_profile.save_user('GL_MJE_FIND_WINDOW_STATE', w_state)) THEN
      NULL;
    END IF;

    COMMIT;
  END set_find_window_state;

END GLXJEENT_PKG;

/
