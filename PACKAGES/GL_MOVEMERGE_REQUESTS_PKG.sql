--------------------------------------------------------
--  DDL for Package GL_MOVEMERGE_REQUESTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_MOVEMERGE_REQUESTS_PKG" AUTHID CURRENT_USER As
/* $Header: glimmrqs.pls 120.5 2004/02/13 23:28:14 kdyung ship $ */
 --
 --
 -- Package
 --  gl_movemerge_requests_pkg
 -- Purpose
 --  Server routines related to table gl_movemerge_requests
 -- History
 --  3/6/1997   Mike Marra      Created


  --
  -- Function
  --   Get_Unique_Id
  -- Purpose
  --   Gets nextval from GL_MOVEMERGE_REQUESTS_S
  -- History
  --   03-06-1997  Mike Marra    Created
  -- Notes
  --   Raises GL_ERROR_GETTING_UNIQUE_ID on failure
  FUNCTION get_unique_id Return NUMBER;

  --
  -- Procedure
  --   Must_Have_Accounts
  -- Purpose
  --   Enforce bus rule that every GL_MOVEMERGE_REQUESTS
  --   record has at least 1 GL_MOVEMERGE_ACCOUNTS record
  -- History
  --   03-06-1997  Mike Marra    Created
  -- Notes
  --   Raises GL_MM_REQUEST_WITHOUT_ACCOUNTS on failure
  PROCEDURE must_have_accounts (mm_id IN NUMBER);

  --
  -- Procedure
  --   Delete_All_Accounts
  -- Purpose
  --   Cascade deletes from parent to child table
  -- History
  --   03-06-1997  Mike Marra    Created
  -- Notes
  --
  PROCEDURE delete_all_accounts (mm_id IN NUMBER);


  -- Name
  --   Check_unique_name
  -- Purpose
  --   Unique check for name
  -- Arguments
  --   name
  --
  PROCEDURE check_unique_name(X_rowid VARCHAR2,
			      X_coaid NUMBER,
                              X_name  VARCHAR2);


  -- Name
  --   Pre_Insert
  -- Purpose
  --   Validations before pre_insert on request block
  -- Arguments
  --   name
  --
  PROCEDURE pre_insert(X_rowid VARCHAR2,
	               X_coaid NUMBER,
                       X_name  VARCHAR2);

 -- Name
 -- validate_segments
 -- Purpose
 -- Calling the validate_segs in FND_FLEX-KEYVAL
 -- Arguments
 -- ops_string - Operations to be performed
 -- concatseg - accouting information to be validated
 -- coaid  - charts of accounts id

  FUNCTION validate_segments(ops_string IN VARCHAR2,
                              concatseg IN VARCHAR2,
                                  coaid IN NUMBER) RETURN VARCHAR2;

 -- Name
 -- Check_Last_Opened_Period
 -- Purpose
 -- To make sure ledger and its associated ALCs all have the same
 -- lastest opened period.
 -- Arguments
 -- ledger_id - ledger id

  PROCEDURE check_last_opened_period(ledgerid IN NUMBER);

 -- Name
 -- get_mm_ledger_id
 -- Purpose
 -- To get a ledger id from a ledger set. Because all ledger and its
 -- associated ALCs have the same Chart of Accounts. Use one of the ledger
 -- ID will be sufficient here.
 -- Arguments
 -- ledger_id - ledger id or ledger set id

  PROCEDURE get_mm_ledger_id(ledgerid IN NUMBER,
                             mm_ledger_id IN OUT NOCOPY NUMBER);

End gl_movemerge_requests_pkg;

 

/
