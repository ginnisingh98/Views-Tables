--------------------------------------------------------
--  DDL for Package Body GL_ACCESS_SET_SECURITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_ACCESS_SET_SECURITY_PKG" AS
/* $Header: gluasecb.pls 120.9 2005/08/19 20:34:41 ticheng ship $ */

  --
  -- PRIVATE VARIABLES
  --
  c_access_set_id	NUMBER(15);
  c_coa_id		NUMBER(15);
  c_security_col	VARCHAR2(15);
  c_security_code       VARCHAR2(1);
  c_auto_created_flag   VARCHAR2(1);
  c_check_dates         BOOLEAN;

  --
  -- PRIVATE FUNCTIONS
  --

  --
  -- Function
  --   get_security_column
  --
  -- Purpose
  --   This function returns the security segment column name for the
  --   access set.
  --
  FUNCTION get_security_column(x_access_set_id  NUMBER) RETURN VARCHAR2 IS
    dumdum		BOOLEAN := FALSE;
    access_set_name	VARCHAR2(30);
    period_set_name	VARCHAR2(15);
    accounted_period_type  VARCHAR2(15);
    auto_created_flag	VARCHAR2(1);

    seg_name		VARCHAR2(30);
    secseg_left_prompt	VARCHAR2(80);
    value_set		VARCHAR2(60);

    secure_seg_num	NUMBER(15);
    security_col_name	VARCHAR2(15);
    coa_id		NUMBER(15);
  BEGIN
    IF (x_access_set_id = c_access_set_id AND c_access_set_id IS NOT NULL) THEN
      RETURN c_security_col;
    END IF;

    -- Reinitialize c_check_dates;
    c_check_dates := null;

    -- get coa id and security segment code information
    gl_access_sets_pkg.select_columns(
		x_access_set_id,
		access_set_name,
		c_security_code,
		coa_id,
		period_set_name,
		accounted_period_type,
		c_auto_created_flag);

    IF (c_security_code = 'F') THEN
      security_col_name := null;
    ELSE

      IF (c_security_code = 'B') THEN
	dumdum := FND_FLEX_APIS.get_qualifier_segnum(
			101, 'GL#', coa_id, 'GL_BALANCING', secure_seg_num);
      ELSIF (c_security_code = 'M') THEN
	dumdum := FND_FLEX_APIS.get_qualifier_segnum(
			101, 'GL#', coa_id, 'GL_MANAGEMENT', secure_seg_num);
      END IF;

      dumdum := FND_FLEX_APIS.get_segment_info(101, 'GL#', coa_id,
			secure_seg_num, security_col_name,
			seg_name, secseg_left_prompt, value_set);
    END IF;

    -- cache information to private global variables
    c_access_set_id := x_access_set_id;
    c_coa_id        := coa_id;
    c_security_col  := security_col_name;

    RETURN security_col_name;
  END get_security_column;

  --
  -- Function
  --   build_privilege_clause
  --
  -- Purpose
  --   This function builds the privilege clause part of a where clause.
  --
  FUNCTION build_privilege_clause(access_privilege_code VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF (access_privilege_code =
	gl_access_set_security_pkg.READ_ONLY_ACCESS) THEN
      RETURN ('');
    ELSIF (access_privilege_code =
	   gl_access_set_security_pkg.WRITE_ACCESS) THEN
      RETURN ('AND acc.access_privilege_code IN (''B'', ''F'') ');
    ELSIF (access_privilege_code =
	   gl_access_set_security_pkg.FULL_ACCESS) THEN
      RETURN ('AND acc.access_privilege_code = ''F'' ');
    ELSE
      fnd_message.set_name('SQLGL', 'GL_INVALID_PARAM');
      fnd_message.set_token('VALUE', access_privilege_code);
      fnd_message.set_token('PARAM', 'access_privilege_code');
      RAISE INVALID_PARAM;
    END IF;
  END build_privilege_clause;

  --
  -- Function
  --   build_date_clause
  --
  -- Purpose
  --   This function builds the date clause part of a where clause.
  --
  FUNCTION build_date_clause(edate DATE) RETURN VARCHAR2 IS
    edatestr VARCHAR2(200);
  BEGIN
    IF (edate IS NULL) THEN
      RETURN ('');
    ELSE
      edatestr := 'to_date(''' || to_char(edate, 'MM-DD-YYYY') ||
		  ''',''MM-DD-YYYY'') ';

      RETURN ('AND '|| edatestr ||
	      'BETWEEN nvl(trunc(acc.start_date), ' || edatestr || '-1) ' ||
	      'AND nvl(trunc(acc.end_date), ' || edatestr || '+1) ');
    END IF;
  END build_date_clause;


  --
  -- Function
  --   check_dates
  --
  -- Purpose
  --   This function determines if date checking is necessary.
  --
  FUNCTION check_dates(c_access_set_id NUMBER) RETURN BOOLEAN IS
    dumdum              VARCHAR2(60);
    security_col	VARCHAR2(15);
  BEGIN
    -- Initialize the access set information.  This call initializes
    -- the c_auto_created_flag global variable.  It will also clear out
    -- c_check_dates if the access set changes
    security_col := get_security_column(c_access_set_id);

    IF (c_check_dates IS NOT NULL) THEN
      IF (c_check_dates) THEN
        RETURN TRUE;
      ELSE
        RETURN FALSE;
      END IF;
    END IF;

    c_check_dates := TRUE;
    -- If this access set is not an implicit one, then we don't need to check dates
    IF (c_auto_created_flag = 'N') THEN
      c_check_dates := FALSE;
    ELSE
      BEGIN
        SELECT 'associated with ledger'
        INTO dumdum
        FROM gl_access_sets acc, gl_ledgers lgr
        WHERE acc.access_set_id = c_access_set_id
        AND   lgr.ledger_id = acc.default_ledger_id
        AND   lgr.implicit_access_set_id = acc.access_set_id
        AND   lgr.object_type_code = 'L';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          c_check_dates := FALSE;
      END;
    END IF;

    return(c_check_dates);
  END check_dates;


  --
  -- PUBLIC FUNCTIONS
  --

  FUNCTION get_security_clause( access_set_id		NUMBER,
				access_privilege_code	VARCHAR2,
				ledger_check_mode	VARCHAR2,
				ledger_context		VARCHAR2,
				ledger_table_alias	VARCHAR2,
				segval_check_mode	VARCHAR2,
				segval_context		VARCHAR2,
				segval_table_alias	VARCHAR2,
				edate			DATE ) RETURN VARCHAR2 IS
    security_col	VARCHAR2(15);
    segval_mode		VARCHAR2(15) := segval_check_mode;
    ledger_table	VARCHAR2(30);
    segval_table	VARCHAR2(30);

    dum_num		NUMBER(15);
  BEGIN

    IF (segval_mode = gl_access_set_security_pkg.CHECK_SEGVALS) THEN
      security_col := get_security_column(access_set_id);

      -- If the security column is null (Ledger Only access set), then segment
      -- values will not be validated.
      IF (security_col IS NULL) THEN
        segval_mode := gl_access_set_security_pkg.NO_SEG_VALIDATION;
      END IF;
    END IF;

    IF (ledger_table_alias IS NOT NULL) THEN
      ledger_table := ledger_table_alias || '.';
    ELSE
      ledger_table := '';
    END IF;

    IF (segval_table_alias IS NOT NULL) THEN
      segval_table := segval_table_alias || '.';
    ELSE
      segval_table := '';
    END IF;

    IF (ledger_check_mode = gl_access_set_security_pkg.CHECK_LEDGER_COLUMN) THEN

      IF (ledger_context IS NULL) THEN
	fnd_message.set_name('SQLGL', 'GL_INVALID_PARAM');
        fnd_message.set_token('VALUE', ledger_context);
	fnd_message.set_token('PARAM', 'ledger_context');
	RAISE INVALID_PARAM;
      END IF;

      IF (segval_mode = gl_access_set_security_pkg.NO_SEG_VALIDATION) THEN
	RETURN (ledger_table || ledger_context || ' IN ( ' ||
		'SELECT acc.ledger_id ' ||
		'FROM gl_access_set_ledgers acc ' ||
		'WHERE acc.access_set_id = ' || to_char(access_set_id) || ' '||
		gl_access_set_security_pkg.build_privilege_clause(access_privilege_code) ||
		gl_access_set_security_pkg.build_date_clause(edate) || ')' );
      ELSIF (segval_mode = gl_access_set_security_pkg.CHECK_SEGVALS) THEN
	RETURN ('(' || ledger_table || ledger_context || ', ' ||
		segval_table || security_col || ') IN ( ' ||
		'SELECT acc.ledger_id, acc.segment_value ' ||
		'FROM gl_access_set_assignments acc ' ||
		'WHERE acc.access_set_id = ' || to_char(access_set_id) || ' '||
		gl_access_set_security_pkg.build_privilege_clause(access_privilege_code) ||
		gl_access_set_security_pkg.build_date_clause(edate) || ')' );
      END IF;

    ELSIF (ledger_check_mode = gl_access_set_security_pkg.CHECK_LEDGER_ID) THEN

      BEGIN
	SELECT to_number(ledger_context)
	INTO dum_num
	FROM dual;

	IF (ledger_context IS NULL) THEN
	  RAISE INVALID_NUMBER;
	END IF;

      EXCEPTION
	WHEN INVALID_NUMBER THEN
	  fnd_message.set_name('SQLGL', 'GL_INVALID_PARAM');
          fnd_message.set_token('VALUE', ledger_context);
	  fnd_message.set_token('PARAM', 'ledger_context');
	RAISE INVALID_PARAM;

      END;

      IF (segval_mode = gl_access_set_security_pkg.NO_SEG_VALIDATION) THEN
	RETURN ('');
      ELSIF (segval_mode = gl_access_set_security_pkg.CHECK_SEGVALS) THEN
	RETURN (segval_table || security_col || ' IN ( ' ||
		'SELECT acc.segment_value ' ||
		'FROM gl_access_set_assignments acc ' ||
		'WHERE acc.access_set_id = ' || to_char(access_set_id) || ' '||
		'AND   acc.ledger_id = ' || ledger_context || ' ' ||
		gl_access_set_security_pkg.build_privilege_clause(access_privilege_code) ||
		gl_access_set_security_pkg.build_date_clause(edate) || ')' );
      END IF;

    ELSIF (ledger_check_mode = gl_access_set_security_pkg.NO_LEDGER) THEN
      IF (segval_mode = gl_access_set_security_pkg.NO_SEG_VALIDATION) THEN
	RETURN ('');
      ELSIF (segval_mode = gl_access_set_security_pkg.CHECK_SEGVALS) THEN
	RETURN (segval_table || security_col || ' IN ( ' ||
		'SELECT acc.segment_value ' ||
		'FROM gl_access_set_assignments acc ' ||
		'WHERE acc.access_set_id = ' || to_char(access_set_id) || ' '||
		gl_access_set_security_pkg.build_privilege_clause(access_privilege_code) ||
		gl_access_set_security_pkg.build_date_clause(edate) || ')' );
      END IF;

    ELSE
      fnd_message.set_name('SQLGL', 'GL_INVALID_PARAM');
      fnd_message.set_token('VALUE', ledger_check_mode);
      fnd_message.set_token('PARAM', 'ledger_check_mode');
      RAISE INVALID_PARAM;
    END IF;

    fnd_message.set_name('SQLGL', 'GL_INVALID_PARAM');
    fnd_message.set_token('VALUE', segval_check_mode);
    fnd_message.set_token('PARAM', 'segval_check_mode');
    RAISE INVALID_PARAM;

  END get_security_clause;

  FUNCTION get_journal_security_clause( access_set_id		NUMBER,
				        access_privilege_code	VARCHAR2,
				        segval_check_mode	VARCHAR2,
				        journal_table_alias	VARCHAR2,
				        check_edate		BOOLEAN )
  RETURN VARCHAR2 IS
    security_col	VARCHAR2(15);
    security_code       VARCHAR2(1);
    segval_mode		VARCHAR2(15) := segval_check_mode;

    retstring           VARCHAR2(2000);
    need_check_edate    BOOLEAN;
    edatestr            VARCHAR2(500) := null;
  BEGIN

    -- First, get an in clause with just ledgers, for efficiency
    retstring := gl_access_set_security_pkg.get_security_clause(
                   access_set_id,
                   access_privilege_code,
                   gl_access_set_security_pkg.CHECK_LEDGER_COLUMN,
                   'LEDGER_ID',
                   journal_table_alias,
                   gl_access_set_security_pkg.NO_SEG_VALIDATION,
                   NULL,
                   NULL,
                   NULL);

    -- Initialize the access set information.  This call initializes
    -- the c_security_code global variable.
    security_col := get_security_column(access_set_id);
    security_code := c_security_code;

    -- See if we really need to check dates.  We only need to check dates
    -- for implicitly created access sets that were created for ledgers.
    need_check_edate := FALSE;
--    IF (check_edate) THEN
--      IF (gl_access_set_security_pkg.check_dates(access_set_id)) THEN
--        need_check_edate := TRUE;
--      END IF;
--    END IF;

    -- If the caller doesn't want segment validation or this is a ledger-only
    -- access set, then only check segment values
    IF (   (segval_mode = gl_access_set_security_pkg.NO_SEG_VALIDATION)
        OR (security_col IS NULL)
       ) THEN
      IF (access_privilege_code = gl_access_set_security_pkg.READ_ONLY_ACCESS) THEN
        IF (need_check_edate) THEN
          -- We know that the ledger is good, we just need to check the date.
          RETURN(retstring || ' '||
            'AND EXISTS ' ||
                '(SELECT ''valid date'' '||
                'FROM gl_access_set_ledgers acc ' ||
                'WHERE acc.access_set_id = ' || to_char(access_set_id) || ' '||
                'AND   acc.ledger_id = '||journal_table_alias||'.ledger_id '||
                'AND   '||journal_table_alias||'.default_effective_date ' ||
                       'BETWEEN nvl(acc.start_date, '||
                           journal_table_alias||'.default_effective_date-1) '||
                       'AND     nvl(acc.end_date, '||
                           journal_table_alias||'.default_effective_date+1) '||
                ')');
        ELSE
          RETURN(retstring);
        END IF;
      ELSE
        IF (need_check_edate) THEN
          edatestr :=
                'AND   sv.default_effective_date ' ||
                       'BETWEEN nvl(acc.start_date, sv.default_effective_date-1) '||
                       'AND     nvl(acc.end_date, sv.default_effective_date+1) ';
        END IF;

        -- For write access, just check the other journals in the batch
        RETURN(retstring || ' '||
          'AND NOT EXISTS ' ||
                '(SELECT ''unwriteable journal'' '||
                'FROM gl_je_headers sv ' ||
                'WHERE sv.je_batch_id = '||journal_table_alias||'.je_batch_id '||
                   'AND NOT EXISTS ' ||
                      '(SELECT ''no access'' ' ||
                       'FROM gl_access_set_ledgers acc ' ||
                       'WHERE  acc.access_set_id = ' || to_char(access_set_id) || ' '||
                       'AND   acc.ledger_id = sv.ledger_id '||
                       'AND   acc.access_privilege_code IN (''B'', ''F'') '||
                        edatestr || '))');
      END IF;
    END IF;

    IF (access_privilege_code = gl_access_set_security_pkg.READ_ONLY_ACCESS) THEN
      IF (need_check_edate) THEN
        edatestr :=
               'AND   '||journal_table_alias||'.default_effective_date ' ||
                      'BETWEEN nvl(acc.start_date, '||
                                  journal_table_alias||'.default_effective_date-1) '||
                      'AND     nvl(acc.end_date, ' ||
                                  journal_table_alias||'.default_effective_date+1) ';
      END IF;

      RETURN(retstring || ' '||
        'AND EXISTS ' ||
              '(SELECT ''readable line'' '||
               'FROM gl_je_segment_values sv, ' ||
                    'gl_access_set_assignments acc ' ||
               'WHERE sv.je_header_id = '||journal_table_alias||'.je_header_id '||
               'AND   sv.segment_type_code = '''||security_code||''' '||
               'AND   acc.access_set_id = '||to_char(access_set_id)|| ' '||
               'AND   acc.ledger_id = '||journal_table_alias||'.ledger_id '||
               'AND   acc.segment_value = sv.segment_value '||
               edatestr || ') ');
    ELSE -- WRITE_ACCESS
      IF (need_check_edate) THEN
        edatestr :=
                   'AND   sv2.default_effective_date ' ||
                       'BETWEEN nvl(acc.start_date, sv2.default_effective_date-1) '||
                       'AND     nvl(acc.end_date, sv2.default_effective_date+1) ';
      END IF;

      RETURN(retstring || ' '||
        'AND NOT EXISTS ' ||
              '(SELECT ''unwriteable line'' '||
               'FROM gl_je_segment_values sv, gl_je_headers sv2 ' ||
               'WHERE sv2.je_batch_id = '||journal_table_alias||'.je_batch_id '||
               'AND   sv.je_header_id = sv2.je_header_id ' ||
               'AND   sv.segment_type_code = '''||security_code||''' '||
               'AND NOT EXISTS '||
                  '(SELECT ''unwriteable line'' ' ||
                   'FROM gl_access_set_assignments acc ' ||
                   'WHERE   acc.access_set_id = '||to_char(access_set_id)|| ' '||
                   'AND   acc.ledger_id = sv2.ledger_id '||
                   'AND   acc.segment_value = sv.segment_value '||
                   'AND   acc.access_privilege_code = ''B'' '||
                   edatestr || ')) ');
    END IF;

  END get_journal_security_clause;

  FUNCTION get_batch_security_clause( access_set_id		NUMBER,
				      access_privilege_code	VARCHAR2,
				      segval_check_mode		VARCHAR2,
				      batch_table_alias		VARCHAR2,
				      check_edate		BOOLEAN )
  RETURN VARCHAR2 IS
    security_col	VARCHAR2(15);
    security_code       VARCHAR2(1);
    segval_mode		VARCHAR2(15) := segval_check_mode;
    ledger_table	VARCHAR2(30);
    segval_table	VARCHAR2(30);

    retstring           VARCHAR2(2000);
    dum_num		NUMBER(15);
    edatestr            VARCHAR2(500) := null;
  BEGIN

    -- Initialize the access set information.  This call initializes
    -- the c_security_code global variable.
    security_col := get_security_column(access_set_id);
    security_code := c_security_code;

    -- See if we really need to check dates.  We only need to check dates
    -- for implicitly created access sets that were created for ledgers.
    --IF (check_edate) THEN
    --  IF (gl_access_set_security_pkg.check_dates(access_set_id)) THEN
    --    edatestr :=
    --       'AND   jeh.default_effective_date ' ||
    --       'BETWEEN nvl(acc.start_date, jeh.default_effective_date-1) '||
    --       'AND     nvl(acc.end_date, jeh.default_effective_date+1) ';
    --  END IF;
    --END IF;

    -- If the caller doesn't want segment validation or this is a ledger-only
    -- access set, then build a statement without segment validation
    IF (   (segval_mode = gl_access_set_security_pkg.NO_SEG_VALIDATION)
        OR (security_col IS NULL)) THEN
      IF (access_privilege_code = gl_access_set_security_pkg.READ_ONLY_ACCESS) THEN
        RETURN(
          'EXISTS ' ||
                '(SELECT ''readable journal'' '||
                 'FROM gl_je_headers jeh, ' ||
                      'gl_access_set_ledgers acc ' ||
                 'WHERE jeh.je_batch_id = '||batch_table_alias||'.je_batch_id '||
                 'AND   acc.access_set_id = '||to_char(access_set_id)||' '||
                 'AND   acc.ledger_id = jeh.ledger_id ' ||
                 edatestr || ') ');
      ELSE -- write access
        RETURN(
          'NOT EXISTS ' ||
             '(SELECT ''unwriteable journal'' '||
              'FROM gl_je_headers jeh ' ||
              'WHERE jeh.je_batch_id = '||batch_table_alias||'.je_batch_id '||
              'AND NOT EXISTS ' ||
                '(SELECT ''unwriteable journal'' '||
                 'FROM gl_access_set_ledgers acc ' ||
                 'WHERE acc.access_set_id = '||to_char(access_set_id)||' '||
                 'AND   acc.ledger_id = jeh.ledger_id ' ||
                 'AND   acc.access_privilege_code IN (''B'', ''F'') '||
                 edatestr || ')) ');
      END IF;

    ELSE -- Need to check segment values
      IF (access_privilege_code = gl_access_set_security_pkg.READ_ONLY_ACCESS) THEN
        RETURN(
          'EXISTS ' ||
                '(SELECT ''readable line'' '||
                 'FROM gl_je_headers jeh, '||
                      'gl_je_segment_values sv, ' ||
                      'gl_access_set_assignments acc ' ||
                 'WHERE jeh.je_batch_id = '||batch_table_alias||'.je_batch_id '||
                 'AND   sv.je_header_id = jeh.je_header_id '||
                 'AND   sv.segment_type_code = '''||security_code||''' '||
                 'AND   acc.access_set_id = '||to_char(access_set_id)|| ' '||
                 'AND   acc.ledger_id = jeh.ledger_id '||
                 'AND   acc.segment_value = sv.segment_value '||
                 edatestr || ') ');
      ELSE -- WRITE_ACCESS
        RETURN(
          'NOT EXISTS ' ||
              '(SELECT ''unwriteable line'' '||
               'FROM gl_je_headers jeh, '||
                    'gl_je_segment_values sv ' ||
               'WHERE jeh.je_batch_id = '||batch_table_alias||'.je_batch_id '||
               'AND   sv.je_header_id = jeh.je_header_id '||
               'AND   sv.segment_type_code = '''||security_code||''' '||
               'AND NOT EXISTS '||
                  '(SELECT ''unwriteable line'' ' ||
                   'FROM gl_access_set_assignments acc ' ||
                   'WHERE   acc.access_set_id = '||to_char(access_set_id)|| ' '||
                   'AND   acc.ledger_id = jeh.ledger_id '||
                   'AND   acc.segment_value = sv.segment_value '||
                   'AND   acc.access_privilege_code = ''B'' '||
                   edatestr || ')) ');
      END IF;
    END IF;
  END get_batch_security_clause;

  FUNCTION get_journal_access ( access_set_id            IN NUMBER,
                                header_only              IN BOOLEAN,
                                check_mode               IN VARCHAR2,
                                je_id                    IN NUMBER )
           RETURN VARCHAR2 IS
    security_col  VARCHAR2(15);
    security_code VARCHAR2(1);
    access_level  VARCHAR2(1);
    dummy         VARCHAR2(25);
    sqlbuf        VARCHAR2(2000);
    lines_exist   BOOLEAN;
  BEGIN
    -- Initialize the access set information.  This call initializes
    -- the c_security_code global variable.
    security_col := get_security_column(access_set_id);
    security_code := c_security_code;

    -- Verify whether any lines exist
    lines_exist := FALSE;
    IF (security_code IS NOT NULL) THEN
      BEGIN
        IF (NOT header_only) THEN
          SELECT 'has lines'
          INTO dummy
          FROM gl_je_headers jeh
          WHERE jeh.je_batch_id = je_id
          AND rownum = 1;
        ELSE
          -- Check for lines
          SELECT 'has lines'
          INTO dummy
          FROM gl_je_headers jeh
          WHERE jeh.je_header_id = je_id
          AND rownum = 1;
        END IF;

        lines_exist := TRUE;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          -- If it has journals but no lines, then only check journals
          security_code := NULL;
      END;
    END IF;

    -- If we haven't found lines (or haven't checked) and we are
    -- checking a batch, then verify that at least one journal exists
    IF (NOT lines_exist AND NOT header_only) THEN
      BEGIN
        SELECT 'has journals'
        INTO dummy
        FROM gl_je_headers jeh
        WHERE jeh.je_batch_id = je_id
        AND rownum = 1;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          -- Anyone can write to a batch with no journals
          RETURN(nvl(check_mode,gl_access_set_security_pkg.WRITE_ACCESS));
      END;
    END IF;

    -- Check whether we are to check for write access
    IF (nvl(check_mode,gl_access_set_security_pkg.WRITE_ACCESS)
          <> gl_access_set_security_pkg.READ_ONLY_ACCESS) THEN

      sqlbuf := 'SELECT ''no write'' '||
                'FROM dual ' ||
                'WHERE EXISTS ' ||
                   '(SELECT ''no write'' ' ||
                    'FROM gl_je_headers jeh ';

      -- For ledger-only access sets, don't include gl_je_segment_values
      IF (security_col IS NOT NULL) THEN
        sqlbuf := sqlbuf ||
                         ', gl_je_segment_values sv ';
      END IF;

      IF (header_only) THEN
        sqlbuf := sqlbuf ||
                    'WHERE jeh.je_header_id = :object_id ';
      ELSE
        sqlbuf := sqlbuf ||
                    'WHERE jeh.je_batch_id = :object_id ';
      END IF;

      -- For ledger-only access sets, don't include gl_je_segment_values
      IF (security_col IS NOT NULL) THEN
        sqlbuf := sqlbuf ||
                    'AND sv.je_header_id = jeh.je_header_id ' ||
                    'AND sv.segment_type_code = :security_seg ';
      END IF;

      sqlbuf := sqlbuf ||
                    'AND NOT EXISTS ' ||
                       '(SELECT ''write row'' '||
                        'FROM gl_access_set_assignments asa ' ||
                        'WHERE asa.access_set_id = :access_set_id ' ||
                        'AND asa.ledger_id = jeh.ledger_id ' ||
                        'AND asa.access_privilege_code = ''B'' ';

      IF (security_col IS NOT NULL) THEN
        sqlbuf := sqlbuf ||
                        'AND asa.segment_value = sv.segment_value ';

      END IF;

      sqlbuf := sqlbuf ||
                      'AND jeh.default_effective_date BETWEEN NVL(asa.start_date, '||
                              'jeh.default_effective_date - 1) '||
                          'AND NVL(asa.end_date, ' ||
                              'jeh.default_effective_date + 1))) ';

      BEGIN
        IF (security_col IS NOT NULL)THEN
          EXECUTE IMMEDIATE sqlbuf
                  INTO dummy
                  USING IN je_id,
                        IN security_code,
                        IN access_set_id;
        ELSE
          EXECUTE IMMEDIATE sqlbuf
                  INTO dummy
                  USING IN je_id,
                        IN access_set_id;
        END IF;

      EXCEPTION
        -- If nothing has been returned then we know that we DO
        -- have write, so return write
        WHEN NO_DATA_FOUND THEN
          RETURN(gl_access_set_security_pkg.WRITE_ACCESS);
      END;
    END IF;

    -- Check whether we are to check for read-only access
    IF (nvl(check_mode, gl_access_set_security_pkg.READ_ONLY_ACCESS)
          <> gl_access_set_security_pkg.WRITE_ACCESS) THEN
      sqlbuf := 'SELECT ''has read'' '||
                'FROM dual ' ||
                'WHERE EXISTS ' ||
                    '(SELECT ''has read'' ' ||
                     'FROM gl_je_headers jeh, ';

      -- For ledger-only access sets, don't include gl_je_segment_values
      IF (security_col IS NOT NULL) THEN
        sqlbuf := sqlbuf ||
                          'gl_je_segment_values sv, ';
      END IF;

      sqlbuf := sqlbuf ||
                          'gl_access_set_assignments asa ';

      IF (header_only) THEN
        sqlbuf := sqlbuf ||
                     'WHERE jeh.je_header_id = :object_id ';
      ELSE
        sqlbuf := sqlbuf ||
                     'WHERE jeh.je_batch_id = :object_id ';
      END IF;

      -- For ledger-only access sets, don't include gl_je_segment_values
      IF (security_col IS NOT NULL) THEN
        sqlbuf := sqlbuf ||
                     'AND sv.je_header_id = jeh.je_header_id ' ||
                     'AND sv.segment_type_code = :security_seg ' ||
                     'AND asa.segment_value = sv.segment_value ';
      END IF;

      sqlbuf := sqlbuf ||
                     'AND asa.access_set_id = :access_set_id ' ||
                     'AND asa.ledger_id = jeh.ledger_id ';

      sqlbuf := sqlbuf ||
                   'AND jeh.default_effective_date BETWEEN NVL(asa.start_date, '||
                                    'jeh.default_effective_date-1) '||
                                'AND NVL(asa.end_date, ' ||
                                    'jeh.default_effective_date+1)) ';

      BEGIN
        IF (security_col IS NOT NULL)THEN
          EXECUTE IMMEDIATE sqlbuf
                  INTO dummy
                  USING IN je_id,
                        IN security_code,
                        IN access_set_id;
        ELSE
          EXECUTE IMMEDIATE sqlbuf
                  INTO dummy
                  USING IN je_id,
                        IN access_set_id;
        END IF;

        IF (dummy IS NOT NULL) THEN
          RETURN(gl_access_set_security_pkg.READ_ONLY_ACCESS);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
    END IF;

    -- We haven't found anything, so return no access
    RETURN(gl_access_set_security_pkg.NO_ACCESS);
  END get_journal_access;

  FUNCTION get_default_ledger_id( x_access_set_id         NUMBER,
                                  x_access_privilege_code VARCHAR2 )
           RETURN NUMBER IS
    CURSOR sdl IS
      SELECT asl.ledger_id
      FROM   gl_access_set_ledgers asl
      WHERE  asl.access_set_id = x_access_set_id
      AND    asl.ledger_id = (select gas.default_ledger_id
                              from   gl_access_sets gas
                              where  gas.access_set_id = asl.access_set_id)
      AND    (   (    (x_access_privilege_code
                         = gl_access_set_security_pkg.FULL_ACCESS)
                  AND (asl.access_privilege_code = 'F'))
              OR (    (x_access_privilege_code
                         = gl_access_set_security_pkg.WRITE_ACCESS)
                  AND (asl.access_privilege_code IN ('F', 'B')))
              OR (x_access_privilege_code = 'R'));

    CURSOR gdl IS
      SELECT DISTINCT ledger_id
      FROM   gl_access_set_ledgers
      WHERE  access_set_id = x_access_set_id
      AND    (   (    (x_access_privilege_code
                         = gl_access_set_security_pkg.FULL_ACCESS)
                  AND (access_privilege_code = 'F'))
              OR (    (x_access_privilege_code
                         = gl_access_set_security_pkg.WRITE_ACCESS)
                  AND (access_privilege_code IN ('F', 'B')))
              OR (x_access_privilege_code = 'R'));

    x_ledger_id   NUMBER;
    x_ledger_id2  NUMBER;
  BEGIN
    IF (x_access_privilege_code NOT IN
         (gl_access_set_security_pkg.FULL_ACCESS,
          gl_access_set_security_pkg.WRITE_ACCESS,
          gl_access_set_security_pkg.READ_ONLY_ACCESS)) THEN
      RETURN NULL;
    END IF;

    -- First choice: check if the access set has default ledger assigned that
    -- satisfies the given access privilege level.
    OPEN sdl;
    FETCH sdl INTO x_ledger_id;
    IF sdl%FOUND THEN
      CLOSE sdl;
      RETURN (x_ledger_id);
    END IF;
    CLOSE sdl;

    -- Second choice: check if there is one and only one ledger assigned to
    -- this access set that satisfies the access privilege level
    OPEN gdl;
    FETCH gdl INTO x_ledger_id;
    IF gdl%FOUND THEN
      FETCH gdl INTO x_ledger_id2;
      IF gdl%FOUND THEN
        x_ledger_id := null;
      END IF;
    END IF;
    CLOSE gdl;

    RETURN (x_ledger_id);
  END get_default_ledger_id;

  FUNCTION get_access( x_access_set_id        NUMBER,
                       x_ledger_id            NUMBER,
                       x_seg_qualifier        VARCHAR2,
                       x_seg_val              VARCHAR2,
                       x_code_combination_id  NUMBER,
                       x_edate                DATE ) RETURN VARCHAR2 IS
    seg_val          VARCHAR2(30);
    acc_priv_code    VARCHAR2(1);
    security_col     VARCHAR2(15);
    sql_stmt         VARCHAR2(100);

    CURSOR check_access_ledger IS
      SELECT access_privilege_code
      FROM   gl_access_set_ledgers
      WHERE  access_set_id = x_access_set_id
      AND    ledger_id = x_ledger_id
      AND    (   (x_edate IS NULL)
              OR (trunc(x_edate) BETWEEN nvl(trunc(start_date), trunc(x_edate)-1)
                                 AND nvl(trunc(end_date), trunc(x_edate)+1)));

    CURSOR check_access_segment IS
      SELECT decode(max(decode(access_privilege_code, 'B', 2, 1)),
                    1, 'R', 2, 'B', 'N')
      FROM   gl_access_set_assignments
      WHERE  access_set_id = x_access_set_id
      AND    segment_value = seg_val
      AND    (   (x_edate IS NULL)
              OR (trunc(x_edate) BETWEEN nvl(trunc(start_date), trunc(x_edate)-1)
                                 AND nvl(trunc(end_date), trunc(x_edate)+1)));

    CURSOR check_access_ls IS
      SELECT access_privilege_code
      FROM   gl_access_set_assignments
      WHERE  access_set_id = x_access_set_id
      AND    ledger_id = x_ledger_id
      AND    segment_value = seg_val
      AND    (   (x_edate IS NULL)
              OR (trunc(x_edate) BETWEEN nvl(trunc(start_date), trunc(x_edate)-1)
                                 AND nvl(trunc(end_date), trunc(x_edate)+1)));

  BEGIN
    security_col := get_security_column(x_access_set_id);

    -- Resolve segment value
    IF (   (security_col IS NULL)
        OR (x_seg_qualifier IS NULL
            AND x_seg_val IS NULL
            AND x_code_combination_id IS NULL)) THEN
      -- It is a Ledger Only access set, or no segment information available:
      -- segment value will not be checked
      seg_val := null;

    ELSIF (x_seg_qualifier IS NULL OR x_seg_val IS NULL) THEN

      IF (x_code_combination_id IS NOT NULL) THEN
        -- find the segment value from ccid
        sql_stmt := 'SELECT max(' || security_col || ') ' ||
                    'FROM gl_code_combinations ' ||
                    'WHERE code_combination_id = :x_ccid';

        EXECUTE IMMEDIATE sql_stmt INTO seg_val USING x_code_combination_id;
      ELSE
        seg_val := null;
      END IF;

    ELSIF (   (c_security_code = 'B' AND x_seg_qualifier = 'GL_BALANCING')
           OR (c_security_code = 'M' AND x_seg_qualifier = 'GL_MANAGEMENT')) THEN
      -- use the segment value passed in
      seg_val := x_seg_val;
    END IF;

    -- Use the proper cursor to get the access level
    IF (x_ledger_id IS NULL) THEN

      IF (seg_val IS NULL) THEN   -- no check needed
        acc_priv_code := WRITE_ACCESS;
      ELSE                        -- only checks segment value
        OPEN check_access_segment;
        FETCH check_access_segment INTO acc_priv_code;
        IF (check_access_segment%NOTFOUND) THEN
          acc_priv_code := NO_ACCESS;
        END IF;
        CLOSE check_access_segment;
      END IF;

    ELSIF (seg_val IS NULL) THEN  -- only checks ledger
      OPEN check_access_ledger;
      FETCH check_access_ledger INTO acc_priv_code;
      IF (check_access_ledger%NOTFOUND) THEN
        acc_priv_code := NO_ACCESS;
      END IF;
      CLOSE check_access_ledger;

    ELSE                          -- checks both ledger and segment value
      OPEN check_access_ls;
      FETCH check_access_ls INTO acc_priv_code;
      IF (check_access_ls%NOTFOUND) THEN
        acc_priv_code := NO_ACCESS;
      END IF;
      CLOSE check_access_ls;
    END IF;

    RETURN acc_priv_code;
  END get_access;

END gl_access_set_security_pkg;

/
