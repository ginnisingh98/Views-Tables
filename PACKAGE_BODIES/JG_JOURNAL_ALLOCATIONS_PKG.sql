--------------------------------------------------------
--  DDL for Package Body JG_JOURNAL_ALLOCATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_JOURNAL_ALLOCATIONS_PKG" AS
/* $Header: jgzztajb.pls 120.5 2006/06/06 12:38:35 vgadde ship $ */

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       get_source_and_category						|
|  DESCRIPTION								|
|	Get the translated values for je_source and categories		|
|  CALLED BY                                                            |
|       Main								|
 --------------------------------------------------------------------- */
PROCEDURE get_source_and_category IS
BEGIN
  JG_UTILITY_PKG.log( '> JG_JOURNAL_ALLOCATIONS_PKG.get_source_and_category');
  SELECT cat.user_je_category_name,
	 src.user_je_source_name,
	 usr.user_conversion_type
  INTO   JG_JOURNAL_ALLOCATIONS_PKG.G_user_je_category_name,
  	 JG_JOURNAL_ALLOCATIONS_PKG.G_user_je_source_name,
  	 JG_JOURNAL_ALLOCATIONS_PKG.G_translated_user
  FROM   GL_JE_SOURCES	  		src,
	 GL_JE_CATEGORIES 		cat,
	 GL_DAILY_CONVERSION_TYPES 	usr
  WHERE	 src.je_source_name 		= JG_JOURNAL_ALLOCATIONS_PKG.G_destn_journal_source 	AND
	 cat.je_category_name 		= JG_JOURNAL_ALLOCATIONS_PKG.G_destn_journal_category 	AND
         usr.conversion_type		= 'User';
  JG_UTILITY_PKG.log( '< JG_JOURNAL_ALLOCATIONS_PKG.get_source_and_category');
END get_source_and_category;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       get_set_of_books_name						|
|  DESCRIPTION								|
|	Get the name of the set of books based on the id		|
|  CALLED BY                                                            |
|       Main								|
 --------------------------------------------------------------------- */
PROCEDURE get_set_of_books_name IS
BEGIN
  JG_UTILITY_PKG.log( '> JG_JOURNAL_ALLOCATIONS_PKG.get_set_of_books_name');
  SELECT name
  INTO   JG_JOURNAL_ALLOCATIONS_PKG.G_set_of_books_name	  -- for report displaying purposes
  FROM   gl_sets_of_books
  WHERE	 set_of_books_id = JG_JOURNAL_ALLOCATIONS_PKG.G_set_of_books_id;
  JG_UTILITY_PKG.log( '< JG_JOURNAL_ALLOCATIONS_PKG.get_set_of_books_name');
END get_set_of_books_name;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                  	|
|       set_parameters							|
|  DESCRIPTION								|
|  	  Sets the concurrent programs parameter values to package      |
|	  Global variables						|
|  CALLED BY                                                          	|
|       Main								|
----------------------------------------------------------------------- */
PROCEDURE set_parameters (p_set_of_books_id 		IN NUMBER,
		  	  p_chart_of_accounts_id 	IN NUMBER,
			  p_functional_currency		IN VARCHAR2,
			  p_period_set_name		IN VARCHAR2,
			  p_rule_set_id			IN NUMBER,
			  p_period_name 		IN VARCHAR2,
			  p_currency_code		IN VARCHAR2,
			  p_amount_type			IN VARCHAR2,
			  p_balance_type		IN VARCHAR2,
			  p_balance_type_id		IN NUMBER,
			  p_balance_segment_value	IN VARCHAR2,
			  p_destn_set_of_books_id	IN NUMBER,
			  p_destn_period_name		IN VARCHAR2,
			  p_destn_journal_source	IN VARCHAR2,
			  p_destn_journal_category 	IN VARCHAR2,
			  p_destn_segment_method	IN VARCHAR2,
			  p_destn_cost_center_grouping  IN VARCHAR2,
			  p_error_handling		IN VARCHAR2,
			  p_validate_only		IN VARCHAR2,
			  p_run_journal_import		IN VARCHAR2,
			  p_destn_summary_level		IN VARCHAR2,
			  p_import_desc_flexfields 	IN VARCHAR2,
			  p_post_errors_to_suspense	IN VARCHAR2,
			  p_debug_flag			IN VARCHAR2) IS
  l_ext_precision NUMBER;
  l_min_acct_unit NUMBER;
