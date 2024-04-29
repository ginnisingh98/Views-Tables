--------------------------------------------------------
--  DDL for Package GL_ELIMINATION_JOURNALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_ELIMINATION_JOURNALS_PKG" AUTHID CURRENT_USER As
/* $Header: gliejous.pls 120.3 2005/05/05 01:07:05 kvora ship $ */
 --
 -- Package
 --  gl_elimination_jous_pkg
 -- Purpose
 --  Server routines related to table gl_elimination_journals
 -- History
 --  11/06/98   W Wong      Created


  --
  -- Function
  --   Get_Unique_Id
  -- Purpose
  --   Gets nextval from GL_ELIMINATION_JOURNALS
  -- History
  --   11-06-1998  W Wong    Created
  -- Notes
  --   Raises GL_ERROR_GETTING_UNIQUE_ID on failure
  FUNCTION get_unique_id Return NUMBER;

  --
  -- Procedure
  --   get_category_name
  --
  -- Purpose
  --   Gets the user category name for the given category
  --
  -- History
  --   05-Nov-98  W Wong 	Created
  --
  -- Arguments
  --   x_category_name		JE Category name
  FUNCTION get_category_name(
	      x_category_name				VARCHAR2
	   ) RETURN VARCHAR2;

  --
  -- Procedure
  --   Check_unique_name
  -- Purpose
  --   Unique check for name
  -- History
  --   05-Nov-98  W Wong 	Created
  -- Parameters
  --   x_rowid		Rowid
  --   x_setid		Elimination Set ID
  --   x_name  		Journal name
  --
  -- Notes
  --   None
  --
  PROCEDURE check_unique_name( X_rowid VARCHAR2,
			       X_setid NUMBER,
                               X_name  VARCHAR2);


End gl_elimination_journals_pkg;

 

/
