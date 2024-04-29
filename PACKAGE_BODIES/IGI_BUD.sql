--------------------------------------------------------
--  DDL for Package Body IGI_BUD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_BUD" AS
-- $Header: igibudab.pls 120.5.12000000.2 2007/08/01 08:49:58 pshivara ship $

/* ===============================================================
	This function checks is a column is numeric or not

	Input : P_CHAR		The entered column 		*/

FUNCTION is_number(P_CHAR VARCHAR2) RETURN NUMBER IS
	l_char		VARCHAR2(1);
BEGIN
	SELECT	'x'
	INTO	l_char
	FROM	sys.dual
	WHERE	TO_CHAR(TO_NUMBER(p_char)) = p_char;

	RETURN 1;

    EXCEPTION
	WHEN VALUE_ERROR THEN
	RETURN -1;

	WHEN OTHERS THEN
	RETURN 0;
END is_number;

/* =======================================================================
	This Function returns the profiled budget amount for the
	requested period. It will first calculate the period_ratio,
	total_ratio and the max_period_number.

	Input :	p_annual_amount		The entered annual amount
		p_period_number		The target period number
		p_start_period		The entered start period number
		p_profile_code		The entered profile code.
		p_set_of_books_id	The entered set of books id.
		p_max_period_number	Maximum period number.

	Output:	period_amount		The amount for the target period */

FUNCTION bud_period_amount
	( 	p_Annual_Amount		NUMBER
	, 	p_Period_Number		NUMBER
	, 	p_Start_Period		NUMBER
	, 	p_Profile_Code		VARCHAR2
	, 	p_Set_Of_Books_Id	NUMBER
	, 	p_Max_Period_Number	NUMBER
	)
	RETURN NUMBER IS

CURSOR cPeriodRatio
	( 	p_first_period	NUMBER
	, 	p_last_period	NUMBER
	) IS
SELECT 	period_ratio
FROM 	igi_bud_profile_periods
WHERE 	profile_code	= p_profile_code
AND 	set_of_books_id	= p_Set_Of_Books_Id
AND 	period_number	BETWEEN
		p_first_period AND p_last_period
AND 	period_ratio	<> 0;

	l_Max_Period_Number	NUMBER;
	l_Total_Ratio		NUMBER;
	l_Profile_Amount	NUMBER	:= 0;

BEGIN

  l_Max_Period_Number	:= p_Max_Period_Number;
--
-- Validate p_Max_Period_Number and sum period ratios
--
	SELECT 	max(period_number)
     	, 	sum(period_ratio)
  	INTO 	l_Max_Period_Number
     	, 	l_Total_Ratio
  	FROM 	igi_bud_profile_periods
 	WHERE 	profile_code	= p_Profile_Code
   	AND 	set_of_books_id	= p_Set_Of_Books_Id
	AND 	period_number	BETWEEN p_Start_Period
				AND decode(p_Max_Period_Number
					, 0, period_number
					, p_Max_Period_Number
					)
	AND 	period_ratio	<> 0;

l_Total_Ratio:=nvl(l_Total_ratio,1);
l_Max_Period_Number:=nvl(l_Max_Period_Number,p_Start_Period);

    IF	p_Annual_Amount	= 0 THEN
	RETURN (0);
    ELSIF l_Total_Ratio	= 0 THEN
	RETURN (0);
    ELSIF p_Period_Number NOT BETWEEN p_Start_Period
			AND l_Max_Period_Number THEN
	RETURN (0);
    ELSIF p_Period_Number <> l_Max_Period_Number THEN
	FOR PeriodRatio IN cPeriodRatio
			( p_Period_Number
			, p_Period_Number) LOOP
		l_Profile_Amount :=
			(floor((abs(p_Annual_Amount)/l_Total_Ratio)*
			PeriodRatio.period_ratio))*sign(p_Annual_Amount);
	END LOOP;
	RETURN l_Profile_Amount;
    ELSE
	FOR PeriodRatio IN cPeriodRatio
			( p_Start_Period
			, l_Max_Period_Number-1)
	LOOP
		l_Profile_Amount := l_Profile_Amount +
			(floor((abs(p_Annual_Amount)/l_Total_Ratio)*
			PeriodRatio.period_ratio))*sign(p_Annual_Amount);
	END LOOP;
	RETURN (p_Annual_Amount-l_Profile_Amount);
    END IF;

    EXCEPTION
	WHEN OTHERS THEN
		RETURN (0);