BEGIN
  JG_UTILITY_PKG.log( '> JG_JOURNAL_ALLOCATIONS_PKG.set_parameters');
  JG_JOURNAL_ALLOCATIONS_PKG.G_set_of_books_id 		:= p_set_of_books_id;
  JG_JOURNAL_ALLOCATIONS_PKG.G_chart_of_accounts_id 	:= p_chart_of_accounts_id;
  JG_JOURNAL_ALLOCATIONS_PKG.G_functional_currency	:= p_functional_currency;
  JG_JOURNAL_ALLOCATIONS_PKG.G_period_set_name		:= p_period_set_name;
  JG_JOURNAL_ALLOCATIONS_PKG.G_rule_set_id		:= p_rule_set_id;
  JG_JOURNAL_ALLOCATIONS_PKG.G_period_name		:= p_period_name;
  JG_JOURNAL_ALLOCATIONS_PKG.G_currency_code		:= p_currency_code;
  JG_JOURNAL_ALLOCATIONS_PKG.G_amount_type		:= p_amount_type;
  JG_JOURNAL_ALLOCATIONS_PKG.G_balance_type		:= p_balance_type;
  JG_JOURNAL_ALLOCATIONS_PKG.G_balance_type_id		:= p_balance_type_id;
  JG_JOURNAL_ALLOCATIONS_PKG.G_balance_segment_value  	:= p_balance_segment_value;
  JG_JOURNAL_ALLOCATIONS_PKG.G_destn_set_of_books_id	:= p_destn_set_of_books_id;
  JG_JOURNAL_ALLOCATIONS_PKG.G_destn_period_name	:= p_destn_period_name;
  JG_JOURNAL_ALLOCATIONS_PKG.G_destn_journal_source   	:= p_destn_journal_source;
  JG_JOURNAL_ALLOCATIONS_PKG.G_destn_journal_category 	:= p_destn_journal_category;
  JG_JOURNAL_ALLOCATIONS_PKG.G_destn_segment_method   	:= p_destn_segment_method;
  JG_JOURNAL_ALLOCATIONS_PKG.G_destn_cost_center_grouping := p_destn_cost_center_grouping;
  JG_JOURNAL_ALLOCATIONS_PKG.G_error_handling		:= p_error_handling;
  JG_JOURNAL_ALLOCATIONS_PKG.G_validate_only		:= p_validate_only;
  JG_JOURNAL_ALLOCATIONS_PKG.G_run_journal_import	:= p_run_journal_import;
  JG_JOURNAL_ALLOCATIONS_PKG.G_destn_summary_level	:= p_destn_summary_level;
  JG_JOURNAL_ALLOCATIONS_PKG.G_import_desc_flexfields 	:= p_import_desc_flexfields;
  JG_JOURNAL_ALLOCATIONS_PKG.G_post_errors_to_suspense 	:= p_post_errors_to_suspense;
  JG_JOURNAL_ALLOCATIONS_PKG.G_debug_flag		:= p_debug_flag;
  --
  -- Then initialize all the other variables
  --
  JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name 	:= 'JG';
  JG_JOURNAL_ALLOCATIONS_PKG.G_GL_appln_short_name 	:= 'SQLGL';
  JG_JOURNAL_ALLOCATIONS_PKG.G_GL_application_id	:= 101;
  JG_JOURNAL_ALLOCATIONS_PKG.G_GL_acct_flex_code	:= 'GL#';
  JG_JOURNAL_ALLOCATIONS_PKG.G_request_id		:= FND_GLOBAL.CONC_REQUEST_ID;
  JG_JOURNAL_ALLOCATIONS_PKG.G_progr_appl_id		:= FND_GLOBAL.PROG_APPL_ID;
  JG_JOURNAL_ALLOCATIONS_PKG.G_conc_progr_id		:= FND_GLOBAL.CONC_PROGRAM_ID;
  JG_JOURNAL_ALLOCATIONS_PKG.G_user_id			:= FND_GLOBAL.USER_ID;
  JG_JOURNAL_ALLOCATIONS_PKG.G_login_id			:= FND_GLOBAL.LOGIN_ID;
  --
  --  Get Functional Currency Format Mask
  --  Bug 3482467 (2638803), changed G_func_currency_format_mask from 15 to 18
  JG_JOURNAL_ALLOCATIONS_PKG.G_func_currency_format_mask :=
	FND_CURRENCY.GET_FORMAT_MASK(JG_JOURNAL_ALLOCATIONS_PKG.G_functional_currency,18);
  FND_CURRENCY.GET_INFO(JG_JOURNAL_ALLOCATIONS_PKG.G_functional_currency
   	  	       ,JG_JOURNAL_ALLOCATIONS_PKG.G_func_currency_precision
    		       ,l_ext_precision
		       ,l_min_acct_unit);

  --
  --  Set the unallocation request id to NULL
  --
  JG_JOURNAL_ALLOCATIONS_PKG.G_unalloc_request_id := NULL;

  -- Initialize acct flex segments info array
  JG_JOURNAL_ALLOCATIONS_PKG.G_acct_flex_segmt_arr.DELETE;

  -- Initialize allocated lines array
  JG_CREATE_JOURNALS_PKG.alloc_lines_arr.DELETE;
  JG_CREATE_JOURNALS_PKG.i := 0;  -- num of rows in array

  -- Initialize zero fill array
  JG_JOURNAL_ALLOCATIONS_PKG.G_zero_fill_arr.DELETE;

  -- Set to program status to SUCCESS
  JG_JOURNAL_ALLOCATIONS_PKG.G_retcode := 0;

  JG_CREATE_JOURNALS_PKG.G_total_offset_accted_dr_amt := 0;
  JG_CREATE_JOURNALS_PKG.G_total_offset_accted_cr_amt := 0;
  JG_CREATE_JOURNALS_PKG.G_total_offset_entered_dr_amt := 0;
  JG_CREATE_JOURNALS_PKG.G_total_offset_entered_cr_amt := 0;

  JG_CREATE_JOURNALS_PKG.G_total_alloc_accted_cr_amt := 0;
  JG_CREATE_JOURNALS_PKG.G_total_alloc_accted_dr_amt := 0;

  JG_ALLOCATE_JOURNALS_PKG.G_last_journal_qry_rec.offset_account := NULL;
  JG_ALLOCATE_JOURNALS_PKG.G_last_journal_qry_rec.cc_range_id := NULL;

  JG_CREATE_JOURNALS_PKG.G_Journal_Name := NULL;
  JG_CREATE_JOURNALS_PKG.G_Journal_Description := NULL;
  JG_CREATE_JOURNALS_PKG.G_Batch_Name := NULL;

  JG_UTILITY_PKG.log( '< JG_JOURNAL_ALLOCATIONS_PKG.set_parameters');
END set_parameters;

