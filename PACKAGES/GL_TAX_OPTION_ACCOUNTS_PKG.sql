--------------------------------------------------------
--  DDL for Package GL_TAX_OPTION_ACCOUNTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_TAX_OPTION_ACCOUNTS_PKG" AUTHID CURRENT_USER AS
/* $Header: glisttas.pls 120.5 2005/05/05 01:27:42 kvora ship $ */
--
-- Package
--   gl_tax_option_accounts_pkg
-- Purpose
--   To implement various data checking needed for the
--   gl_tax_option_accounts table
-- History
--   05-DEC-96 	W Wong		Created
--

  --
  -- Procedure
  --   check_tax_type
  --
  -- Purpose
  --   Check the following constraints for tax type of a given account:
  --   1. Only one input line can be defined for each account.
  --   2. Only one output line can be defined for each account.
  --   3. If an account has a non-taxable line, then input and output
  --      lines cannot be defined for that account.
  --
  -- History
  --   22-Nov-96  W. Wong 	Created
  --
  -- Arguments
  --   x_ledger_id 			ID of the current ledger
  --   x_org_id				ID of the current organization
  --   x_account_segment_value          Account segment to be checked
  --   x_tax_code                       Tax code of current account
  --   x_rowid				Row ID
  --
  PROCEDURE check_tax_type(
  	      x_ledger_id			   	NUMBER,
	      x_org_id				   	NUMBER,
	      x_account_segment_value		        VARCHAR2,
	      x_tax_type_code			   	VARCHAR2,
	      x_rowid					VARCHAR2);

  --
  -- Procedure
  --   select_columns
  --
  -- Purpose
  --   Gets various information about the tax options associated
  --   with the given account, ledger id, and organization
  --
  -- History
  --   05-DEC-96  D J Ogg 	Created
  --
  -- Arguments
  --   x_ledger_id 			ID of the current ledger
  --   x_org_id				ID of the current organization
  --   x_account_segment_value          Account segment to be checked
  --   x_tax_type_code                  Default Tax type
  --   x_tax_code                       Default Tax code
  --   x_allow_override			Allow Tax code override
  --   x_amount_includes_tax		Default amount includes tax
  --
  PROCEDURE select_columns(
	      x_ledger_id				NUMBER,
	      x_org_id					NUMBER,
	      x_account_value				VARCHAR2,
	      x_tax_type_code			IN OUT NOCOPY	VARCHAR2,
	      x_tax_code			IN OUT NOCOPY 	VARCHAR2,
	      x_allow_override			IN OUT NOCOPY	VARCHAR2,
 	      x_amount_includes_tax		IN OUT NOCOPY	VARCHAR2);

  --
  -- Procedure
  --   get_acct_description
  --
  -- Purpose
  --   Gets the description for an account segment value
  --
  -- History
  --   13-Jan-97  D J Ogg 	Created
  --
  -- Arguments
  --   x_coa_id 		ID of the current chart of accounts
  --   x_account_val		Account Segment value
  FUNCTION get_acct_description(
	      x_coa_id					NUMBER,
	      x_account_val				VARCHAR2
	   ) RETURN VARCHAR2;

END gl_tax_option_accounts_pkg;

 

/