END;

/* =======================================================================
	This function returns true if profile is still valid and false
	if profile does not exist or is out NOCOPY of date.
	Input:	p_set_of_books_id
		p_profile_code
	Return:	boolean							*/

FUNCTION bud_profile_valid
	( 	p_set_of_books_id	NUMBER
	, 	p_profile_code		VARCHAR2
	)
RETURN boolean IS

	x		NUMBER;
BEGIN
	SELECT 	1
  	INTO 	x
	FROM 	igi_bud_profile_codes pc
 	WHERE 	pc.set_of_books_id = p_set_of_books_id
	AND 	pc.profile_code = p_profile_code
	AND 	nvl(pc.start_date_active, sysdate-1) <= sysdate
	AND 	nvl(pc.end_date_active, sysdate+1) > sysdate;

	RETURN true;

    EXCEPTION
	WHEN OTHERS THEN
	RETURN false;
END;

/* ========================================================================
	This Procedure creates entries in IGI_BUD_JOURNAL_PERIODS and
	GL_INTERFACE for each balanced entry into IGI_BUD_JOURNAL_LINES.
	Inputs:	Batch_ID		The Batch ID of the line.
		Header_ID		The Header ID of the line.
		Line_Number		The Line Number of the line.
		SOB_ID			The Set Of Books ID
		Profile_Code		The Required Profile Code.
		Start_Period		The Required Start Period.
		Entered_DR		The Entered Debit Amount.
		Entered_CR		The Entered Credit Amount. 	*/

PROCEDURE bud_profile_insert
	( 	p_sob_id		NUMBER
	, 	p_batch_id		NUMBER
	, 	p_header_id		NUMBER
	, 	p_line_number		NUMBER
	, 	p_cc_id			NUMBER
	, 	p_profile_code		VARCHAR2
	, 	p_start_period		VARCHAR2
	, 	p_entered_dr		NUMBER
	, 	p_entered_cr		NUMBER
	, 	p_description		VARCHAR2
	, 	p_reason_code		VARCHAR2
	, 	p_recurring		VARCHAR2
	, 	p_effect		VARCHAR2
	, 	p_next_year_budget	NUMBER
	)
IS
		p_period_amount		NUMBER;
		p_period_nyb		NUMBER;
		p_total_ratio		NUMBER;
		p_start_period_number	NUMBER;
		p_max_period_number	NUMBER;
		p_period_name		VARCHAR2(30);
		p_period_year		NUMBER;
		p_period_set_name	VARCHAR2(30);
		p_period_type		VARCHAR2(30);

CURSOR periods IS
SELECT 	period_number,period_ratio
FROM	IGI_BUD_PROFILE_PERIODS jupp
WHERE	jupp.PROFILE_CODE = p_profile_code
AND	jupp.SET_OF_BOOKS_ID = p_sob_id;

CURSOR totals_nyb IS
SELECT 	sum(nvl(jupp.period_ratio,0)) total
,       max(nvl(jubjl.period_number,0))
FROM	IGI_BUD_PROFILE_PERIODS jupp
,       IGI_BUD_JOURNAL_PERIODS jubjl
WHERE	jupp.PROFILE_CODE = p_profile_code
AND	jupp.SET_OF_BOOKS_ID = p_sob_id
AND     jubjl.BE_BATCH_ID = p_batch_id
AND     jubjl.BE_HEADER_ID = p_header_id
AND     jubjl.BE_LINE_NUM  = p_line_number
AND     jupp.PERIOD_NUMBER = jubjl.PERIOD_NUMBER;

CURSOR periods_nyb IS
SELECT 	jubjl.period_number
,       period_ratio
FROM	IGI_BUD_PROFILE_PERIODS jupp
,       IGI_BUD_JOURNAL_PERIODS jubjl
WHERE	jupp.PROFILE_CODE = p_profile_code
AND	jupp.SET_OF_BOOKS_ID = p_sob_id
AND     jupp.PERIOD_NUMBER   = jubjl.PERIOD_NUMBER
AND     jubjl.BE_BATCH_ID = p_batch_id
AND     jubjl.BE_HEADER_ID = p_header_id
AND     jubjl.BE_LINE_NUM  = p_line_number;

