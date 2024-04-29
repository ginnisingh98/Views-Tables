--------------------------------------------------------
--  DDL for Package Body GL_JE_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_JE_HEADERS_PKG" as
/* $Header: glijhrvb.pls 120.22.12010000.2 2009/05/28 11:58:21 skotakar ship $ */

  PROCEDURE check_unique(batch_id NUMBER, header_name VARCHAR2,
                         row_id VARCHAR2) IS
    CURSOR chk_duplicates is
      SELECT 'Duplicate'
      FROM   GL_JE_HEADERS jeh
      WHERE  jeh.je_batch_id = batch_id
      AND    jeh.name = header_name
      AND    (   row_id is null
              OR jeh.rowid <> row_id);
    dummy VARCHAR2(100);
  BEGIN
    OPEN chk_duplicates;
    FETCH chk_duplicates INTO dummy;

    IF chk_duplicates%FOUND THEN
      CLOSE chk_duplicates;
      fnd_message.set_name('SQLGL', 'GL_DUPLICATE_JE_HEADER_NAME');
      app_exception.raise_exception;
    END IF;

    CLOSE chk_duplicates;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_je_headers_pkg.check_unique');
      RAISE;
  END check_unique;

  FUNCTION get_unique_id RETURN NUMBER IS
    CURSOR get_new_id IS
      SELECT gl_je_headers_s.NEXTVAL
      FROM dual;
    new_id number;
  BEGIN
    OPEN get_new_id;
    FETCH get_new_id INTO new_id;

    IF get_new_id%FOUND THEN
      CLOSE get_new_id;
      return(new_id);
    ELSE
      CLOSE get_new_id;
      fnd_message.set_name('SQLGL', 'GL_ERROR_GETTING_UNIQUE_ID');
      fnd_message.set_token('SEQUENCE', 'GL_JE_HEADERS_S');
      app_exception.raise_exception;
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_je_headers_pkg.get_unique_id');
      RAISE;
  END get_unique_id;

  PROCEDURE delete_headers(batch_id  NUMBER) IS
    dummy NUMBER;
  BEGIN
    -- Delete all of the lines in that batch
    DELETE gl_je_lines
    WHERE  je_header_id IN (SELECT je_header_id
                            FROM   gl_je_headers
                            WHERE  je_batch_id = batch_id);

    -- Delete all of the segment value assignments in that
    -- batch
    dummy := gl_je_segment_values_pkg.delete_batch_segment_values(batch_id);

    -- Delete all of the reconciliation lines
    DELETE gl_je_lines_recon
    WHERE  je_header_id IN (SELECT je_header_id
                            FROM   gl_je_headers
                            WHERE  je_batch_id = batch_id);

    -- Mark all of the reversals as no longer reversals, since the
    -- original journal has been deleted.  This is necessary to fix
    -- bug #1001521
    UPDATE gl_je_headers
    SET    reversed_je_header_id = null,
           accrual_rev_je_header_id = decode(accrual_rev_status,
                                        'R', accrual_rev_je_header_id,
                                        null)
    WHERE  je_header_id IN
      (SELECT accrual_rev_je_header_id
       FROM   gl_je_headers
       WHERE  je_batch_id = batch_id
       AND    accrual_rev_status = 'R');

    -- Bug fix 2749073 Mark the original journal as reversible
    -- incase if the reversed journal associated is deleted.
     UPDATE gl_je_headers
     SET    accrual_rev_status = null,
            accrual_rev_je_header_id = null,
            accrual_rev_flag = 'Y'
     WHERE  je_header_id IN
      (SELECT reversed_je_header_id
       FROM gl_je_headers
       WHERE je_batch_id = batch_id
       AND   reversed_je_header_id IS NOT NULL );

  --Delete the respective rows from GL_IMPORT_REFERENCES
  --Bug Fix :2894045
    GL_IMPORT_REFERENCES_PKG.delete_batch ( batch_id);


    -- Delete all of the headers in that batch
    DELETE gl_je_headers
    WHERE  je_batch_id = batch_id;


  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_je_headers_pkg.delete_headers');
      RAISE;
  END delete_headers;

  PROCEDURE change_effective_date(batch_id  		NUMBER,
				  new_effective_date 	DATE) IS
  BEGIN
    -- Update all of the lines in the header
    UPDATE gl_je_lines
    SET effective_date = new_effective_date
    WHERE  je_header_id IN (SELECT je_header_id
                            FROM   gl_je_headers
                            WHERE  je_batch_id = batch_id);

    -- Update all of the headers in that batch
    UPDATE gl_je_headers jeh
    SET default_effective_date = new_effective_date,
        currency_conversion_date =
          (select decode(jeh.currency_code,
                           'STAT', new_effective_date,
                           lgr.currency_code, new_effective_date,
                           jeh.currency_conversion_date)
           from gl_ledgers lgr
           where lgr.ledger_id = jeh.ledger_id),
        accrual_rev_effective_date
          = (select decode(jeh.accrual_rev_status,
                           null, ps.start_date,
                           jeh.accrual_rev_effective_date)
             from gl_period_statuses ps
             where ps.application_id = 101
             and ps.ledger_id = jeh.ledger_id
             and ps.period_name = jeh.accrual_rev_period_name)
    WHERE je_batch_id = batch_id;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_je_headers_pkg.change_effective_date');
      RAISE;
  END change_effective_date;

  PROCEDURE calculate_totals(	batch_id				NUMBER,
		      		running_total_dr		IN OUT NOCOPY	NUMBER,
		      		running_total_cr		IN OUT NOCOPY	NUMBER,
		      		running_total_accounted_dr	IN OUT NOCOPY	NUMBER,
		      		running_total_accounted_cr	IN OUT NOCOPY	NUMBER
                            ) IS
    CURSOR calc_totals is
      SELECT sum(nvl(jeh.running_total_dr, 0)),
             sum(nvl(jeh.running_total_cr, 0)),
             sum(nvl(jeh.running_total_accounted_dr, 0)),
             sum(nvl(jeh.running_total_accounted_cr, 0))
      FROM   GL_JE_HEADERS jeh
      WHERE  jeh.je_batch_id = batch_id
      AND    (jeh.display_alc_journal_flag is null or jeh.display_alc_journal_flag = 'Y');
  BEGIN
    OPEN calc_totals;
    FETCH calc_totals INTO running_total_dr, running_total_cr,
			   running_total_accounted_dr,
			   running_total_accounted_cr;

    IF calc_totals%NOTFOUND THEN
      CLOSE calc_totals;
      RAISE NO_DATA_FOUND;
    END IF;

    CLOSE calc_totals;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'gl_je_headers_pkg.calculate_totals');
      RAISE;
  END calculate_totals;


  FUNCTION change_period(batch_id        NUMBER,
                         period_name     VARCHAR2,
                         effective_date  DATE,
                         user_id         NUMBER,
                         login_id        NUMBER,
                         header_id       NUMBER     DEFAULT null,
                         currency_code   VARCHAR2   DEFAULT null,
                         conversion_date DATE       DEFAULT null,
                         conversion_type VARCHAR2   DEFAULT null,
                         conversion_rate NUMBER     DEFAULT null
                        ) RETURN NUMBER IS
    CURSOR convert_headers IS
      SELECT jeh.je_header_id, jeh.currency_code, jeh.actual_flag,
             jeh.currency_conversion_type, jeh.je_category,
             jeh.ledger_id, lgr.currency_code, jeh.reversed_je_header_id
      FROM   gl_je_headers jeh, gl_ledgers lgr
      WHERE  jeh.je_batch_id = batch_id
      AND    lgr.ledger_id = jeh.ledger_id
      ORDER BY jeh.name || to_char(jeh.ledger_id)
      FOR UPDATE OF jeh.default_effective_date, jeh.period_name,
                    jeh.last_update_date, jeh.last_updated_by,
                    jeh.last_update_login, jeh.running_total_accounted_dr,
                    jeh.running_total_accounted_cr,
                    jeh.currency_conversion_rate;

    CURSOR convert_header_range IS
      SELECT jeh.je_header_id, jeh.currency_code, jeh.actual_flag,
             jeh.currency_conversion_type, jeh.je_category,
             jeh.ledger_id, lgr.currency_code, jeh.reversed_je_header_id
      FROM   gl_je_headers jeh, gl_ledgers lgr
      WHERE  jeh.je_batch_id = batch_id
      AND    lgr.ledger_id = jeh.ledger_id
      AND    jeh.name > (SELECT name || to_char(ledger_id)
                         FROM   gl_je_headers
                         WHERE  je_header_id = header_id)
      ORDER BY jeh.name || to_char(jeh.ledger_id)
      FOR UPDATE OF jeh.default_effective_date, jeh.period_name,
                    jeh.last_update_date, jeh.last_updated_by,
                    jeh.last_update_login, jeh.running_total_accounted_dr,
                    jeh.running_total_accounted_cr,
                    jeh.currency_conversion_rate;

    -- Various information selected from the header
    cheader_id           GL_JE_HEADERS.JE_HEADER_ID%TYPE;
    ccurrency_code       GL_JE_HEADERS.CURRENCY_CODE%TYPE;
    cje_category         GL_JE_HEADERS.JE_CATEGORY%TYPE;
    cje_actual_flag      GL_JE_HEADERS.ACTUAL_FLAG%TYPE;
    cconversion_date     GL_JE_HEADERS.CURRENCY_CONVERSION_DATE%TYPE;
    cconversion_type     GL_JE_HEADERS.CURRENCY_CONVERSION_TYPE%TYPE;
    cconversion_rate     GL_JE_HEADERS.CURRENCY_CONVERSION_RATE%TYPE;
    crev_jeh_id          GL_JE_HEADERS.REVERSED_JE_HEADER_ID%TYPE;
    cledger_id		 NUMBER;
    cfunct_curr          VARCHAR2(15);

    -- Reversal information
    reversal_option_code   VARCHAR2(1);
    reversal_change_sign_flag   VARCHAR2(1);
    reversal_period        VARCHAR2(15);
    reversal_date          DATE;
    period_code            VARCHAR2(30);
    date_code              VARCHAR2(30);
    autorev_flag           VARCHAR2(1);
    autopst_flag           VARCHAR2(1);

    -- Indicates whether or not the current record being processed
    -- is a bad journal
    bad_journal          BOOLEAN := FALSE;

    -- Keep track of whether or not to clear statistical amounts
    clear_stat		 VARCHAR2(1) := 'N';

    -- Denominator and Numerator rate to use for fixed rate relationships
    denom_rate		 NUMBER;
    numer_rate		 NUMBER;
    tmp_rate		 NUMBER;

  BEGIN

    -- Check the parameters
    IF (header_id IS NOT NULL) THEN
      IF (currency_code IS NULL) THEN
        fnd_message.set_name('FND', 'FORM_INVALID_ARGUMENT');
        fnd_message.set_token('PROCEDURE', 'gl_je_headers_pkg.change_period');
        fnd_message.set_token('ARGUMENT', 'currency_code');
        fnd_message.set_token('VALUE', currency_code);
      ELSIF (conversion_date IS NULL) THEN
        fnd_message.set_name('FND', 'FORM_INVALID_ARGUMENT');
        fnd_message.set_token('PROCEDURE', 'gl_je_headers_pkg.change_period');
        fnd_message.set_token('ARGUMENT', 'conversion_date');
        fnd_message.set_token('VALUE', conversion_date);
      ELSIF (conversion_type IS NULL) THEN
        fnd_message.set_name('FND', 'FORM_INVALID_ARGUMENT');
        fnd_message.set_token('PROCEDURE', 'gl_je_headers_pkg.change_period');
        fnd_message.set_token('ARGUMENT', 'conversion_type');
        fnd_message.set_token('VALUE', conversion_type);
      ELSIF (conversion_rate IS NULL) THEN
        fnd_message.set_name('FND', 'FORM_INVALID_ARGUMENT');
        fnd_message.set_token('PROCEDURE', 'gl_je_headers_pkg.change_period');
        fnd_message.set_token('ARGUMENT', 'conversion_rate');
        fnd_message.set_token('VALUE', conversion_rate);
      END IF;
    END IF;

    -- Delete all the corrupted ALC journal lines and headers in this batch.
    DELETE FROM GL_JE_LINES
    WHERE je_header_id in
          (SELECT je_header_id
           FROM gl_je_headers
           WHERE je_batch_id = batch_id
           AND display_alc_journal_flag = 'N');

    DELETE FROM GL_JE_HEADERS
    WHERE je_batch_id = batch_id
    AND   display_alc_journal_flag = 'N';

    -- If data for an erroneous header has been passed, then process
    -- that header first, then all of the headers after that header.
    IF (header_id IS NOT NULL) THEN
      bad_journal      := TRUE;
      cheader_id       := header_id;
      ccurrency_code   := currency_code;
      cconversion_date := conversion_date;
      cconversion_type := conversion_type;
      cconversion_rate := conversion_rate;

      SELECT jeh.je_category, jeh.actual_flag, jeh.ledger_id,
             lgr.currency_code, jeh.reversed_je_header_id
      INTO cje_category, cje_actual_flag, cledger_id,
           cfunct_curr, crev_jeh_id
      FROM gl_je_headers jeh, gl_ledgers lgr
      WHERE jeh.je_header_id = header_id
      AND   lgr.ledger_id = jeh.ledger_id;

      -- If the user has just changed the currency to stat, then
      -- clear the statistical amounts
      IF (ccurrency_code = 'STAT') THEN
        clear_stat := 'Y';
      ELSE
	clear_stat := 'N';
      END IF;

      OPEN convert_header_range;

    -- Otherwise, process all of the headers
    ELSE
      bad_journal := FALSE;
      clear_stat := 'N';

      -- Get the headers to be processed
      OPEN convert_headers;
    END IF;

    LOOP
      -- Setup the data, if necessary.
      IF (NOT bad_journal) THEN

	-- Do not clear statistical amounts
	clear_stat := 'N';

        -- Get the data to process
        IF (header_id IS NULL) THEN
          FETCH convert_headers INTO cheader_id, ccurrency_code,
                                     cje_actual_flag,
                                     cconversion_type, cje_category,
                                     cledger_id, cfunct_curr,
                                     crev_jeh_id;
          EXIT WHEN convert_headers%NOTFOUND;
        ELSE
          FETCH convert_header_range INTO cheader_id, ccurrency_code,
                                          cje_actual_flag,
                                          cconversion_type, cje_category,
                                          cledger_id, cfunct_curr,
                                          crev_jeh_id;
          EXIT WHEN convert_header_range%NOTFOUND;
        END IF;

        -- Default the conversion date to the effective date
        cconversion_date := effective_date;

        IF (    (ccurrency_code <> 'STAT')
            AND (ccurrency_code <> cfunct_curr)
           ) THEN
          IF (gl_currency_api.is_fixed_rate(
                                ccurrency_code,
	                        cfunct_curr,
                                cconversion_date) = 'Y') THEN
            cconversion_type := 'EMU FIXED';
          END IF;
        END IF;
      END IF;

      -- Get the new reversal information
      reversal_option_code := null;
      reversal_change_sign_flag := null;
      reversal_period := null;
      reversal_date := null;
      IF ((cje_actual_flag = 'A') AND (crev_jeh_id IS NULL)) THEN
        BEGIN
          gl_autoreverse_date_pkg.get_reversal_period_date(
            X_Ledger_Id => cledger_id,
            X_Je_Category => cje_category,
            X_Je_Source => 'Manual',
            X_Je_Period_Name => period_name,
            X_Je_Date => effective_date,
            X_Reversal_Method => reversal_change_sign_flag,
            X_Reversal_Period => reversal_period,
            X_Reversal_Date => reversal_date);
        EXCEPTION
          WHEN OTHERS THEN
            null;
        END;
      END IF;

      IF (reversal_change_sign_flag IS NULL) THEN
      	gl_autoreverse_date_pkg.get_default_reversal_method(
	  X_Ledger_Id     	=> cledger_id,
	  X_Category_Name 	=> cje_category,
          X_Reversal_Method_Code => reversal_change_sign_flag);
      END IF;

      -- If the conversion type is User and this batch has not been
      -- processed previously then there is no need to update the
      -- conversion rate.  Just go ahead and update the period,
      -- effective date, and conversion date information.
      -- (If this batch has been processed previously,
      -- then it must originally have had a conversion type other than
      -- user, so we can assume the conversion rate has changed.)
      IF (    (cconversion_type = 'User')
          AND (NOT bad_journal)) THEN

        -- Update the period and effective date for the lines
        gl_je_lines_pkg.update_lines(
          cheader_id,
          period_name,
          effective_date,
          -1,
          -1,
          null,
	  null,
          'N',
	  clear_stat,
          user_id,
          login_id);

        -- Update the period, effective date, and conversion date for the
        -- header.
        UPDATE gl_je_headers jeh
        SET period_name = change_period.period_name,
            default_effective_date = effective_date,
            currency_conversion_date = cconversion_date,
            accrual_rev_period_name = decode(accrual_rev_status,
			                NULL, reversal_period,
				        accrual_rev_period_name),
            accrual_rev_flag = decode(accrual_rev_status,
			         NULL, decode(reversal_period,
                                         NULL, 'N', 'Y'),
				 accrual_rev_flag),
            accrual_rev_effective_date = decode(accrual_rev_status,
			                   NULL, reversal_date,
				           accrual_rev_effective_date),
            accrual_rev_change_sign_flag = decode(accrual_rev_status,
			                     NULL, reversal_change_sign_flag,
				             accrual_rev_change_sign_flag),
            last_update_date = sysdate,
            last_updated_by  = user_id,
            last_update_login = login_id
        WHERE jeh.je_header_id = cheader_id;

      -- Otherwise, we need to update the conversion rate as well as the
      -- period, effective date, and conversion date
      ELSE

        -- Get the conversion rate, if necessary.
        IF (NOT bad_journal) THEN
          BEGIN
	    cconversion_rate := 1;

            cconversion_rate := gl_currency_api.get_rate(
                                  ccurrency_code,
	                          cfunct_curr,
                                  cconversion_date,
                                  cconversion_type);
          EXCEPTION
            WHEN gl_currency_api.no_rate THEN
              -- Close the cursors
              IF (header_id IS NULL) THEN
                CLOSE convert_headers;
              ELSE
                CLOSE convert_header_range;
              END IF;

              RETURN(cheader_id);
          END;
        END IF;

        -- Update the period, effective date, and conversion rate for the lines
        IF (ccurrency_code = 'STAT') THEN
          -- For functional or STAT currency, ignore and clear the
          -- ignore rate flag
          gl_je_lines_pkg.update_lines(
            cheader_id,
            period_name,
            effective_date,
            1,
            cconversion_rate,
	    'STAT',
	    'STAT',
            'Y',
	    clear_stat,
            user_id,
            login_id);
        -- Update the period, effective date, and conversion rate for the lines
        ELSIF (ccurrency_code = cfunct_curr) THEN
          -- For functional or STAT currency, ignore and clear the
          -- ignore rate flag
          gl_je_lines_pkg.update_lines(
            cheader_id,
            period_name,
            effective_date,
            1,
            cconversion_rate,
	    cfunct_curr,
	    cfunct_curr,
            'Y',
	    clear_stat,
            user_id,
            login_id);
        ELSIF (cconversion_type = 'EMU FIXED') THEN
          -- If the rate is fixed,
          -- then ignore and clear any ignore
          -- rate flag.
          gl_currency_api.get_triangulation_rate(
            x_from_currency => ccurrency_code,
            x_to_currency => cfunct_curr,
            x_conversion_date => cconversion_date,
            x_conversion_type => cconversion_type,
            x_denominator => denom_rate,
            x_numerator => numer_rate,
            x_rate => tmp_rate);

          gl_je_lines_pkg.update_lines(
            cheader_id,
            period_name,
            effective_date,
            denom_rate,
            numer_rate,
	    ccurrency_code,
	    cfunct_curr,
            'Y',
	    clear_stat,
            user_id,
            login_id);
        ELSE
          -- For other currencies, do not update the amounts of lines
          -- with the conversion rate flag set.
          gl_je_lines_pkg.update_lines(
            cheader_id,
            period_name,
            effective_date,
            1,
            cconversion_rate,
	    ccurrency_code,
	    cfunct_curr,
            'N',
	    clear_stat,
            user_id,
            login_id);
        END IF;

        -- Update the period, effective date, conversion date, and
        -- accounted running totals for the header.
        UPDATE gl_je_headers jeh
        SET (running_total_dr, running_total_cr,
             running_total_accounted_dr, running_total_accounted_cr,
             period_name, default_effective_date,
             currency_code, currency_conversion_date,
             currency_conversion_type, currency_conversion_rate,
             last_update_date, last_updated_by, last_update_login)
          = (SELECT sum(nvl(jel.entered_dr, 0)),
                    sum(nvl(jel.entered_cr, 0)),
                    sum(nvl(jel.accounted_dr, 0)),
                    sum(nvl(jel.accounted_cr, 0)),
                    change_period.period_name, change_period.effective_date,
                    ccurrency_code, cconversion_date,
                    cconversion_type, cconversion_rate,
                    sysdate, user_id, login_id
             FROM   gl_je_lines jel
             WHERE  jel.je_header_id = jeh.je_header_id),
          accrual_rev_period_name = decode(accrual_rev_status,
			              NULL, reversal_period,
				      accrual_rev_period_name),
          accrual_rev_flag = decode(accrual_rev_status,
			       NULL, decode(reversal_period,
                                       NULL, 'N', 'Y'),
			       accrual_rev_flag),
          accrual_rev_effective_date = decode(accrual_rev_status,
			                 NULL, reversal_date,
				         accrual_rev_effective_date),
          accrual_rev_change_sign_flag = decode(accrual_rev_status,
			                   NULL, reversal_change_sign_flag,
				           accrual_rev_change_sign_flag)
        WHERE jeh.je_header_id = cheader_id;
      END IF;

      -- We have already processed the first bad journal by this point
      bad_journal := FALSE;
    END LOOP;

    -- Close the cursors
    IF (header_id IS NULL) THEN
      CLOSE convert_headers;
    ELSE
      CLOSE convert_header_range;
    END IF;

    -- All the journals were completed, so return -1 to indicate
    -- success
    RETURN(-1);
  END change_period;


  FUNCTION max_effective_date(batch_id          NUMBER) RETURN DATE IS
    CURSOR get_date IS
      SELECT max(default_effective_date)
      FROM   gl_je_headers jeh
      WHERE  jeh.je_batch_id = batch_id
      AND    (jeh.display_alc_journal_flag is null or jeh.display_alc_journal_flag = 'Y')
      AND    jeh.accrual_rev_status IS NULL;
    max_effective_date DATE;
  BEGIN

    OPEN get_date;

    FETCH get_date INTO max_effective_date;

    IF (get_date%NOTFOUND) THEN
      CLOSE get_date;
      RAISE NO_DATA_FOUND;
    ELSE
      CLOSE get_date;
      RETURN(max_effective_date);
    END IF;
  END max_effective_date;


  FUNCTION needs_tax(batch_id          NUMBER) RETURN BOOLEAN IS
    CURSOR check_tax IS
      SELECT max(decode(jeh.tax_status_code, 'R', 1, 0))
      FROM   gl_je_headers jeh
      WHERE  jeh.je_batch_id = batch_id;
    dummy  NUMBER;
  BEGIN

    OPEN check_tax;

    FETCH check_tax INTO dummy;

    IF (check_tax%NOTFOUND) THEN
      dummy := 0;
    END IF;

    IF (nvl(dummy, 0) = 0) THEN
      RETURN(FALSE);
    ELSE
      RETURN(TRUE);
    END IF;
  END needs_tax;


  FUNCTION has_seqnum(batch_id          NUMBER) RETURN BOOLEAN IS
    CURSOR check_seqnum IS
      SELECT 1
      FROM   dual
      WHERE  EXISTS (
        SELECT 'has seqnum'
        FROM   gl_je_headers jeh
        WHERE  jeh.je_batch_id = batch_id
        AND    jeh.doc_sequence_value IS NOT NULL);
    dummy  NUMBER;
  BEGIN

    OPEN check_seqnum;

    FETCH check_seqnum INTO dummy;

    IF (check_seqnum%NOTFOUND) THEN
      dummy := 0;
    END IF;

    CLOSE check_seqnum;

    IF (nvl(dummy, 0) = 0) THEN
      RETURN(FALSE);
    ELSE
      RETURN(TRUE);
    END IF;
  END has_seqnum;


  PROCEDURE populate_fields(ledger_id				NUMBER,
			    ledger_name			IN OUT NOCOPY  VARCHAR2,
			    je_source_name		      	VARCHAR2,
			    user_je_source_name		IN OUT NOCOPY  VARCHAR2,
                            frozen_source_flag		IN OUT NOCOPY	VARCHAR2,
			    je_category_name			VARCHAR2,
			    user_je_category_name	IN OUT NOCOPY  VARCHAR2,
			    period_name				VARCHAR2,
			    start_date			IN OUT NOCOPY  DATE,
			    end_date			IN OUT NOCOPY  DATE,
			    period_year			IN OUT NOCOPY	NUMBER,
			    period_num			IN OUT NOCOPY 	NUMBER,
			    currency_conversion_type		VARCHAR2,
			    user_currency_conv_type	IN OUT NOCOPY	VARCHAR2,
			    budget_version_id			NUMBER,
			    budget_name			IN OUT NOCOPY  VARCHAR2,
			    encumbrance_type_id			NUMBER,
			    encumbrance_type		IN OUT NOCOPY  VARCHAR2,
			    accrual_rev_period_name		VARCHAR2,
			    accrual_rev_start_date	IN OUT NOCOPY  DATE,
			    accrual_rev_end_date	IN OUT NOCOPY  DATE,
			    posting_acct_seq_version_id		NUMBER,
			    posting_acct_seq_name	IN OUT NOCOPY  VARCHAR2,
			    close_acct_seq_version_id		NUMBER,
			    close_acct_seq_name	IN OUT NOCOPY  VARCHAR2,
			    error_name			IN OUT NOCOPY  VARCHAR2) IS
    closing_status VARCHAR2(1);
    invalid_item   VARCHAR2(30) := '';

    tmp_closing_status 		VARCHAR2(1);
    tmp_period_year    		NUMBER;
    tmp_period_num    	 	NUMBER;
    effective_date_rule_code 	VARCHAR2(1);
    journal_approval_flag       VARCHAR2(1);
    tax_precision		NUMBER;
    tax_mau			NUMBER;
  BEGIN
    error_name := '';

    -- Get the ledger information
    BEGIN
      gl_ledgers_pkg.select_columns(
        ledger_id,
  	ledger_name);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	invalid_item := 'LEDGER';
    END;

     -- Get the source information
    BEGIN
      gl_je_sources_pkg.select_columns(
        je_source_name,
        user_je_source_name,
        effective_date_rule_code,
	frozen_source_flag,
        journal_approval_flag);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	invalid_item := 'SOURCE';
    END;

    -- Get the category information
    BEGIN
      gl_je_categories_pkg.select_columns(
        je_category_name,
        user_je_category_name);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	invalid_item := 'CATEGORY';
    END;

    -- Get the period information
    BEGIN
      gl_period_statuses_pkg.select_columns(
        101,
        ledger_id,
        period_name,
        closing_status,
        start_date,
        end_date,
        period_num,
        period_year);

      IF (closing_status IS NULL) THEN
        invalid_item := 'PERIOD';
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	invalid_item := 'PERIOD';
    END;

    -- Get the reversing period information
    IF (accrual_rev_period_name IS NOT NULL) THEN
      BEGIN
        gl_period_statuses_pkg.select_columns(
          101,
          ledger_id,
          accrual_rev_period_name,
          tmp_closing_status,
          accrual_rev_start_date,
          accrual_rev_end_date,
          tmp_period_num,
          tmp_period_year);

        IF (tmp_closing_status IS NULL) THEN
          invalid_item := 'REVPERIOD';
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
	  invalid_item := 'REVPERIOD';
      END;
    END IF;
    -- Get the conversion type information
    BEGIN
      gl_daily_conv_types_pkg.select_columns(
        currency_conversion_type,
        user_currency_conv_type);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
	invalid_item := 'CONVERSION_TYPE';
    END;

    -- Get the budget information
    IF (budget_version_id IS NOT NULL) THEN
      BEGIN
        gl_budget_versions_pkg.select_columns(
          budget_version_id,
          budget_name);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
	  invalid_item := 'BUDGET';
      END;

      IF (budget_name IS NULL) THEN
        invalid_item := 'BUDGET';
      END IF;
    END IF;

    -- Get the encumbrance information
    IF (encumbrance_type_id IS NOT NULL) THEN
      BEGIN
        gl_encumbrance_types_pkg.select_columns(
          encumbrance_type_id,
          encumbrance_type);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
 	  invalid_item := 'ENCUMBRANCE';
      END;

      IF (encumbrance_type IS NULL) THEN
        invalid_item := 'ENCUMBRANCE';
      END IF;
    END IF;

    -- Get the sequence information
    IF (posting_acct_seq_version_id IS NOT NULL) THEN
    BEGIN
      SELECT header_name || ':' || version_name
      INTO posting_acct_seq_name
      FROM fun_seq_versions
      WHERE seq_version_id = posting_acct_seq_version_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;
    END IF;

    -- Get the sequence information
    IF (close_acct_seq_version_id IS NOT NULL) THEN
    BEGIN
      SELECT header_name || ':' || version_name
      INTO close_acct_seq_name
      FROM fun_seq_versions
      WHERE seq_version_id = close_acct_seq_version_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN NULL;
    END;
    END IF;

    IF (invalid_item IS NOT NULL) THEN
      error_name := 'GL_JE_INVALID_' || invalid_item;
    END IF;

  END populate_fields;

