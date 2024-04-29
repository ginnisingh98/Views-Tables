--------------------------------------------------------
--  DDL for Package JG_JOURNAL_ALLOCATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_JOURNAL_ALLOCATIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: jgzztajs.pls 115.5 2002/11/15 17:09:36 arimai ship $ */
--
-- procedure to allocate
--
  PROCEDURE main(errbuf 			IN OUT NOCOPY VARCHAR2,
		 retcode		   	IN OUT NOCOPY VARCHAR2,
		 p_set_of_books_id	   	IN NUMBER,
		 p_chart_of_accounts_id    	IN NUMBER,
		 p_functional_currency		IN VARCHAR2,
		 p_period_set_name		IN VARCHAR2,
		 p_rule_set_id		   	IN NUMBER,
		 p_period_name		   	IN VARCHAR2,
		 p_currency_code	   	IN VARCHAR2,
		 p_amount_type		   	IN VARCHAR2,
		 p_balance_type		   	IN VARCHAR2,
		 p_balance_type_id	   	IN NUMBER,
		 p_balance_segment_value   	IN VARCHAR2,
		 p_destn_set_of_books_id   	IN NUMBER,
		 p_destn_period_name		IN VARCHAR2,
		 p_destn_journal_source    	IN VARCHAR2,
		 p_destn_journal_category  	IN VARCHAR2,
		 p_destn_segment_method	   	IN VARCHAR2,
		 p_destn_cost_center_grouping	IN VARCHAR2,
		 p_error_handling	   	IN VARCHAR2,
		 p_validate_only	   	IN VARCHAR2,
		 p_run_journal_import	   	IN VARCHAR2,
		 p_destn_summary_level	   	IN VARCHAR2,
		 p_import_desc_flexfields  	IN VARCHAR2,
		 p_post_errors_to_suspense 	IN VARCHAR2,
		 p_debug_flag		   	IN VARCHAR2);
--
-- procedure to unallocate
--
  PROCEDURE main(errbuf 			IN OUT NOCOPY VARCHAR2,
	         retcode		        IN OUT NOCOPY VARCHAR2,
	         p_chart_of_accounts_id		IN NUMBER,
	         p_functional_currency		IN VARCHAR2,
	         p_request_id			IN NUMBER,
	         p_debug_flag			IN VARCHAR2);

  /* -------------------------------------------------------------------
  |  PRIVATE PROCEDURE                                                  |
  |       set_parameters						|
  |  DESCRIPTION							|
  |  	  Sets the concurrent programs parameter values to package      |
  |	  Global variables						|
  -------------------------------------------------------------------- */
  PROCEDURE set_parameters (p_set_of_books_id 		IN NUMBER,
		  	    p_chart_of_accounts_id 	IN NUMBER,
			    p_functional_currency	IN VARCHAR2,
			    p_period_set_name		IN VARCHAR2,
			    p_rule_set_id		IN NUMBER,
			    p_period_name 		IN VARCHAR2,
			    p_currency_code		IN VARCHAR2,
			    p_amount_type		IN VARCHAR2,
			    p_balance_type		IN VARCHAR2,
			    p_balance_type_id		IN NUMBER,
			    p_balance_segment_value	IN VARCHAR2,
			    p_destn_set_of_books_id	IN NUMBER,
			    p_destn_period_name		IN VARCHAR2,
			    p_destn_journal_source	IN VARCHAR2,
			    p_destn_journal_category 	IN VARCHAR2,
			    p_destn_segment_method	IN VARCHAR2,
			    p_destn_cost_center_grouping IN VARCHAR2,
			    p_error_handling		IN VARCHAR2,
			    p_validate_only		IN VARCHAR2,
			    p_run_journal_import	IN VARCHAR2,
			    p_destn_summary_level	IN VARCHAR2,
			    p_import_desc_flexfields 	IN VARCHAR2,
			    p_post_errors_to_suspense	IN VARCHAR2,
			    p_debug_flag		IN VARCHAR2);