/* Bug 1979303 sekhar 13-sep-01
 added cursor to get the user je source name */
 CURSOR get_user_je_source IS
 select user_je_source_name
 from gl_je_sources
 where je_source_name = 'IGIGBMJL'
 and language = userenv('LANG');

       l_total number(24,2) := 0;
       l_max   number       := 0;
       l_amount number      :=0;
       l_nyb_amt number     :=0;

 /* Bug 1979303 sekhar 13-sep-01
  added following variable for user_je_source name     */
  l_user_je_source_name varchar2(25);

BEGIN
	SELECT	gp.PERIOD_NUM
	, 	gp.PERIOD_YEAR
	, 	gsob.PERIOD_SET_NAME
	, 	gsob.ACCOUNTED_PERIOD_TYPE
	INTO	p_start_period_number
	, 	p_period_year
	, 	p_period_set_name
	, 	p_period_type
	FROM	GL_PERIODS gp
	, 	GL_SETS_OF_BOOKS gsob
	WHERE	gsob.SET_OF_BOOKS_ID = p_sob_id
	AND	gp.PERIOD_SET_NAME = gsob.PERIOD_SET_NAME
	AND	gp.PERIOD_NAME = p_start_period;

    FOR period IN periods LOOP
	SELECT	gp.PERIOD_NAME
	INTO	p_period_name
	FROM	GL_PERIODS gp
	WHERE	gp.PERIOD_SET_NAME = p_period_set_name
	AND	gp.PERIOD_YEAR = p_period_year
	AND	gp.PERIOD_TYPE = p_period_type
	AND	gp.PERIOD_NUM = period.period_number;

	p_period_amount := IGI_BUD.bud_period_amount
		( 	NVL(p_entered_dr,0) - NVL(p_entered_cr,0)
		, 	period.period_number
		, 	p_start_period_number
		, 	p_profile_code
		, 	p_sob_id
		,	0
		);
