--------------------------------------------------------
--  DDL for Package GL_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_GLOBAL" AUTHID CURRENT_USER as
/* $Header: glustgls.pls 120.3 2005/10/03 19:43:16 spala ship $ */

--
-- Package
--   GL_GLOBAL
-- Purpose
--   To set global environment variables within gl
-- History
--   11-OCT-02  D J Ogg          Created.
--

  --
  -- Procedure
  --   set_aff_validation
  -- Purpose
  --   Sets the context information for accounting flexfields so that
  --   only the valid balancing and management segment values will be
  --   displayed
  -- History
  --   11-OCT-02  D. J. Ogg    Created
  --   02-AUG-05  Srini Pala   Added logic to get the context ledger_id based
  --                           on the context type.
  -- Arguments
  --   context_type     The type of context being set. Valid values are:
  --                        LE - Legal Entity
  --                        LG - Ledger
  --                        OU - Operating Unit
  --   context_id       The legal entity id, ledger id, or operating unit
  --                    id depending upon the context type.
  -- Example
  --   gl_global.set_aff_validation('LE', 105);
  -- Notes
  --


   PROCEDURE set_aff_validation
                             (context_type VARCHAR2,
                              context_id   NUMBER);

  --*******************************************************************
  --
  -- Function
  --   Context_Ledger_Id
  -- Purpose
  --   Returns set context ledger_id
  --
  --
  -- History
  --   02-AUG-05  Srini Pala   Created
  --
  --
  -- Arguments
  --
  --
  -- Example
  --   gl_global.Context_Ledger_Id;
  -- Notes
  --

   Function Context_Ledger_Id Return NUMBER;

END GL_GLOBAL;

 

/
