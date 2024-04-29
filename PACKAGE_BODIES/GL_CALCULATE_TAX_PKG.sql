--------------------------------------------------------
--  DDL for Package Body GL_CALCULATE_TAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_CALCULATE_TAX_PKG" as
/* $Header: glujetxb.pls 120.6.12000000.2 2007/07/03 17:10:50 djogg ship $ */

  ---
  --- PRIVATE FUNCTIONS
  ---

  --
  -- Procedure
  --   setup
  -- Purpose
  --   Validates the parameters and gets various information
  -- History
  --   10-DEC-96  D. J. Ogg    Created
  -- Arguments
  --   header_id			The header id
  --   tax_level                        'J'ournal or 'B'atch
  --   lgr_id				Ledger id of header or batch
  --   org_id                           Org of batch
  --   per_name				Period of header or batch
  --   calculation_level		Calculation level for ledger and org
  --   base_currency			Currency of ledger
  --   tax_mau				Tax mau for ledger and org
  -- Notes
  --
  PROCEDURE setup(header_id		NUMBER,
                  tax_level             VARCHAR2,
		  lgr_id		IN OUT NOCOPY  VARCHAR2,
                  org_id                IN OUT NOCOPY  NUMBER,
		  per_name		IN OUT NOCOPY  VARCHAR2,
		  calculation_level	IN OUT NOCOPY  VARCHAR2,
		  base_currency		IN OUT NOCOPY  VARCHAR2,
		  tax_mau		IN OUT NOCOPY  VARCHAR2) IS

    tax_status_code	VARCHAR2(1); -- Tax status of journal or batch
    dummy2		NUMBER;  -- Dummy variable
    dummy		VARCHAR2(100);  -- Dummy variable
    le_id               NUMBER; -- legal entity id
    x_return_status     VARCHAR2(30);
    x_msg_out           VARCHAR2(2000);
  BEGIN

    -- Validate the header and get batch level information
    BEGIN
      -- Lock the header
      SELECT je_batch_id
      INTO   dummy2
      FROM   gl_je_headers jeh
      WHERE  jeh.je_header_id = header_id
      FOR UPDATE;

      -- Lock the batch
      SELECT 'Good batch'
      INTO   dummy
      FROM   gl_je_batches jeb
      WHERE  jeb.je_batch_id = dummy2
      FOR UPDATE;

      -- Get various information
      SELECT jeh.tax_status_code, jeh.ledger_id, jeb.org_id,
             jeb.default_period_name, lgr.currency_code
      INTO   tax_status_code, lgr_id, org_id, per_name,
             base_currency
      FROM   gl_je_headers jeh, gl_je_batches jeb, gl_ledgers lgr
      WHERE  jeh.je_header_id = header_id
      AND    jeb.je_batch_id = jeh.je_batch_id
      AND    lgr.ledger_id = jeh.ledger_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('SQLGL', 'GL_CTAX_BAD_HEADER');
        fnd_message.set_token('HEADER_ID', to_char(header_id));
        app_exception.raise_exception;
    END;

    IF (tax_status_code <> 'R') THEN
      fnd_message.set_name('SQLGL', 'GL_CTAX_HEADER_TAXED');
      app_exception.raise_exception;
    END IF;

    -- Get various information about the tax setup
    BEGIN
      --SELECT calculation_level_code,
      --       decode(tax_mau, NULL, power(10, -1*tax_precision), tax_mau)
      --INTO   calculation_level, tax_mau
      --FROM   gl_tax_options
      --WHERE  ledger_id = lgr_id
      --AND    org_id = current_org_id;

      le_id := XLE_UTILITIES_GRP.Get_DefaultLegalContext_OU(
                 org_id);

      zx_gl_tax_options_pkg.get_ledger_controls(
            1.0,
            lgr_id,
            org_id,
            le_id,
            calculation_level,
            tax_mau,
            x_return_status,
            x_msg_out);
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        BEGIN
          SELECT nvl(multi_org_flag, 'N')
          INTO   dummy
          FROM   fnd_product_groups;
	EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	    dummy := 'Y';
	END;

	IF (dummy = 'N') THEN
          fnd_message.set_name('SQLGL', 'GL_CTAX_NO_OPTIONS');
        ELSIF (tax_level = 'J') THEN
          fnd_message.set_name('SQLGL', 'GL_CTAX_NO_OPTIONS_JOURN_ORG');
        ELSE
          fnd_message.set_name('SQLGL', 'GL_CTAX_NO_OPTIONS_BATCH_ORG');
	END IF;
        app_exception.raise_exception;
    END;
  END setup;

  --
  -- Procedure
  --   round_it
  -- Purpose
  --   Rounds a number to the appropriate precision
  -- History
  --   10-DEC-96  D. J. Ogg    Created
  -- Arguments
  --   amount				The amount to be rounded
  --   rounding_rule			Rounding rule to be followed: Up, Down, or
  --					Nearest
  --   mau				Mau of currency
  -- Notes
  --
  FUNCTION round_it(amount		NUMBER,
		    rounding_rule	VARCHAR2,
		    mau			NUMBER) RETURN NUMBER IS
  BEGIN
    IF (amount IS NULL) THEN
      RETURN(NULL);
    ELSIF (rounding_rule = 'U') THEN
      IF (sign(amount) >= 0) THEN
        RETURN(ceil(amount / mau) * mau);
      ELSE
        RETURN(-1 * ceil(abs(amount) / mau) * mau);
      END IF;
    ELSIF (rounding_rule = 'D') THEN
      IF (sign(amount) >= 0) THEN
        RETURN(floor(amount / mau) * mau);
      ELSE
        RETURN(-1 * floor(abs(amount) / mau) * mau);
      END IF;
    ELSE
      RETURN(round(amount / mau) * mau);
    END IF;
  END round_it;


  ---
  --- PUBLIC FUNCTIONS
  ---

  PROCEDURE calculate(	tax_level			VARCHAR2,
			batch_header_id			NUMBER,
			disp_header_id			NUMBER DEFAULT NULL,
			resp_appl_id			NUMBER,
			resp_id				NUMBER,
			user_id				NUMBER,
			login_id			NUMBER,
			coa_id				NUMBER,
			header_total_dr		IN OUT NOCOPY	NUMBER,
			header_total_cr		IN OUT NOCOPY 	NUMBER,
			header_total_acc_dr	IN OUT NOCOPY	NUMBER,
			header_total_acc_cr	IN OUT NOCOPY 	NUMBER,
			batch_total_dr		IN OUT NOCOPY	NUMBER,
			batch_total_cr		IN OUT NOCOPY	NUMBER,
			batch_total_acc_dr	IN OUT NOCOPY	NUMBER,
			batch_total_acc_cr	IN OUT NOCOPY	NUMBER,
			has_bad_accounts	IN OUT NOCOPY 	BOOLEAN
		     ) IS


    lgr_id          	NUMBER;  -- Current ledger
    org_id              NUMBER;  -- Current operating unit
    per_name        	VARCHAR2(15);  -- Current period name
    calculation_level	VARCHAR2(1);  -- Calculation level: Journal or Line
    tax_mau		NUMBER;  -- Minimum accountable unit for tax
			         -- calculations
    base_currency	VARCHAR2(15);  -- Functional currency of set of books
    tax_status_code     VARCHAR2(1);  -- Tax status code of batch

    header_id		NUMBER;  -- Id of current header
    next_line_num	NUMBER;  -- Next unused line number for current header
    conv_rate		NUMBER;  -- Conversion rate for current header
    header_eff_date	DATE; -- Effective date of header
    currency		VARCHAR2(15);  -- Currency for header
    curr_mau		NUMBER;  -- Minimum accountable unit for header

    line_count		NUMBER;  -- Total number of lines processed

    line_num		NUMBER;  -- Number of current line
    eff_date		DATE;  -- effective date of line
    ent_dr		NUMBER;  -- line debits
    ent_cr		NUMBER;  -- line credits
    description		VARCHAR2(250);  -- line description
    rounding_rule	VARCHAR2(1);  -- line rounding rule
    incl_tax		VARCHAR2(1);  -- line includes tax
    tax_code		VARCHAR2(50);  -- line tax code
    tax_rate		NUMBER;  -- line tax rate
    tax_ccid		NUMBER;  -- tax ccid for line
    tax_group		NUMBER;  -- tax group for line

    no_more_records	BOOLEAN;  -- Indicates that all records have been
				  -- fetched
    last_in_group	BOOLEAN;  -- Indicates this is the last record in
				  -- the group
    first_in_group	BOOLEAN;  -- Indicates this is the first record
				  -- in the group

    bad_acct		BOOLEAN;  -- Indicates that the current tax
				  -- account is bad
    bad_csegs		VARCHAR2(750);  -- Gives the bad tax account

    line_tax_dr		NUMBER;  -- Tax debits for current line
    line_tax_cr		NUMBER;  -- Tax credits for next line
    line_tax_acc_dr	NUMBER;  -- Tax accounted debits for current line
    line_tax_acc_cr	NUMBER;  -- Tax accounted credits for next line

    total_ent_dr	NUMBER;  -- Total entered debits
    total_ent_cr	NUMBER;  -- Total entered credits

    total_jtax_dr	NUMBER;  -- Correct tax dr for current tax line
    total_jtax_cr	NUMBER;  -- Correct tax cr for current tax line
    total_jtax_acc_dr	NUMBER;  -- Correct tax accounted dr for current tax
				 -- line
    total_jtax_acc_cr	NUMBER;  -- Correct tax accounted cr current tax line

    total_ltax_dr	NUMBER;  -- Sum of individual lines tax dr (needed for
				 -- journal method)
    total_ltax_cr	NUMBER;  -- Sum of individual lines tax cr (needed for
				 -- journal method)
    total_ltax_acc_dr	NUMBER;  -- Correct tax accounted dr for current tax
				 -- line
    total_ltax_acc_cr	NUMBER;  -- Correct tax accounted cr current tax line

    tax_line_descr	VARCHAR2(240);  -- Description of tax line
    line_curs_init      BOOLEAN;

    CURSOR j_journals IS
        SELECT max(jeh.je_header_id), max(jel.je_line_num) + 1,
               max(jeh.currency_conversion_rate),
	       max(jeh.default_effective_date),
	       max(jeh.currency_code),
	       max(decode(curr.minimum_accountable_unit,
			  NULL, power(10, -1*curr.precision),
			  curr.minimum_accountable_unit))
        FROM   gl_je_headers jeh, fnd_currencies curr, gl_je_lines jel
        WHERE  jeh.je_header_id = batch_header_id
	AND    curr.currency_code = jeh.currency_code
        AND    jel.je_header_id = jeh.je_header_id;

    CURSOR b_journals IS
        SELECT jeh.je_header_id, max(jel.je_line_num) + 1,
               max(jeh.currency_conversion_rate),
	       max(jeh.default_effective_date),
	       max(jeh.currency_code),
	       max(decode(curr.minimum_accountable_unit,
		          NULL, power(10, -1*curr.precision),
		          curr.minimum_accountable_unit))
        FROM   gl_je_headers jeh, fnd_currencies curr, gl_je_lines jel
        WHERE  jeh.je_batch_id = batch_header_id
	AND    jeh.tax_status_code = 'R'
	AND    curr.currency_code = jeh.currency_code
        AND    jel.je_header_id = jeh.je_header_id
        GROUP BY jeh.je_header_id;
  BEGIN

    -- Initially, there are no bad accounts
    has_bad_accounts := FALSE;

    -- Build a cursor to loop through each journal
    IF (tax_level = 'J') THEN
      OPEN j_journals;
    ELSE

      BEGIN
        SELECT max(decode(jeh.tax_status_code, 'R', '1', '0'))
        INTO tax_status_code
        FROM gl_je_headers jeh
        WHERE jeh.je_batch_id = batch_header_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('SQLGL', 'GL_CTAX_BAD_BATCH');
          fnd_message.set_token('BATCH_ID', to_char(batch_header_id));
          app_exception.raise_exception;
      END;

      IF (nvl(tax_status_code,'0') <> '1') THEN
        fnd_message.set_name('SQLGL', 'GL_CTAX_BATCH_TAXED');
        app_exception.raise_exception;
      END IF;

      OPEN b_journals;
    END IF;

    line_curs_init := FALSE;
    LOOP
      -- Get a journal
      IF (tax_level = 'J') THEN
        FETCH j_journals INTO header_id, next_line_num, conv_rate,
			      header_eff_date, currency, curr_mau;
        EXIT WHEN j_journals%NOTFOUND;
      ELSE
        FETCH b_journals INTO header_id, next_line_num, conv_rate,
			      header_eff_date, currency, curr_mau;
        EXIT WHEN b_journals%NOTFOUND;
      END IF;

      -- Initialize the journal information
      setup(header_id           => header_id,
            tax_level           => tax_level,
	    lgr_id		=> lgr_id,
	    org_id		=> org_id,
	    per_name		=> per_name,
	    calculation_level	=> calculation_level,
	    base_currency	=> base_currency,
	    tax_mau		=> tax_mau);

      -- Setup the lines cursor.  Must be done
      -- after setup call.  Close the cursor if it is already open
      IF (line_curs_init) THEN
        gl_calculate_tax2_pkg.close_cursor;
      END IF;
      gl_calculate_tax2_pkg.define_cursor(
        coa_id	  	        => coa_id,
        calculation_level	=> calculation_level);
      line_curs_init := TRUE;


      -- If this is a functional currency journal, then use the tax mau
      IF (currency = base_currency) THEN
        curr_mau := tax_mau;
      END IF;

      -- Prepare the lines cursor for fetch
      gl_calculate_tax2_pkg.bind_cursor(header_id);
      gl_calculate_tax2_pkg.execute_cursor;

      -- Initialize everything
      line_count := 0;
      first_in_group := TRUE;
      total_ent_dr := null;
      total_ent_cr := null;
      total_jtax_dr := null;
      total_jtax_cr := null;
      total_jtax_acc_dr := null;
      total_jtax_acc_cr := null;
      total_ltax_dr := null;
      total_ltax_cr := null;
      total_ltax_acc_dr := null;
      total_ltax_acc_cr := null;


      LOOP

	gl_calculate_tax2_pkg.fetch_cursor(
	  coa_id			=> coa_id,
          lgr_id                        => lgr_id,
          org_id                        => org_id,
	  calculation_level		=> calculation_level,
	  journal_effective_date	=> header_eff_date,
	  resp_appl_id			=> resp_appl_id,
	  resp_id			=> resp_id,
	  user_id			=> user_id,
	  no_more_records		=> no_more_records,
	  last_in_group			=> last_in_group,
	  bad_acct			=> bad_acct,
	  bad_csegs			=> bad_csegs,
	  line_num			=> line_num,
	  eff_date			=> eff_date,
	  ent_dr			=> ent_dr,
	  ent_cr			=> ent_cr,
	  rounding_rule			=> rounding_rule,
	  description			=> description,
	  incl_tax			=> incl_tax,
	  tax_code			=> tax_code,
	  tax_rate			=> tax_rate,
	  tax_ccid			=> tax_ccid,
	  tax_group			=> tax_group);

	EXIT WHEN no_more_records;

        line_count := line_count + 1;

        -- Update the entered debits and credits totals
        IF (first_in_group) THEN
	  total_ent_dr := ent_dr;
  	  total_ent_cr := ent_cr;
	ELSE
          total_ent_dr := total_ent_dr + ent_dr;
	  total_ent_cr := total_ent_cr + ent_cr;
	END IF;

        -- If this is the last in the group, then finish the group
        IF (last_in_group) THEN

	  -- Keep track of bad accounts
          IF (bad_acct) THEN
	    has_bad_accounts := TRUE;
 	  END IF;

	  IF (calculation_level <> 'L') THEN
	    -- Determine description for tax line
	    fnd_message.set_name('SQLGL', 'GL_CTAX_LINE_DESCRIPTION');
	    fnd_message.set_token('TAX_CODE', tax_code);
	    fnd_message.set_token('PERCENTAGE', to_char(tax_rate*100));
	    IF (bad_acct) THEN
	      tax_line_descr := substrb(bad_csegs||': '||fnd_message.get,
					1, 240);
	    ELSE
	      tax_line_descr := substrb(fnd_message.get, 1, 240);
	    END IF;

	    -- Calculate tax amount for tax line
            IF (incl_tax = 'Y') THEN
	      total_jtax_dr := round_it((total_ent_dr*tax_rate)/(1+tax_rate),
				        rounding_rule, curr_mau);
	      total_jtax_cr := round_it((total_ent_cr*tax_rate)/(1+tax_rate),
				        rounding_rule, curr_mau);
            ELSE
  	      total_jtax_dr := round_it(total_ent_dr * tax_rate,
				        rounding_rule, curr_mau);
	      total_jtax_cr := round_it(total_ent_cr * tax_rate,
				        rounding_rule, curr_mau);
	    END IF;
	    total_jtax_acc_dr := round_it(total_jtax_dr * conv_rate,
				          rounding_rule, tax_mau);
	    total_jtax_acc_cr := round_it(total_jtax_cr * conv_rate,
				          rounding_rule, tax_mau);

	    -- Calculate tax amount for last taxable line
	    IF (first_in_group) THEN
  	      line_tax_dr := total_jtax_dr;
	      line_tax_cr := total_jtax_cr;
	      line_tax_acc_dr := total_jtax_acc_dr;
	      line_tax_acc_cr := total_jtax_acc_cr;
	    ELSE
  	      line_tax_dr := total_jtax_dr - total_ltax_dr;
	      line_tax_cr := total_jtax_cr - total_ltax_cr;
	      line_tax_acc_dr := total_jtax_acc_dr - total_ltax_acc_dr;
	      line_tax_acc_cr := total_jtax_acc_cr - total_ltax_acc_cr;
	    END IF;
	  ELSE
	    -- Determine description for tax line
	    fnd_message.set_name('SQLGL', 'GL_CTAX_JOURNAL_DESCRIPTION');
	    fnd_message.set_token('TAX_CODE', tax_code);
	    fnd_message.set_token('PERCENTAGE', to_char(tax_rate*100));
            fnd_message.set_token('LINE_NUM', to_char(line_num));
	    fnd_message.set_token('LINE_DESCRIPTION', description);
	    IF (bad_acct) THEN
	      tax_line_descr := substrb(bad_csegs||': '||fnd_message.get,
					1, 240);
	    ELSE
	      tax_line_descr := substrb(fnd_message.get,1,240);
	    END IF;

	    -- Calculate tax amount for line
            IF (incl_tax = 'Y') THEN
	      line_tax_dr := round_it((ent_dr*tax_rate)/(1+tax_rate),
				      rounding_rule, curr_mau);
	      line_tax_cr := round_it((ent_cr*tax_rate)/(1+tax_rate),
				      rounding_rule, curr_mau);
            ELSE
  	      line_tax_dr := round_it(ent_dr * tax_rate,
				      rounding_rule, curr_mau);
	      line_tax_cr := round_it(ent_cr * tax_rate,
				      rounding_rule, curr_mau);
	    END IF;
	    line_tax_acc_dr := round_it(line_tax_dr * conv_rate,
				        rounding_rule, tax_mau);
	    line_tax_acc_cr := round_it(line_tax_cr * conv_rate,
				        rounding_rule, tax_mau);

	    total_jtax_dr := line_tax_dr;
	    total_jtax_cr := line_tax_cr;
	    total_jtax_acc_dr := line_tax_acc_dr;
	    total_jtax_acc_cr := line_tax_acc_cr;
	  END IF;

          INSERT INTO gl_je_lines
	    (ledger_id, je_header_id, je_line_num,
	     code_combination_id, status,
	     period_name, effective_date,
	     entered_dr, entered_cr,
	     accounted_dr, accounted_cr,
	     taxable_line_flag, tax_line_flag, tax_group_id,
	     description,
	     creation_date, created_by,
	     last_update_date, last_updated_by, last_update_login)
	  VALUES
	    (lgr_id, header_id, next_line_num,
	     tax_ccid, 'U',
	     per_name, eff_date,
	     total_jtax_dr, total_jtax_cr,
	     total_jtax_acc_dr, total_jtax_acc_cr,
	     'N', 'Y', tax_group,
	     ltrim(rtrim(tax_line_descr)),
	     sysdate, user_id,
	     sysdate, user_id, login_id);

	  -- Clear everything out
	  total_ent_dr := null;
	  total_ent_cr := null;
          total_jtax_dr := null;
          total_jtax_cr := null;
  	  total_jtax_acc_dr := null;
	  total_jtax_acc_cr := null;
          total_ltax_dr := null;
          total_ltax_cr := null;
  	  total_ltax_acc_dr := null;
	  total_ltax_acc_cr := null;

	  -- Get the next line number
	  next_line_num := next_line_num + 1;
	ELSE
	  -- Calculate tax amount for line
          IF (incl_tax = 'Y') THEN
	    line_tax_dr := round_it((ent_dr*tax_rate)/(1+tax_rate),
				    rounding_rule, curr_mau);
	    line_tax_cr := round_it((ent_cr*tax_rate)/(1+tax_rate),
				    rounding_rule, curr_mau);
          ELSE
  	    line_tax_dr := round_it(ent_dr * tax_rate,
				    rounding_rule, curr_mau);
	    line_tax_cr := round_it(ent_cr * tax_rate,
				    rounding_rule, curr_mau);
	  END IF;
	  line_tax_acc_dr := round_it(line_tax_dr * conv_rate,
				      rounding_rule, tax_mau);
	  line_tax_acc_cr := round_it(line_tax_cr * conv_rate,
				      rounding_rule, tax_mau);

	  -- Update the totals
	  IF (first_in_group) THEN
 	    total_ltax_dr := line_tax_dr;
	    total_ltax_cr := line_tax_cr;
	    total_ltax_acc_dr := line_tax_acc_dr;
	    total_ltax_acc_cr := line_tax_acc_cr;
	  ELSE
 	    total_ltax_dr := total_ltax_dr + line_tax_dr;
	    total_ltax_cr := total_ltax_cr + line_tax_cr;
	    total_ltax_acc_dr := total_ltax_acc_dr + line_tax_acc_dr;
	    total_ltax_acc_cr := total_ltax_acc_cr + line_tax_acc_cr;
	  END IF;
        END IF;

	UPDATE gl_je_lines jel
	SET    entered_dr = decode(incl_tax,
				   'Y', jel.entered_dr - line_tax_dr,
				   jel.entered_dr),
	       entered_cr = decode(incl_tax,
				   'Y', jel.entered_cr - line_tax_cr,
				   jel.entered_cr),
	       accounted_dr = decode(incl_tax,
				     'Y', jel.accounted_dr - line_tax_acc_dr,
				     jel.accounted_dr),
	       accounted_cr = decode(incl_tax,
				     'Y', jel.accounted_cr - line_tax_acc_cr,
				     jel.accounted_cr),
	       tax_group_id = tax_group,
	       last_update_date = sysdate,
	       last_updated_by = user_id,
	       last_update_login = login_id
	WHERE jel.je_header_id = header_id
	AND   jel.je_line_num = line_num;

        first_in_group := last_in_group;
      END LOOP;

      -- Raise an error
      IF (line_count = 0) THEN
        IF (tax_level = 'B') THEN
          fnd_message.set_name('SQLGL', 'GL_CTAX_BATCH_NO_TAX_LINES');
          app_exception.raise_exception;
	ELSE
          fnd_message.set_name('SQLGL', 'GL_CTAX_JOURNAL_NO_TAX_LINES');
          app_exception.raise_exception;
	END IF;
      END IF;

      -- Update the running totals
      IF (    (tax_level = 'B')
	  AND (nvl(disp_header_id, -1) <> header_id)
         ) THEN
        UPDATE gl_je_headers
	SET tax_status_code = 'T',
	    last_updated_by = user_id,
	    last_update_date = sysdate,
	    last_update_login = login_id,
            (running_total_dr, running_total_cr,
	     running_total_accounted_dr, running_total_accounted_cr)
	       = (SELECT sum(entered_dr), sum(entered_cr),
		         sum(accounted_dr), sum(accounted_cr)
	          FROM   gl_je_lines
	          WHERE  je_header_id = header_id)
        WHERE je_header_id = header_id
        AND   tax_status_code = 'R';
      ELSE
        SELECT sum(entered_dr), sum(entered_cr),
	       sum(accounted_dr), sum(accounted_cr)
	INTO   header_total_dr, header_total_cr,
	       header_total_acc_dr, header_total_acc_cr
	FROM   gl_je_lines
	WHERE  je_header_id = header_id;
      END IF;
    END LOOP;

    -- Get the updated batch running totals, if necessary.
    IF (tax_level = 'B') THEN
      SELECT sum(running_total_dr), sum(running_total_cr),
	     sum(running_total_accounted_dr),
	     sum(running_total_accounted_cr)
      INTO   batch_total_dr, batch_total_cr,
	     batch_total_acc_dr, batch_total_acc_cr
      FROM   gl_je_headers
      WHERE  je_batch_id = batch_header_id
      AND    je_header_id <> nvl(disp_header_id, -1);

      IF (disp_header_id IS NOT NULL) THEN
        batch_total_dr := nvl(batch_total_dr, 0) + nvl(header_total_dr, 0);
        batch_total_cr := nvl(batch_total_cr, 0) + nvl(header_total_cr, 0);
        batch_total_acc_dr := nvl(batch_total_acc_dr, 0)
				+ nvl(header_total_acc_dr, 0);
        batch_total_acc_cr := nvl(batch_total_acc_cr, 0)
				+ nvl(header_total_acc_cr, 0);
      END IF;
    END IF;

    -- Close the cursors
    IF (tax_level = 'J') THEN
      CLOSE j_journals;
    ELSE
      CLOSE b_journals;
    END IF;
    gl_calculate_tax2_pkg.close_cursor;
  END calculate;

END GL_CALCULATE_TAX_PKG;

/