/*
p_period_nyb 	:= IGI_BUD.bud_period_amount
		( nvl(p_next_year_budget,0)
		, period.period_number
		, p_start_period_number
		, p_profile_code
		, p_sob_id
		,0
		);
*/

     IF p_period_amount <> 0 THEN
	INSERT INTO IGI_BUD_JOURNAL_PERIODS
	(	BE_BATCH_ID
	,	BE_HEADER_ID
	,	BE_LINE_NUM
	,	PERIOD_NUMBER
	,	PERIOD_YEAR
	,	PERIOD_NAME
	,	ENTERED_DR
	,	ENTERED_CR
	,	NEXT_YEAR_BUDGET
	)
	VALUES
	(	p_batch_id
        ,	p_header_id
	,	p_line_number
	,	period.period_number
	,	p_period_year
	,	p_period_name
	,	DECODE( SIGN(p_period_amount), '1',ABS(p_period_amount),NULL)
	,	DECODE( SIGN(p_period_amount),'-1',ABS(p_period_amount),NULL)
	,	NULL
	);

      END IF;
    END LOOP;

    OPEN totals_nyb;
    FETCH totals_nyb INTO l_total, l_max;
    CLOSE totals_nyb;

    IF l_total > 0 and l_max > 0 THEN
   	l_amount := 0;
	FOR   nyb IN periods_nyb
	LOOP
      	    IF nyb.period_number <> l_max THEN
      		l_nyb_amt := 0;
      		l_nyb_amt := floor(( abs(p_next_year_budget)/ l_total)
					* nyb.period_ratio)
	       				* sign(p_next_year_budget);
      		l_amount := l_amount + l_nyb_amt;

		UPDATE 	IGI_BUD_JOURNAL_PERIODS
      		SET    	NEXT_YEAR_BUDGET  = l_nyb_amt
      		WHERE	PERIOD_NUMBER     = nyb.period_number
		AND     BE_BATCH_ID 	  = p_batch_id
		AND     BE_HEADER_ID 	  = p_header_id
		AND     BE_LINE_NUM  	  = p_line_number;
      	    ELSE
      		UPDATE 	IGI_BUD_JOURNAL_PERIODS
      		SET	NEXT_YEAR_BUDGET  =
	         		p_next_year_budget - l_amount
      		WHERE 	PERIOD_NUMBER      = nyb.period_number
		AND 	BE_BATCH_ID = p_batch_id
		AND 	BE_HEADER_ID = p_header_id
		AND   	BE_LINE_NUM  = p_line_number;
      	    END IF;
	END LOOP;
    END IF;
    /* bug 1979303 sekhar
    Modified and correct parameter is passed */

    OPEN get_user_je_source;
    FETCH get_user_je_source INTO l_user_je_source_name;
    CLOSE get_user_je_source;

	INSERT INTO GL_INTERFACE
	(	STATUS
	,	CREATED_BY
	,	DATE_CREATED
	,	GROUP_ID
	,	SET_OF_BOOKS_ID
	,	ACTUAL_FLAG
	,	USER_JE_CATEGORY_NAME
	,	USER_JE_SOURCE_NAME
	,	BUDGET_VERSION_ID
	,	CURRENCY_CODE
	,	ACCOUNTING_DATE
	,	CODE_COMBINATION_ID
	,	ENTERED_CR
	,	ENTERED_DR
	,	PERIOD_NAME
	,	REFERENCE1
	,	REFERENCE2
	,	REFERENCE4
	,	REFERENCE5
	,	REFERENCE7
	,	REFERENCE10
	,	REFERENCE21
	,	REFERENCE22
	,	REFERENCE23
	,	REFERENCE24
	,	REFERENCE25
	,	REFERENCE26
	,	REFERENCE27
	,	REFERENCE28
	,	REFERENCE29
	,	REFERENCE30
	)
	SELECT
		'HOLDING'
	,	'-1'
	,	SYSDATE
	,	jubjb.BE_BATCH_ID
	,	jubjb.SET_OF_BOOKS_ID
	,	'B'
	,	gjc.USER_JE_CATEGORY_NAME
	,	l_user_je_source_name
	,	jubjh.BUDGET_VERSION_ID
	,	jubjh.CURRENCY_CODE
	,	SYSDATE
	,	p_cc_id
	,	jubjp.ENTERED_CR
	,	jubjp.ENTERED_DR
	,	jubjp.PERIOD_NAME
	,	jubjb.NAME
	,	jubjb.NAME
	,	jubjh.NAME
	,	jubjh.DESCRIPTION
	,	'N'
	,	p_description
	,	'IGIGBUDPR'
	,	jubjb.BE_BATCH_ID
	,	p_profile_code
	,	p_reason_code
	,	p_start_period
	,	p_recurring
	,	p_effect
	,	jubjp.NEXT_YEAR_BUDGET
	,	jubjh.BE_HEADER_ID
	,	p_line_number
	FROM	IGI_BUD_JOURNAL_BATCHES jubjb
	,	IGI_BUD_JOURNAL_HEADERS jubjh
	,	IGI_BUD_JOURNAL_PERIODS jubjp
	,	GL_JE_CATEGORIES gjc
	WHERE	jubjb.BE_BATCH_ID = p_batch_id
	AND	jubjh.BE_HEADER_ID = p_header_id
	AND	jubjp.BE_HEADER_ID = p_header_id
	AND	jubjp.BE_LINE_NUM = p_line_number
	AND	gjc.JE_CATEGORY_NAME = jubjh.JE_CATEGORY_NAME
        --Start Bug 2885983 extra join to remove mjc
        AND     jubjh.be_header_id = jubjp.be_header_id;
        --End Bug 2885983

END;	--	bud_profile_insert

/* ===========================================================================
	This function returns a select string which produces a comma seperated
	key flexfield for a given key flexfield
	Inputs:	p_appl_short_name	The application short name (eg SQLGL)
		p_id_flex_code		The flex code (eg GL#)
		p_if_flex_num		The flex num (eg 101)
		p_table_alias		Alias for table
	Output:	r_where_list 						     */

FUNCTION flexsql_select
	( 	p_appl_short_name	VARCHAR2
	, 	p_id_flex_code		VARCHAR2
	, 	p_id_flex_num		NUMBER
	, 	p_table_alias		VARCHAR2
	)
RETURN VARCHAR2
IS
	where_list		VARCHAR2(2000)	:=null;
	r_where_list		VARCHAR2(2000)	:=null;

CURSOR segments IS
SELECT 	fs.application_column_name
FROM	FND_ID_FLEX_SEGMENTS fs
, 	FND_APPLICATION a
WHERE	a.application_short_name = p_appl_short_name
AND	fs.application_id = a.application_id
AND	fs.ID_FLEX_CODE = p_id_flex_code
AND	fs.ID_FLEX_NUM = p_id_flex_num
AND	fs.ENABLED_FLAG = 'Y'
ORDER BY fs.SEGMENT_NUM;

