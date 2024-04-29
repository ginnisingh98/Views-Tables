--------------------------------------------------------
--  DDL for Package IGI_BUD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_BUD" AUTHID CURRENT_USER AS
-- $Header: igibudas.pls 120.2.12000000.2 2007/08/01 08:40:56 pshivara ship $
/* ================================================================== */
FUNCTION is_number(P_CHAR VARCHAR2) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(is_number,WNDS,WNPS);
/* ================================================================== */
FUNCTION bud_period_amount
		( p_annual_amount	NUMBER
		, p_period_number	NUMBER
		, p_start_period	NUMBER
		, p_profile_code	VARCHAR2
		, p_set_of_books_id	NUMBER
		, p_max_period_number   NUMBER
		)
RETURN NUMBER;
/* ================================================================== */
FUNCTION bud_profile_valid
		( p_set_of_books_id	NUMBER
		, p_profile_code	VARCHAR2
		)
RETURN boolean;
/* ================================================================== */
PROCEDURE bud_profile_insert
		( p_sob_id		NUMBER
		, p_batch_id		NUMBER
		, p_header_id		NUMBER
		, p_line_number		NUMBER
		, p_cc_id		NUMBER
		, p_profile_code	VARCHAR2
		, p_start_period	VARCHAR2
		, p_entered_dr		NUMBER
		, p_entered_cr		NUMBER
		, p_description		VARCHAR2
		, p_reason_code		VARCHAR2
		, p_recurring		VARCHAR2
		, p_effect		VARCHAR2
		, p_next_year_budget	NUMBER
		);
/* ================================================================== */
FUNCTION flexsql_select
		( p_appl_short_name		VARCHAR2
		, p_id_flex_code		VARCHAR2
		, p_id_flex_num			NUMBER
		, p_table_alias			VARCHAR2
		)
RETURN VARCHAR2;
/* ================================================================== */
FUNCTION flexsql_concat
		( p_appl_short_name		VARCHAR2
		, p_id_flex_code		VARCHAR2
		, p_id_flex_num			NUMBER
		, p_table_alias			VARCHAR2
		)
RETURN VARCHAR2;
/* ================================================================== */
FUNCTION flexsql_range
		( p_appl_short_name		VARCHAR2
		, p_id_flex_code		VARCHAR2
		, p_id_flex_num			NUMBER
		, p_single_table_alias		VARCHAR2
		, p_range_table_alias		VARCHAR2
		, p_not_between			VARCHAR2
		)
RETURN VARCHAR2;
/* ================================================================== */
PROCEDURE bud_profile_default
		( p_code_combination_id		NUMBER
		, p_set_of_books_id		NUMBER
		, p_new_profile_code		VARCHAR2
		);
/* ================================================================== */
PROCEDURE bud_next_year_budget
		( p_je_header_id		NUMBER
	  	, p_set_of_books_id		NUMBER
	  	, p_budget_version_id		NUMBER
	  	, p_currency_code		VARCHAR2
	  	, p_period_name			VARCHAR2
		);
/* ================================================================== */
END;	-- End of package header create

 

/
