--------------------------------------------------------
--  DDL for Package GCS_TRANSLATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_TRANSLATION_PKG" AUTHID CURRENT_USER AS
/* $Header: gcsxlats.pls 120.2 2006/02/03 23:57:59 mikeward noship $ */

--
-- PUBLIC EXCEPTIONS
--

  GCS_CCY_SUBPROGRAM_RAISED	EXCEPTION;

--
-- PUBLIC GLOBAL VARIABLES
--
  -- Holds fnd_global.user_id and login_id
  g_fnd_user_id		NUMBER;
  g_fnd_login_id	NUMBER;

  -- Attribute ID's for the dimension attributes to be used in this program.
  -- Include CAL_PERIOD_END_DATE, NAT_ACCT_EXTENDED_ACCT_TYPE and
  -- DATASET_BALANCE_TYPE_CODE.
  g_cp_end_date_attr_id		NUMBER;
  g_li_acct_type_attr_id	NUMBER;
  g_xat_sign_attr_id		NUMBER;
  g_xat_basic_acct_type_attr_id	NUMBER;

  -- These are the associated version id's
  g_cp_end_date_v_id		NUMBER;
  g_li_acct_type_v_id		NUMBER;
  g_xat_sign_v_id		NUMBER;
  g_xat_basic_acct_type_v_id	NUMBER;

  -- For holding error text
  g_error_text	VARCHAR2(32767);

--
-- Package
--   gcs_translation_pkg
-- Purpose
--   Package procedures for the Translation Program
-- History
--   11-AUG-03	M Ward		Created
--
  --
  -- Procedure
  --   Translate
  -- Purpose
  --   Translates balances to the target currency within the FEM balances
  --   table.
  -- Arguments
  --   p_cal_period_id		The period being translated
  --   p_cons_relationship_id	Relationship, giving the parent, child, and
  --				hierarchy information.
  --   p_translation_mode	'INCREMENTAL' or 'FULL' translation.
  --   p_dataset_code		Dataset of the information in the entry.
  --   p_new_entry_id		Entry ID to be used on the created entry.
  -- Example
  --   GL_TRANSLATION_PKG.Translate(1, 2, 'FULL')
  -- Notes
  --
  PROCEDURE Translate(
	x_errbuf	OUT NOCOPY	VARCHAR2,
	x_retcode	OUT NOCOPY	VARCHAR2,
	p_cal_period_id		NUMBER,
	p_cons_relationship_id	NUMBER,
	p_balance_type_code	VARCHAR2,
        p_hier_dataset_code	NUMBER,
	p_new_entry_id		NUMBER);

END GCS_TRANSLATION_PKG;

 

/
