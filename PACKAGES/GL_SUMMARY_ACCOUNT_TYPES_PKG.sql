--------------------------------------------------------
--  DDL for Package GL_SUMMARY_ACCOUNT_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_SUMMARY_ACCOUNT_TYPES_PKG" AUTHID CURRENT_USER as
/* $Header: gluacsms.pls 120.2 2005/05/05 01:34:35 kvora ship $ */

--
-- Package
--   GL_SUMMARY_ACCOUNT_TYPES_PKG
-- Purpose
--   To determine the account types of summary accounts and update the
--   summary accounts
-- History
--   26-AUG-97  D J Ogg          Created
--

  --
  -- Exceptions
  --
  INVALID_COMBINATION   EXCEPTION;


  --
  -- Procedure
  --   update_account_types
  -- Purpose
  --   Updates the account types of summary accounts
  -- History
  --   26-AUG-97  D. J. Ogg    Created
  -- Arguments
  --   coa_id				The chart of accounts id
  --   min_ccid_processed		Minimum ccid to process
  --					accounts were bad
  -- Notes
  --
  PROCEDURE update_account_types(coa_id			NUMBER,
				 min_ccid_processed	NUMBER);

END GL_SUMMARY_ACCOUNT_TYPES_PKG;

 

/