PROCEDURE Insert_Row(X_Rowid                        IN OUT NOCOPY VARCHAR2,
                     X_Je_Header_Id                        IN OUT NOCOPY NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Ledger_Id                     	   NUMBER,
                     X_Je_Category                         VARCHAR2,
                     X_Je_Source                           VARCHAR2,
                     X_Period_Name                         VARCHAR2,
                     X_Name                                VARCHAR2,
                     X_Currency_Code                       VARCHAR2,
                     X_Status                              VARCHAR2,
                     X_Date_Created                        DATE,
                     X_Accrual_Rev_Flag                    VARCHAR2,
                     X_Multi_Bal_Seg_Flag                  VARCHAR2,
                     X_Actual_Flag                         VARCHAR2,
                     X_Default_Effective_Date              DATE,
                     X_Conversion_Flag                     VARCHAR2,
                     X_Creation_Date                       DATE,
                     X_Created_By                          NUMBER,
                     X_Last_Update_Login                   NUMBER,
                     X_Encumbrance_Type_Id                 NUMBER,
                     X_Budget_Version_Id                   NUMBER,
                     X_Balanced_Je_Flag                    VARCHAR2,
                     X_Balancing_Segment_Value             VARCHAR2,
                     X_Je_Batch_Id                         IN OUT NOCOPY NUMBER,
                     X_From_Recurring_Header_Id            NUMBER,
                     X_Unique_Date                         VARCHAR2,
                     X_Earliest_Postable_Date              DATE,
                     X_Posted_Date                         DATE,
                     X_Accrual_Rev_Effective_Date          DATE,
                     X_Accrual_Rev_Period_Name             VARCHAR2,
                     X_Accrual_Rev_Status                  VARCHAR2,
                     X_Accrual_Rev_Je_Header_Id            NUMBER,
                     X_Accrual_Rev_Change_Sign_Flag        VARCHAR2,
                     X_Description                         VARCHAR2,
		     X_Tax_Status_Code			   VARCHAR2,
                     X_Control_Total                       NUMBER,
                     X_Running_Total_Dr                    NUMBER,
                     X_Running_Total_Cr                    NUMBER,
                     X_Running_Total_Accounted_Dr          NUMBER,
                     X_Running_Total_Accounted_Cr          NUMBER,
                     X_Currency_Conversion_Rate            NUMBER,
                     X_Currency_Conversion_Type            VARCHAR2,
                     X_Currency_Conversion_Date            DATE,
                     X_External_Reference                  VARCHAR2,
                     X_Originating_Bal_Seg_Value           VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Context                             VARCHAR2,
		     X_Global_Attribute1                   VARCHAR2,
		     X_Global_Attribute2                   VARCHAR2,
		     X_Global_Attribute3                   VARCHAR2,
		     X_Global_Attribute4                   VARCHAR2,
		     X_Global_Attribute5                   VARCHAR2,
		     X_Global_Attribute6                   VARCHAR2,
		     X_Global_Attribute7                   VARCHAR2,
		     X_Global_Attribute8                   VARCHAR2,
		     X_Global_Attribute9                   VARCHAR2,
		     X_Global_Attribute10                  VARCHAR2,
		     X_Global_Attribute_Category           VARCHAR2,
                     X_Ussgl_Transaction_Code              VARCHAR2,
                     X_Context2                            VARCHAR2,
                     X_Doc_Sequence_Id                     NUMBER,
                     X_Doc_Sequence_Value                  NUMBER,
		     X_Header_Mode			   VARCHAR2,
		     X_Batch_Row_Id			   IN OUT NOCOPY VARCHAR2,
		     X_Batch_Name			   VARCHAR2,
                     X_Chart_of_Accounts_ID		   NUMBER,
		     X_Period_Set_Name		           VARCHAR2,
		     X_Accounted_Period_Type		   VARCHAR2,
		     X_Batch_Status			   VARCHAR2,
		     X_Status_Verified			   VARCHAR2,
		     X_Batch_Default_Effective_Date	   DATE,
		     X_Batch_Posted_Date		   DATE,
		     X_Batch_Date_Created		   DATE,
		     X_Budgetary_Control_Status		   VARCHAR2,
                     X_Approval_Status_Code                VARCHAR2,
		     X_Batch_Control_Total		   IN OUT NOCOPY NUMBER,
		     X_Batch_Running_Total_Dr	           IN OUT NOCOPY NUMBER,
		     X_Batch_Running_Total_Cr	           IN OUT NOCOPY NUMBER,
                     X_Average_Journal_Flag		   VARCHAR2,
                     X_Org_Id                              NUMBER,
		     X_Posting_Run_Id			   NUMBER,
		     X_Request_Id			   NUMBER,
		     X_Packet_Id			   NUMBER,
		     X_Unreservation_Packet_Id		   NUMBER,
		     X_Jgzz_Recon_Context                  VARCHAR2,
                     X_Jgzz_Recon_Ref                      VARCHAR2,
                     X_Reference_Date                      DATE
 ) IS
   CURSOR C IS SELECT rowid FROM GL_JE_HEADERS

             WHERE je_header_id = X_Je_Header_Id;
   has_line VARCHAR2(1);