/* ---------------------------------------------------------------------
|  PRIVATE FUNCTION                                                   	|
|       valid_rule_set							|
|  DESCRIPTION								|
|       This function performs a number of validation checks on the     |
|       selected rule set prior to looping through each source journal  |
|       line. Here is a list of the checks performed:	       		|
|	1) Checks that account ranges within separate cost center ranges|
|	   do not overlap.  This could lead to multiple allocations     |
|	   of the same source journal line.    				|
|	2) Checks that at least one allocation rule line exists for     |
|          each account range	    	       	    	 		|
|	3) If allocation lines exist, it checks they add up to 100% if  |
|	   partial allocation has not been set for the rule             |
|	4) If allocation lines exist, it checks they do not add up to   |
|	   greater than 100% if partial allocation has been set for the |
|	   rule	   	     			       	                |
|	5) Checks that there is an offset account defined at the account|
|	   range level if the total number of offsets at the rule line  |
|	   level does not equal the total number of rule lines.	  	|
|	6) Informs whether or not there is at least one offset account  |
|	   defined at the account range level 	    	       		|
|  CALLED BY                                                            |
|       JG_JOURNAL_ALLOCATIONS_PKG.main					|
|  RETURNS								|
|  	TRUE if valid rule set, FALSE otherwise. Error			|
|       Message Code returned if FALSE.	  		   		|
 --------------------------------------------------------------------- */
 FUNCTION valid_rule_set(p_err_msg_code     IN OUT NOCOPY VARCHAR2
 	  		,p_acct_rnge_offset IN OUT NOCOPY BOOLEAN) RETURN BOOLEAN IS
   CURSOR c_rule_set IS
   SELECT rs.partial_allocation		       	     partial_allocation
   ,	  ccr.cc_range_low		             cc_range_low
   ,	  ccr.cc_range_high		             cc_range_high
   ,	  acr.account_range_low		       	     account_range_low
   ,	  acr.account_range_high	             account_range_high
   ,	  acr.offset_account			     acc_range_offset_acct
   ,	  acr.account_range_id		             account_range_id
   ,	  SUM(rl.allocation_percent) 	       	     total_percent
   ,      COUNT(*)		     		     total_num_of_lines
   ,	  SUM(DECODE(rl.offset_account, NULL, 0, 1)) total_num_of_offsets
   FROM   jg_zz_ta_rule_lines     rl
   ,	  jg_zz_ta_account_ranges acr
   ,      jg_zz_ta_cc_ranges 	  ccr
   ,	  jg_zz_ta_rule_sets	  rs
   WHERE  rs.rule_set_id = ccr.rule_set_id
   AND    ccr.cc_range_id = acr.cc_range_id
   AND	  acr.account_range_id = rl.account_range_id (+)
   AND	  rs.rule_set_id = JG_JOURNAL_ALLOCATIONS_PKG.G_rule_set_id
   GROUP BY rs.partial_allocation
   ,	  ccr.cc_range_low
   ,	  ccr.cc_range_high
   ,	  acr.account_range_low
   ,	  acr.account_range_high
   ,	  acr.offset_account
   ,	  acr.account_range_id;
   TYPE ACCOUNT_RANGE_LINE IS RECORD(cc_range_low       jg_zz_ta_cc_ranges.cc_range_low%TYPE
   			      	    ,cc_range_high      jg_zz_ta_cc_ranges.cc_range_high%TYPE
				    ,account_range_low  jg_zz_ta_account_ranges.account_range_low%TYPE
				    ,account_range_high jg_zz_ta_account_ranges.account_range_high%TYPE);
   TYPE ACCOUNT_RANGE_TABLE IS TABLE OF ACCOUNT_RANGE_LINE INDEX BY BINARY_INTEGER;
   l_acct_range_arr ACCOUNT_RANGE_TABLE;
   arr_count  	BINARY_INTEGER; --:= 0; Default values not allowed in Init. -- running count of number of account ranges
 BEGIN
   JG_UTILITY_PKG.log( '> JG_JOURNAL_ALLOCATIONS_PKG.valid_rule_set');
   p_acct_rnge_offset := FALSE;
   FOR c_rs_rec IN c_rule_set LOOP
      --
      -- No sum means that no allocation lines exist 2)
      --
      IF c_rs_rec.total_percent IS NULL THEN
         p_err_msg_code := 'JG_ZZ_MISSING_ALLOC_PERC_RULE';
         RETURN FALSE;
      --
      -- check if missing any offset account numbers when there is no offset at the account range 5)
      --
      ELSIF c_rs_rec.total_num_of_lines <> c_rs_rec.total_num_of_offsets AND c_rs_rec.acc_range_offset_acct IS NULL THEN
         p_err_msg_code := 'JG_ZZ_MISSING_OFFSET_ACCOUNT';
         RETURN FALSE;
      --
      -- check if no partial allocation that total percent = 100% 3)
      --
      ELSIF c_rs_rec.total_percent <> 100 AND c_rs_rec.partial_allocation = 'N' THEN
         p_err_msg_code := 'JG_ZZ_INVALID_ALLOC_PERC_TOTAL';
         RETURN FALSE;
      --
      -- check if partial allocation that percent is not greater than 100% 4)
      --
      ELSIF c_rs_rec.total_percent > 100 AND c_rs_rec.partial_allocation = 'Y' THEN
         p_err_msg_code := 'JG_ZZ_GRTR_THAN_100_ALLOC_PERC';
         RETURN FALSE;
      --
      -- check if have an offset account at the account range level 6)
      --
      ELSIF c_rs_rec.acc_range_offset_acct IS NOT NULL THEN
         p_acct_rnge_offset := TRUE;
      END IF;
      --
      -- Check that account ranges within separate cost center ranges do not overlap 1)
      --
      arr_count := 0;
      FOR i IN 1..arr_count LOOP
          IF ((c_rs_rec.cc_range_low BETWEEN l_acct_range_arr(i).cc_range_low AND l_acct_range_arr(i).cc_range_high) OR
	      (c_rs_rec.cc_range_high BETWEEN l_acct_range_arr(i).cc_range_low AND l_acct_range_arr(i).cc_range_high)) AND
	     ((c_rs_rec.account_range_low BETWEEN l_acct_range_arr(i).account_range_low AND l_acct_range_arr(i).account_range_high) OR
	      (c_rs_rec.account_range_high BETWEEN l_acct_range_arr(i).account_range_low AND l_acct_range_arr(i).account_range_high)) THEN
	      p_err_msg_code := 'JG_ZZ_INVALID_OVRLAPPING_RNGES';
	      RETURN FALSE;
	  END IF;
      END LOOP;
      arr_count := arr_count + 1;
      l_acct_range_arr(arr_count).cc_range_low := c_rs_rec.cc_range_low;
      l_acct_range_arr(arr_count).cc_range_high := c_rs_rec.cc_range_high;
      l_acct_range_arr(arr_count).account_range_low := c_rs_rec.account_range_low;
      l_acct_range_arr(arr_count).account_range_high := c_rs_rec.account_range_high;
   END LOOP;
   p_err_msg_code := NULL;
   JG_UTILITY_PKG.log( '< JG_JOURNAL_ALLOCATIONS_PKG.valid_rule_set');
   RETURN TRUE;
   -- Bug 1064357: The following line should be at before the return line
   -- JG_UTILITY_PKG.log( '< JG_JOURNAL_ALLOCATIONS_PKG.valid_rule_set');
 END valid_rule_set;

/* ---------------------------------------------------------------------
|  PRIVATE PROCEDURE                                                    |
|       Get_Segments_Info						|
|  DESCRIPTION								|
|  	Gets flexfield structure and the segments information for the	|
|	flex code passed in.	 	 	 			|
|  CALLED BY                                                            |
|       Main								|
 --------------------------------------------------------------------- */
PROCEDURE get_segments_info IS
  l_segment_type fnd_flex_key_api.segment_type;
  l_vset 	 fnd_vset.valueset_r;
  l_fmt 	 fnd_vset.valueset_dr;
