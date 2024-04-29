--------------------------------------------------------
--  DDL for Package GL_COA_MIRROR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_COA_MIRROR_PKG" AUTHID CURRENT_USER as
/* $Header: glcoamrs.pls 120.2 2005/05/05 02:02:42 kvora ship $ */

  -- PUBLIC VARIABLES
     chart_of_accounts_id     NUMBER;

  --
  -- Procedure
  --   set_coa_id
  -- Purpose
  --   Sets the chart of accounts_id
  -- History
  --   01/15/03     C Ma            Created.
  -- Arguments
  --   coa_id
  -- Example
  --   gl_coa_mirror_pkg.set_coa_id(221);
  -- Notes
  --
  PROCEDURE set_coa_id(X_coa_id NUMBER);

  --
  -- Procedure
  --   get_coa_id
  -- Purpose
  --   Gets the package (global) variable
  -- History
  --   01/15/03      C Ma           Created.
  -- Arguments
  --   None.
  -- Example
  --   l_coa_id := gl_coa_mirror_pkg.get_coa_id;
  -- Notes
  --
  FUNCTION get_coa_id RETURN NUMBER;

END GL_COA_MIRROR_PKG;

 

/