BEGIN
    FOR segment IN segments LOOP
	SELECT  decode(r_where_list, null, null, ',')||
		decode(p_table_alias,null,null,
			p_table_alias||'.')||
			segment.APPLICATION_COLUMN_NAME
	INTO    where_list
	FROM	dual;

	r_where_list := r_where_list||where_list;
    END LOOP;

    RETURN (r_where_list);
END;		-- Of flexsql_select

/* =========================================================================
	This function returns a select string which produces a concatenated
	key flexfield for a given key flexfield
	Inputs:	p_appl_short_name	The application short name (eg SQLGL)
		p_id_flex_code		The flex code (eg GL#)
		p_if_flex_num		The flex num (eg 101)
		p_table_alias		Alias for table
	Output:	r_where_list 						   */

FUNCTION flexsql_concat
		( p_appl_short_name	VARCHAR2
		, p_id_flex_code	VARCHAR2
		, p_id_flex_num		NUMBER
		, p_table_alias		VARCHAR2
		)
RETURN VARCHAR2
IS
	where_list		VARCHAR2(2000)	:=null;
	r_where_list		VARCHAR2(2000)	:=null;

CURSOR segments IS
SELECT 	fs.application_column_name
, 	str.concatenated_segment_delimiter delim
FROM	FND_ID_FLEX_SEGMENTS fs
, 	FND_ID_FLEX_STRUCTURES str
, 	FND_APPLICATION a
WHERE	a.application_short_name = p_appl_short_name
AND	fs.application_id = a.application_id
AND	fs.ID_FLEX_CODE = p_id_flex_code
AND	fs.ID_FLEX_NUM = p_id_flex_num
AND	fs.ENABLED_FLAG = 'Y'
AND     str.application_id = fs.application_id
AND     str.id_flex_code = fs.id_flex_code
AND     str.id_flex_num = fs.id_flex_num
ORDER BY fs.SEGMENT_NUM;