BEGIN
  JG_UTILITY_PKG.log( '> JG_JOURNAL_ALLOCATIONS_PKG.get_segments_info');
  --
  -- Below info required if the zero-fill option is used for the segment method
  -- and we also need the value set id for the cost center and account number to determine
  -- their format types: char, number etc. Value Set Id determined from the results below.
  --
  JG_JOURNAL_ALLOCATIONS_PKG.G_flexfield_type :=
	FND_FLEX_KEY_API.find_flexfield(JG_JOURNAL_ALLOCATIONS_PKG.G_GL_appln_short_name,
				        JG_JOURNAL_ALLOCATIONS_PKG.G_GL_acct_flex_code);
  JG_JOURNAL_ALLOCATIONS_PKG.G_structure_type :=
	FND_FLEX_KEY_API.find_structure(JG_JOURNAL_ALLOCATIONS_PKG.G_flexfield_type ,
				        JG_JOURNAL_ALLOCATIONS_PKG.G_chart_of_accounts_id);
  FND_FLEX_KEY_API.get_segments(JG_JOURNAL_ALLOCATIONS_PKG.G_flexfield_type,
				JG_JOURNAL_ALLOCATIONS_PKG.G_structure_type,
		       		TRUE,
		       		JG_JOURNAL_ALLOCATIONS_PKG.G_num_of_segments,
		       		JG_JOURNAL_ALLOCATIONS_PKG.G_segment_list);

  --
  -- Get the cc segment data
  --
  IF NOT (FND_FLEX_APIS.get_qualifier_segnum(JG_JOURNAL_ALLOCATIONS_PKG.G_GL_application_id,
		                             JG_JOURNAL_ALLOCATIONS_PKG.G_GL_acct_flex_code,
					     JG_JOURNAL_ALLOCATIONS_PKG.G_chart_of_accounts_id,
					     'FA_COST_CTR',
					     JG_JOURNAL_ALLOCATIONS_PKG.G_cc_segment_num) )  THEN
    --
    -- No error as it is possible to define a chart of accounts without a
    -- cost center segment.
    --
    JG_JOURNAL_ALLOCATIONS_PKG.G_cc_segment_num 	:= NULL;
    JG_JOURNAL_ALLOCATIONS_PKG.G_cc_seg_num_string 	:= ',  NULL  cost_center ';
  END IF;

  --
  -- Get the account segment data
  --
  IF NOT FND_FLEX_APIS.get_qualifier_segnum(JG_JOURNAL_ALLOCATIONS_PKG.G_GL_application_id,
				            JG_JOURNAL_ALLOCATIONS_PKG.G_GL_acct_flex_code,
				            JG_JOURNAL_ALLOCATIONS_PKG.G_chart_of_accounts_id,
				            'GL_ACCOUNT',
                                            JG_JOURNAL_ALLOCATIONS_PKG.G_acct_segment_num) THEN
    FND_MESSAGE.SET_NAME(JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name, 'JG_ZZ_NO_NATURAL_ACCT_SEG');
    RAISE APP_EXCEPTION.application_exception;
  END IF;

  --
  -- Get the balancing segment data
  --
  IF NOT FND_FLEX_APIS.get_qualifier_segnum(JG_JOURNAL_ALLOCATIONS_PKG.G_GL_application_id,
 				            JG_JOURNAL_ALLOCATIONS_PKG.G_GL_acct_flex_code,
					    JG_JOURNAL_ALLOCATIONS_PKG.G_chart_of_accounts_id,
					    'GL_BALANCING',
					    JG_JOURNAL_ALLOCATIONS_PKG.G_bal_segment_num) THEN
    FND_MESSAGE.SET_NAME(JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name, 'JG_ZZ_NO_BALANCING_SEGMENT');
    RAISE APP_EXCEPTION.application_exception;
  END IF;

  --
  -- consider each segment separately
  --
  FOR j IN 1..JG_JOURNAL_ALLOCATIONS_PKG.G_num_of_segments LOOP

     IF (NOT fnd_flex_apis.get_segment_info(x_application_id 	=> JG_JOURNAL_ALLOCATIONS_PKG.G_GL_application_id,
	        			    x_id_flex_code 	=> JG_JOURNAL_ALLOCATIONS_PKG.G_GL_acct_flex_code,
	        			    x_id_flex_num	=> JG_JOURNAL_ALLOCATIONS_PKG.G_chart_of_accounts_id,
	        			    x_seg_num		=> j,
	        		 	    x_appcol_name	=> G_acct_flex_segmt_arr(j).segment_col_name,
	        			    x_seg_name		=> G_acct_flex_segmt_arr(j).segment_name,
	        			    x_prompt		=> G_acct_flex_segmt_arr(j).segment_prompt,
	    				    x_value_set_name	=> G_acct_flex_segmt_arr(j).segment_vset_name)) THEN
       FND_MESSAGE.set_name(JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name, 'JG_ZZ_MISSING_SEGMENT_INFO');
       FND_MESSAGE.set_token('SEGMENT_NUM', TO_CHAR(j));
       RAISE APP_EXCEPTION.application_exception;
     ELSE
       --
       -- Determine the format type of the value set associated with the segment.  If it is numeric, then
       -- the low and high range values should be converted to numeric also before
       -- comparing against each journal line cost center
       --
       l_segment_type := FND_FLEX_KEY_API.find_segment(JG_JOURNAL_ALLOCATIONS_PKG.G_flexfield_type,
	   		       	        	       JG_JOURNAL_ALLOCATIONS_PKG.G_structure_type,
					               G_acct_flex_segmt_arr(j).segment_name);
       G_acct_flex_segmt_arr(j).segment_vset_id := l_segment_type.value_set_id;
       FND_VSET.get_valueset(G_acct_flex_segmt_arr(j).segment_vset_id,
		       	     l_vset,
		             l_fmt);  -- format type stored in here
       G_acct_flex_segmt_arr(j).segment_vset_fmt_type := l_fmt.format_type;

       --
       -- Need to store cc segment number string to substitute into the dynamic select string
       --
       IF j = JG_JOURNAL_ALLOCATIONS_PKG.G_cc_segment_num THEN
         JG_JOURNAL_ALLOCATIONS_PKG.G_cc_seg_num_string := ', jlv.' || G_acct_flex_segmt_arr(j).segment_col_name || ' cost_center ';
         JG_UTILITY_PKG.debug(JG_JOURNAL_ALLOCATIONS_PKG.G_cc_seg_num_string);
       ELSIF j = JG_JOURNAL_ALLOCATIONS_PKG.G_acct_segment_num THEN
         JG_JOURNAL_ALLOCATIONS_PKG.G_acc_seg_num_string :=
		', jlv.' || G_acct_flex_segmt_arr(j).segment_col_name || ' account_number ';
         JG_JOURNAL_ALLOCATIONS_PKG.G_acct_key_element :=
		to_number( substr( G_acct_flex_segmt_arr(j).segment_col_name, 8));
         JG_UTILITY_PKG.debug( 'acct_key_element = ' || to_char(JG_JOURNAL_ALLOCATIONS_PKG.G_acct_key_element));
         JG_UTILITY_PKG.debug(JG_JOURNAL_ALLOCATIONS_PKG.G_acc_seg_num_string);
       ELSIF j = JG_JOURNAL_ALLOCATIONS_PKG.G_bal_segment_num THEN
         JG_JOURNAL_ALLOCATIONS_PKG.G_bal_key_element := to_number(substr(G_acct_flex_segmt_arr(j).segment_col_name,8));
         JG_UTILITY_PKG.debug( 'l_bal_key_element = ' || to_char(JG_JOURNAL_ALLOCATIONS_PKG.G_bal_key_element));
       END IF;

     END IF;

  END LOOP;

  JG_UTILITY_PKG.log('< JG_JOURNAL_ALLOCATIONS_PKG.get_segments_info');
END get_segments_info;

/* ---------------------------------------------------------------------
|  PRIVATE FUNCTION                                                     |
|       validate_have_zero_fills					|
|  DESCRIPTION								|
|  		Checks whether the given set of books allows zero-filled|
|		values for all account segments other than the account	|
|		number and the balancing segment.  Stores the valid	|
|		zero strings in an array for later reference. 		|
|  CALLED BY                                                            |
|       Validate_Segment_Method						|
|  RETURNS								|
|  		TRUE if valid.						|
 --------------------------------------------------------------------- */
