--------------------------------------------------------
--  DDL for Package Body GL_CALCULATE_TAX2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_CALCULATE_TAX2_PKG" as
/* $Header: glujet2b.pls 120.3.12000000.2 2007/07/03 17:09:29 djogg ship $ */

  ---
  --- PRIVATE VARIABLES
  ---
  line_select		VARCHAR2(2000);  -- Buffer for line select dynamic sql
  ccid_select		VARCHAR2(4500);  -- Buffer for flex select dynamic sql

  lines_cursor		INTEGER;  -- Handles the lines cursor
  ccid_cursor		INTEGER;  -- Handles the flex cursor

  --- Variables for next line
  no_next_record	BOOLEAN;  -- Indicates there is no next record
  first_time		BOOLEAN;  -- Indicates this is the first time through
  next_line_num		NUMBER;  -- Number of next line
  next_eff_date		DATE;  -- effective date of line
  next_ent_dr		NUMBER;  -- line debits
  next_ent_cr		NUMBER;  -- line credits
  next_description	VARCHAR2(250);  -- line description
  next_rounding_rule	VARCHAR2(1);  -- line rounding rule
  next_incl_tax		VARCHAR2(1);  -- line includes tax
  next_tax_type		VARCHAR2(1);  -- line tax type
  next_tax_code_id	NUMBER;  -- line tax code id
  next_tax_code		VARCHAR2(50);  -- line tax code
  next_tax_rate		NUMBER;  -- line tax rate
  next_bal_seg_val	VARCHAR2(25);  -- balancing segment value for line
  next_tax_ccid		NUMBER;  -- tax ccid for line
  next_tax_group	NUMBER;  -- tax group for line
  next_tax_bad_acct	BOOLEAN;  -- indicates whether the account is bad
  next_tax_bad_csegs	VARCHAR2(750);  -- provides the bad account

  ---
  --- PRIVATE FUNCTIONS
  ---

  --
  -- Procedure
  --   build_selects
  -- Purpose
  --   Builds the dynamic sql statements needed
  -- History
  --   13-DEC-1996  D. J. Ogg    Created
  -- Arguments
  --   coa_id			Current chart of accounts
  --   calculation_level	Calculation level - journal or line
  -- Example
  --   gl_calculate_tax2_pkg.build_selects(1, 'L');
  -- Notes
  --
  PROCEDURE build_selects(coa_id			NUMBER,
			  calculation_level 		VARCHAR2) IS

    flexwherebuf	VARCHAR2(1500); -- Holds the flexfield portion of the
					-- where clause
    flexselectbuf	VARCHAR2(2000); -- Holds the flexfield portion of the
					-- select clause

    segcount		NUMBER; -- Number of segments in flexfield
    delim       	VARCHAR2(1); -- Delimiter for flexfield
    bal_seg_num		NUMBER; -- Number of balancing segment
    bal_seg_appcol	VARCHAR2(30); -- Database column holding balancing
                                      --segment

    appcol_name		VARCHAR2(30); -- Database column holding current
                                      -- segment
    seg_name		VARCHAR2(30); -- User name for current segment
    prompt		VARCHAR2(80); -- Prompt for current segment
    value_set_name	VARCHAR2(60); -- Value set for current segment

  BEGIN

    -- Get the balancing segment number
    IF (NOT fnd_flex_apis.get_qualifier_segnum(
      		appl_id 		=> 101,
      		key_flex_code		=> 'GL#',
      		structure_number	=> coa_id,
		flex_qual_name		=> 'GL_BALANCING',
		segment_number		=> bal_seg_num)) THEN
      app_exception.raise_exception;
    END IF;

    -- Get the delimiter
    delim := fnd_flex_apis.get_segment_delimiter(
      		x_application_id 	=> 101,
      		x_id_flex_code		=> 'GL#',
      		x_id_flex_num		=> coa_id);

    -- Get the number of segments
    SELECT count(*)
    INTO   segcount
    FROM   fnd_id_flex_segments
    WHERE  enabled_flag = 'Y'
    AND    id_flex_num = coa_id
    AND    application_id = 101
    AND    id_flex_code = 'GL#';

    flexwherebuf := '';
    flexselectbuf := '';

    -- Get the segment information and build the flexfield
    -- portions of the select statement
    FOR segnum IN 1..segcount LOOP
      IF (NOT fnd_flex_apis.get_segment_info(
	        x_application_id 	=> 101,
	        x_id_flex_code 		=> 'GL#',
	        x_id_flex_num		=> coa_id,
	        x_seg_num		=> segnum,
	        x_appcol_name		=> appcol_name,
	        x_seg_name		=> seg_name,
	        x_prompt		=> prompt,
	    	x_value_set_name	=> value_set_name)) THEN
        app_exception.raise_exception;
      END IF;

      IF (segnum = bal_seg_num) THEN
        bal_seg_appcol := appcol_name;

        flexselectbuf := flexselectbuf ||
                         'replace(:bal_seg_val, ''' ||
                         delim || ''', ''
'') ';
        flexwherebuf := flexwherebuf ||
                        'AND new_cc.' || appcol_name || '(+) = :bal_seg_val ';
      ELSE
        flexselectbuf := flexselectbuf ||
                         'replace(tax_cc.' || appcol_name || ', ''' ||
                         delim || ''', ''
'') ';
        flexwherebuf := flexwherebuf ||
                        'AND new_cc.' || appcol_name || '(+) = tax_cc.' ||
                        appcol_name || ' ';
      END IF;

      IF (segnum <> segcount) THEN
        flexselectbuf := flexselectbuf || ' || ''' || delim || ''' || ';
      END IF;
    END LOOP;


    ---
    --- Build the line select statement
    ---

    line_select := 'SELECT jel.je_line_num, jel.effective_date, ' ||
                          'jel.entered_dr, jel.entered_cr, ' ||
                          'jel.tax_rounding_rule_code, jel.description, ' ||
                          'jel.amount_includes_tax_flag, ' ||
		          'jel.tax_type_code, jel.tax_code_id, ' ||
		          'cc.'||bal_seg_appcol||' ' ||
                   'FROM gl_je_lines jel, ' ||
                        'gl_code_combinations cc ' ||
                   'WHERE jel.je_header_id = :header ' ||
                   'AND   jel.taxable_line_flag = ''Y'' ' ||
                   'AND   cc.code_combination_id = jel.code_combination_id ';

    IF (calculation_level = 'L') THEN
      line_select := line_select ||
                     'ORDER BY jel.je_line_num ';
    ELSE
      line_select := line_select ||
                     'ORDER BY jel.tax_type_code, jel.tax_code_id, ' ||
		              'jel.tax_rounding_rule_code, ' ||
			      'jel.amount_includes_tax_flag, ' ||
		              'cc.' || bal_seg_appcol || ', ' ||
			      'decode(jel.entered_dr, NULL, 1, 0), ' ||
			      'decode(jel.entered_cr, NULL, 1, 0), ' ||
			      'greatest(nvl(jel.entered_dr, 0), ' ||
				       'nvl(jel.entered_cr, 0)), ' ||
			      'jel.je_line_num ';
    END IF;


    ---
    --- Build the flex select statement
    ---
    ccid_select := 'SELECT new_cc.code_combination_id, ' ||
		   flexselectbuf ||
                   'FROM gl_code_combinations tax_cc, ' ||
			'gl_code_combinations new_cc  ' ||
                   'WHERE tax_cc.code_combination_id = :tax_ccid ' ||
		   'AND   tax_cc.chart_of_accounts_id = :coa_id ' ||
		   flexwherebuf ||
		   'AND   new_cc.template_id(+) IS NULL ' ||
		   'AND   new_cc.chart_of_accounts_id(+) = :coa_id ' ||
		   'AND   new_cc.enabled_flag(+) = ''Y'' ' ||
		   'AND   new_cc.detail_posting_allowed_flag(+) = ''Y'' ' ||
		   'AND   trunc(:eff_date) ' ||
                            'between trunc(nvl(new_cc.start_date_active(+),' ||
				              ':eff_date - 1)) ' ||
			    'and trunc(nvl(new_cc.end_date_active(+), ' ||
					  ':eff_date + 1))';

  END build_selects;


  --
  -- Procedure
  --   get_tax_ccid
  -- Purpose
  --   Gets the appropriate ccid to be used for tax
  -- History
  --   13-DEC-1996  D. J. Ogg    Created
  -- Arguments
  --   coa_id			Current chart of accounts
  --   tax_code			Tax code of current line
  --   non_bal_tax_ccid		Tax ccid with the wrong balancing segment value
  --   bal_seg_val		The correct balancing segment value
  --   journal_effective_date	Effective date of journal being taxed
  --   tax_ccid			Tax ccid for the current line
  --   bad_acct			Indicates that the tax account is bad
  --   bad_csegs		Gives the bad account
  -- Example
  --   gl_calculate_tax2_pkg.get_tax_ccid(1, 2, '01', '01-JAN-91',
  --                                      tax_ccid, bad_acct, bad_csegs);
  -- Notes
  --
  PROCEDURE get_tax_ccid(coa_id				NUMBER,
			 tax_code			VARCHAR2,
			 non_bal_tax_ccid		NUMBER,
			 bal_seg_val			VARCHAR2,
			 journal_eff_date		DATE,
			 resp_appl_id			NUMBER,
			 resp_id			NUMBER,
			 user_id			NUMBER,
			 tax_ccid		IN OUT NOCOPY	NUMBER,
			 bad_acct		IN OUT NOCOPY	BOOLEAN,
			 bad_csegs		IN OUT NOCOPY	VARCHAR2) IS

    row_count 		NUMBER;  -- Number of rows returned by fetch
    tax_csegs		VARCHAR2(750); -- Holds concatenated segments
    message		VARCHAR2(250);
  BEGIN
    dbms_sql.bind_variable(ccid_cursor, ':tax_ccid', non_bal_tax_ccid);
    dbms_sql.bind_variable(ccid_cursor, ':eff_date', journal_eff_date);
    dbms_sql.bind_variable(ccid_cursor, ':bal_seg_val', bal_seg_val);
    dbms_sql.bind_variable(ccid_cursor, ':coa_id', coa_id);

    row_count := dbms_sql.execute_and_fetch(ccid_cursor);

    IF (row_count = 0) THEN
      fnd_message.set_name('SQLGL', 'GL_CTAX_BAD_TAX_CCID');
      fnd_message.set_token('TAX_CODE', tax_code);
      app_exception.raise_exception;
    END IF;


    dbms_sql.column_value(ccid_cursor, 1, tax_ccid);
    dbms_sql.column_value(ccid_cursor, 2, tax_csegs);

    bad_acct := FALSE;
    bad_csegs := null;
    IF (tax_ccid IS NULL) THEN
      IF (NOT fnd_flex_keyval.validate_segs(
                operation	=> 'CREATE_COMBINATION',
		appl_short_name	=> 'SQLGL',
		key_flex_code	=> 'GL#',
		structure_number=> coa_id,
		concat_segments	=> tax_csegs,
                vrule		=> '\nSUMMARY_FLAG\nI\nAPPL=SQLGL;' ||
                                   'NAME=GL_CTAX_SUMMARY_ACCOUNT\nN\0' ||
                                   'GL_GLOBAL\nDETAIL_POSTING_ALLOWED\nI\n' ||
				   'APPL=SQLGL;' ||
                                   'NAME=GL_CTAX_DETAIL_POSTING\nY',
                validation_date	=> journal_eff_date,
		resp_appl_id	=> resp_appl_id,
		resp_id		=> resp_id,
		user_id		=> user_id)) THEN

	bad_acct := TRUE;
	bad_csegs := tax_csegs;
        tax_ccid := -1;
      ELSE
	tax_ccid := fnd_flex_keyval.combination_id;
      END IF;
    END IF;

  END get_tax_ccid;

  ---
  --- PUBLIC FUNCTIONS
  ---

  PROCEDURE define_cursor(coa_id			NUMBER,
			  calculation_level		VARCHAR2) IS
    tax_ccid	NUMBER; -- dummy column for define
    tax_csegs	VARCHAR2(750); -- dummy column for define
  BEGIN
    build_selects(coa_id		=> coa_id,
		  calculation_level	=> calculation_level);

    -- Setup the lines cursor
    lines_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(lines_cursor, line_select, dbms_sql.v7);
    dbms_sql.define_column(lines_cursor, 1, next_line_num);
    dbms_sql.define_column(lines_cursor, 2, next_eff_date);
    dbms_sql.define_column(lines_cursor, 3, next_ent_dr);
    dbms_sql.define_column(lines_cursor, 4, next_ent_cr);
    dbms_sql.define_column(lines_cursor, 5, next_rounding_rule, 1);
    dbms_sql.define_column(lines_cursor, 6, next_description, 250);
    dbms_sql.define_column(lines_cursor, 7, next_incl_tax, 1);
    dbms_sql.define_column(lines_cursor, 8, next_tax_type, 1);
    dbms_sql.define_column(lines_cursor, 9, next_tax_code_id);
    dbms_sql.define_column(lines_cursor, 10, next_bal_seg_val, 25);

    -- Setup the ccid cursor
    ccid_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(ccid_cursor, ccid_select, dbms_sql.v7);
    dbms_sql.define_column(ccid_cursor, 1, tax_ccid);
    dbms_sql.define_column(ccid_cursor, 2, tax_csegs, 750);
  END define_cursor;

  PROCEDURE bind_cursor(header_id		NUMBER) IS
  BEGIN
    dbms_sql.bind_variable(lines_cursor, ':header', header_id);
  END bind_cursor;

  PROCEDURE execute_cursor IS
    dummy NUMBER;
  BEGIN
    -- Setup everything for the fetch
    no_next_record := FALSE;
    first_time := TRUE;
    dummy := dbms_sql.execute(lines_cursor);
  END execute_cursor;

  PROCEDURE fetch_cursor(coa_id				NUMBER,
			 lgr_id                         NUMBER,
			 org_id                         NUMBER,
			 calculation_level		VARCHAR2,
			 journal_effective_date		DATE,
			 resp_appl_id			NUMBER,
			 resp_id			NUMBER,
			 user_id			NUMBER,
			 no_more_records	IN OUT NOCOPY	BOOLEAN,
			 last_in_group		IN OUT NOCOPY	BOOLEAN,
			 bad_acct		IN OUT NOCOPY  BOOLEAN,
			 bad_csegs		IN OUT NOCOPY	VARCHAR2,
			 line_num		IN OUT NOCOPY	NUMBER,
			 eff_date		IN OUT NOCOPY	DATE,
			 ent_dr			IN OUT NOCOPY	NUMBER,
			 ent_cr			IN OUT NOCOPY	NUMBER,
			 rounding_rule		IN OUT NOCOPY	VARCHAR2,
			 description		IN OUT NOCOPY	VARCHAR2,
			 incl_tax		IN OUT NOCOPY	VARCHAR2,
			 tax_code		IN OUT NOCOPY	VARCHAR2,
			 tax_rate		IN OUT NOCOPY	NUMBER,
			 tax_ccid		IN OUT NOCOPY	NUMBER,
			 tax_group		IN OUT NOCOPY	NUMBER) IS

      row_count		NUMBER;  -- number of rows fetched

      tax_type		VARCHAR2(1);  -- tax type of current row;
      tax_code_id	NUMBER;  -- tax code id of current row;
      bal_seg_val       VARCHAR2(25);  -- balancing segment value of current row

      non_bal_tax_ccid		NUMBER;  -- tax ccid associated with tax code of
					 -- current row.  May not have the correct
					 -- balancing segment value
      next_non_bal_tax_ccid	NUMBER;  -- tax ccid associated with tax code of
					 -- next row.  May not have the correct
					 -- balancing segment value
      temp_return_status varchar2(1);
      err_msg            varchar2(2000);
  BEGIN
      no_more_records := FALSE;
      last_in_group := FALSE;

      -- If there are no more records, then exit
      IF (no_next_record) THEN
        no_more_records := TRUE;
        RETURN;
      END IF;

      -- If this is the first time in, or the calculation
      -- level is line, then get the current row
      IF (   (first_time)
          OR (calculation_level = 'L')
         ) THEN

        row_count := dbms_sql.fetch_rows(lines_cursor);
	IF (row_count = 0) THEN
          no_more_records := TRUE;
          RETURN;
        END IF;

        -- Get a journal line
        dbms_sql.column_value(lines_cursor, 1, line_num);
        dbms_sql.column_value(lines_cursor, 2, eff_date);
        dbms_sql.column_value(lines_cursor, 3, ent_dr);
        dbms_sql.column_value(lines_cursor, 4, ent_cr);
        dbms_sql.column_value(lines_cursor, 5, rounding_rule);
        dbms_sql.column_value(lines_cursor, 6, description);
        dbms_sql.column_value(lines_cursor, 7, incl_tax);
        dbms_sql.column_value(lines_cursor, 8, tax_type);
        dbms_sql.column_value(lines_cursor, 9, tax_code_id);
        dbms_sql.column_value(lines_cursor, 10, bal_seg_val);

        -- Get the base tax rate and ccid
        zx_gl_tax_options_pkg.get_tax_rate_and_account
          (1.0, lgr_id, org_id, tax_type, tax_code_id,
           tax_rate, non_bal_tax_ccid, temp_return_status, err_msg);
        tax_rate := tax_rate / 100;

        IF (temp_return_status = 'E') THEN
          FND_MESSAGE.Set_Name('ZX', err_msg);
          fnd_message.set_token('PROCEDURE', 'gl_calculate_tax2_pkg.fetch_cursor');
          APP_EXCEPTION.Raise_Exception;
        ELSIF (temp_return_status = 'U') THEN
          fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
          fnd_message.set_token('PROCEDURE',  'gl_calculate_tax2_pkg.fetch_cursor');
          APP_EXCEPTION.Raise_Exception;
        END IF;

        -- Get the tax code
        zx_gl_tax_options_pkg.get_tax_rate_code
          (1.0, tax_type, tax_code_id, tax_code, temp_return_status, err_msg);

        IF (temp_return_status = 'E') THEN
          FND_MESSAGE.Set_Name('ZX', err_msg);
          fnd_message.set_token('PROCEDURE', 'gl_calculate_tax2_pkg.fetch_cursor');
          APP_EXCEPTION.Raise_Exception;
        ELSIF (temp_return_status = 'U') THEN
          fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
          fnd_message.set_token('PROCEDURE',  'gl_calculate_tax2_pkg.fetch_cursor');
          APP_EXCEPTION.Raise_Exception;
        END IF;

  	-- Get the tax group
        SELECT gl_je_lines_s.nextval
        INTO   tax_group
        FROM   sys.dual;

	-- Get the correct tax ccid
  	get_tax_ccid(coa_id		=> coa_id,
	 	     tax_code		=> tax_code,
		     non_bal_tax_ccid	=> non_bal_tax_ccid,
		     bal_seg_val	=> bal_seg_val,
		     journal_eff_date	=> journal_effective_date,
		     resp_appl_id	=> resp_appl_id,
		     resp_id		=> resp_id,
		     user_id		=> user_id,
		     tax_ccid		=> tax_ccid,
		     bad_acct		=> bad_acct,
		     bad_csegs		=> bad_csegs);

        next_tax_group := tax_group;
	next_tax_ccid := tax_ccid;
        next_tax_code := tax_code;
	next_tax_rate := tax_rate;

	first_time := FALSE;

      -- Otherwise, copy the current row from the next row fields
      ELSE
        line_num := next_line_num;
        eff_date := next_eff_date;
        ent_dr   := next_ent_dr;
        ent_cr   := next_ent_cr;
        rounding_rule := next_rounding_rule;
        description := next_description;
        incl_tax := next_incl_tax;
        tax_type := next_tax_type;
        tax_code_id := next_tax_code_id;
        tax_code := next_tax_code;
        tax_rate := next_tax_rate;
        tax_ccid := next_tax_ccid;
	bad_acct := next_tax_bad_acct;
	bad_csegs := next_tax_bad_csegs;
	tax_group := next_tax_group;
        bal_seg_val := next_bal_seg_val;
      END IF;

      -- If the calculation level is journal, then
      -- fetch the next row
      IF (calculation_level <> 'L') THEN
        row_count := dbms_sql.fetch_rows(lines_cursor);
	IF (row_count = 0) THEN
	  no_next_record := TRUE;
        END IF;

        dbms_sql.column_value(lines_cursor, 1, next_line_num);
        dbms_sql.column_value(lines_cursor, 2, next_eff_date);
        dbms_sql.column_value(lines_cursor, 3, next_ent_dr);
        dbms_sql.column_value(lines_cursor, 4, next_ent_cr);
        dbms_sql.column_value(lines_cursor, 5, next_rounding_rule);
        dbms_sql.column_value(lines_cursor, 6, next_description);
        dbms_sql.column_value(lines_cursor, 7, next_incl_tax);
        dbms_sql.column_value(lines_cursor, 8, next_tax_type);
        dbms_sql.column_value(lines_cursor, 9, next_tax_code_id);
        dbms_sql.column_value(lines_cursor, 10, next_bal_seg_val);
      END IF;

      -- Determine if the current record is the last one in its
      -- group
      IF (calculation_level = 'L') THEN
	last_in_group := TRUE;
      ELSIF (no_next_record) THEN
        last_in_group := TRUE;
      ELSIF (   (rounding_rule <> next_rounding_rule)
	     OR (incl_tax <> next_incl_tax)
             OR (tax_type <> next_tax_type)
             OR (tax_code_id <> next_tax_code_id)
             OR (bal_seg_val <> next_bal_seg_val)
             OR ((ent_dr IS NULL) <> (next_ent_dr IS NULL))
             OR ((ent_cr IS NULL) <> (next_ent_cr IS NULL))
            ) THEN
        last_in_group := TRUE;
      ELSE
        last_in_group := FALSE;
      END IF;

      IF (    (calculation_level <> 'L')
	  AND last_in_group
          AND NOT no_next_record) THEN

        -- Get the base tax rate and ccid
        zx_gl_tax_options_pkg.get_tax_rate_and_account
          (1.0, lgr_id, org_id, next_tax_type, next_tax_code_id,
           next_tax_rate, next_non_bal_tax_ccid, temp_return_status, err_msg);
        next_tax_rate := next_tax_rate / 100;

        IF (temp_return_status = 'E') THEN
          FND_MESSAGE.Set_Name('ZX', err_msg);
          fnd_message.set_token('PROCEDURE', 'gl_calculate_tax2_pkg.fetch_cursor');
          APP_EXCEPTION.Raise_Exception;
        ELSIF (temp_return_status = 'U') THEN
          fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
          fnd_message.set_token('PROCEDURE',  'gl_calculate_tax2_pkg.fetch_cursor');
          APP_EXCEPTION.Raise_Exception;
        END IF;

        -- Get the tax code
        zx_gl_tax_options_pkg.get_tax_rate_code
          (1.0, next_tax_type, next_tax_code_id, next_tax_code, temp_return_status, err_msg);

        IF (temp_return_status = 'E') THEN
          FND_MESSAGE.Set_Name('ZX', err_msg);
          fnd_message.set_token('PROCEDURE', 'gl_calculate_tax2_pkg.fetch_cursor');
          APP_EXCEPTION.Raise_Exception;
        ELSIF (temp_return_status = 'U') THEN
          fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
          fnd_message.set_token('PROCEDURE',  'gl_calculate_tax2_pkg.fetch_cursor');
          APP_EXCEPTION.Raise_Exception;
        END IF;

        -- Get a group id for the next set
        SELECT gl_je_lines_s.nextval
        INTO   next_tax_group
        FROM   sys.dual;

        -- Get the correct tax ccid for the next set
        get_tax_ccid(coa_id		=> coa_id,
	 	     tax_code		=> next_tax_code,
	    	     non_bal_tax_ccid	=> next_non_bal_tax_ccid,
		     bal_seg_val	=> next_bal_seg_val,
	    	     journal_eff_date	=> journal_effective_date,
		     resp_appl_id	=> resp_appl_id,
		     resp_id		=> resp_id,
		     user_id		=> user_id,
		     tax_ccid		=> next_tax_ccid,
		     bad_acct		=> next_tax_bad_acct,
		     bad_csegs		=> next_tax_bad_csegs);
      END IF;

  END fetch_cursor;

  PROCEDURE close_cursor IS
  BEGIN
    dbms_sql.close_cursor(lines_cursor);
    dbms_sql.close_cursor(ccid_cursor);
  END close_cursor;

END GL_CALCULATE_TAX2_PKG;

/
