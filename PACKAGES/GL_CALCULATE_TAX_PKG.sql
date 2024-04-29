--------------------------------------------------------
--  DDL for Package GL_CALCULATE_TAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_CALCULATE_TAX_PKG" AUTHID CURRENT_USER as
/* $Header: glujetxs.pls 120.4 2005/05/05 01:39:48 kvora ship $ */

--
-- Package
--   GL_CALCULATE_TAX_PKG
-- Purpose
--   To implement automatic taxing of journals for the Enter
--   Journals form
-- History
--   10-DEC-96  D J Ogg          Created
--

  --
  -- Procedure
  --   calculate
  -- Purpose
  --   Automatically generates tax lines for a manual journal
  -- History
  --   10-DEC-96  D. J. Ogg    Created
  -- Arguments
  --   tax_level			Indicates whether we are taxing
  --					just the a journal or the entire
  --					batch
  --   batch_header_id			The header or batch id
  --   header_id			If we are in batch mode and you want
  --					the running totals for a header back,
  --					the id of the header
  --   resp_appl_id			The current resp appl id
  --   resp_id				The current resp id
  --   user_id				The current user id
  --   login_id				The current login id
  --   coa_id                           The current chart of accounts id
  --   header_total_dr			Updated header running total dr
  --   header_total_cr			Updated header running total cr
  --   header_total_acc_dr		Updated header running total dr
  --   header_total_acc_cr		Updated header running total cr
  --   batch_total_dr			Updated batch running total dr
  --   batch_total_cr			Updated batch running total cr
  --   batch_total_acc_dr		Updated batch running total dr
  --   batch_total_acc_cr		Updated batch running total cr
  --   has_bad_accounts			Indicates whether one or more tax
  --					accounts were bad
  -- Notes
  --
  PROCEDURE calculate(	tax_level			VARCHAR2,
			batch_header_id			NUMBER,
			disp_header_id			NUMBER DEFAULT NULL,
			resp_appl_id			NUMBER,
			resp_id				NUMBER,
			user_id				NUMBER,
			login_id			NUMBER,
			coa_id				NUMBER,
			header_total_dr		IN OUT NOCOPY	NUMBER,
			header_total_cr		IN OUT NOCOPY 	NUMBER,
			header_total_acc_dr	IN OUT NOCOPY	NUMBER,
			header_total_acc_cr	IN OUT NOCOPY 	NUMBER,
			batch_total_dr		IN OUT NOCOPY	NUMBER,
			batch_total_cr		IN OUT NOCOPY	NUMBER,
			batch_total_acc_dr	IN OUT NOCOPY	NUMBER,
			batch_total_acc_cr	IN OUT NOCOPY	NUMBER,
			has_bad_accounts	IN OUT NOCOPY	BOOLEAN);

END GL_CALCULATE_TAX_PKG;

 

/