FUNCTION validate_have_zero_fills RETURN BOOLEAN IS
 -- l_zero_string  VARCHAR2(25) := RPAD('0', 25, '0'); Default values not allowed in init.
  l_zero_value   VARCHAR2(25);
  l_found	 BOOLEAN;
  l_row     	 NUMBER;
  l_vset 	 fnd_vset.valueset_r;
  l_fmt 	 fnd_vset.valueset_dr;
  l_value	 fnd_vset.value_dr;
BEGIN
  JG_UTILITY_PKG.log('> JG_JOURNAL_ALLOCATIONS_PKG.validate_have_zero_fills');
  --
  -- consider each segment separately
  --
  FOR j IN 1..JG_JOURNAL_ALLOCATIONS_PKG.G_num_of_segments LOOP
    --
    -- Initialize array values to NULL
    --
    JG_JOURNAL_ALLOCATIONS_PKG.G_zero_fill_arr(j).zero_string := NULL;
    JG_JOURNAL_ALLOCATIONS_PKG.G_zero_fill_arr(j).segment_col_name := NULL;
    --
    -- Don't substitute in zeros for either the natural account segment
    -- or the balancing segment
    --
    IF j NOT IN (JG_JOURNAL_ALLOCATIONS_PKG.G_acct_segment_num,JG_JOURNAL_ALLOCATIONS_PKG.G_bal_segment_num) THEN

      --
      -- Need to retrieve the valueset record structure for the current segment as we cannot store
      -- PLSQL tables of composite structures such as this one.  Consequently, the table
      -- G_acct_flex_segmt_arr in Get_Segments_Info doesn't hold the valueset record.
      --
      FND_VSET.get_valueset(G_acct_flex_segmt_arr(j).segment_vset_id,
		       	    l_vset,
		            l_fmt);  -- format type stored in here

      JG_UTILITY_PKG.debug( 'segment position num = '||TO_CHAR(j));
      JG_UTILITY_PKG.debug( 'max size = '||TO_CHAR(l_fmt.max_size));
      FOR k IN REVERSE 1..l_fmt.max_size LOOP
        l_zero_value := SUBSTR(RPAD('0', 25, '0'), 1, k); --l_zero_string replaced
	FND_VSET.get_value_init(l_vset, TRUE);
        FND_VSET.get_value(l_vset, l_row, l_found, l_value);
	WHILE l_found LOOP
 	  IF l_zero_value = l_value.value THEN
            JG_JOURNAL_ALLOCATIONS_PKG.G_zero_fill_arr(j).zero_string := l_value.value;
            JG_JOURNAL_ALLOCATIONS_PKG.G_zero_fill_arr(j).segment_col_name := G_acct_flex_segmt_arr(j).segment_col_name;
            GOTO value_found;
          ELSE
            FND_VSET.get_value(l_vset, l_row, l_found, l_value);
	  END IF;
        END LOOP;
        FND_VSET.get_value_end(l_vset);
      END LOOP;
      FND_MESSAGE.SET_NAME(JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name, 'JG_ZZ_ZERO_FILL_INVALID');
      RETURN FALSE;
      <<value_found>>
      JG_UTILITY_PKG.debug('value found for segment position num '|| TO_CHAR(j));

    END IF;  -- Check for natural acct or balancing segment position
  END LOOP; -- loop round for next segment
  JG_UTILITY_PKG.log( '< JG_JOURNAL_ALLOCATIONS_PKG.validate_have_zero_fills');
RETURN TRUE;
END validate_have_zero_fills;

/* ---------------------------------------------------------------------
|  PRIVATE FUNCTION                                                     |
|       run_journal_import						|
|  DESCRIPTION								|
|  	Runs the concurrent request to execute 'Journal Import'.	|
|  CALLED BY                                                            |
|       Main								|
|  RETURNS								|
|  	TRUE if successfully completes 					|
 --------------------------------------------------------------------- */
FUNCTION run_journal_import RETURN BOOLEAN IS
  l_num_of_copies    		NUMBER(5);
  l_print_style      		VARCHAR2(50);
  l_printer			VARCHAR2(50);
  l_save_output_flag 		VARCHAR2(3);
  l_save_output_bool 		BOOLEAN;
  l_ji_request_id		NUMBER;
  l_interface_run_id 		NUMBER;
  l_group_id			NUMBER;
  l_summary_journal_flag 	VARCHAR2(1);
  l_journal_import_finished     BOOLEAN;
  l_phase			VARCHAR2(200);
  l_status			VARCHAR2(200);
  l_dev_phase			VARCHAR2(200);
  l_dev_status			VARCHAR2(200);
  l_message			VARCHAR2(500);
