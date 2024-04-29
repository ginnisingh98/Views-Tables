--------------------------------------------------------
--  DDL for Package JG_ALLOCATE_JOURNALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_ALLOCATE_JOURNALS_PKG" AUTHID CURRENT_USER AS
/* $Header: jgzztaks.pls 115.2 2002/11/20 09:20:49 arimai ship $ */

  PROCEDURE allocate;

  FUNCTION get_dynamic_select_string RETURN VARCHAR2;
--
--
-- Handle for Journal Query
--
  G_journal_qry_c		INTEGER;

--
-- Record for Journal Query
--
  TYPE FISCAL_JOURNAL_LINE IS RECORD
	 (l_je_lines_v_rec	jg_zz_ta_je_lines_v%ROWTYPE,
	  account_number	jg_zz_ta_je_lines_v.segment1%TYPE,
	  cost_center		jg_zz_ta_je_lines_v.segment1%TYPE,
	  cc_range_id		jg_zz_ta_cc_ranges.cc_range_id%TYPE,
	  account_range_id	jg_zz_ta_account_ranges.account_range_id%TYPE,
	  offset_account	jg_zz_ta_account_ranges.offset_account%TYPE,
	  cc_range_low		jg_zz_ta_cc_ranges.cc_range_low%TYPE,
	  cc_range_high		jg_zz_ta_cc_ranges.cc_range_high%TYPE,
	  rule_set_name		jg_zz_ta_rule_sets.name%TYPE,
	  partial_allocation    jg_zz_ta_rule_sets.partial_allocation%TYPE,
	  cc_range_description  jg_zz_ta_cc_ranges.description%TYPE);
  G_journal_qry_rec		FISCAL_JOURNAL_LINE;
  G_last_journal_qry_rec	FISCAL_JOURNAL_LINE;
  G_currency_format_mask	VARCHAR2(100);
  G_currency_precision  	FND_CURRENCIES.precision%TYPE;
  G_jrnl_total_allocn_percent   NUMBER := NULL;

END JG_ALLOCATE_JOURNALS_PKG;

 

/
