--------------------------------------------------------
--  DDL for Package GL_CALCULATE_TAX2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_CALCULATE_TAX2_PKG" AUTHID CURRENT_USER as
/* $Header: glujet2s.pls 120.3.12000000.2 2007/07/03 17:08:22 djogg ship $ */

--
-- Package
--   GL_CALCULATE_TAX2_PKG
-- Purpose
--   To implement automatic taxing of journals for the Enter
--   Journals form
-- History
--   10-DEC-96  D J Ogg          Created
--

  --
  -- Procedure
  --   define_cursor
  -- Purpose
  --   Defines the cursor to retrieve data about the lines
  --   that need tax generation
  -- History
  --   13-DEC-1996  D. J. Ogg    Created
  -- Arguments
  --   coa_id			Current chart of accounts
  --   calculation_level	Calculation level - journal or line
  -- Example
  --   gl_calculate_tax2_pkg.define_cursor(1, 'L', errbuf);
  -- Notes
  --
  PROCEDURE define_cursor(coa_id			NUMBER,
			  calculation_level		VARCHAR2);

  --
  -- Procedure
  --   bind_cursor
  -- Purpose
  --   Binds the current header id to the cursor to retrieve data about the lines
  --   that need tax generation
  -- History
  --   13-DEC-1996  D. J. Ogg    Created
  -- Arguments
  --   header_id		Header to be taxed
  -- Example
  --   gl_calculate_tax2_pkg.bind_cursor(1);
  -- Notes
  --
  PROCEDURE bind_cursor(header_id			NUMBER);

  --
  -- Procedure
  --   execute_cursor
  -- Purpose
  --   Executes the cursor to retrieve data about the lines
  --   that need tax generation
  -- History
  --   13-DEC-1996  D. J. Ogg    Created
  -- Arguments
  --   * NONE *
  -- Example
  --   gl_calculate_tax2_pkg.execute_cursor;
  -- Notes
  --
  PROCEDURE execute_cursor;

  --
  -- Procedure
  --   fetch_cursor
  -- Purpose
  --   Fetches data about the lines that need tax generation
  -- History
  --   13-DEC-1996  D. J. Ogg    Created
  -- Arguments
  --   coa_id			Current chart of accounts
  --   lgr_id			Current ledger
  --   org_id			Current operating unit
  --   calculation_level	Calculation level - journal or line
  --   journal_effective_date	Effective date of journal being taxed
  --   no_more_records		Indicates all records have been fetched
  --   last_in_group		Indicates that this is the last record
  --				in the group
  --   bad_acct			Indicates that the tax account is bad
  --   bad_csegs		Gives the bad account
  --   line_num			Line number of the current line
  --   eff_date			Effective date of the current line
  --   ent_dr			Entered debits of the current line
  --   ent_cr			Entered credits of the current line
  --   rounding_rule		Rounding rule of the current line
  --   description		Description of the current line
  --   incl_tax			Tax included flag for the current line
  --   tax_code			Tax code for the current line
  --   tax_rate			Tax rate for the current line
  --   tax_ccid			Tax ccid for the current line
  --   tax_group		Tax group for the current line
  -- Example
  --   gl_calculate_tax2_pkg.define_cursor(1, 'L', errbuf);
  -- Notes
  --
  PROCEDURE fetch_cursor(coa_id				NUMBER,
			 lgr_id                         NUMBER,
			 org_id                         NUMBER,
			 calculation_level		VARCHAR2,
			 journal_effective_date		DATE,
			 resp_appl_id			NUMBER,
			 resp_id			NUMBER,
			 user_id			NUMBER,
			 no_more_records	IN OUT NOCOPY 	BOOLEAN,
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
			 tax_group		IN OUT NOCOPY	NUMBER);

  --
  -- Procedure
  --   closes_cursor
  -- Purpose
  --   Closes the cursor to retrieve data about the lines
  --   that need tax generation
  -- History
  --   13-DEC-1996  D. J. Ogg    Created
  -- Arguments
  --   * NONE *
  -- Example
  --   gl_calculate_tax2_pkg.close_cursor;
  -- Notes
  --
  PROCEDURE close_cursor;

END GL_CALCULATE_TAX2_PKG;

 

/