--
-- Kai 5.1.1999, we need to replace this mask with FND_DATE based dynamic mack for R115.
--
--  l_date_mask			VARCHAR2(40) DEFAULT 'YYYY/MM/DD'; Default vlaues not allowed in Init.
BEGIN
  JG_UTILITY_PKG.log('> JG_JOURNAL_ALLOCATIONS_PKG.run_journal_import');
  --
  -- Get print options from the original Allocation request
  --
  IF NOT FND_CONCURRENT.GET_REQUEST_PRINT_OPTIONS(	JG_JOURNAL_ALLOCATIONS_PKG.G_request_id,
				 		 	l_num_of_copies,
						 	l_print_style,
						 	l_printer,
						 	l_save_output_flag) THEN
    FND_MESSAGE.SET_NAME(JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name,  'JG_ZZ_NO_PRINT_OPTIONS_FOUND');
    RETURN FALSE;
  ELSE
    IF l_save_output_flag = 'Y' THEN
      l_save_output_bool := TRUE;
    ELSE
      l_save_output_bool := FALSE;
    END IF;
    --
    -- Set print options
    --
    IF NOT FND_REQUEST.SET_PRINT_OPTIONS(	l_printer,
                                      		l_print_style,
                                      		l_num_of_copies,
                                      		l_save_output_bool) THEN
      FND_MESSAGE.SET_NAME(JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name,  'JG_ZZ_SET_PRINT_OPTIONS_FAILED' );
      RETURN FALSE;
    END IF;
  END IF;
  --
  -- Get Unique Interface Run Id
  --
  l_interface_run_id := GL_INTERFACE_CONTROL_PKG.Get_Unique_Run_Id;

  --
  -- Get Interface Group Id
  --
  SELECT MAX(group_id)
  INTO   l_group_id
  FROM   gl_interface_groups_v
  WHERE  set_of_books_id = JG_JOURNAL_ALLOCATIONS_PKG.G_destn_set_of_books_id
  AND	 user_je_source_name = JG_JOURNAL_ALLOCATIONS_PKG.G_destn_journal_source;

  --
  -- Populate GL_Interface_Control table
  --
  GL_INTERFACE_CONTROL_PKG.Insert_Row(--JG_JOURNAL_ALLOCATIONS_PKG.G_destn_set_of_books_id, Removed, ledger Arch. changes in package
  				      l_interface_run_id,
				      JG_JOURNAL_ALLOCATIONS_PKG.G_destn_journal_source,
				      JG_JOURNAL_ALLOCATIONS_PKG.G_destn_set_of_books_id,
				      l_group_id,
				      NULL);
  IF (JG_JOURNAL_ALLOCATIONS_PKG.G_destn_summary_level = 'D') THEN   -- Detail
    l_summary_journal_flag := 'N';
  ELSE
    l_summary_journal_flag := 'Y';
  END IF;

  --
  -- Submit Journal Import Concurrent Request
  --
  l_ji_request_id := FND_REQUEST.Submit_Request(
  			          	application => JG_JOURNAL_ALLOCATIONS_PKG.G_GL_appln_short_name,
                        program => 'GLLEZL',
                        description => null,
                        start_time => null,
                        sub_request=>FALSE,
                        argument1 => l_interface_run_id,
                        argument2 => fnd_profile.value('GL_ACCESS_SET_ID'),
                        argument3 => JG_JOURNAL_ALLOCATIONS_PKG.G_post_errors_to_suspense,
                        argument4 => to_char(JG_JOURNAL_ALLOCATIONS_PKG.G_GL_start_date,'YYYY/MM/DD'),
                        argument5 => to_char(JG_JOURNAL_ALLOCATIONS_PKG.G_GL_end_date,'YYYY/MM/DD'),
                        argument6 => l_summary_journal_flag,
                        argument7 => JG_JOURNAL_ALLOCATIONS_PKG.G_import_desc_flexfields,
                        argument8 => 'Y');

  COMMIT;
  IF (l_ji_request_id = 0) THEN
    FND_MESSAGE.Set_Name(JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name,'JG_ZZ_JOURNAL_IMPORT_FAILED');
    RETURN FALSE;
  END IF;

  --
  -- If running journal import in Summary Mode, then JI gives the lines the description 'Journal Import Created'
  -- by default. The below code overwrites this default description for all lines with the journal header
  -- descriptions.
  --
  IF JG_JOURNAL_ALLOCATIONS_PKG.G_destn_summary_level = 'S' AND JG_JOURNAL_ALLOCATIONS_PKG.G_destn_cost_center_grouping = 'Y' THEN
     l_journal_import_finished := FND_CONCURRENT.WAIT_FOR_REQUEST(l_ji_request_id
     			       	  		      	    	 ,10
								 ,0
								 ,l_phase
								 ,l_status
								 ,l_dev_phase
								 ,l_dev_status
								 ,l_message);
     IF l_journal_import_finished THEN
        JG_UTILITY_PKG.debug('journal import finished = true');
     ELSE
        JG_UTILITY_PKG.debug('journal import finished = false');
     END IF;
     JG_UTILITY_PKG.debug('phase = '||l_phase);
     JG_UTILITY_PKG.debug('status = '||l_status);
     JG_UTILITY_PKG.debug('dev phase = '||l_dev_phase);
     JG_UTILITY_PKG.debug('dev status = '||l_dev_status);
     JG_UTILITY_PKG.debug('message = '||l_message);
     IF l_dev_phase = 'COMPLETE' AND l_dev_status = 'NORMAL' THEN
        BEGIN
	  APPS_DDL.apps_ddl('UPDATE gl_je_lines l '||
	  	            'SET    l.description = (SELECT h.description '||
	  	 	                            'FROM   gl_je_headers h '||
			                            'WHERE  h.je_header_id = l.je_header_id) '||
	  		    'WHERE  l.je_header_id IN (SELECT h.je_header_id '||
	  	 	    	    		      'FROM   gl_je_headers h '||
			    			      ',      gl_je_batches b '||
			    			      'WHERE  b.je_batch_id = h.je_batch_id '||
				    		      'AND    b.name LIKE '''||TO_CHAR(JG_JOURNAL_ALLOCATIONS_PKG.G_Request_Id)||'%'''||
						      ' AND    b.default_period_name = '''||JG_JOURNAL_ALLOCATIONS_PKG.G_destn_period_name||
						      ''' AND   b.ledger_id = '||TO_CHAR(JG_JOURNAL_ALLOCATIONS_PKG.G_destn_set_of_books_id)||')');
                                                      -- GC Ledger Architecture change
	EXCEPTION
	-- Do nothing if there is an error in updating the lines
	WHEN OTHERS THEN
           JG_UTILITY_PKG.debug('Error in Update statement after journal import run');
  	   NULL;
	END;
     END IF;
  END IF;


  JG_UTILITY_PKG.log('< JG_JOURNAL_ALLOCATIONS_PKG.run_journal_import');
  RETURN TRUE;
EXCEPTION WHEN OTHERS THEN
  FND_MESSAGE.Set_Name(JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name,'JG_ZZ_JOURNAL_IMPORT_FAILED');
  JG_UTILITY_PKG.log('< JG_JOURNAL_ALLOCATIONS_PKG.run_journal_import');
  RETURN FALSE;
END run_journal_import;

/* ------------------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                             |
|       main									|
|  DESCRIPTION								        |
|  		Creates journal allocation lines in the GL_Interface table   	|
|		based on posted fiscal journal lines that meet the parameter	|
|		criteria passed in and have not already been allocated.		|
|		Once a line has been allocated, a record of this entry is kept	|
|		in the table jg_zz_ta_allocated_lines to resolve the latter.	|
|		Parameters also affect the composition of the destination 	|
|		analytical account lines.  			   	  	|
|		The user can choose whether or not to run the Journal Import 	|
|		after creating the allocations.  The original journal lines 	|
|		are split into one or more destination lines based on the 	|
|		percentages defined	under the rule set chosen by the user.  |
|		'Define Journal Allocations' form allows the user to set up 	|
|		these rule sets. For a particular rule set, allocation splits 	|
|		are dependent on both the cost center and the natural account 	|
|		number of the fiscal journal line. 	 	 		|
|		Aswell as the destination accounts being dependent on the rule	|
|		set chosen, they are dependent on the segment method parameter.	|
|		Segment method 'Journal Account' implies that all destination	|
|		Accounting Flexfield segments other than the natural account	|
|		segment are taken from the fiscal journal account segments.	|
|		Segment method 'Zero Filled' implies that all destination	|
|		Accounting Flexfield segments other than the natural account	|
|		and the balancing segment are filled with zeros if zeros are	|
|		valid values for each of the remaining segments.   		|
|  OUTPUT									|
|  		As a result of running this procedure, it will generate a	|
|		report that will display all fiscal journal lines that have 	|
|		been allocated alongwith the allocated line details. Any errors	|
|		occurring in creating the allocations will be displayed in the  |
|		same report.
|		In addition, the allocations will be inserted into the 		|
|		GL_Interface table ready for Journal Import (if running in	|
|		non-validation mode), a record will be kept of those fiscal	|
|		lines that have been allocated and it will run Journal Import	|
|		if the user chose to do so.	   	   	  	   	|
--------------------------------------------------------------------------------*/
PROCEDURE main(errbuf 			 	IN OUT NOCOPY VARCHAR2,
	       retcode		         	IN OUT NOCOPY VARCHAR2,
	       p_set_of_books_id		IN NUMBER,
	       p_chart_of_accounts_id   	IN NUMBER,
	       p_functional_currency		IN VARCHAR2,
	       p_period_set_name		IN VARCHAR2,
	       p_rule_set_id			IN NUMBER,
	       p_period_name			IN VARCHAR2,
	       p_currency_code			IN VARCHAR2,
	       p_amount_type			IN VARCHAR2,
	       p_balance_type			IN VARCHAR2,
	       p_balance_type_id		IN NUMBER,
	       p_balance_segment_value  	IN VARCHAR2,
	       p_destn_set_of_books_id  	IN NUMBER,
	       p_destn_period_name		IN VARCHAR2,
	       p_destn_journal_source   	IN VARCHAR2,
	       p_destn_journal_category 	IN VARCHAR2,
	       p_destn_segment_method		IN VARCHAR2,
	       p_destn_cost_center_grouping	IN VARCHAR2,
	       p_error_handling			IN VARCHAR2,
	       p_validate_only			IN VARCHAR2,
	       p_run_journal_import		IN VARCHAR2,
	       p_destn_summary_level		IN VARCHAR2,
	       p_import_desc_flexfields 	IN VARCHAR2,
	       p_post_errors_to_suspense	IN VARCHAR2,
	       p_debug_flag			IN VARCHAR2) IS

  l_err_msg_code     VARCHAR2(50);
  l_acct_rnge_offset BOOLEAN;

BEGIN
  JG_UTILITY_PKG.log('> JG_JOURNAL_ALLOCATIONS_PKG.main');

  -- Bug 1064357: Session mode must be set
  FND_FLEX_KEY_API.set_session_mode('customer_data');

  JG_UTILITY_PKG.debug(TO_CHAR(SYSDATE, 'HH24:MI:SS'));
  --
  -- Determine whether to output debug messages to log file
  --
  IF (p_debug_flag = 'Y') THEN
    JG_UTILITY_PKG.enable_debug;
  -- APPS_DDL.apps_ddl('ALTER SESSION SET SQL_TRACE TRUE');
  END IF;
  --
  -- Initialize the parameter globals
  --
  JG_JOURNAL_ALLOCATIONS_PKG.set_parameters(	p_set_of_books_id,
		  		     		p_chart_of_accounts_id,
	       					p_functional_currency,
	       				        p_period_set_name,
				     		p_rule_set_id,
				     		p_period_name,
				     		p_currency_code,
				     		p_amount_type,
				     		p_balance_type,
				     		p_balance_type_id,
				     		p_balance_segment_value,
				     		p_destn_set_of_books_id,
						p_destn_period_name,
				     		p_destn_journal_source,
				     		p_destn_journal_category,
				     		p_destn_segment_method,
						p_destn_cost_center_grouping,
				     		p_error_handling,
				     		p_validate_only,
				     		p_run_journal_import,
				     		p_destn_summary_level,
				     		p_import_desc_flexfields,
				     		p_post_errors_to_suspense,
				     		p_debug_flag);

  --
  -- Perform a number of validation checks on the rule set.  If any errors found,
  -- then the program should be aborted
  --
  IF NOT JG_JOURNAL_ALLOCATIONS_PKG.valid_rule_set(l_err_msg_code, l_acct_rnge_offset) THEN
     FND_MESSAGE.set_name(JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name, l_err_msg_code);
     RAISE APP_EXCEPTION.application_exception;
  END IF;

  IF (JG_JOURNAL_ALLOCATIONS_PKG.G_validate_only = 'N') THEN
     --
     -- Get the translated meanings from source and category for gl_interface
     --
     JG_JOURNAL_ALLOCATIONS_PKG.get_source_and_category;
     --
     -- Get Period Name's start and end dates for gl_interface
     --
     GL_INFO.gl_get_period_dates(JG_JOURNAL_ALLOCATIONS_PKG.G_destn_set_of_books_id,
                                 JG_JOURNAL_ALLOCATIONS_PKG.G_destn_period_name,
	                         JG_JOURNAL_ALLOCATIONS_PKG.G_GL_start_date,
	                         JG_JOURNAL_ALLOCATIONS_PKG.G_GL_end_date,
		  	         errbuf);
     IF (errbuf IS NOT NULL) THEN
       RAISE APP_EXCEPTION.application_exception;
     END IF;
  END IF;
  --
  -- Get set of books name from source set of books id for reporting purposes
  --
  JG_JOURNAL_ALLOCATIONS_PKG.get_set_of_books_name;
  --
  -- Get all the segment info of the acct key flexfield
  --
  JG_JOURNAL_ALLOCATIONS_PKG.get_segments_info;

  --
  -- Check that zero fills are valid values for segments if chosen segment method.
  -- Offset acct range totals are also zero-filled, so check for these also.
  --
  IF (JG_JOURNAL_ALLOCATIONS_PKG.G_destn_segment_method = 'ZF' OR l_acct_rnge_offset) THEN
    IF (NOT JG_JOURNAL_ALLOCATIONS_PKG.validate_have_zero_fills) THEN
      RAISE APP_EXCEPTION.application_exception;
    END IF;
  END IF;

  JG_UTILITY_PKG.debug(TO_CHAR(SYSDATE, 'HH24:MI:SS'));

  --
  -- Call the next package, to allocate
  --
  JG_ALLOCATE_JOURNALS_PKG.allocate;
  --
  -- Submit the journal import if at least one allocation and not in validation mode
  --
  JG_UTILITY_PKG.debug(TO_CHAR(SYSDATE, 'HH24:MI:SS'));

  IF (JG_JOURNAL_ALLOCATIONS_PKG.G_run_journal_import = 'Y' AND
      JG_CREATE_JOURNALS_PKG.i <> 0 AND
      JG_JOURNAL_ALLOCATIONS_PKG.G_Validate_Only = 'N') THEN
     IF NOT JG_JOURNAL_ALLOCATIONS_PKG.run_journal_import THEN
        RAISE APP_EXCEPTION.application_exception;
     END IF;
  END IF;
  retcode := JG_JOURNAL_ALLOCATIONS_PKG.G_retcode;
  JG_UTILITY_PKG.debug( 'retcode = '||retcode);
  JG_UTILITY_PKG.log('< JG_JOURNAL_ALLOCATIONS_PKG.main');
EXCEPTION
  WHEN APP_EXCEPTION.application_exception THEN
    JG_UTILITY_PKG.log('< Application_Exception clause');
    JG_JOURNAL_ALLOCATIONS_PKG.G_retcode := '2';
    retcode := JG_JOURNAL_ALLOCATIONS_PKG.G_retcode;
    IF JG_JOURNAL_ALLOCATIONS_PKG.G_errbuf IS NULL THEN
       errbuf := FND_MESSAGE.get;
    ELSIF retcode = '2' THEN    -- error
       errbuf := JG_JOURNAL_ALLOCATIONS_PKG.G_errbuf;
    END IF;
    JG_UTILITY_PKG.log(errbuf);
    ROLLBACK;
  WHEN OTHERS THEN
    JG_UTILITY_PKG.log('< Others Exception clause');
    JG_JOURNAL_ALLOCATIONS_PKG.G_retcode := '2';
    retcode := JG_JOURNAL_ALLOCATIONS_PKG.G_retcode;
    ROLLBACK;
    RAISE;
END main;

/* ------------------------------------------------------------------------------
|  PUBLIC PROCEDURE                                                             |
|       main									|
|  DESCRIPTION								        |
|	Unallocates the allocated lines 				        |
--------------------------------------------------------------------------------*/
PROCEDURE main(errbuf 			 	IN OUT NOCOPY VARCHAR2,
	       retcode		         	IN OUT NOCOPY VARCHAR2,
	       p_chart_of_accounts_id		IN NUMBER,
	       p_functional_currency		IN VARCHAR2,
	       p_request_id			IN NUMBER,
	       p_debug_flag			IN VARCHAR2) IS
  l_ext_precision NUMBER;
  l_min_acct_unit NUMBER;
BEGIN
  JG_UTILITY_PKG.log('> JG_JOURNAL_ALLOCATIONS_PKG.main');

  -- Bug 1064357: Session mode must be set
  FND_FLEX_KEY_API.set_session_mode('customer_data');

  --
  -- Determine the debug
  --
  IF p_debug_flag = 'Y' THEN
    JG_UTILITY_PKG.enable_debug;
  END IF;
  --
  -- Set the Global variables
  --
  JG_JOURNAL_ALLOCATIONS_PKG.G_JG_appln_short_name 	:= 'JG';
  JG_JOURNAL_ALLOCATIONS_PKG.G_GL_appln_short_name 	:= 'SQLGL';
  JG_JOURNAL_ALLOCATIONS_PKG.G_GL_application_id	:= 101;
  JG_JOURNAL_ALLOCATIONS_PKG.G_GL_acct_flex_code	:= 'GL#';
  JG_JOURNAL_ALLOCATIONS_PKG.G_request_id		:= FND_GLOBAL.CONC_REQUEST_ID;
  JG_JOURNAL_ALLOCATIONS_PKG.G_progr_appl_id		:= FND_GLOBAL.PROG_APPL_ID;
  JG_JOURNAL_ALLOCATIONS_PKG.G_conc_progr_id		:= FND_GLOBAL.CONC_PROGRAM_ID;
  JG_JOURNAL_ALLOCATIONS_PKG.G_user_id			:= FND_GLOBAL.USER_ID;
  JG_JOURNAL_ALLOCATIONS_PKG.G_login_id			:= FND_GLOBAL.LOGIN_ID;
  JG_JOURNAL_ALLOCATIONS_PKG.G_validate_only		:= 'N';
  JG_JOURNAL_ALLOCATIONS_PKG.G_functional_currency      := p_functional_currency;
  JG_JOURNAL_ALLOCATIONS_PKG.G_chart_of_accounts_id	:= p_chart_of_accounts_id;
  --
  -- Initialized to segment1 and segment2 for unallocation process
  -- the cost center and account segment numbers are not required for unallocation
  --
  JG_JOURNAL_ALLOCATIONS_PKG.G_cc_seg_num_string	:= ', SEGMENT1';
  JG_JOURNAL_ALLOCATIONS_PKG.G_acc_seg_num_string       := ', SEGMENT2';
  --
  -- Unallocation can only fail in the table locking, set to Error out NOCOPY
  --
  JG_JOURNAL_ALLOCATIONS_PKG.G_error_handling		:= 'E';
  --
  -- Initialize retcode to 0 for successful completion
  --
  JG_JOURNAL_ALLOCATIONS_PKG.G_retcode := 0;

  JG_ALLOCATE_JOURNALS_PKG.G_last_journal_qry_rec.offset_account := NULL;
  --
  --  Get Functional Currency Format Mask and precision
  --  Bug 3482467 (2638803) , changed G_func_currency_format_mask from 15 to 18
  JG_JOURNAL_ALLOCATIONS_PKG.G_func_currency_format_mask :=
	FND_CURRENCY.Get_Format_Mask(JG_JOURNAL_ALLOCATIONS_PKG.G_functional_currency,18);
  FND_CURRENCY.get_info(JG_JOURNAL_ALLOCATIONS_PKG.G_functional_currency,
   	  	        JG_JOURNAL_ALLOCATIONS_PKG.G_func_currency_precision,
    		        l_ext_precision,
		        l_min_acct_unit);
  JG_UTILITY_PKG.debug( 'func curr format mask = '||JG_JOURNAL_ALLOCATIONS_PKG.G_func_currency_format_mask);
  JG_UTILITY_PKG.debug( 'func curr precision = '||JG_JOURNAL_ALLOCATIONS_PKG.G_func_currency_precision);
  --
  -- Initialize the parameter globals
  --
  JG_JOURNAL_ALLOCATIONS_PKG.G_unalloc_request_id := p_request_id;
  --
  -- Call the next package, to allocate
  --
  JG_ALLOCATE_JOURNALS_PKG.allocate;

  retcode := JG_JOURNAL_ALLOCATIONS_PKG.G_retcode;

  JG_UTILITY_PKG.debug('retcode = '||retcode);
  JG_UTILITY_PKG.log('< JG_JOURNAL_ALLOCATIONS_PKG.main');
EXCEPTION
  WHEN APP_EXCEPTION.application_exception THEN
    JG_JOURNAL_ALLOCATIONS_PKG.G_retcode := '2';
    retcode := JG_JOURNAL_ALLOCATIONS_PKG.G_retcode;
    IF JG_JOURNAL_ALLOCATIONS_PKG.G_errbuf IS NULL THEN
       errbuf := FND_MESSAGE.get;
    ELSIF retcode = '2' THEN    -- error
       errbuf := JG_JOURNAL_ALLOCATIONS_PKG.G_errbuf;
    END IF;
    JG_UTILITY_PKG.log(errbuf);
    ROLLBACK;
  WHEN OTHERS THEN
    JG_JOURNAL_ALLOCATIONS_PKG.G_retcode := '2';
    retcode := JG_JOURNAL_ALLOCATIONS_PKG.G_retcode;
    ROLLBACK;
    RAISE;
END main;
END JG_JOURNAL_ALLOCATIONS_PKG;

/