BEGIN

  -- Make sure all journals have at least one line.
  has_line := 'N';
  IF (X_Je_Header_Id IS NOT NULL) THEN
  BEGIN
    SELECT 'Y'
    INTO has_line
    FROM gl_je_lines
    WHERE je_header_id = X_Je_Header_Id
    AND rownum = 1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      has_line := 'N';
  END;
  END IF;

  IF (has_line = 'N') THEN
    fnd_message.set_name('SQLGL', 'GL_JE_JOURNAL_W_NO_LINES');
    app_exception.raise_exception;
  END IF;

  IF (X_Je_Batch_Id IS NULL) THEN
    X_Je_Batch_Id := gl_je_batches_pkg.get_unique_id;
  END IF;

  INSERT INTO GL_JE_HEADERS(
          je_header_id,
          last_update_date,
          last_updated_by,
          ledger_id,
          je_category,
          je_source,
          period_name,
          name,
          currency_code,
          status,
          date_created,
          accrual_rev_flag,
          multi_bal_seg_flag,
          actual_flag,
          default_effective_date,
          conversion_flag,
          creation_date,
          created_by,
          last_update_login,
          encumbrance_type_id,
          budget_version_id,
          balanced_je_flag,
          balancing_segment_value,
          je_batch_id,
          from_recurring_header_id,
          unique_date,
          earliest_postable_date,
          posted_date,
          accrual_rev_effective_date,
          accrual_rev_period_name,
          accrual_rev_status,
          accrual_rev_je_header_id,
          accrual_rev_change_sign_flag,
          description,
	  tax_status_code,
          control_total,
          running_total_dr,
          running_total_cr,
          running_total_accounted_dr,
          running_total_accounted_cr,
          currency_conversion_rate,
          currency_conversion_type,
          currency_conversion_date,
          external_reference,
          originating_bal_seg_value,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          context,
          global_attribute1,
          global_attribute2,
          global_attribute3,
          global_attribute4,
          global_attribute5,
          global_attribute6,
          global_attribute7,
          global_attribute8,
          global_attribute9,
          global_attribute10,
          global_attribute_category,
          ussgl_transaction_code,
          context2,
          doc_sequence_id,
          doc_sequence_value,
          jgzz_recon_context,
          jgzz_recon_ref,
          reference_date
         ) VALUES (
          X_Je_Header_Id,
          X_Last_Update_Date,
          X_Last_Updated_By,
          X_Ledger_Id,
          X_Je_Category,
          X_Je_Source,
          X_Period_Name,
          X_Name,
          X_Currency_Code,
          X_Status,
          X_Date_Created,
          X_Accrual_Rev_Flag,
          X_Multi_Bal_Seg_Flag,
          X_Actual_Flag,
          X_Default_Effective_Date,
          X_Conversion_Flag,
          X_Creation_Date,
          X_Created_By,
          X_Last_Update_Login,
          X_Encumbrance_Type_Id,
          X_Budget_Version_Id,
          X_Balanced_Je_Flag,
          X_Balancing_Segment_Value,
          X_Je_Batch_Id,
          X_From_Recurring_Header_Id,
          X_Unique_Date,
          X_Earliest_Postable_Date,
          X_Posted_Date,
          X_Accrual_Rev_Effective_Date,
          X_Accrual_Rev_Period_Name,
          X_Accrual_Rev_Status,
          X_Accrual_Rev_Je_Header_Id,
          X_Accrual_Rev_Change_Sign_Flag,
          X_Description,
	  X_Tax_Status_Code,
          X_Control_Total,
          X_Running_Total_Dr,
          X_Running_Total_Cr,
          X_Running_Total_Accounted_Dr,
          X_Running_Total_Accounted_Cr,
          X_Currency_Conversion_Rate,
          X_Currency_Conversion_Type,
          X_Currency_Conversion_Date,
          X_External_Reference,
          X_Originating_Bal_Seg_Value,
          X_Attribute1,
          X_Attribute2,
          X_Attribute3,
          X_Attribute4,
          X_Attribute5,
          X_Attribute6,
          X_Attribute7,
          X_Attribute8,
          X_Attribute9,
          X_Attribute10,
          X_Context,
          X_Global_Attribute1,
          X_Global_Attribute2,
          X_Global_Attribute3,
          X_Global_Attribute4,
          X_Global_Attribute5,
          X_Global_Attribute6,
          X_Global_Attribute7,
          X_Global_Attribute8,
          X_Global_Attribute9,
          X_Global_Attribute10,
          X_Global_Attribute_Category,
          X_Ussgl_Transaction_Code,
          X_Context2,
          X_Doc_Sequence_Id,
          X_Doc_Sequence_Value,
          X_Jgzz_Recon_Context,
          X_Jgzz_Recon_Ref,
          X_Reference_Date

  );

  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;

  -- If we are in header mode, insert the batch
  IF (X_Header_Mode = 'Y') THEN

    -- Return the correct values for the batch totals
    X_Batch_Control_Total    := null;
    X_Batch_Running_Total_Dr := X_Running_Total_Dr;
    X_Batch_Running_Total_Cr := X_Running_Total_Cr;

    GL_JE_BATCHES_PKG.Insert_Row(
        X_Rowid                => X_Batch_Row_Id,
        X_Je_Batch_Id          => X_Je_Batch_Id,
        X_Name                 => X_Batch_Name,
        X_Chart_of_Accounts_Id => X_Chart_of_Accounts_Id,
        X_Period_Set_Name      => X_Period_Set_Name,
	X_Accounted_Period_Type => X_Accounted_Period_Type,
        X_Status               => X_Batch_Status,
        X_Budgetary_Control_Status=>
          X_Budgetary_Control_Status,
        X_Approval_Status_Code => X_Approval_Status_Code,
        X_Status_Verified      => X_Status_Verified,
        X_Actual_Flag          => X_Actual_Flag,
        X_Default_Period_Name  => X_Period_Name,
        X_Default_Effective_Date=>
          X_Batch_Default_Effective_Date,
        X_Posted_Date          => X_Batch_Posted_Date,
        X_Date_Created         =>
          X_Batch_Date_Created,
        X_Control_Total	       => X_Batch_Control_Total,
	X_Running_Total_Dr     => X_Batch_Running_Total_Dr,
	X_Running_Total_Cr     => X_Batch_Running_Total_Cr,
	X_Running_Total_Accounted_Dr =>
	  X_Running_Total_Accounted_Dr,
	X_Running_Total_Accounted_Cr =>
	  X_Running_Total_Accounted_Cr,
        X_Average_Journal_Flag => X_Average_Journal_Flag,
        X_Org_Id               => X_Org_Id,
        X_Posting_Run_Id       => X_Posting_Run_Id,
        X_Request_Id           => X_Request_Id,
        X_Packet_Id            => X_Packet_Id,
        X_Unreservation_Packet_Id=>
          X_Unreservation_Packet_Id,
        X_Creation_Date        => X_Creation_Date,
        X_Created_By           => X_Created_By,
        X_Last_Update_Date     => X_Last_Update_Date,
        X_Last_Updated_By      => X_Last_Updated_By,
        X_Last_Update_Login    => X_Last_Update_Login);
  END IF;
