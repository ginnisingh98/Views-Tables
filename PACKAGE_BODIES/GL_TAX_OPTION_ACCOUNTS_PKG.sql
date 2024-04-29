--------------------------------------------------------
--  DDL for Package Body GL_TAX_OPTION_ACCOUNTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_TAX_OPTION_ACCOUNTS_PKG" AS
/* $Header: glisttab.pls 120.6 2005/05/05 01:27:36 kvora ship $ */

  ---
  --- PRIVATE VARIABLES
  ---

  --- Position of the account segment
  acct_seg_num		NUMBER := null;


  ---
  --- PRIVATE FUNCTIONS
  ---

  --
  -- Procedure
  --   select_row
  -- Purpose
  --   Gets the row from gl_tax_option_accounts associated with
  --   the given account, ledger id, and organization.
  -- History
  --   05-DEC-96  D J Ogg  Created.
  -- Arguments
  --   recinfo 		A row from gl_tax_options
  -- Example
  --   gl_tax_option_accounts_pkg.select_row(recinfo);
  -- Notes
  --
  PROCEDURE select_row( recinfo IN OUT NOCOPY gl_tax_option_accounts%ROWTYPE )  IS
  BEGIN
    SELECT  *
    INTO    recinfo
    FROM    gl_tax_option_accounts
    WHERE   account_segment_value = recinfo.account_segment_value
    AND     ledger_id = recinfo.ledger_id
    AND     org_id = recinfo.org_id;
  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_tax_option_accounts_pkg.select_row');
      RAISE;
  END select_row;


  --
  -- FUNCTION
  --   check_line
  -- Purpose
  --   Check if a give account wiht a given ledger is and organization,
  --   has the given tax type.
  -- History
  --   22-Nov-96 	W Wong 	Created
  -- Arguments
  --   x_ledger_id	Ledger ID
  --   x_org_id		Organization ID
  --   x_account	Account Segment Value
  --   x_tax_type	Tax Type to be checked
  --   x_rowid		Row ID
  --
  -- Example
  --   gl_tax_option_accounts_pkg.check_line(ledger_id, org_id, account, tax_type);
  -- Notes
  --

  FUNCTION check_line(  x_ledger_id		NUMBER,
			x_org_id		NUMBER,
			x_account 		VARCHAR2,
			x_tax_type 		VARCHAR2,
			x_rowid			VARCHAR2 ) RETURN NUMBER IS

  x_total NUMBER;

  BEGIN
    -- Need to check if account has another input line
    SELECT count(*)
    INTO x_total
    FROM gl_tax_option_accounts
    WHERE ledger_id = x_ledger_id
    AND   org_id = x_org_id
    AND   account_segment_value = x_account
    AND   tax_type_code = x_tax_type
    AND ( x_rowid is null OR rowid <> x_rowid );

    return (x_total);

  END check_line;


  --
  -- PUBLIC FUNCTIONS
  --

  PROCEDURE select_columns(
	      x_ledger_id				NUMBER,
	      x_org_id					NUMBER,
	      x_account_value				VARCHAR2,
	      x_tax_type_code			IN OUT NOCOPY	VARCHAR2,
	      x_tax_code			IN OUT NOCOPY 	VARCHAR2,
	      x_allow_override			IN OUT NOCOPY	VARCHAR2,
 	      x_amount_includes_tax		IN OUT NOCOPY	VARCHAR2) IS

    recinfo gl_tax_option_accounts%ROWTYPE;

  BEGIN
    recinfo.ledger_id := x_ledger_id;
    recinfo.org_id := x_org_id;
    recinfo.account_segment_value := x_account_value;
    select_row( recinfo );
    x_tax_type_code := recinfo.tax_type_code;
    x_allow_override := recinfo.allow_tax_code_override_flag;
    x_amount_includes_tax := recinfo.amount_includes_tax_flag;
    x_tax_code := recinfo.tax_code;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_tax_option_accounts_pkg.select_columns');
      RAISE;
  END select_columns;


  PROCEDURE check_tax_type(
		x_ledger_id				NUMBER,
		x_org_id				NUMBER,
		x_account_segment_value			VARCHAR2,
		x_tax_type_code				VARCHAR2,
		x_rowid					VARCHAR2) IS

  non_tax_lines		NUMBER;
  duplicate_lines       NUMBER;
  in_lines 		NUMBER;
  out_lines		NUMBER;

  BEGIN
    non_tax_lines := 0; duplicate_lines := 0; in_lines := 0; out_lines := 0;

    -- Need to check if account has a duplicate line
    duplicate_lines := check_line(x_ledger_id, x_org_id,
	  	                  x_account_segment_value, x_tax_type_code,
				  x_rowid );

    IF (duplicate_lines <> 0) THEN
      -- Account has a duplicate line
      fnd_message.set_name('SQLGL', 'GL_STAX_DUPLICATE_TAX_TYPE');
      app_exception.raise_exception;
    END IF;


    IF (x_tax_type_code IN ('I', 'O')) THEN

      -- Check if the given account has a non-taxable line
      non_tax_lines := check_line(x_ledger_id, x_org_id, x_account_segment_value,
			 	  'N', x_rowid);

      IF (non_tax_lines <> 0) THEN
        -- Account has non-taxable line.  Cannot define any input/output line.
          fnd_message.set_name('SQLGL',  'GL_STAX_NO_INPUT_OUTPUT');
          app_exception.raise_exception;

      END IF;

    ELSE
      -- Tax type code is non_taxable
      -- Need to check if there is another input/output line
      in_lines := check_line(x_ledger_id, x_org_id, x_account_segment_value, 'I',
                             x_rowid);

      IF (in_lines = 0) THEN
	-- There is no input line for this account, check output line.
	out_lines := check_line(x_ledger_id, x_org_id, x_account_segment_value,
		                'O', x_rowid);

        IF (out_lines <> 0) THEN
          -- Account has an output line.  Cannot define non-taxable line.
          fnd_message.set_name('SQLGL', 'GL_STAX_OUTPUT_NO_NON_TAX');
          app_exception.raise_exception;

	END IF;

      ELSE
	-- Account has an input line. Cannot define non-taxable line.
          fnd_message.set_name('SQLGL', 'GL_STAX_INPUT_NO_NON_TAX');
          app_exception.raise_exception;

      END IF;

    END IF;

  END check_tax_type;


  FUNCTION get_acct_description(
	      x_coa_id					NUMBER,
	      x_account_val				VARCHAR2
	   ) RETURN VARCHAR2 IS
  BEGIN
    IF (acct_seg_num IS NULL) THEN
      IF (NOT fnd_flex_apis.get_qualifier_segnum(
                appl_id 		=> 101,
                key_flex_code		=> 'GL#',
      	        structure_number	=> x_coa_id,
	        flex_qual_name		=> 'GL_ACCOUNT',
	        segment_number		=> acct_seg_num)
          ) THEN
        app_exception.raise_exception;
      END IF;
    END IF;

    -- Get the description
    IF (fnd_flex_keyval.validate_segs(
          operation => 'CHECK_SEGMENTS',
          appl_short_name => 'SQLGL',
          key_flex_code => 'GL#',
          structure_number => x_coa_id,
          concat_segments => x_account_val,
          displayable => 'GL_ACCOUNT',
          allow_nulls => TRUE,
          allow_orphans => TRUE)) THEN
      null;
    END IF;

    RETURN(fnd_flex_keyval.segment_description(acct_seg_num));
  END get_acct_description;

END gl_tax_option_accounts_pkg;


/