--
-- Globals for parameters
--
  G_set_of_books_id 		GL_SETS_OF_BOOKS.set_of_books_id%TYPE;
  G_chart_of_accounts_id 	GL_SETS_OF_BOOKS.chart_of_accounts_id%TYPE;
  G_rule_set_id			JG_ZZ_TA_RULE_SETS.rule_set_id%TYPE;
  G_period_name 		GL_PERIODS.period_name%TYPE;
  G_currency_code		FND_CURRENCIES.currency_code%TYPE;
  G_amount_type			FND_LOOKUPS.lookup_code%TYPE;
  G_balance_type		FND_LOOKUPS.lookup_code%TYPE;
  G_balance_type_id		GL_BUDGET_VERSIONS.budget_version_id%TYPE;
  G_balance_segment_value	VARCHAR2(100);
  G_destn_set_of_books_id	GL_SETS_OF_BOOKS.set_of_books_id%TYPE;
  G_destn_period_name		GL_PERIODS.period_name%TYPE;
  G_destn_journal_source	GL_JE_SOURCES.je_source_name%TYPE;
  G_destn_journal_category 	GL_JE_CATEGORIES.je_category_name%TYPE;
  G_destn_segment_method	FND_LOOKUPS.lookup_code%TYPE;
  G_destn_cost_center_grouping  FND_LOOKUPS.lookup_code%TYPE;
  G_error_handling		FND_LOOKUPS.lookup_code%TYPE;
  G_validate_only		FND_LOOKUPS.lookup_code%TYPE;
  G_destn_summary_level	        FND_LOOKUPS.lookup_code%TYPE;
  G_import_desc_flexfields 	FND_LOOKUPS.lookup_code%TYPE;
  G_post_errors_to_suspense	FND_LOOKUPS.lookup_code%TYPE;
  G_run_journal_import		FND_LOOKUPS.lookup_code%TYPE;
  G_debug_flag			FND_LOOKUPS.lookup_code%TYPE;
  G_functional_currency		FND_CURRENCIES.currency_code%TYPE;
  G_period_set_name		GL_PERIOD_SETS.period_set_name%TYPE;
  G_unalloc_request_id		FND_CONCURRENT_REQUESTS.request_id%TYPE;
--
-- Globals for other variables
--
  G_func_currency_format_mask	VARCHAR2(100);
  G_func_currency_precision	FND_CURRENCIES.PRECISION%TYPE;
  G_JG_appln_short_name		FND_APPLICATION.application_short_name%TYPE;
  G_GL_appln_short_name		FND_APPLICATION.application_short_name%TYPE;
  G_GL_application_id		FND_APPLICATION.application_id%TYPE;
  G_GL_acct_flex_code		VARCHAR2(100);
  G_GL_start_date		GL_PERIODS.start_date%TYPE;
  G_GL_end_date			GL_PERIODS.end_date%TYPE;
  G_retcode			VARCHAR2(1) := 0;
  G_errbuf			VARCHAR2(500) := NULL;
  G_user_je_source_name		GL_JE_SOURCES.user_je_source_name%TYPE;
  G_user_je_category_name	GL_JE_CATEGORIES.user_je_category_name%TYPE;
  G_translated_user		GL_DAILY_CONVERSION_TYPES.user_conversion_type%TYPE;
  G_set_of_books_name		GL_SETS_OF_BOOKS.name%TYPE;
--
-- Globals for AOL conc. program variables
--
  G_request_id			FND_CONCURRENT_REQUESTS.request_id%TYPE;
  G_progr_appl_id		NUMBER;
  G_conc_progr_id		NUMBER;
  G_user_id			NUMBER;
  G_login_id			NUMBER;
--
-- Globals for accounting flexfield
--
  G_num_of_segments		NUMBER;
  G_flexfield_type		FND_FLEX_KEY_API.flexfield_type;
  G_structure_type		FND_FLEX_KEY_API.structure_type;
  G_segment_list		FND_FLEX_KEY_API.segment_list;

--
-- Array for storing information about every segment in the Accounting
-- Flexfield Structure.
--
  TYPE ACCT_FLEX_SEGMT_RECORD IS RECORD
         (segment_col_name      fnd_id_flex_segments.application_column_name%TYPE
	 ,segment_name	        fnd_id_flex_segments.segment_name%TYPE
	 ,segment_prompt        VARCHAR2(80)
	 ,segment_vset_id	fnd_flex_value_sets.flex_value_set_id%TYPE
	 ,segment_vset_name     fnd_flex_value_sets.flex_value_set_name%TYPE
	 ,segment_vset_fmt_type fnd_flex_value_sets.format_type%TYPE);
  TYPE ACCT_FLEX_SEGMT_TABLE IS TABLE OF ACCT_FLEX_SEGMT_RECORD
         INDEX BY BINARY_INTEGER;
  G_acct_flex_segmt_arr         ACCT_FLEX_SEGMT_TABLE;

--
-- Array for storing valid zero strings for the accounting flexfield segments
-- Stored in their position order for displaying.  Also stores the actual
-- column name e.g. SEGMENT1
--
  TYPE ZERO_FILL_RECORD IS RECORD
	 (zero_string	   gl_code_combinations.segment1%TYPE
	 ,segment_col_name VARCHAR2(30));
  TYPE ZERO_FILL_TABLE IS TABLE OF ZERO_FILL_RECORD
	 INDEX BY BINARY_INTEGER;
  G_zero_fill_arr 		 ZERO_FILL_TABLE;

--
-- Globals for Cost Center Segment
--
  G_cc_seg_num_string  		VARCHAR2(100) := NULL;
  G_cc_segment_num	 	NUMBER;

--
-- Globals for Account Segment
--
  G_acc_seg_num_string 		VARCHAR2(100) := NULL;
  G_acct_segment_num		NUMBER;
  G_acct_key_element		binary_integer; -- Variable to hold the account segment number

--
-- Globals for Balancing Segment
--
  G_bal_segment_num		NUMBER;
  G_bal_key_element		binary_integer; -- Variable to hold the balancing segment number

END JG_JOURNAL_ALLOCATIONS_PKG;

 

/