END Insert_Row;


PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,

                   X_Je_Header_Id                          NUMBER,
                   X_Ledger_Id                             NUMBER,
                   X_Je_Category                           VARCHAR2,
                   X_Je_Source                             VARCHAR2,
                   X_Period_Name                           VARCHAR2,
                   X_Name                                  VARCHAR2,
                   X_Currency_Code                         VARCHAR2,
                   X_Status                                VARCHAR2,
                   X_Date_Created                          DATE,
                   X_Accrual_Rev_Flag                      VARCHAR2,
                   X_Multi_Bal_Seg_Flag                    VARCHAR2,
                   X_Actual_Flag                           VARCHAR2,
                   X_Default_Effective_Date                DATE,
                   X_Conversion_Flag                       VARCHAR2,
                   X_Encumbrance_Type_Id                   NUMBER,
                   X_Budget_Version_Id                     NUMBER,
                   X_Balanced_Je_Flag                      VARCHAR2,
                   X_Balancing_Segment_Value               VARCHAR2,
                   X_Je_Batch_Id                           NUMBER,
                   X_From_Recurring_Header_Id              NUMBER,
                   X_Unique_Date                           VARCHAR2,
                   X_Earliest_Postable_Date                DATE,
                   X_Posted_Date                           DATE,
                   X_Accrual_Rev_Effective_Date            DATE,
                   X_Accrual_Rev_Period_Name               VARCHAR2,
                   X_Accrual_Rev_Status                    VARCHAR2,
                   X_Accrual_Rev_Je_Header_Id              NUMBER,
                   X_Accrual_Rev_Change_Sign_Flag          VARCHAR2,
                   X_Description                           VARCHAR2,
		   X_Tax_Status_Code		    	   VARCHAR2,
                   X_Control_Total                         NUMBER,
                   X_Running_Total_Dr                      NUMBER,
                   X_Running_Total_Cr                      NUMBER,
                   X_Running_Total_Accounted_Dr            NUMBER,
                   X_Running_Total_Accounted_Cr            NUMBER,
                   X_Currency_Conversion_Rate              NUMBER,
                   X_Currency_Conversion_Type              VARCHAR2,
                   X_Currency_Conversion_Date              DATE,
                   X_External_Reference                    VARCHAR2,
                   X_Attribute1                            VARCHAR2,
                   X_Attribute2                            VARCHAR2,
                   X_Attribute3                            VARCHAR2,
                   X_Attribute4                            VARCHAR2,
                   X_Attribute5                            VARCHAR2,
                   X_Attribute6                            VARCHAR2,
                   X_Attribute7                            VARCHAR2,
                   X_Attribute8                            VARCHAR2,
                   X_Attribute9                            VARCHAR2,
                   X_Attribute10                           VARCHAR2,
                   X_Context                               VARCHAR2,
                   X_Ussgl_Transaction_Code                VARCHAR2,
                   X_Context2                              VARCHAR2,
                   X_Doc_Sequence_Id                       NUMBER,
                   X_Doc_Sequence_Value                    NUMBER
) IS
  CURSOR C IS
      SELECT *
      FROM   GL_JE_HEADERS
      WHERE  rowid = X_Rowid
      FOR UPDATE of Je_Header_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN

  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
  CLOSE C;
  if (
          (   (Recinfo.je_header_id = X_Je_Header_Id)
           OR (    (Recinfo.je_header_id IS NULL)
               AND (X_Je_Header_Id IS NULL)))
      AND (   (Recinfo.ledger_id = X_Ledger_Id)
           OR (    (Recinfo.ledger_id IS NULL)
               AND (X_Ledger_Id IS NULL)))
      AND (   (Recinfo.je_category = X_Je_Category)
           OR (    (Recinfo.je_category IS NULL)
               AND (X_Je_Category IS NULL)))
      AND (   (Recinfo.je_source = X_Je_Source)
           OR (    (Recinfo.je_source IS NULL)
               AND (X_Je_Source IS NULL)))
      AND (   (Recinfo.period_name = X_Period_Name)
           OR (    (Recinfo.period_name IS NULL)
               AND (X_Period_Name IS NULL)))
      AND (   (Recinfo.name = X_Name)
           OR (    (Recinfo.name IS NULL)
               AND (X_Name IS NULL)))
      AND (   (Recinfo.currency_code = X_Currency_Code)
           OR (    (Recinfo.currency_code IS NULL)
               AND (X_Currency_Code IS NULL)))
      AND (   (Recinfo.status = X_Status)
           OR (    (Recinfo.status IS NULL)
               AND (X_Status IS NULL)))
      AND (   (trunc(Recinfo.date_created) = trunc(X_Date_Created))
           OR (    (Recinfo.date_created IS NULL)
               AND (X_Date_Created IS NULL)))
      AND (   (Recinfo.accrual_rev_flag = X_Accrual_Rev_Flag)
           OR (    (Recinfo.accrual_rev_flag IS NULL)
               AND (X_Accrual_Rev_Flag IS NULL)))
      AND (   (Recinfo.multi_bal_seg_flag = X_Multi_Bal_Seg_Flag)
           OR (    (Recinfo.multi_bal_seg_flag IS NULL)
               AND (X_Multi_Bal_Seg_Flag IS NULL)))
      AND (   (Recinfo.actual_flag = X_Actual_Flag)
           OR (    (Recinfo.actual_flag IS NULL)
               AND (X_Actual_Flag IS NULL)))
      AND (   (Recinfo.default_effective_date = X_Default_Effective_Date)
           OR (    (Recinfo.default_effective_date IS NULL)
               AND (X_Default_Effective_Date IS NULL)))
      AND (   (Recinfo.conversion_flag = X_Conversion_Flag)
           OR (    (Recinfo.conversion_flag IS NULL)
               AND (X_Conversion_Flag IS NULL)))
      AND (   (Recinfo.encumbrance_type_id = X_Encumbrance_Type_Id)
           OR (    (Recinfo.encumbrance_type_id IS NULL)
               AND (X_Encumbrance_Type_Id IS NULL)))
      AND (   (Recinfo.budget_version_id = X_Budget_Version_Id)
           OR (    (Recinfo.budget_version_id IS NULL)
               AND (X_Budget_Version_Id IS NULL)))
      AND (   (Recinfo.balanced_je_flag = X_Balanced_Je_Flag)
           OR (    (Recinfo.balanced_je_flag IS NULL)
               AND (X_Balanced_Je_Flag IS NULL)))
      AND (   (Recinfo.balancing_segment_value = X_Balancing_Segment_Value)
           OR (    (Recinfo.balancing_segment_value IS NULL)
               AND (X_Balancing_Segment_Value IS NULL)))
      AND (   (Recinfo.je_batch_id = X_Je_Batch_Id)
           OR (    (Recinfo.je_batch_id IS NULL)
               AND (X_Je_Batch_Id IS NULL)))
      AND (   (Recinfo.from_recurring_header_id = X_From_Recurring_Header_Id)
           OR (    (Recinfo.from_recurring_header_id IS NULL)
               AND (X_From_Recurring_Header_Id IS NULL)))
      AND (   (Recinfo.unique_date = X_Unique_Date)
           OR (    (Recinfo.unique_date IS NULL)
               AND (X_Unique_Date IS NULL)))
      AND (   (Recinfo.earliest_postable_date = X_Earliest_Postable_Date)
           OR (    (Recinfo.earliest_postable_date IS NULL)
               AND (X_Earliest_Postable_Date IS NULL)))
      AND (   (trunc(Recinfo.posted_date) = trunc(X_Posted_Date))
           OR (    (Recinfo.posted_date IS NULL)
               AND (X_Posted_Date IS NULL)))
      AND (   (Recinfo.accrual_rev_effective_date = X_Accrual_Rev_Effective_Date)
           OR (    (Recinfo.accrual_rev_effective_date IS NULL)
               AND (X_Accrual_Rev_Effective_Date IS NULL)))
      AND (   (Recinfo.accrual_rev_period_name = X_Accrual_Rev_Period_Name)
           OR (    (Recinfo.accrual_rev_period_name IS NULL)
               AND (X_Accrual_Rev_Period_Name IS NULL)))
      AND (   (Recinfo.accrual_rev_status = X_Accrual_Rev_Status)
           OR (    (Recinfo.accrual_rev_status IS NULL)
               AND (X_Accrual_Rev_Status IS NULL)))
      AND (   (Recinfo.accrual_rev_je_header_id = X_Accrual_Rev_Je_Header_Id)
           OR (    (Recinfo.accrual_rev_je_header_id IS NULL)
               AND (X_Accrual_Rev_Je_Header_Id IS NULL)))
      AND (   (Recinfo.accrual_rev_change_sign_flag = X_Accrual_Rev_Change_Sign_Flag)
           OR (    (Recinfo.accrual_rev_change_sign_flag IS NULL)
               AND (X_Accrual_Rev_Change_Sign_Flag IS NULL)))
      AND (   (Recinfo.description = X_Description)
           OR (    (Recinfo.description IS NULL)
               AND (X_Description IS NULL)))
      AND (   (Recinfo.tax_status_code = X_tax_status_code)
           OR (    (Recinfo.tax_status_code IS NULL)
               AND (X_Tax_Status_Code IS NULL)))
      AND (   (Recinfo.control_total = X_Control_Total)
           OR (    (Recinfo.control_total IS NULL)
               AND (X_Control_Total IS NULL)))
      AND (   (Recinfo.running_total_dr = X_Running_Total_Dr)
           OR (    (Recinfo.running_total_dr IS NULL)
               AND (X_Running_Total_Dr IS NULL)))
      AND (   (Recinfo.running_total_cr = X_Running_Total_Cr)
           OR (    (Recinfo.running_total_cr IS NULL)
               AND (X_Running_Total_Cr IS NULL)))
      AND (   (Recinfo.running_total_accounted_dr = X_Running_Total_Accounted_Dr)
           OR (    (Recinfo.running_total_accounted_dr IS NULL)
               AND (X_Running_Total_Accounted_Dr IS NULL)))
      AND (   (Recinfo.running_total_accounted_cr = X_Running_Total_Accounted_Cr)
           OR (    (Recinfo.running_total_accounted_cr IS NULL)
               AND (X_Running_Total_Accounted_Cr IS NULL)))
      AND (   (Recinfo.currency_conversion_rate = X_Currency_Conversion_Rate)
           OR (    (Recinfo.currency_conversion_rate IS NULL)
               AND (X_Currency_Conversion_Rate IS NULL)))
      AND (   (Recinfo.currency_conversion_type = X_Currency_Conversion_Type)
           OR (    (Recinfo.currency_conversion_type IS NULL)
               AND (X_Currency_Conversion_Type IS NULL)))
      AND (   (Recinfo.currency_conversion_date = X_Currency_Conversion_Date)
           OR (    (Recinfo.currency_conversion_date IS NULL)
               AND (X_Currency_Conversion_Date IS NULL)))
      AND (   (Recinfo.external_reference = X_External_Reference)
           OR (    (Recinfo.external_reference IS NULL)
               AND (X_External_Reference IS NULL)))
      AND (   (Recinfo.attribute1 = X_Attribute1)
           OR (    (rtrim(Recinfo.attribute1,' ') IS NULL)
               AND (X_Attribute1 IS NULL)))
      AND (   (Recinfo.attribute2 = X_Attribute2)
           OR (    (rtrim(Recinfo.attribute2,' ') IS NULL)
               AND (X_Attribute2 IS NULL)))
      AND (   (Recinfo.attribute3 = X_Attribute3)
           OR (    (rtrim(Recinfo.attribute3,' ') IS NULL)
               AND (X_Attribute3 IS NULL)))
      AND (   (Recinfo.attribute4 = X_Attribute4)
           OR (    (rtrim(Recinfo.attribute4,' ') IS NULL)
               AND (X_Attribute4 IS NULL)))
      AND (   (Recinfo.attribute5 = X_Attribute5)
           OR (    (rtrim(Recinfo.attribute5,' ') IS NULL)
               AND (X_Attribute5 IS NULL)))
      AND (   (Recinfo.attribute6 = X_Attribute6)
           OR (    (rtrim(Recinfo.attribute6,' ') IS NULL)
               AND (X_Attribute6 IS NULL)))
      AND (   (Recinfo.attribute7 = X_Attribute7)
           OR (    (rtrim(Recinfo.attribute7,' ') IS NULL)
               AND (X_Attribute7 IS NULL)))
      AND (   (Recinfo.attribute8 = X_Attribute8)
           OR (    (rtrim(Recinfo.attribute8,' ') IS NULL)
               AND (X_Attribute8 IS NULL)))
      AND (   (Recinfo.attribute9 = X_Attribute9)
           OR (    (rtrim(Recinfo.attribute9,' ') IS NULL)
               AND (X_Attribute9 IS NULL)))
      AND (   (Recinfo.attribute10 = X_Attribute10)
           OR (    (rtrim(Recinfo.attribute10,' ') IS NULL)
               AND (X_Attribute10 IS NULL)))
      AND (   (Recinfo.context = X_Context)
           OR (    (rtrim(Recinfo.context,' ') IS NULL)
               AND (X_Context IS NULL)))
      AND (   (Recinfo.ussgl_transaction_code = X_Ussgl_Transaction_Code)
           OR (    (Recinfo.ussgl_transaction_code IS NULL)
               AND (X_Ussgl_Transaction_Code IS NULL)))
      AND (   (Recinfo.context2 = X_Context2)
           OR (    (Recinfo.context2 IS NULL)
               AND (X_Context2 IS NULL)))
      AND (   (Recinfo.doc_sequence_id = X_Doc_Sequence_Id)
           OR (    (Recinfo.doc_sequence_id IS NULL)
               AND (X_Doc_Sequence_Id IS NULL)))
      AND (   (Recinfo.doc_sequence_value = X_Doc_Sequence_Value)
           OR (    (Recinfo.doc_sequence_value IS NULL)
               AND (X_Doc_Sequence_Value IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;

PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,

                   X_Je_Header_Id                          NUMBER,
                   X_Ledger_Id                             NUMBER,
                   X_Je_Category                           VARCHAR2,
                   X_Je_Source                             VARCHAR2,
                   X_Period_Name                           VARCHAR2,
                   X_Name                                  VARCHAR2,
                   X_Currency_Code                         VARCHAR2,
                   X_Status                                VARCHAR2,
                   X_Date_Created                          DATE,
                   X_Accrual_Rev_Flag                      VARCHAR2,
                   X_Multi_Bal_Seg_Flag                    VARCHAR2,
                   X_Actual_Flag                           VARCHAR2,
                   X_Default_Effective_Date                DATE,
                   X_Conversion_Flag                       VARCHAR2,
                   X_Encumbrance_Type_Id                   NUMBER,
                   X_Budget_Version_Id                     NUMBER,
                   X_Balanced_Je_Flag                      VARCHAR2,
                   X_Balancing_Segment_Value               VARCHAR2,
                   X_Je_Batch_Id                           NUMBER,
                   X_From_Recurring_Header_Id              NUMBER,
                   X_Unique_Date                           VARCHAR2,
                   X_Earliest_Postable_Date                DATE,
                   X_Posted_Date                           DATE,
                   X_Accrual_Rev_Effective_Date            DATE,
                   X_Accrual_Rev_Period_Name               VARCHAR2,
                   X_Accrual_Rev_Status                    VARCHAR2,
                   X_Accrual_Rev_Je_Header_Id              NUMBER,
                   X_Accrual_Rev_Change_Sign_Flag          VARCHAR2,
                   X_Description                           VARCHAR2,
		   X_Tax_Status_Code		    	   VARCHAR2,
                   X_Control_Total                         NUMBER,
                   X_Running_Total_Dr                      NUMBER,
                   X_Running_Total_Cr                      NUMBER,
                   X_Running_Total_Accounted_Dr            NUMBER,
                   X_Running_Total_Accounted_Cr            NUMBER,
                   X_Currency_Conversion_Rate              NUMBER,
                   X_Currency_Conversion_Type              VARCHAR2,
                   X_Currency_Conversion_Date              DATE,
                   X_External_Reference                    VARCHAR2,
                   X_Originating_Bal_Seg_Value             VARCHAR2,
                   X_Attribute1                            VARCHAR2,
                   X_Attribute2                            VARCHAR2,
                   X_Attribute3                            VARCHAR2,
                   X_Attribute4                            VARCHAR2,
                   X_Attribute5                            VARCHAR2,
                   X_Attribute6                            VARCHAR2,
                   X_Attribute7                            VARCHAR2,
                   X_Attribute8                            VARCHAR2,
                   X_Attribute9                            VARCHAR2,
                   X_Attribute10                           VARCHAR2,
                   X_Context                               VARCHAR2,
                   X_Global_Attribute1			   VARCHAR2,
                   X_Global_Attribute2			   VARCHAR2,
                   X_Global_Attribute3			   VARCHAR2,
                   X_Global_Attribute4			   VARCHAR2,
                   X_Global_Attribute5			   VARCHAR2,
                   X_Global_Attribute6			   VARCHAR2,
                   X_Global_Attribute7			   VARCHAR2,
                   X_Global_Attribute8			   VARCHAR2,
                   X_Global_Attribute9			   VARCHAR2,
                   X_Global_Attribute10			   VARCHAR2,
                   X_Global_Attribute_Category		   VARCHAR2,
                   X_Ussgl_Transaction_Code                VARCHAR2,
                   X_Context2                              VARCHAR2,
                   X_Doc_Sequence_Id                       NUMBER,
                   X_Doc_Sequence_Value                    NUMBER,
		   X_Header_Mode			   VARCHAR2,
		   X_Batch_Row_Id			   VARCHAR2,
		   X_Batch_Name			    	   VARCHAR2,
                   X_Chart_of_Accounts_ID		   NUMBER,
		   X_Period_Set_Name		           VARCHAR2,
		   X_Accounted_Period_Type		   VARCHAR2,
		   X_Batch_Status			   VARCHAR2,
		   X_Status_Verified			   VARCHAR2,
		   X_Batch_Default_Effective_Date	   DATE,
		   X_Batch_Posted_Date		    	   DATE,
		   X_Batch_Date_Created		    	   DATE,
		   X_Budgetary_Control_Status		   VARCHAR2,
                   X_Approval_Status_Code                  VARCHAR2,
		   X_Batch_Control_Total		   NUMBER,
		   X_Batch_Running_Total_Dr	           NUMBER,
		   X_Batch_Running_Total_Cr	           NUMBER,
                   X_Average_Journal_Flag                  VARCHAR2,
		   X_Posting_Run_Id			   NUMBER,
		   X_Request_Id			    	   NUMBER,
		   X_Packet_Id			    	   NUMBER,
		   X_Unreservation_Packet_Id		   NUMBER,
		   X_Verify_Request_Completed		   VARCHAR2,
                   X_Jgzz_Recon_Context			   VARCHAR2,
		   X_Jgzz_Recon_Ref			   VARCHAR2,
                   X_Reference_Date                        DATE
) IS
  CURSOR C IS
      SELECT *
      FROM   GL_JE_HEADERS
      WHERE  rowid = X_Rowid
      FOR UPDATE of Je_Header_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN

  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
  CLOSE C;
  if (
          (   (Recinfo.je_header_id = X_Je_Header_Id)
           OR (    (Recinfo.je_header_id IS NULL)
               AND (X_Je_Header_Id IS NULL)))
      AND (   (Recinfo.ledger_id = X_Ledger_Id)
           OR (    (Recinfo.ledger_id IS NULL)
               AND (X_Ledger_Id IS NULL)))
      AND (   (Recinfo.je_category = X_Je_Category)
           OR (    (Recinfo.je_category IS NULL)
               AND (X_Je_Category IS NULL)))
      AND (   (Recinfo.je_source = X_Je_Source)
           OR (    (Recinfo.je_source IS NULL)
               AND (X_Je_Source IS NULL)))
      AND (   (Recinfo.period_name = X_Period_Name)
           OR (    (Recinfo.period_name IS NULL)
               AND (X_Period_Name IS NULL)))
      AND (   (Recinfo.name = X_Name)
           OR (    (Recinfo.name IS NULL)
               AND (X_Name IS NULL)))
      AND (   (Recinfo.currency_code = X_Currency_Code)
           OR (    (Recinfo.currency_code IS NULL)
               AND (X_Currency_Code IS NULL)))
      AND (   (Recinfo.status = X_Status)
           OR (    (Recinfo.status IS NULL)
               AND (X_Status IS NULL)))
      AND (   (trunc(Recinfo.date_created) = trunc(X_Date_Created))
           OR (    (Recinfo.date_created IS NULL)
               AND (X_Date_Created IS NULL)))
      AND (   (Recinfo.accrual_rev_flag = X_Accrual_Rev_Flag)
           OR (    (Recinfo.accrual_rev_flag IS NULL)
               AND (X_Accrual_Rev_Flag IS NULL)))
      AND (   (Recinfo.multi_bal_seg_flag = X_Multi_Bal_Seg_Flag)
           OR (    (Recinfo.multi_bal_seg_flag IS NULL)
               AND (X_Multi_Bal_Seg_Flag IS NULL)))
      AND (   (Recinfo.actual_flag = X_Actual_Flag)
           OR (    (Recinfo.actual_flag IS NULL)
               AND (X_Actual_Flag IS NULL)))
      AND (   (Recinfo.default_effective_date = X_Default_Effective_Date)
           OR (    (Recinfo.default_effective_date IS NULL)
               AND (X_Default_Effective_Date IS NULL)))
      AND (   (Recinfo.conversion_flag = X_Conversion_Flag)
           OR (    (Recinfo.conversion_flag IS NULL)
               AND (X_Conversion_Flag IS NULL)))
      AND (   (Recinfo.encumbrance_type_id = X_Encumbrance_Type_Id)
           OR (    (Recinfo.encumbrance_type_id IS NULL)
               AND (X_Encumbrance_Type_Id IS NULL)))
      AND (   (Recinfo.budget_version_id = X_Budget_Version_Id)
           OR (    (Recinfo.budget_version_id IS NULL)
               AND (X_Budget_Version_Id IS NULL)))
      AND (   (Recinfo.balanced_je_flag = X_Balanced_Je_Flag)
           OR (    (Recinfo.balanced_je_flag IS NULL)
               AND (X_Balanced_Je_Flag IS NULL)))
      AND (   (Recinfo.balancing_segment_value = X_Balancing_Segment_Value)
           OR (    (Recinfo.balancing_segment_value IS NULL)
               AND (X_Balancing_Segment_Value IS NULL)))
      AND (   (Recinfo.je_batch_id = X_Je_Batch_Id)
           OR (    (Recinfo.je_batch_id IS NULL)
               AND (X_Je_Batch_Id IS NULL)))
      AND (   (Recinfo.from_recurring_header_id = X_From_Recurring_Header_Id)
           OR (    (Recinfo.from_recurring_header_id IS NULL)
               AND (X_From_Recurring_Header_Id IS NULL)))
      AND (   (Recinfo.unique_date = X_Unique_Date)
           OR (    (Recinfo.unique_date IS NULL)
               AND (X_Unique_Date IS NULL)))
      AND (   (Recinfo.earliest_postable_date = X_Earliest_Postable_Date)
           OR (    (Recinfo.earliest_postable_date IS NULL)
               AND (X_Earliest_Postable_Date IS NULL)))
      AND (   (trunc(Recinfo.posted_date) = trunc(X_Posted_Date))
           OR (    (Recinfo.posted_date IS NULL)
               AND (X_Posted_Date IS NULL)))
      AND (   (Recinfo.accrual_rev_effective_date = X_Accrual_Rev_Effective_Date)
           OR (    (Recinfo.accrual_rev_effective_date IS NULL)
               AND (X_Accrual_Rev_Effective_Date IS NULL)))
      AND (   (Recinfo.accrual_rev_period_name = X_Accrual_Rev_Period_Name)
           OR (    (Recinfo.accrual_rev_period_name IS NULL)
               AND (X_Accrual_Rev_Period_Name IS NULL)))
      AND (   (Recinfo.accrual_rev_status = X_Accrual_Rev_Status)
           OR (    (Recinfo.accrual_rev_status IS NULL)
               AND (X_Accrual_Rev_Status IS NULL)))
      AND (   (Recinfo.accrual_rev_je_header_id = X_Accrual_Rev_Je_Header_Id)
           OR (    (Recinfo.accrual_rev_je_header_id IS NULL)
               AND (X_Accrual_Rev_Je_Header_Id IS NULL)))
      AND (   (Recinfo.accrual_rev_change_sign_flag = X_Accrual_Rev_Change_Sign_Flag)
           OR (    (Recinfo.accrual_rev_change_sign_flag IS NULL)
               AND (X_Accrual_Rev_Change_Sign_Flag IS NULL)))
      AND (   (Recinfo.description = X_Description)
           OR (    (Recinfo.description IS NULL)
               AND (X_Description IS NULL)))
      AND (   (Recinfo.tax_status_code = X_tax_status_code)
           OR (    (Recinfo.tax_status_code IS NULL)
               AND (X_Tax_Status_Code IS NULL)))
      AND (   (Recinfo.control_total = X_Control_Total)
           OR (    (Recinfo.control_total IS NULL)
               AND (X_Control_Total IS NULL)))
      AND (   (Recinfo.running_total_dr = X_Running_Total_Dr)
           OR (    (Recinfo.running_total_dr IS NULL)
               AND (X_Running_Total_Dr IS NULL)))
      AND (   (Recinfo.running_total_cr = X_Running_Total_Cr)
           OR (    (Recinfo.running_total_cr IS NULL)
               AND (X_Running_Total_Cr IS NULL)))
      AND (   (Recinfo.running_total_accounted_dr = X_Running_Total_Accounted_Dr)
           OR (    (Recinfo.running_total_accounted_dr IS NULL)
               AND (X_Running_Total_Accounted_Dr IS NULL)))
      AND (   (Recinfo.running_total_accounted_cr = X_Running_Total_Accounted_Cr)
           OR (    (Recinfo.running_total_accounted_cr IS NULL)
               AND (X_Running_Total_Accounted_Cr IS NULL)))
      AND (   (Recinfo.currency_conversion_rate = X_Currency_Conversion_Rate)
           OR (    (Recinfo.currency_conversion_rate IS NULL)
               AND (X_Currency_Conversion_Rate IS NULL)))
      AND (   (Recinfo.currency_conversion_type = X_Currency_Conversion_Type)
           OR (    (Recinfo.currency_conversion_type IS NULL)
               AND (X_Currency_Conversion_Type IS NULL)))
      AND (   (Recinfo.currency_conversion_date = X_Currency_Conversion_Date)
           OR (    (Recinfo.currency_conversion_date IS NULL)
               AND (X_Currency_Conversion_Date IS NULL)))
      AND (   (Recinfo.external_reference = X_External_Reference)
           OR (    (Recinfo.external_reference IS NULL)
               AND (X_External_Reference IS NULL)))
      AND (   (Recinfo.originating_bal_seg_value = X_Originating_Bal_Seg_Value)
           OR (    (Recinfo.originating_bal_seg_value IS NULL)
               AND (X_Originating_Bal_Seg_Value IS NULL)))
      AND (   (Recinfo.attribute1 = X_Attribute1)
           OR (    (rtrim(Recinfo.attribute1,' ') IS NULL)
               AND (X_Attribute1 IS NULL)))
      AND (   (Recinfo.attribute2 = X_Attribute2)
           OR (    (rtrim(Recinfo.attribute2,' ') IS NULL)
               AND (X_Attribute2 IS NULL)))
      AND (   (Recinfo.attribute3 = X_Attribute3)
           OR (    (rtrim(Recinfo.attribute3,' ') IS NULL)
               AND (X_Attribute3 IS NULL)))
      AND (   (Recinfo.attribute4 = X_Attribute4)
           OR (    (rtrim(Recinfo.attribute4,' ') IS NULL)
               AND (X_Attribute4 IS NULL)))
      AND (   (Recinfo.attribute5 = X_Attribute5)
           OR (    (rtrim(Recinfo.attribute5,' ') IS NULL)
               AND (X_Attribute5 IS NULL)))
      AND (   (Recinfo.attribute6 = X_Attribute6)
           OR (    (rtrim(Recinfo.attribute6,' ') IS NULL)
               AND (X_Attribute6 IS NULL)))
      AND (   (Recinfo.attribute7 = X_Attribute7)
           OR (    (rtrim(Recinfo.attribute7,' ') IS NULL)
               AND (X_Attribute7 IS NULL)))
      AND (   (Recinfo.attribute8 = X_Attribute8)
           OR (    (rtrim(Recinfo.attribute8,' ') IS NULL)
               AND (X_Attribute8 IS NULL)))
      AND (   (Recinfo.attribute9 = X_Attribute9)
           OR (    (rtrim(Recinfo.attribute9,' ') IS NULL)
               AND (X_Attribute9 IS NULL)))
      AND (   (Recinfo.attribute10 = X_Attribute10)
           OR (    (rtrim(Recinfo.attribute10,' ') IS NULL)
               AND (X_Attribute10 IS NULL)))
      AND (   (Recinfo.context = X_Context)
           OR (    (rtrim(Recinfo.context,' ') IS NULL)
               AND (X_Context IS NULL)))
      AND (   (Recinfo.global_attribute1 = X_Global_Attribute1)
           OR (    (rtrim(Recinfo.global_attribute1,' ') IS NULL)
               AND (X_Global_Attribute1 IS NULL)))
      AND (   (Recinfo.global_attribute2 = X_Global_Attribute2)
           OR (    (rtrim(Recinfo.global_attribute2,' ') IS NULL)
               AND (X_Global_Attribute2 IS NULL)))
      AND (   (Recinfo.global_attribute3 = X_Global_Attribute3)
           OR (    (rtrim(Recinfo.global_attribute3,' ') IS NULL)
               AND (X_Global_Attribute3 IS NULL)))
      AND (   (Recinfo.global_attribute4 = X_Global_Attribute4)
           OR (    (rtrim(Recinfo.global_attribute4,' ') IS NULL)
               AND (X_Global_Attribute4 IS NULL)))
      AND (   (Recinfo.global_attribute5 = X_Global_Attribute5)
           OR (    (rtrim(Recinfo.global_attribute5,' ') IS NULL)
               AND (X_Global_Attribute5 IS NULL)))
      AND (   (Recinfo.global_attribute6 = X_Global_Attribute6)
           OR (    (rtrim(Recinfo.global_attribute6,' ') IS NULL)
               AND (X_Global_Attribute6 IS NULL)))
      AND (   (Recinfo.global_attribute7 = X_Global_Attribute7)
           OR (    (rtrim(Recinfo.global_attribute7,' ') IS NULL)
               AND (X_Global_Attribute7 IS NULL)))
      AND (   (Recinfo.global_attribute8 = X_Global_Attribute8)
           OR (    (rtrim(Recinfo.global_attribute8,' ') IS NULL)
               AND (X_Global_Attribute8 IS NULL)))
      AND (   (Recinfo.global_attribute9 = X_Global_Attribute9)
           OR (    (rtrim(Recinfo.global_attribute9,' ') IS NULL)
               AND (X_Global_Attribute9 IS NULL)))
      AND (   (Recinfo.global_attribute10 = X_Global_Attribute10)
           OR (    (rtrim(Recinfo.global_attribute10,' ') IS NULL)
               AND (X_Global_Attribute10 IS NULL)))
      AND (   (Recinfo.global_attribute_category = X_Global_Attribute_Category)
           OR (    (rtrim(Recinfo.global_attribute_category,' ') IS NULL)
               AND (X_Global_Attribute_Category IS NULL)))
      AND (   (Recinfo.ussgl_transaction_code = X_Ussgl_Transaction_Code)
           OR (    (Recinfo.ussgl_transaction_code IS NULL)
               AND (X_Ussgl_Transaction_Code IS NULL)))
      AND (   (Recinfo.context2 = X_Context2)
           OR (    (Recinfo.context2 IS NULL)
               AND (X_Context2 IS NULL)))
      AND (   (Recinfo.doc_sequence_id = X_Doc_Sequence_Id)
           OR (    (Recinfo.doc_sequence_id IS NULL)
               AND (X_Doc_Sequence_Id IS NULL)))
      AND (   (Recinfo.doc_sequence_value = X_Doc_Sequence_Value)
           OR (    (Recinfo.doc_sequence_value IS NULL)
               AND (X_Doc_Sequence_Value IS NULL)))
      AND (   (Recinfo.jgzz_recon_context = X_Jgzz_Recon_Context)
           OR (    (Recinfo.jgzz_recon_context IS NULL)
               AND (X_Jgzz_Recon_Context IS NULL)))
      AND (   (Recinfo.jgzz_recon_ref = X_Jgzz_Recon_Ref)
           OR (    (Recinfo.jgzz_recon_ref IS NULL)
               AND (X_Jgzz_Recon_Ref IS NULL)))
      AND (   (Recinfo.reference_date = X_Reference_Date)
           OR (    (Recinfo.reference_date IS NULL)
               AND (X_Reference_Date IS NULL)))
          ) then
    null;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;

  -- If we are in header mode, then Lock the batch record
  IF (X_Header_Mode = 'Y') THEN
    GL_JE_BATCHES_PKG.Lock_Row(
            X_Rowid                => X_Batch_Row_Id,
            X_Je_Batch_Id          => X_Je_Batch_Id,
            X_Name                 => X_Batch_Name,
            X_Chart_of_Accounts_Id => X_Chart_of_Accounts_Id,
            X_Period_Set_Name      => X_Period_Set_Name,
	    X_Accounted_Period_Type => X_Accounted_Period_Type,
            X_Status               => X_Batch_Status,
            X_Budgetary_Control_Status=>
              X_Budgetary_Control_Status,
            X_Approval_Status_Code => X_Approval_Status_Code,
            X_Status_Verified      => X_Status_Verified,
            X_Actual_Flag          => X_Actual_Flag,
            X_Default_Period_Name  => X_Period_Name,
            X_Default_Effective_Date=>
              X_Batch_Default_Effective_Date,
            X_Posted_Date          =>
              X_Batch_Posted_Date,
            X_Date_Created         =>
              X_Batch_Date_Created,
	    X_Control_Total  =>
              X_Batch_Control_Total,
 	    X_Running_Total_Dr =>
              X_Batch_Running_Total_Dr,
 	    X_Running_Total_Cr =>
              X_Batch_Running_Total_Cr,
            X_Average_Journal_Flag =>
              X_Average_Journal_Flag,
            X_Posting_Run_Id       =>
              X_Posting_Run_Id,
            X_Request_Id           => X_Request_Id,
            X_Packet_Id            => X_Packet_Id,
            X_Unreservation_Packet_Id=>
              X_Unreservation_Packet_Id,
	    X_Verify_Request_Completed => X_Verify_Request_Completed);
  END IF;
END Lock_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Je_Header_Id                        NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Ledger_Id                           NUMBER,
                     X_Je_Category                         VARCHAR2,
                     X_Je_Source                           VARCHAR2,
                     X_Period_Name                         VARCHAR2,
                     X_Name                                VARCHAR2,
                     X_Currency_Code                       VARCHAR2,
                     X_Status                              VARCHAR2,
                     X_Date_Created                        DATE,
                     X_Accrual_Rev_Flag                    VARCHAR2,
                     X_Multi_Bal_Seg_Flag                  VARCHAR2,
                     X_Actual_Flag                         VARCHAR2,
                     X_Default_Effective_Date              DATE,
                     X_Conversion_Flag                     VARCHAR2,
                     X_Last_Update_Login                   NUMBER,
                     X_Encumbrance_Type_Id                 NUMBER,
                     X_Budget_Version_Id                   NUMBER,
                     X_Balanced_Je_Flag                    VARCHAR2,
                     X_Balancing_Segment_Value             VARCHAR2,
                     X_Je_Batch_Id                         NUMBER,
                     X_From_Recurring_Header_Id            NUMBER,
                     X_Unique_Date                         VARCHAR2,
                     X_Earliest_Postable_Date              DATE,
                     X_Posted_Date                         DATE,
                     X_Accrual_Rev_Effective_Date          DATE,
                     X_Accrual_Rev_Period_Name             VARCHAR2,
                     X_Accrual_Rev_Status                  VARCHAR2,
                     X_Accrual_Rev_Je_Header_Id            NUMBER,
                     X_Accrual_Rev_Change_Sign_Flag        VARCHAR2,
                     X_Description                         VARCHAR2,
 		     X_Tax_Status_Code			   VARCHAR2,
                     X_Control_Total                       NUMBER,
                     X_Running_Total_Dr                    NUMBER,
                     X_Running_Total_Cr                    NUMBER,
                     X_Running_Total_Accounted_Dr          NUMBER,
                     X_Running_Total_Accounted_Cr          NUMBER,
                     X_Currency_Conversion_Rate            NUMBER,
                     X_Currency_Conversion_Type            VARCHAR2,
                     X_Currency_Conversion_Date            DATE,
                     X_External_Reference                  VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Context                             VARCHAR2,
                     X_Ussgl_Transaction_Code              VARCHAR2,
                     X_Context2                            VARCHAR2,
                     X_Doc_Sequence_Id                     NUMBER,
                     X_Doc_Sequence_Value                  NUMBER
) IS
   has_line VARCHAR2(1);
BEGIN

  -- Make sure all journals have at least one line.
  has_line := 'N';
  IF (X_Je_Header_Id IS NOT NULL) THEN
  BEGIN
    SELECT 'Y'
    INTO has_line
    FROM gl_je_lines
    WHERE je_header_id = X_Je_Header_Id
    AND rownum = 1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      has_line := 'N';
  END;
  END IF;

  IF (has_line = 'N') THEN
    fnd_message.set_name('SQLGL', 'GL_JE_JOURNAL_W_NO_LINES');
    app_exception.raise_exception;
  END IF;

  UPDATE GL_JE_HEADERS
  SET

    je_header_id                              =    X_Je_Header_Id,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    ledger_id                                 =    X_Ledger_Id,
    je_category                               =    X_Je_Category,
    je_source                                 =    X_Je_Source,
    period_name                               =    X_Period_Name,
    name                                      =    X_Name,
    currency_code                             =    X_Currency_Code,
    status                                    =    X_Status,
    date_created                              =    X_Date_Created,
    accrual_rev_flag                          =    X_Accrual_Rev_Flag,
    multi_bal_seg_flag                        =    X_Multi_Bal_Seg_Flag,
    actual_flag                               =    X_Actual_Flag,
    default_effective_date                    =    X_Default_Effective_Date,
    conversion_flag                           =    X_Conversion_Flag,
    last_update_login                         =    X_Last_Update_Login,
    encumbrance_type_id                       =    X_Encumbrance_Type_Id,
    budget_version_id                         =    X_Budget_Version_Id,
    balanced_je_flag                          =    X_Balanced_Je_Flag,
    balancing_segment_value                   =    X_Balancing_Segment_Value,
    je_batch_id                               =    X_Je_Batch_Id,
    from_recurring_header_id                  =    X_From_Recurring_Header_Id,
    unique_date                               =    X_Unique_Date,
    earliest_postable_date                    =    X_Earliest_Postable_Date,
    posted_date                               =    X_Posted_Date,
    accrual_rev_effective_date                =    X_Accrual_Rev_Effective_Date,
    accrual_rev_period_name                   =    X_Accrual_Rev_Period_Name,
    accrual_rev_status                        =    X_Accrual_Rev_Status,
    accrual_rev_je_header_id                  =    X_Accrual_Rev_Je_Header_Id,
    accrual_rev_change_sign_flag              =    X_Accrual_Rev_Change_Sign_Flag,
    description                               =    X_Description,
    tax_status_code			      =    X_Tax_Status_Code,
    control_total                             =    X_Control_Total,
    running_total_dr                          =    X_Running_Total_Dr,
    running_total_cr                          =    X_Running_Total_Cr,
    running_total_accounted_dr                =    X_Running_Total_Accounted_Dr,
    running_total_accounted_cr                =    X_Running_Total_Accounted_Cr,
    currency_conversion_rate                  =    X_Currency_Conversion_Rate,
    currency_conversion_type                  =    X_Currency_Conversion_Type,
    currency_conversion_date                  =    X_Currency_Conversion_Date,
    external_reference                        =    X_External_Reference,
    attribute1                                =    X_Attribute1,
    attribute2                                =    X_Attribute2,
    attribute3                                =    X_Attribute3,
    attribute4                                =    X_Attribute4,
    attribute5                                =    X_Attribute5,
    attribute6                                =    X_Attribute6,
    attribute7                                =    X_Attribute7,
    attribute8                                =    X_Attribute8,
    attribute9                                =    X_Attribute9,
    attribute10                               =    X_Attribute10,
    context                                   =    X_Context,
    ussgl_transaction_code                    =    X_Ussgl_Transaction_Code,
    context2                                  =    X_Context2,
    doc_sequence_id                           =    X_Doc_Sequence_Id,
    doc_sequence_value                        =    X_Doc_Sequence_Value
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

END Update_Row;

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Je_Header_Id                        NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Ledger_Id                           NUMBER,
                     X_Je_Category                         VARCHAR2,
                     X_Je_Source                           VARCHAR2,
                     X_Period_Name                         VARCHAR2,
                     X_Name                                VARCHAR2,
                     X_Currency_Code                       VARCHAR2,
                     X_Status                              VARCHAR2,
                     X_Date_Created                        DATE,
                     X_Accrual_Rev_Flag                    VARCHAR2,
                     X_Multi_Bal_Seg_Flag                  VARCHAR2,
                     X_Actual_Flag                         VARCHAR2,
                     X_Default_Effective_Date              DATE,
                     X_Conversion_Flag                     VARCHAR2,
                     X_Last_Update_Login                   NUMBER,
                     X_Encumbrance_Type_Id                 NUMBER,
                     X_Budget_Version_Id                   NUMBER,
                     X_Balanced_Je_Flag                    VARCHAR2,
                     X_Balancing_Segment_Value             VARCHAR2,
                     X_Je_Batch_Id                         NUMBER,
                     X_From_Recurring_Header_Id            NUMBER,
                     X_Unique_Date                         VARCHAR2,
                     X_Earliest_Postable_Date              DATE,
                     X_Posted_Date                         DATE,
                     X_Accrual_Rev_Effective_Date          DATE,
                     X_Accrual_Rev_Period_Name             VARCHAR2,
                     X_Accrual_Rev_Status                  VARCHAR2,
                     X_Accrual_Rev_Je_Header_Id            NUMBER,
                     X_Accrual_Rev_Change_Sign_Flag        VARCHAR2,
                     X_Description                         VARCHAR2,
		     X_Tax_Status_Code			   VARCHAR2,
                     X_Control_Total                       NUMBER,
                     X_Running_Total_Dr                    NUMBER,
                     X_Running_Total_Cr                    NUMBER,
                     X_Running_Total_Accounted_Dr          NUMBER,
                     X_Running_Total_Accounted_Cr          NUMBER,
                     X_Currency_Conversion_Rate            NUMBER,
                     X_Currency_Conversion_Type            VARCHAR2,
                     X_Currency_Conversion_Date            DATE,
                     X_External_Reference                  VARCHAR2,
		     X_Originating_Bal_Seg_Value           VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Context                             VARCHAR2,
                     X_Global_Attribute1                   VARCHAR2,
                     X_Global_Attribute2                   VARCHAR2,
                     X_Global_Attribute3                   VARCHAR2,
                     X_Global_Attribute4                   VARCHAR2,
                     X_Global_Attribute5                   VARCHAR2,
                     X_Global_Attribute6                   VARCHAR2,
                     X_Global_Attribute7                   VARCHAR2,
                     X_Global_Attribute8                   VARCHAR2,
                     X_Global_Attribute9                   VARCHAR2,
                     X_Global_Attribute10                  VARCHAR2,
                     X_Global_Attribute_Category           VARCHAR2,
                     X_Ussgl_Transaction_Code              VARCHAR2,
                     X_Context2                            VARCHAR2,
                     X_Doc_Sequence_Id                     NUMBER,
                     X_Doc_Sequence_Value                  NUMBER,
		     X_Effective_Date_Changed		   VARCHAR2,
		     X_Header_Mode			   VARCHAR2,
		     X_Batch_Row_Id			   VARCHAR2,
		     X_Batch_Name			   VARCHAR2,
                     X_Chart_of_Accounts_ID		   NUMBER,
		     X_Period_Set_Name		           VARCHAR2,
		     X_Accounted_Period_Type		   VARCHAR2,
		     X_Batch_Status			   VARCHAR2,
		     X_Status_Verified			   VARCHAR2,
		     X_Batch_Default_Effective_Date	   DATE,
		     X_Batch_Posted_Date		   DATE,
		     X_Batch_Date_Created		   DATE,
		     X_Budgetary_Control_Status		   VARCHAR2,
                     X_Approval_Status_Code                IN OUT NOCOPY VARCHAR2,
		     X_Batch_Control_Total		   IN OUT NOCOPY NUMBER,
		     X_Batch_Running_Total_Dr	           IN OUT NOCOPY NUMBER,
		     X_Batch_Running_Total_Cr	           IN OUT NOCOPY NUMBER,
                     X_Average_Journal_Flag                VARCHAR2,
		     X_Posting_Run_Id			   NUMBER,
		     X_Request_Id			   NUMBER,
		     X_Packet_Id			   NUMBER,
		     X_Unreservation_Packet_Id		   NUMBER,
		     Update_Effective_Date_Flag		   VARCHAR2,
		     Update_Approval_Stat_Flag		   VARCHAR2,
		     X_Jgzz_Recon_Context		   VARCHAR2,
		     X_Jgzz_Recon_Ref			   VARCHAR2,
                     X_Reference_Date                      DATE
) IS
   has_line VARCHAR2(1);
BEGIN

  -- Make sure all journals have at least one line.
  has_line := 'N';
  IF (X_Je_Header_Id IS NOT NULL) THEN
  BEGIN
    SELECT 'Y'
    INTO has_line
    FROM gl_je_lines
    WHERE je_header_id = X_Je_Header_Id
    AND rownum = 1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      has_line := 'N';
  END;
  END IF;

  IF (has_line = 'N') THEN
    fnd_message.set_name('SQLGL', 'GL_JE_JOURNAL_W_NO_LINES');
    app_exception.raise_exception;
  END IF;

  -- Update the lines effective date, if necessary
  IF (X_Effective_Date_Changed = 'Y') THEN
    gl_je_lines_pkg.update_lines(
      X_Je_Header_Id,
      X_Period_Name,
      X_Default_Effective_Date,
      -1,
      -1,
      null,
      null,
      'N',
      'N',
      X_Last_Updated_By,
      X_Last_Update_Login);
  END IF;

  UPDATE GL_JE_HEADERS
  SET

    je_header_id                              =    X_Je_Header_Id,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By,
    ledger_id                                 =    X_Ledger_Id,
    je_category                               =    X_Je_Category,
    je_source                                 =    X_Je_Source,
    period_name                               =    X_Period_Name,
    name                                      =    X_Name,
    currency_code                             =    X_Currency_Code,
    status                                    =    X_Status,
    date_created                              =    X_Date_Created,
    accrual_rev_flag                          =    X_Accrual_Rev_Flag,
    multi_bal_seg_flag                        =    X_Multi_Bal_Seg_Flag,
    actual_flag                               =    X_Actual_Flag,
    default_effective_date                    =    X_Default_Effective_Date,
    conversion_flag                           =    X_Conversion_Flag,
    last_update_login                         =    X_Last_Update_Login,
    encumbrance_type_id                       =    X_Encumbrance_Type_Id,
    budget_version_id                         =    X_Budget_Version_Id,
    balanced_je_flag                          =    X_Balanced_Je_Flag,
    balancing_segment_value                   =    X_Balancing_Segment_Value,
    je_batch_id                               =    X_Je_Batch_Id,
    from_recurring_header_id                  =    X_From_Recurring_Header_Id,
    unique_date                               =    X_Unique_Date,
    earliest_postable_date                    =    X_Earliest_Postable_Date,
    posted_date                               =    X_Posted_Date,
    accrual_rev_effective_date                =    X_Accrual_Rev_Effective_Date,
    accrual_rev_period_name                   =    X_Accrual_Rev_Period_Name,
    accrual_rev_status                        =    X_Accrual_Rev_Status,
    accrual_rev_je_header_id                  =    X_Accrual_Rev_Je_Header_Id,
    accrual_rev_change_sign_flag              =    X_Accrual_Rev_Change_Sign_Flag,
    description                               =    X_Description,
    tax_status_code			      =    X_Tax_Status_Code,
    control_total                             =    X_Control_Total,
    running_total_dr                          =    X_Running_Total_Dr,
    running_total_cr                          =    X_Running_Total_Cr,
    running_total_accounted_dr                =    X_Running_Total_Accounted_Dr,
    running_total_accounted_cr                =    X_Running_Total_Accounted_Cr,
    currency_conversion_rate                  =    X_Currency_Conversion_Rate,
    currency_conversion_type                  =    X_Currency_Conversion_Type,
    currency_conversion_date                  =    X_Currency_Conversion_Date,
    external_reference                        =    X_External_Reference,
    originating_bal_seg_value                 =    X_Originating_Bal_Seg_Value,
    attribute1                                =    X_Attribute1,
    attribute2                                =    X_Attribute2,
    attribute3                                =    X_Attribute3,
    attribute4                                =    X_Attribute4,
    attribute5                                =    X_Attribute5,
    attribute6                                =    X_Attribute6,
    attribute7                                =    X_Attribute7,
    attribute8                                =    X_Attribute8,
    attribute9                                =    X_Attribute9,
    attribute10                               =    X_Attribute10,
    context                                   =    X_Context,
    global_attribute1                         =    X_Global_Attribute1,
    global_attribute2                         =    X_Global_Attribute2,
    global_attribute3                         =    X_Global_Attribute3,
    global_attribute4                         =    X_Global_Attribute4,
    global_attribute5                         =    X_Global_Attribute5,
    global_attribute6                         =    X_Global_Attribute6,
    global_attribute7                         =    X_Global_Attribute7,
    global_attribute8                         =    X_Global_Attribute8,
    global_attribute9                         =    X_Global_Attribute9,
    global_attribute10                        =    X_Global_Attribute10,
    global_attribute_category                 =    X_Global_Attribute_Category,
    ussgl_transaction_code                    =    X_Ussgl_Transaction_Code,
    context2                                  =    X_Context2,
    doc_sequence_id                           =    X_Doc_Sequence_Id,
    doc_sequence_value                        =    X_Doc_Sequence_Value,
    jgzz_recon_context                        =    X_Jgzz_Recon_Context,
    jgzz_recon_ref                            =    X_Jgzz_Recon_Ref,
    reference_date                            =    X_Reference_Date
  WHERE rowid = X_rowid;

  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

  -- If we are in header mode, then update the batch
  -- Update the header first so that we can correctly
  -- calculate the running totals.
  IF (X_Header_Mode = 'Y') THEN
    GL_JE_BATCHES_PKG.Update_Row(
        X_Rowid                => X_Batch_Row_Id,
        X_Je_Batch_Id          => X_Je_Batch_Id,
        X_Name                 => X_Batch_Name,
        X_Chart_of_Accounts_Id => X_Chart_of_Accounts_Id,
        X_Period_Set_Name      => X_Period_Set_Name,
	X_Accounted_Period_Type => X_Accounted_Period_Type,
        X_Status               => X_Batch_Status,
        X_Budgetary_Control_Status=>
          X_Budgetary_Control_Status,
        X_Approval_Status_Code => X_Approval_Status_Code,
        X_Status_Verified      => X_Status_Verified,
        X_Actual_Flag          => X_Actual_Flag,
        X_Default_Period_Name  => X_Period_Name,
        X_Default_Effective_Date=>
          X_Batch_Default_Effective_Date,
        X_Posted_Date          => X_Batch_Posted_Date,
        X_Date_Created         => X_Batch_Date_Created,
	X_Control_Total        => X_Batch_Control_Total,
 	X_Running_Total_Dr     => X_Batch_Running_Total_Dr,
 	X_Running_Total_Cr     => X_Batch_Running_Total_Cr,
        X_Average_Journal_Flag => X_Average_Journal_Flag,
        X_Posting_Run_Id       => X_Posting_Run_Id,
        X_Request_Id           => X_Request_Id,
        X_Packet_Id            => X_Packet_Id,
        X_Unreservation_Packet_Id=>
          X_Unreservation_Packet_Id,
        X_Last_Update_Date     => X_Last_Update_Date,
        X_Last_Updated_By      => X_Last_Updated_By,
        X_Last_Update_Login    => X_Last_Update_Login,
        Update_Effective_Date_Flag => Update_Effective_Date_Flag,
        Update_Approval_Stat_Flag => Update_Approval_Stat_Flag);
  END IF;

END Update_Row;

PROCEDURE Delete_Row(X_Rowid 				   VARCHAR2,
		     X_Je_Header_Id 			   NUMBER,
		     X_Header_Mode 			   VARCHAR2,
		     X_Batch_Row_Id			   VARCHAR2,
		     X_Je_Batch_Id			   NUMBER,
		     X_Ledger_Id			   NUMBER,
		     X_Actual_Flag			   VARCHAR2,
		     X_Period_Name			   VARCHAR2,
		     X_Batch_Name			   VARCHAR2,
                     X_Chart_of_Accounts_ID		   NUMBER,
		     X_Period_Set_Name		           VARCHAR2,
		     X_Accounted_Period_Type		   VARCHAR2,
		     X_Batch_Status			   VARCHAR2,
		     X_Status_Verified			   VARCHAR2,
		     X_Batch_Default_Effective_Date	   DATE,
		     X_Batch_Posted_Date		   DATE,
		     X_Batch_Date_Created		   DATE,
		     X_Budgetary_Control_Status		   VARCHAR2,
                     X_Approval_Status_Code                IN OUT NOCOPY VARCHAR2,
		     X_Batch_Control_Total		   IN OUT NOCOPY NUMBER,
		     X_Batch_Running_Total_Dr	           IN OUT NOCOPY NUMBER,
		     X_Batch_Running_Total_Cr	           IN OUT NOCOPY NUMBER,
                     X_Average_Journal_Flag                VARCHAR2,
		     X_Posting_Run_Id			   NUMBER,
		     X_Request_Id			   NUMBER,
		     X_Packet_Id			   NUMBER,
		     X_Unreservation_Packet_Id		   NUMBER,
		     X_Last_Updated_By			   NUMBER,
		     X_Last_Update_Login		   NUMBER
) IS
  CURSOR count_headers IS
    SELECT count(*)
    FROM   gl_je_headers
    WHERE  je_batch_id = X_Je_Batch_Id;

  CURSOR get_child IS
    SELECT je_header_id
    FROM gl_je_headers
    WHERE parent_je_header_id = X_Je_Header_Id;

  header_count NUMBER := 0;
  l_je_header_id NUMBER;
  dummy        NUMBER;
BEGIN
  -- Delete any lines
  gl_je_lines_pkg.delete_lines(X_Je_Header_Id);

  -- Delete the associated segment values
  dummy := gl_je_segment_values_pkg.delete_segment_values(X_Je_Header_Id);

  -- Delete all of the reconciliation lines
  DELETE gl_je_lines_recon
  WHERE  je_header_id = X_Je_Header_Id;

  OPEN get_child;
  LOOP
     FETCH get_child INTO l_je_header_id;
     EXIT WHEN get_child%NOTFOUND;

     gl_je_lines_pkg.delete_lines(l_je_header_id);
     dummy := gl_je_segment_values_pkg.delete_segment_values(l_je_header_id);

     -- Delete all of the reconciliation lines
     DELETE gl_je_lines_recon
     WHERE  je_header_id = l_je_header_id;

  END LOOP;
  CLOSE get_child;

  -- Mark the reversals as no longer reversals, since the
  -- original journal has been deleted.  This is necessary to fix
  -- bug #1001521
  UPDATE gl_je_headers
  SET    reversed_je_header_id = null,
         accrual_rev_je_header_id = decode(accrual_rev_status,
                                      'R', accrual_rev_je_header_id,
                                      null)
  WHERE  je_header_id =
      (SELECT accrual_rev_je_header_id
       FROM   gl_je_headers
       WHERE  rowid = X_Rowid
       AND    accrual_rev_status = 'R');

 -- Bug fix 2749073 Mark the original journal as reversible
 -- incase if the reversed journal associated is deleted.
 UPDATE gl_je_headers
  SET   accrual_rev_status = null,
        accrual_rev_je_header_id =null,
        accrual_rev_flag = 'Y'
 WHERE je_header_id =
 ( SELECT reversed_je_header_id
   FROM   gl_je_headers
   WHERE  je_header_id = X_Je_Header_Id
   AND    reversed_je_header_id IS NOT NULL);

  -- Mark the ALC reversals as no longer reversals, since the
  -- original journal has been deleted.
  UPDATE gl_je_headers
  SET    reversed_je_header_id = null,
         accrual_rev_je_header_id = decode(accrual_rev_status,
                                      'R', accrual_rev_je_header_id,
                                      null)
  WHERE  je_header_id =
      (SELECT accrual_rev_je_header_id
       FROM   gl_je_headers
       WHERE  parent_je_header_id = X_Je_Header_Id
       AND    accrual_rev_status = 'R');

 --Mark the original journal as reversible
 -- incase if the reversed journal associated is deleted.
 UPDATE gl_je_headers
  SET   accrual_rev_status = null,
        accrual_rev_je_header_id =null,
        accrual_rev_flag = 'Y'
 WHERE je_header_id =
 ( SELECT reversed_je_header_id
   FROM   gl_je_headers
   WHERE  parent_je_header_id = X_Je_Header_Id
   AND    reversed_je_header_id IS NOT NULL);

 --Delete the the corresponding ALCs when a primary journals is deleted.
 DELETE FROM gl_je_headers
 WHERE parent_je_header_id = X_Je_Header_Id;

  -- Delete the journal
  DELETE FROM GL_JE_HEADERS
  WHERE  rowid = X_Rowid;

  -- If we are deleting in the journal zone and we are in journal
  -- mode or if we are deleting from the folder zone, we need
  -- to update or delete the batch.  We will delete
  -- the batch in the case where there are no other journals.
  IF (X_Header_Mode IN ('Y', 'F')) THEN

    -- Determine the number of headers left in the batch
    OPEN count_headers;
    FETCH count_headers INTO header_count;
    CLOSE count_headers;

    IF (header_count = 0) THEN
      GL_JE_BATCHES_PKG.delete_row(X_Batch_Row_id, X_Je_Batch_Id);
    ELSE
      GL_JE_BATCHES_PKG.Update_Row(
        X_Rowid                => X_Batch_Row_Id,
        X_Je_Batch_Id          => X_Je_Batch_Id,
        X_Name                 => X_Batch_Name,
        X_Chart_of_Accounts_Id => X_Chart_of_Accounts_Id,
        X_Period_Set_Name      => X_Period_Set_Name,
	X_Accounted_Period_Type => X_Accounted_Period_Type,
        X_Status               => X_Batch_Status,
        X_Budgetary_Control_Status=>
          X_Budgetary_Control_Status,
        X_Approval_Status_Code => X_Approval_Status_Code,
        X_Status_Verified      => 'N',
        X_Actual_Flag          => X_Actual_Flag,
        X_Default_Period_Name  => X_Period_Name,
        X_Default_Effective_Date=>
          X_Batch_Default_Effective_Date,
        X_Posted_Date          => X_Batch_Posted_Date,
        X_Date_Created         => X_Batch_Date_Created,
	X_Control_Total        => X_Batch_Control_Total,
 	X_Running_Total_Dr     => X_Batch_Running_Total_Dr,
 	X_Running_Total_Cr     => X_Batch_Running_Total_Cr,
        X_Average_Journal_Flag => X_Average_Journal_Flag,
        X_Posting_Run_Id       => X_Posting_Run_Id,
        X_Request_Id           => X_Request_Id,
        X_Packet_Id            => X_Packet_Id,
        X_Unreservation_Packet_Id=>
          X_Unreservation_Packet_Id,
        X_Last_Update_Date     => sysdate,
        X_Last_Updated_By      => X_Last_Updated_By,
        X_Last_Update_Login    => X_Last_Update_Login,
        Update_Effective_Date_Flag => 'N',
        Update_Approval_Stat_Flag => 'D');
    END IF;

  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    null;
END Delete_Row;

END GL_JE_HEADERS_PKG;

/
