--------------------------------------------------------
--  DDL for Package GL_ACCESS_SET_SECURITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_ACCESS_SET_SECURITY_PKG" AUTHID CURRENT_USER AS
/* $Header: gluasecs.pls 120.7 2005/08/19 20:34:14 ticheng ship $ */
--
-- Package
--   gl_access_set_security_pkg
-- Purpose
--   Routines related to access set security for programs.
-- History
--   06/25/2001   T Cheng      Created
--

  -- Exceptions
  INVALID_PARAM		EXCEPTION;

  -- access levels
  FULL_ACCESS 		CONSTANT VARCHAR2(15) := 'F';
  WRITE_ACCESS		CONSTANT VARCHAR2(15) := 'B';
  READ_ONLY_ACCESS	CONSTANT VARCHAR2(15) := 'R';
  NO_ACCESS		CONSTANT VARCHAR2(15) := 'N';

  -- ledger check mode
  NO_LEDGER		CONSTANT VARCHAR2(15) := 'NO_LEDGER';
  CHECK_LEDGER_ID	CONSTANT VARCHAR2(15) := 'LEDGER_ID';
  CHECK_LEDGER_COLUMN	CONSTANT VARCHAR2(15) := 'LEDGER_COLUMN';

  -- segment value check mode
  NO_SEG_VALIDATION	CONSTANT VARCHAR2(15) := 'NO_SEG_VAL';
  CHECK_SEGVALS		CONSTANT VARCHAR2(15) := 'SEG_COLUMN';

  --
  -- Function
  --   get_security_clause
  -- Purpose
  --   Builds the security clause part of a where clause
  --
  -- History
  --   06-25-2001   T Cheng      Created
  -- Arguments
  --   access_set_id	      Access set id.
  --   access_privilege_code  The access level the customer should have.
  --			      Valid values are:
  --			      gl_access_set_security_pkg.FULL_ACCESS (only
  --				valid for "CHECK_LEDGER_COLUMN" +
  --				"NO_SEG_VALIDATION")
  --			      gl_access_set_security_pkg.WRITE_ACCESS
  --			      gl_access_set_security_pkg.READ_ONLY_ACCESS
  --   ledger_check_mode      The type of checks available:
  --			      gl_access_set_security_pkg.NO_LEDGER - there
  --				is no ledger info passed in
  --			      gl_access_set_security_pkg.CHECK_LEDGER_ID -
  --				ledger id is available, passed in as
  --				ledger_context
  --			      gl_access_set_security_pkg.CHECK_LEDGER_COLUMN -
  --				the column that stores ledger id is passed
  --				in as ledger_context
  --   ledger_context	      Ledger id or ledger column name, depending on
  --			      ledger_check_mode.
  --   ledger_table_alias     The alias used for the table which the ledger
  --			      column is in. Only used for CHECK_LEDGER_COLUMN
  --			      mode.
  --   segval_check_mode      The modes available:
  --			      gl_access_set_security_pkg.NO_SEG_VALIDATION -
  --			        no segment value validation
  --			      gl_access_set_security_pkg.CHECK_SEGVALS - check
  --			        security segment values.
  --   segval_context	      (Currently not used.)
  --   segval_table_alias     The alias used for the table where segment
  --			      values are stored. The table should have all
  --			      segment1 through segment30.
  --   edate		      Date to check against. Pass in null to skip
  --			      date validation.
  -- Notes
  --   Do not use 'acc' as table aliases.
  --
  FUNCTION get_security_clause( access_set_id		NUMBER,
				access_privilege_code	VARCHAR2,
				ledger_check_mode	VARCHAR2,
				ledger_context		VARCHAR2,
				ledger_table_alias	VARCHAR2,
				segval_check_mode	VARCHAR2,
				segval_context		VARCHAR2,
				segval_table_alias	VARCHAR2,
				edate			DATE ) RETURN VARCHAR2;


  --
  -- Function
  --   get_journal_security_clause
  -- Purpose
  --   builds the security clause part of a where clause for journals
  --
  -- History
  --   05-JUL-2002   D J Ogg  Created
  -- Arguments
  --   access_set_id	      Access set id.
  --   access_privilege_code  The access level the customer should have.
  --			      Valid values are:
  --			      gl_access_set_security_pkg.WRITE_ACCESS
  --			      gl_access_set_security_pkg.READ_ONLY_ACCESS
  --   segval_check_mode      The modes available:
  --			      gl_access_set_security_pkg.NO_SEG_VALIDATION -
  --			        no segment value validation
  --			      gl_access_set_security_pkg.CHECK_SEGVALS - check
  --			        security segment values.
  --   journal_table_alias    The alias used for the gl_je_headers table
  --   check_edate            Should the journal effective date be checked
  --                          against the access set?
  -- Notes
  --   Do not use 'sv', 'sv2', or 'acc' as table aliases.
  --
  FUNCTION get_journal_security_clause( access_set_id		NUMBER,
			   	        access_privilege_code	VARCHAR2,
                                        segval_check_mode       VARCHAR2,
				        journal_table_alias     VARCHAR2,
				        check_edate		BOOLEAN )
  RETURN VARCHAR2;

  --
  -- Function
  --   get_batch_security_clause
  -- Purpose
  --   builds the security clause part of a where clause for batches
  --
  -- History
  --   05-JUL-2002   D J Ogg  Created
  -- Arguments
  --   access_set_id	      Access set id.
  --   access_privilege_code  The access level the customer should have.
  --			      Valid values are:
  --			      gl_access_set_security_pkg.WRITE_ACCESS
  --			      gl_access_set_security_pkg.READ_ONLY_ACCESS
  --   segval_check_mode      The modes available:
  --			      gl_access_set_security_pkg.NO_SEG_VALIDATION -
  --			        no segment value validation
  --			      gl_access_set_security_pkg.CHECK_SEGVALS - check
  --			        security segment values.
  --   batch_table_alias      The alias used for the gl_je_batches table
  --   check_edate            Should the journal effective date be checked
  --                          against the access set?
  -- Notes
  --   Do not use 'jeh', 'sv', or 'acc' as table aliases.
  --
  FUNCTION get_batch_security_clause( access_set_id		NUMBER,
			   	      access_privilege_code	VARCHAR2,
                                      segval_check_mode         VARCHAR2,
				      batch_table_alias         VARCHAR2,
				      check_edate		BOOLEAN )
  RETURN VARCHAR2;


  --   NAME
  --     get_journal_access
  --   DESCRIPTION
  --     This routine checks to determine the level of access
  --     you have to a particular batch.
  --   Arguments
  --     access_set_id    The current access set id
  --     header_only      Only check privileges on the header.
  --                      Note that to truly have write access,
  --                      you must have write access to the entire
  --                      batch, but this mode is provided for
  --                      write as well as read, since the reverse
  --                      journals program needs it to check
  --                      privileges on the reversing journal before
  --                      the reversal is done.
  --     check_mode       The type of privilege to check.  A null value
  --                      for this parameter indicates that all privileges
  --                      should be checked.  Valid values are:
  --                        gl_access_set_security_pkg.WRITE_ACCESS
  --                           -- check only write access.  Returns
  --                              gl_access_set_security_pkg.WRITE_ACCESS
  --                              if you have write access and
  --                              gl_access_set_security_pkg.NO_ACCESS
  --                              otherwise.
  --                        gl_access_set_security_pkg.READ_ONLY_ACCESS
  --                           -- check only read access.  Returns
  --                              gl_access_set_security_pkg.READ_ONLY_ACCESS
  --                              if you have read-only or read/write access and
  --                              gl_access_set_security_pkg.NO_ACCESS
  --                              otherwise.
  --     je_id            If x_header_only is true, then the je_header_id.
  --                      Otherwise, the je_batch_id.
  FUNCTION get_journal_access ( access_set_id            IN NUMBER,
                                header_only              IN BOOLEAN,
                                check_mode               IN VARCHAR2,
                                je_id                    IN NUMBER )
           RETURN VARCHAR2;

  --
  -- Function
  --   get_default_ledger
  -- Purpose
  --   Get the default ledger for a data access set.
  -- History
  --   20-MAY-2003   T Cheng      Created.
  -- Arguments
  --   x_access_set_id          Access set id.
  --   x_access_privilege_code  The access level the user should have.
  --                            Valid values are:
  --			          gl_access_set_security_pkg.FULL_ACCESS
  --			          gl_access_set_security_pkg.WRITE_ACCESS
  --			          gl_access_set_security_pkg.READ_ONLY_ACCESS
  -- Notes
  --   If there is no default ledger, returns NULL.
  --
  FUNCTION get_default_ledger_id( x_access_set_id         NUMBER,
                                  x_access_privilege_code VARCHAR2 )
           RETURN NUMBER;

  --
  -- Function
  --   get_access
  -- Purpose
  --   Get the access level for the given ledger and/or account segment in the
  --   data access set.
  -- History
  --   12-AUG-2005   T Cheng      Created.
  -- Arguments
  --   x_access_set_id        Access set id.
  --   x_ledger_id            Ledger id. Pass in null to skip the check
  --                          on ledger.
  --   x_seg_qualifier        The segment qualifier of the segment whose value
  --                          was passed in.
  --   x_seg_val              The value of the segment.
  --   x_code_combination_id  Code combination id of the account to be checked.
  --   x_edate                Date to check against. Pass in null to skip
  --                          date validation.
  -- Returns
  --   One of the access levels.
  --   (FULL_ACCESS is only valid when only a ledger is provided.)
  -- Notes
  --   (x_seg_qualifier + x_seg_val), when both provided, takes precedence
  --   over x_code_combination_id. If x_seg_qualifier and/or x_seg_val AND
  --   x_code_combination_id are not provided, then segment value will not
  --   be checked.
  --
  FUNCTION get_access( x_access_set_id        NUMBER,
                       x_ledger_id            NUMBER DEFAULT NULL,
                       x_seg_qualifier        VARCHAR2 DEFAULT NULL,
                       x_seg_val              VARCHAR2 DEFAULT NULL,
                       x_code_combination_id  NUMBER DEFAULT NULL,
                       x_edate                DATE DEFAULT NULL )
           RETURN VARCHAR2;

END gl_access_set_security_pkg;

 

/