BEGIN
    FOR segment IN segments LOOP
	SELECT  decode(r_where_list, null, null,
                               '||'''||segment.delim||'''||')||
			decode(p_table_alias,null,null,
				p_table_alias||'.')||
			segment.APPLICATION_COLUMN_NAME
	INTO    where_list
	FROM	dual;

	r_where_list := r_where_list||where_list;
    END LOOP;
    RETURN (r_where_list);
END;		-- Of flexsql_concat

/* ===========================================================================
	This function returns a where clause (beginning AND ... ) for a
	given key flexfield for use between low/high range of segments
	eg: SEGMENT1 BETWEEN SEGMENT1_LOW AND SEGMENT1_HIGH
	Inputs:	p_appl_short_name	The application short name (eg SQLGL)
		p_id_flex_code		The flex code (eg GL#)
		p_if_flex_num		The flex num (eg 101)
		p_single_table_alias	Alias for non-range table
		p_range_table_alias	Alias for range table
	Output:	r_where_list 						    */

FUNCTION flexsql_range
	( 	p_appl_short_name	VARCHAR2
	, 	p_id_flex_code	VARCHAR2
	, 	p_id_flex_num		NUMBER
	, 	p_single_table_alias	VARCHAR2
	, 	p_range_table_alias	VARCHAR2
	, 	p_not_between		VARCHAR2
	)
RETURN VARCHAR2
IS
	where_list		VARCHAR2(2000)	:=null;
	r_where_list		VARCHAR2(2000)	:=null;

CURSOR segments IS
SELECT 	fs.application_column_name
FROM	FND_ID_FLEX_SEGMENTS fs
, 	FND_APPLICATION a
WHERE	a.application_short_name = p_appl_short_name
AND	fs.application_id = a.application_id
AND	fs.ID_FLEX_CODE = p_id_flex_code
AND	fs.ID_FLEX_NUM = p_id_flex_num
AND	fs.ENABLED_FLAG = 'Y'
ORDER BY fs.SEGMENT_NUM;

BEGIN
    FOR segment IN segments LOOP
	SELECT  decode(r_where_list, null, null, ' AND ')||
			decode(p_single_table_alias,null,null,
				p_single_table_alias||'.')||
			segment.APPLICATION_COLUMN_NAME||
			' '||p_not_between ||' BETWEEN '||
			decode(p_range_table_alias,null,null,
				p_range_table_alias||'.')||
			segment.APPLICATION_COLUMN_NAME||'_LOW AND '||
			decode(p_range_table_alias,null,null,
				p_range_table_alias||'.')||
			segment.APPLICATION_COLUMN_NAME||'_HIGH'
	INTO    where_list
	FROM	dual;

	r_where_list := r_where_list||where_list;
    END LOOP;
    RETURN (r_where_list);
END;		-- Of flexsql_range

/* ==================================================================
   This proceedure updates or inserts into igi_bud_profile_defaults
   Parameters:		Valid Code Combination ID
			Valid Set of Books ID
			Valid Profile Code			    */

PROCEDURE bud_profile_default
	( 	p_code_combination_id		NUMBER
	, 	p_set_of_books_id		NUMBER
	, 	p_new_profile_code		VARCHAR2
	)
IS
	err_msg			VARCHAR2(240);
BEGIN
    IF p_new_profile_code is NOT NULL THEN
	UPDATE 	igi_bud_profile_defaults
   	SET 	latest_profile_code = p_new_profile_code
 	WHERE 	code_combination_id = p_code_combination_id
   	AND 	set_of_books_id = p_set_of_books_id;

	IF SQL%NOTFOUND THEN		-- No row to update so
		INSERT INTO igi_bud_profile_defaults
		( code_combination_id
		, set_of_books_id
		, primary_profile_code
		, latest_profile_code
		, creation_date
		, created_by
		, last_update_date
		, last_updated_by
		, last_update_login
		)
		VALUES
		( 	p_code_combination_id
		, 	p_set_of_books_id
		, 	p_new_profile_code
		, 	p_new_profile_code
		, 	sysdate
		, 	-1
		, 	sysdate
		, 	-1
		, 	-1
		);
	END IF;
    END IF;

    EXCEPTION
	WHEN OTHERS THEN
	err_msg := substr(SQLERRM, 1, 240);
        --Bug 3199481 (start)
        If (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) then
            FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_UNEXP_ERROR');
  	    FND_MESSAGE.SET_TOKEN('CODE', sqlcode);
  	    FND_MESSAGE.SET_TOKEN('MSG', sqlerrm);
  	    FND_LOG.MESSAGE(fnd_log.level_unexpected,'igi.plsql.igi_bud.bud_profile_default.Msg1',TRUE);
        End if;
        --Bug 3199481 (end)
        raise_application_error (-20000, err_msg);

END;		-- Of bud_profile_default
/* =============================================================
   This proceedure updates or inserts igi_bud_ny_balances
   Parameters:		JE_HEADER_ID of Posted Budget Journal */

PROCEDURE bud_next_year_budget
	( 	p_je_header_id		NUMBER
	,	p_set_of_books_id	NUMBER
	,	p_budget_version_id	NUMBER
	,	p_currency_code		VARCHAR2
	,	p_period_name		VARCHAR2
	)
IS
	p_code_combination_id	NUMBER;

CURSOR lines IS
SELECT	JE_LINE_NUM
, 	CODE_COMBINATION_ID
, 	REFERENCE_3
FROM	GL_JE_LINES
WHERE	JE_HEADER_ID = p_je_header_id;

	l_line_reference_3   gl_je_lines.reference_3%type;
BEGIN
  FOR line IN lines LOOP
    BEGIN
	INSERT INTO IGI_BUD_NY_BALANCES
	( 	SET_OF_BOOKS_ID
	, 	CODE_COMBINATION_ID
	, 	BUDGET_VERSION_ID
	, 	PERIOD_NAME
	, 	CURRENCY_CODE
	, 	NEXT_YEAR_BUDGET)
	SELECT
	 	p_set_of_books_id
	, 	gjl.CODE_COMBINATION_ID
	, 	p_budget_version_id
	, 	p_period_name
	, 	p_currency_code
	, 	NVL(gjl.REFERENCE_8,0)
	FROM   	GL_JE_LINES gjl
	WHERE  	gjl.JE_HEADER_ID = p_je_header_id
	AND    	gjl.JE_LINE_NUM = line.JE_LINE_NUM
	--
	-- 01-NOV-00 EGARRETT Start(1)
	-- replaced translate with is_number function
	AND	is_number(NVL(gjl.reference_8,0)) = 1;
      /*  AND    translate(gjl.REFERENCE_8,
       '-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz\|*!"#$%^&*()_+. '
                      ,'-0123456789') = gjl.REFERENCE_8
        AND             ( (gjl.REFERENCE_8 like '-%' and
			   instr(gjl.REFERENCE_8,'-') <> 0)
			   OR ( instr(gjl.REFERENCE_8,'-') = 0)); */
	-- 01-NOV-00 EGARRETT End(1)

      EXCEPTION
	WHEN dup_val_on_index THEN
	SELECT	CODE_COMBINATION_ID
	INTO	p_code_combination_id
	FROM	GL_JE_LINES
	WHERE	JE_HEADER_ID = p_je_header_id
	AND	JE_LINE_NUM = line.JE_LINE_NUM;

	UPDATE  IGI_BUD_NY_BALANCES nyb
	SET	NEXT_YEAR_BUDGET =
		(SELECT	nyb.NEXT_YEAR_BUDGET +
			NVL(gjl.REFERENCE_8,0)
		 FROM	GL_JE_LINES gjl
	  	 WHERE	gjl.JE_HEADER_ID = p_je_header_id
		 AND	gjl.JE_LINE_NUM = line.JE_LINE_NUM
		-- 01-NOV-00 EGARRETT Start(2)
		 AND	is_number(NVL(gjl.reference_8,0)) = 1)
                /* AND  	translate(gjl.REFERENCE_8,
      '-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz\|*!"#$%^&*()_+. '
                       ,'-0123456789') = gjl.REFERENCE_8
        	 AND             ( (gjl.REFERENCE_8 like '-%' and
			   instr(gjl.REFERENCE_8,'-') <> 0)
			   OR ( instr(gjl.REFERENCE_8,'-') = 0))) */
		-- 01-NOV-00 EGARRETT End(2)
	WHERE	SET_OF_BOOKS_ID = p_set_of_books_id
	AND	BUDGET_VERSION_ID = p_budget_version_id
	AND	CURRENCY_CODE = p_currency_code
	AND	CODE_COMBINATION_ID = p_code_combination_id
	AND	PERIOD_NAME = p_period_name;

        WHEN  value_error  THEN
        --Bug 3199481 (Start)
        If (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) then
           FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_UNEXP_ERROR');
           FND_MESSAGE.SET_TOKEN('CODE', sqlcode);
           FND_MESSAGE.SET_TOKEN('MSG', sqlerrm);
           FND_LOG.MESSAGE(fnd_log.level_unexpected,'igi.plsql.igi_bud.bud_next_year_budget.Msg1',TRUE);
        End if;
        --Bug 3199481 (End)
        raise_application_error(-20002,'Value Error Occurred');
        WHEN  others  THEN
        --Bug 3199481 (Start)
        If (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) then
            FND_MESSAGE.SET_NAME('IGI', 'IGI_LOGGING_UNEXP_ERROR');
            FND_MESSAGE.SET_TOKEN('CODE', sqlcode);
            FND_MESSAGE.SET_TOKEN('MSG', sqlerrm);
            FND_LOG.MESSAGE(fnd_log.level_unexpected,'igi.plsql.igi_bud.bud_next_year_budget.Msg2',TRUE);
        End if;
        --Bug 3199481 (End)
        raise_application_error(-20003,SQLERRM);
    END;

    BEGIN
	SELECT NULL
	INTO   l_line_reference_3
	FROM   sys.dual
	WHERE  line.reference_3 <> 'MANUAL'
	AND    line.reference_3 is not null
	AND    line.reference_3 not in (
			SELECT  profile_code
			FROM   	igi_bud_profile_codes
			WHERE  	set_of_books_id = p_set_of_books_id
			AND    	sysdate >= nvl(start_date_Active,sysdate-1)
			AND	sysdate <= nvl(end_date_active,sysdate+1));

      EXCEPTION
     	WHEN OTHERS THEN NULL;
    END;

    IF l_line_reference_3 <> 'MANUAL'
    	AND l_line_reference_3 IS NOT NULL THEN
	IGI_BUD.bud_profile_default
		( 	line.CODE_COMBINATION_ID
		, 	p_set_of_books_id
		, 	line.REFERENCE_3);
    END IF;
  END LOOP;
END;	-- of bud_next_year_budget
-- ==========================================================================
END;		-- Of Budgeting Package Body Creation

/
