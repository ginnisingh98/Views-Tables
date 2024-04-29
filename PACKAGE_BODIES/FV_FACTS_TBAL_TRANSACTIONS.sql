--------------------------------------------------------
--  DDL for Package Body FV_FACTS_TBAL_TRANSACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_FACTS_TBAL_TRANSACTIONS" AS
--$Header: FVFCTRGB.pls 115.45 2002/11/11 17:32:25 ksriniva ship $
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('FV_DEBUG_FLAG'),'N');

    --  ======================================================================
    --			Variable Naming Conventions
    --  ======================================================================
    --  Parameter variables have the format 	    	"vp_<Variable Name>"
    --  FACTS Attribute Flags have the format  		"va_<Variable Name>_flag"
    --  FACTS Attribute values have the format     	"va_<Variable Name>_val"
    --  Constant values for the FACTS record
    --  have the format  	    	    		"vc_<Variable Name>"
    --  Other Global Variables have the format	    	"v_<Variable_Name>"
    --  Procedure Level local variables have
    --  the format			    		"vl_<Variable_Name>"
    --
    --  ======================================================================
    --				Parameters
    --  ======================================================================

    vp_errbuf		Varchar2(600) 		;
    vp_retcode		number 			;
    vp_set_of_books_id	number 			;
    vp_treasury_symbol	Varchar2(35)		;
    vp_start_date	Date			;
    vp_end_date		Date			;
    vp_source           GL_JE_HEADERS.JE_SOURCE%TYPE   := NULL  ;
    vp_category         GL_JE_HEADERS.JE_CATEGORY%TYPE := NULL  ;
    vp_currency_code	Varchar2(15)		;
    p_jE_header_id         GL_JE_HEADERS.JE_HEADER_ID%TYPE := NULL  ;
    --  ======================================================================
    --				FACTS Attributes
    --  ======================================================================

    va_balance_type_flag 		Varchar2(1)	;
    va_public_law_code_flag  		Varchar2(1)	;
    va_reimburseable_flag 		Varchar2(1)	;
    va_bea_category_flag    		Varchar2(1)	;
    va_appor_cat_flag	 		Varchar2(1)	;
    va_borrowing_source_flag		Varchar2(1)	;
    va_def_indef_flag			Varchar2(1)	;
    va_legis_ind_flag	    		Varchar2(1)	;
    va_authority_type_flag		Varchar2(1)	;
    va_function_flag			Varchar2(1)	;
    va_availability_flag		Varchar2(1)	;
    va_def_liquid_flag			Varchar2(1)	;
    va_deficiency_flag			Varchar2(1)	;
    va_transaction_partner_val		Varchar2(1)	;
    va_cohort				Varchar2(2)	;
    va_def_indef_val			Varchar2(1)	;
    va_appor_cat_b_dtl			Varchar2(3)	;
    va_appor_cat_b_txt			Varchar2(25)	;
    va_public_law_code_val		Varchar2(7)	;
    va_appor_cat_val			Varchar2(1)	;
    va_authority_type_val		Varchar2(1)	;
    va_reimburseable_val  		Varchar2(1)	;
    va_bea_category_val     		Varchar2(5)	;
    va_borrowing_source_val		Varchar2(6)	;
    va_deficiency_val			Varchar2(1)	;
    va_legis_ind_val			Varchar2(1)	;
    va_balance_type_val			Varchar2(1)	;

    /* Bug No: 2494754 */

    va_budget_function          VARCHAR2(3)     ;
    va_advance_flag             VARCHAR2(1)     ;
    va_transfer_ind             VARCHAR2(1)     ;
    va_advance_type_val         VARCHAR2(1)     ;
    va_transfer_dept_id         VARCHAR2(2)     ;
    va_transfer_main_acct       VARCHAR2(4)     ;


-- Added New Variables for the Document Number and Date
--
    va_document_number			Varchar2(240)	;
    va_document_Date			Date		;
    va_source                           GL_JE_HEADERS.JE_SOURCE%TYPE  ;
    va_category                         GL_JE_HEADERS.JE_CATEGORY%TYPE;
    va_user_category                    GL_JE_CATEGORIES.USER_JE_CATEGORY_NAME%TYPE;
    v_doc_created_by			NUMBER(15)	;
    v_doc_creation_date			DATE		;
    v_ccid				GL_CODE_COMBINATIONS.CODE_COMBINATION_ID%TYPE;
    v_seg_fiscal_yr			fv_pya_fiscalyear_map.fyr_segment_value%type;

    --  ======================================================================
    --				FACTS File Constants
    --  ======================================================================
    vc_fiscal_yr		Varchar2(4) 		;
    vc_rpt_fiscal_yr		Varchar2(4)		;
    vc_rpt_fiscal_month		Varchar2(2)		;
    --  ======================================================================
    --				Variables for Transaction Register report
    --  ======================================================================
    v_pagebreak1		VARCHAR2(30)		;
    v_pagebreak1_low		VARCHAR2(30)		;
    v_pagebreak1_high		VARCHAR2(30)		;
    v_pagebreak2		VARCHAR2(30)		;
    v_pagebreak2_low		VARCHAR2(30)		;
    v_pagebreak2_high		VARCHAR2(30)		;
    v_pagebreak3		VARCHAR2(30)		;
    v_pagebreak3_low		VARCHAR2(30)		;
    v_pagebreak3_high		VARCHAR2(30)		;


    --  ======================================================================
    --				Other GLOBAL Variables
    --  ======================================================================
    --	------------------------------
    --	Period Declarations
    --	-----------------------------
    v_begin_period_name		Varchar2(20)	;
    v_begin_period_start_dt 	date 		;
    v_begin_period_end_dt	date 		;
    v_begin_period_num		Number		;
    v_begin_quarter_num		Number 		;
    v_period_name		Varchar2(20)	;
    v_fiscal_year		Number		;
    v_period_start_dt		date 		;
    v_period_end_dt		date 		;
    v_period_num		Number	 	;
    v_quarter_num		Number 		;
    v_bal_seg_name		Varchar2(20)	;
    v_acc_seg_name		Varchar2(20)	;
    v_prg_seg_name		Varchar2(20)	;
    v_cohort_seg_name		Varchar2(20)	;
    v_acc_val_set_id		Number		;
    v_prg_val_set_id		Number		;
    v_cohort_select		Varchar2(20)	;
    v_cohort_stmt		Varchar2(500)	;
    v_cohort_where		Varchar2(120)	;
    v_chart_of_accounts_id	Varchar2(20)	;
    v_prg_seg_val_set_id	Number(10)	;
    v_acc_seg_val_set_id	Number(10)	;
    v_acct_num			Varchar2(25)	;
    v_fund_val			Varchar2(25)	;
    v_sgl_acct_num		number 		;

    -- This flag is set to 'Y' when a account number is found
    -- in FV_FACTS_ATTRIBUTES table and is not an USSGL account
    v_acct_attr_flag		Varchar2(1)	;
--Start Bug 2464961--
    v_amount_dr			NUMBER 		;
    v_amount_cr			NUMBER 		;
    v_amount			Number 		;
--End Bug 2464961--
    v_begin_amount		number 		;
    v_treasury_symbol_id	Number		;
    v_record_category		Varchar2(30) 	;

    /* Bug No: 2494754 */

    -- Declare a Flag to determine Debug Mode
    v_debug	Boolean	:= TRUE ;

    v_fiscal_yr                 Varchar2(25)    ;
    v_year_gtn2001              BOOLEAN ;
    v_time_frame                fv_treasury_symbols.time_frame%TYPE ;
    v_financing_acct            fv_facts_federal_accounts.financing_account%TYPE ;
    v_year_budget_auth          VARCHAR2(3);


-- ------------------------------------------------------------------
--			PROCEDURE MAIN
-- ------------------------------------------------------------------
--      Main procedure that is called to execute FACTS process.
-- 	This calls all subsequent procedures that are pare of the FACTS
-- 	process.
-- ------------------------------------------------------------------
Procedure MAIN(
	Errbuf          OUT NOCOPY 	Varchar2,
       	retcode         OUT NOCOPY 	Varchar2,
      	Set_Of_Books_Id		Number,
      	p_coa			Number,
       	Treasury_Symbol		Varchar2,
	Start_Date		Date,
	End_Date		Date,
        --Source_Name             varchar2 DEFAULT NULL ,
        --Category_Name           varchar2 DEFAULT NULL,
      	Source_Name             varchar2 := NULL ,
        Category_Name           varchar2 := NULL,
        currency_code		Varchar2,
	p_pagebreak1		VARCHAR2,
	p_pagebreak1_low	VARCHAR2,
	p_pagebreak1_high	VARCHAR2,
	p_pagebreak2		VARCHAR2,
	p_pagebreak2_low	VARCHAR2,
	p_pagebreak2_high	VARCHAR2,
	p_pagebreak3		VARCHAR2,
	p_pagebreak3_low	VARCHAR2,
	p_pagebreak3_high	VARCHAR2)


IS
BEGIN

     -- Load FACTS Parameters into Global Variables
    vp_set_of_books_id	:= 	set_of_books_id 	;
    vp_treasury_symbol  := 	treasury_symbol 	;
    vp_start_date	:=    Start_Date		;
    vp_end_date		:=    End_Date			;
    vp_retcode		:= 	0 			;
    vp_source           :=    Source_Name               ;
    vp_category         :=    Category_Name             ;
    vp_currency_code	:=    currency_code		;


     -- Load Transaction Register Report Parameters into Global Variables
     v_pagebreak1	:=	p_pagebreak1		;
     v_pagebreak1_low	:=	p_pagebreak1_low	;
     v_pagebreak1_high	:=	p_pagebreak1_high	;
     v_pagebreak2	:=	p_pagebreak2		;
     v_pagebreak2_low	:=	p_pagebreak2_low	;
     v_pagebreak2_high	:=	p_pagebreak2_high	;
     v_pagebreak3	:=      p_pagebreak3		;
     v_pagebreak3_low	:=	p_pagebreak3_low	;
     v_pagebreak3_high	:= 	p_pagebreak3_high	;


    -- Get the Treasury Symbol Id for the passed Treasury Symbol
    	 fnd_message.set_Name('FV', 'Deriving Treasury Symbol...') ;

    Begin --TS

	Select Treasury_Symbol_id
	Into 	 v_treasury_symbol_id
	From 	 fv_treasury_symbols
	where  treasury_symbol = vp_treasury_symbol
	And    set_of_books_id = vp_set_of_books_id;


    Exception
	WHEN NO_DATA_FOUND Then
	    vp_retcode := -1 ;
	vp_errbuf := 'Treasury Symbol Id cannot be found for the Treasury
			Symbol - '|| vp_treasury_symbol || ' [ MAIN ] ' ;
	       fnd_file.put_line(fnd_file.log, vp_errbuf) ;
	   -- fv_utility.debug_mesg('[TS MAIN]'||SQLERRM);
    Return ;
    End ; -- TS


   If vp_retcode = 0 Then
	    -- fv_utility.debug_mesg('PURGING TEMP TABLE');
          fnd_message.set_Name('FV', 'Purging FACTS Temp....') ;
        fnd_file.put_line(fnd_file.log, fnd_message.get) ;
	    PURGE_FACTS_TRANSACTIONS ;
   End If ;

   If vp_retcode = 0 Then
	    -- fv_utility.debug_mesg('DERVING QUALIFIER');
          fnd_message.set_Name('FV', 'Deriving Qualifier Seg....') ;
        fnd_file.put_line(fnd_file.log, fnd_message.get) ;
	    GET_QUALIFIER_SEGMENTS ;
   End If ;

   If vp_retcode = 0 Then
	    -- fv_utility.debug_mesg('GET COHORT INFO');
	    fnd_message.set_Name('FV','Deriving Treasury Sym Info');
        fnd_file.put_line(fnd_file.log, fnd_message.get) ;
	    GET_COHORT_INFO ;
   End If ;


   If vp_retcode = 0 Then
	    -- fv_utility.debug_mesg('GET PERIOD INFO');
          fnd_message.set_Name('FV', 'Deriving Period Info') ;
        fnd_file.put_line(fnd_file.log, fnd_message.get) ;
	    GET_PERIOD_INFO ;
   End If ;

   If vp_retcode = 0 Then
	    -- fv_utility.debug_mesg('START MAIN PROCESS');
          fnd_message.set_Name('FV', 'FACTS Main Process.....') ;
        fnd_file.put_line(fnd_file.log, fnd_message.get) ;
          PROCESS_TBAL_TRANSACTIONS ;
	    COMMIT;
   Else
	    ROLLBACK;
   End If ;

   retcode := vp_retcode;
   errbuf := vp_errbuf;

EXCEPTION
	-- Exception Processing
	When Others Then
    -- fv_utility.debug_mesg('WHEN OTHERS ERROR: IN [MAIN]'||SQLERRM||SQLCODE);
    vp_retcode := sqlcode ;
    vp_errbuf  := sqlerrm || ' [MAIN] ' ;
    fnd_file.put_line(fnd_file.log, vp_errbuf) ;
END MAIN ;

-- -------------------------------------------------------------------
--		 PROCEDURE PURGE_FACTS_TRANSACTIONS
-- -------------------------------------------------------------------
--    Purges all FACTS transactions from the FV_FACTS_TEMP table for
--    the passed Treasaury Symbol.
-- ------------------------------------------------------------------

Procedure PURGE_FACTS_TRANSACTIONS
IS
BEGIN
	DELETE FROM FV_FACTS_TEMP
	Where  treasury_symbol_id      =  v_treasury_symbol_id
	And    fct_int_record_category = 'TRIAL_BALANCE';
	Commit ;

EXCEPTION

	-- Exception Processing
	When NO_DATA_FOUND Then
	    Null ;
	When Others Then
	    vp_retcode := sqlcode ;
	    vp_errbuf  := sqlerrm ;
            fnd_file.put_line(fnd_file.log, vp_errbuf) ;
  -- fv_utility.debug_mesg('WHEN OTHERS ERROR IN PURGE DATA:'||SQLERRM||SQLCODE);
	    Return ;
END PURGE_FACTS_TRANSACTIONS ;

-- -------------------------------------------------------------------
--		 PROCEDURE GET_QUALIFIER_SEGMENTS
-- -------------------------------------------------------------------
--    Gets the Accounting and Balancing segment names for the Chart
--    Of Accounts associated with the passed set of Books. This is done
--    by calling to FND procedures.
-- ------------------------------------------------------------------

Procedure GET_QUALIFIER_SEGMENTS
is
  num_boolean          BOOLEAN			;
  apps_id              Number       := 101	;
  flex_code            Varchar2(25) := 'GL#'	;
  seg_number           Number			;
  seg_app_name         Varchar2(40)		;
  seg_prompt           Varchar2(25)		;
  seg_value_set_name   Varchar2(40)		;
  Invalid_segment      exception		;

BEGIN
    SELECT       chart_of_accounts_id
    INTO         v_chart_of_accounts_id
    FROM         gl_sets_of_books
    WHERE        set_of_books_id =  vp_set_of_books_id ;

    num_boolean := FND_FLEX_APIS.GET_QUALIFIER_SEGNUM
                (	apps_id,
			flex_code,
			v_chart_of_accounts_id,
			'GL_ACCOUNT',
			seg_number);

    if(num_boolean) then
         num_boolean := FND_FLEX_APIS.GET_SEGMENT_INFO
                (	apps_id,
			flex_code,
			v_chart_of_accounts_id,
			seg_number,
			v_acc_seg_name,
           	 	seg_app_name,
			seg_prompt,
			seg_value_set_name);
    else
         	raise invalid_segment;
    End if;

    num_boolean := FND_FLEX_APIS.GET_QUALIFIER_SEGNUM
              	(apps_id,
		flex_code,
		v_chart_of_accounts_id,
		'GL_BALANCING',
		seg_number);

    if(num_boolean) then
      	num_boolean := FND_FLEX_APIS.GET_SEGMENT_INFO
              	(apps_id,
		flex_code,
		v_chart_of_accounts_id,
		seg_number,
		v_bal_seg_name,
            	seg_app_name,
		seg_prompt,
		seg_value_set_name);
    else
      		raise invalid_segment;
    end if;

    v_acc_seg_name := upper(v_acc_seg_name) ;
    v_bal_seg_name := upper(v_bal_seg_name) ;

 -- fv_utility.debug_mesg('ACCOUNT:'||v_acc_seg_Name||'  BAL SEGMENT:'||v_bal_seg_name);


EXCEPTION
    when invalid_segment then
     	vp_retcode := -1;
     	vp_errbuf  := 'Cannot Read  the Balancing and account segments';
          fnd_file.put_line(fnd_file.log, vp_errbuf) ;
	  -- fv_utility.debug_mesg(' INVALID SEGMENT [GET_SEGMENT_INFO]');

     	rollback;
     	return;

    when others then
        vp_retcode := sqlcode;
	  vp_errbuf  := sqlerrm ;
	fnd_file.put_line(fnd_file.log,vp_errbuf) ;
  -- fv_utility.debug_mesg('WHEN OTHERS ERROR IN [GET_QUALIFIER_SEGMENT]'||SQLERRM);
        return;
END GET_QUALIFIER_SEGMENTS ;

-- -------------------------------------------------------------------
--			 PROCEDURE GET_PERIOD_INFO
-- -------------------------------------------------------------------
--    Gets the Period infomation like Period Number, Period_year,
--    quarter number and other corresponding period information based on
--    the quarter number passed to the Main Procedure
-- ------------------------------------------------------------------

Procedure GET_PERIOD_INFO
IS

BEGIN

    Begin
    	-- Select Period Information for Beginning Period
    	Select 	period_name,
   		period_year,
   		period_num
	Into	v_begin_period_name,
		v_fiscal_year,
		v_begin_period_num
    	From 	gl_period_statuses
    	Where trunc(start_date) = trunc(vp_start_date)
    	and application_id = 101
    	and adjustment_period_flag = 'N'
    	and set_of_books_id = vp_set_of_books_id ;

    Exception
	When NO_DATA_FOUND Then
	    vp_retcode := -1 ;
	    vp_errbuf := 'Error Getting Beginning Period Information
			 [GET_PERIOD_INFO]'  ;
             fnd_file.put_line(fnd_file.log, vp_errbuf) ;
	   -- fv_utility.debug_mesg('NO DATA FOUND ERROR IN [GET PERIOD_INFO-1]');

	    Return ;

	When TOO_MANY_ROWS Then
	    vp_retcode := -1 ;
	    vp_errbuf := 'More than one Beginning Period Returned !!
			 [GET_PERIOD_INFO]'  ;
             fnd_file.put_line(fnd_file.log, vp_errbuf) ;
	-- fv_utility.debug_mesg('TOO MANY ROWS ERROR IN [GET PERIOD_INFO-1]');
	    Return ;
    End ;
EXCEPTION

	-- Exception Processing
	When Others Then
	    vp_retcode := sqlcode ;
	    vp_errbuf  := sqlerrm || ' [GET_PERIOD_INFO] ' ;
            fnd_file.put_line(fnd_file.log, vp_errbuf) ;
  -- fv_utility.debug_mesg('WHEN OTHERS ERROR IN [GET PERIOD_INFO-MAIN]'||SQLERRM);
          Return ;
END GET_PERIOD_INFO ;


-- -------------------------------------------------------------------
--		 PROCEDURE GET_COHORT_INFO
-- -------------------------------------------------------------------
--    Gets the cohort segment name based on the Financing Acct value
-- ------------------------------------------------------------------

Procedure GET_COHORT_INFO
IS
    vl_financing_acct	Varchar2(1)	;
BEGIN

    Select 	FFFA.financing_account,
		FFFA.cohort_segment_name
    Into  	vl_financing_acct,
		v_cohort_seg_name
    From       FV_FACTS_FEDERAL_ACCOUNTS	FFFA,
   		FV_TREASURY_SYMBOLS 		FTS
    Where  	FFFA.Federal_acct_symbol_id 	= FTS.Federal_acct_symbol_id
    AND		FTS.treasury_symbol		= vp_treasury_symbol
    AND    	FTS.set_of_books_id		= vp_set_of_books_id
    AND    	FFFA.set_of_books_id		= vp_set_of_books_id ;

    ------------------------------------------------
    --	Deriving COHORT Value
    ------------------------------------------------
    If vl_financing_acct NOT IN ('D', 'G') Then
	-- Consider COHORT value only for 'D' and 'G' financing Accounts
           v_cohort_seg_name := NULL 	;
    End If ;

EXCEPTION

    When NO_DATA_FOUND Then
    	vp_retcode := -1 ;
    	vp_errbuf := 'No Financing Account found for the passed
		Treasury Symbol [GET_COHORT_INFO] ' ;
          fnd_file.put_line(fnd_file.log, vp_errbuf) ;
 -- fv_utility.debug_mesg('NO DATA FOUND ERROR IN [GET_COHORT_INFO]'||SQLERRM);
	 return;
    When TOO_MANY_ROWS Then
        vp_retcode := -1 ;
    	  vp_errbuf := 'More than one Financing Account returned for the
				passed Treasury Symbol [GET_COHORT_INFO]'  ;
            fnd_file.put_line(fnd_file.log, vp_errbuf) ;
  -- fv_utility.debug_mesg('TOO MANY ROWS ERROR IN [GET_COHORT_INFO]'||SQLERRM);
	 return;
    When OTHERS Then
        vp_retcode := SQLCODE ;
    	  vp_errbuf :=  'WHEN OTHERS IN [GET_COHORT_INFO]'||SQLERRM;
            fnd_file.put_line(fnd_file.log, vp_errbuf) ;
  -- fv_utility.debug_mesg('WHEN OTHERS ERROR IN [GET_COHORT_INFO]'||SQLERRM);
	 return;

END GET_COHORT_INFO ;

-- -------------------------------------------------------------------
--		 PROCEDURE PROCESS_TBAL_TRANSACTIONS
-- -------------------------------------------------------------------
--    This procedure selets all the transactions that needs to be
--    analyzed for reporting in the FACTS Trial Balance report. After getting the
-- 	list of trasnactions that needs to be reported, it applies all the
-- 	FACTS attributes for the account number and perform further
-- 	processing for Legislative Indicator. It populates the table FV_FACTS_TEMP
-- 	for using in the Trial balance report
-- ------------------------------------------------------------------
PROCEDURE PROCESS_TBAL_TRANSACTIONS
IS
	vl_ret_va		Boolean	:= TRUE 	;
	vl_exec_ret		Integer			;
	vl_main_cursor		Integer			;
	vl_main_select		Varchar2(2000)		;
	vl_main_fetch		Integer			;
	vl_main_amount		Number			;
        vl_legis_cursor		Integer        		;
        vl_legis_select		Varchar2(2000) 		;
	vl_legis_ref		Varchar2(240)		;
	vl_legis_ref1		Varchar2(240)		;
	vl_legis_ref2		Varchar2(240)		;
	vl_legis_ref3		Varchar2(240)		;
	vl_legis_ref4		Varchar2(240)		;
	vl_legis_ref5		Varchar2(240)		;
	vl_legis_ref9		Varchar2(240)		;
	vl_je_date		Date			;
	vl_je_category		GL_JE_HEADERS.JE_CATEGORY%TYPE;
	vl_je_Source		GL_JE_HEADERS.JE_SOURCE%TYPE;
--Start Bug 2464961--
--	vl_legis_amount		Number			;
	vl_legis_amount_dr      NUMBER ;
	vl_legis_amount_cr      NUMBER ;

--End Bug 2464961--

	vl_je_name		Varchar2(100)		;
	vl_program		Varchar2(25)		;
	vl_cohort_yr		Varchar2(25)		;
	vl_sgl_acct_num		Varchar2(25) 		;
	vl_count		Number:=0		;
	vl_tran_type		Varchar2(25)		;
	vl_exception		Varchar2(30)		;

	-- Will have 'Y' when account has facts attributes otherwise 'N'.
	vl_attributes_found	Varchar2(1)		;

	-- Cohort Segment Local Variables
	vl_cohort_select	Varchar2(25)		;
	vl_cohort_group	 	Varchar2(25)		;

	-- Requisition Id for FACTS file processes
	vl_req_id		Number			;
	vl_print_option		BOOLEAN			;
	vl_printer_name		Varchar2(240)		;
	vl_exists		varchar2(1)		;
        vl_actual_Flag 		Varchar2(1) := 'A'	;

	--  New Test Variable
	vll_count		Number := 0		;
	vll_inner_count		Number := 0		;

	-- Char Varibale to hold Date in DD-MON-YYYY Format
	vl_period_start_dt 	Varchar2(20)		;
 	vl_period_end_dt   	Varchar2(20)		;

	-- New Variables for the new modification
        vl_amount_cursor	Number			;
	vl_Amount_select  	Varchar2(2000)		;
	vl_amount_ret     	Integer			;
	vl_new_amount		Number			;
	vl_amount_fetch		Integer			;

	-- Variables to Capture documnet detiails
	vl_doc_created_by      Number			;
	vl_doc_creation_date   DATE			;
	vl_pagebreak1_seg	VARCHAR2(40)		;
	vl_pagebreak2_seg	VARCHAR2(40)		;
	vl_pagebreak3_seg	VARCHAR2(40)		;
	vl_num_boolean		BOOLEAN			;
	vl_apps_id		NUMBER := 101		;
	vl_flex_code		VARCHAR2(25)	:= 'GL#';
	vl_seg_app_name		VARCHAR2(40)		;
	vl_seg_prompt		VARCHAR2(25)		;
	vl_seg_value_set_name	VARCHAR2(40)		;
	vl_disbursements_flag 	VARCHAR2(1);
	v_ussgl_acct			fv_facts_ussgl_accounts.ussgl_account%TYPE;
	v_excptn_cat			fv_facts_temp.fct_int_record_category%TYPE;
	vl_fyr_segment_value		fv_pya_fiscalyear_map.fyr_segment_value%type;
	v_fyr_segment_name	VARCHAR2(20)		;
	--v_financing_acct	VARCHAR2(1);
	P_refer2		VARCHAR2(80);




BEGIN
    -- Get all the transction balances for the combinations that have
    -- fund values which are associated with the passed Treasury
    -- Symbol Sum all the amounts and group the data by Account Number
    -- and Fund Value.

    -- Dynamic SQL is used for declaring the following cursor and to
    -- fetch the values.

       IF v_pagebreak1 IS NOT NULL THEN
	 vl_num_boolean := FND_FLEX_APIS.GET_SEGMENT_INFO
              	(vl_apps_id,
		vl_flex_code,
		v_chart_of_accounts_id,
		v_pagebreak1,
		vl_pagebreak1_seg,
            	vl_seg_app_name,
		vl_seg_prompt,
		vl_seg_value_set_name);
     END IF;

   IF v_pagebreak2 IS NOT NULL THEN
	vl_num_boolean := FND_FLEX_APIS.GET_SEGMENT_INFO
              	(vl_apps_id,
		vl_flex_code,
		v_chart_of_accounts_id,
		v_pagebreak2,
		vl_pagebreak2_seg,
            	vl_seg_app_name,
		vl_seg_prompt,
		vl_seg_value_set_name);
   END IF;

   IF v_pagebreak3 IS NOT NULL THEN
	vl_num_boolean := FND_FLEX_APIS.GET_SEGMENT_INFO
              	(vl_apps_id,
		vl_flex_code,
		v_chart_of_accounts_id,
		v_pagebreak3,
		vl_pagebreak3_seg,
            	vl_seg_app_name,
		vl_seg_prompt,
		vl_seg_value_set_name);
   END IF;


    fnd_message.set_Name('FV', 'Selecting FACTS Trans...') ;
    		fnd_file.put_line(fnd_file.log, fnd_message.get) ;
  		-- fv_utility.debug_mesg('**** START MAIN PROCESS ****');

    Begin
        vl_main_cursor := DBMS_SQL.OPEN_CURSOR  ;
    Exception
        When Others Then
            vp_retcode := sqlcode ;
            VP_ERRBUF  := sqlerrm ;
         fnd_file.put_line(fnd_file.log, vp_errbuf) ;
	 -- fv_utility.debug_mesg('WHEN OTHERS ERROR IN MAIN CURSOR OPEN'||SQLERRM);
	 Return ;
    End ;

    If v_cohort_seg_name IS NOT NULL Then
	v_cohort_select := ', GLCC.' || v_cohort_seg_name ;
    Else
	v_cohort_select := ' ' ;
    End If ;


    -- Get the balances for the Account Number and Fund Value
    vl_main_select := 'SELECT  DISTINCT GLCC.'||v_acc_seg_name||
            ', GLCC.'||v_bal_seg_name||v_cohort_select||
	  ' FROM 	GL_CODE_COMBINATIONS    GLCC,
                	FV_FUND_PARAMETERS 	FFP,
                	FV_TREASURY_SYMBOLS 	FTS
        WHERE   	FTS.TREASURY_SYMBOL = ' ||''''||vp_treasury_symbol||'''' ||
	--pkpatel :changed to fix Bug 1575992
        ' AND   	FTS.TREASURY_SYMBOL_ID = FFP.TREASURY_SYMBOL_ID
          AND   	GLCC.'|| v_bal_seg_name ||'= FFP.FUND_VALUE
          AND   	FFP.SET_OF_BOOKS_ID =  ' || vp_set_of_books_id ||
        ' AND   	FTS.SET_OF_BOOKS_ID =  ' || vp_set_of_books_id ;


	IF v_pagebreak1 IS NOT NULL THEN
	    vl_main_select := vl_main_select ||
	    ' AND EXISTS (SELECT 1 FROM gl_code_combinations glcc2
		WHERE glcc.code_combination_id = glcc2.code_combination_id '
		|| ' AND glcc2.' || vl_pagebreak1_seg ||
		' BETWEEN '|| ''''|| v_pagebreak1_low  || '''' || ' AND '
			|| ''''||  v_pagebreak1_high  || '''' ;
	END IF;

	IF v_pagebreak2 IS NOT NULL THEN
	    vl_main_select := vl_main_select || ' AND glcc2.' || vl_pagebreak2_seg ||
		' BETWEEN '|| ''''|| v_pagebreak2_low  || '''' || ' AND '
			|| ''''||  v_pagebreak2_high  || '''' ;
	END IF;

	IF v_pagebreak3 IS NOT NULL THEN
	    vl_main_select := vl_main_select || ' AND glcc2.' || vl_pagebreak3_seg ||
		' BETWEEN '|| ''''|| v_pagebreak3_low  || '''' || ' AND '
			|| ''''||  v_pagebreak3_high  || '''' ;
	END IF;

	IF v_pagebreak1 IS NOT NULL THEN
		vl_main_select := vl_main_select || ')';
	END IF;

	vl_main_select := vl_main_select || ' ORDER BY GLCC.' || v_acc_seg_name;

fnd_file.put_line(fnd_file.log,vl_main_select);

    Begin
        dbms_sql.parse(vl_main_cursor, vl_main_select, DBMS_SQL.V7) ;
    Exception
        When Others Then
           vp_retcode := sqlcode ;
           VP_ERRBUF  := sqlerrm ;
           fnd_file.put_line(fnd_file.log, vp_errbuf) ;
           -- fv_utility.debug_mesg('ERROR IN MAIN CURSOR PARSE'||SQLERRM);

	   Return ;
    End ;

    dbms_sql.define_column(vl_main_cursor, 1, v_acct_num, 25);
    dbms_sql.define_column(vl_main_cursor, 2, v_fund_val, 25);
	   If v_cohort_Seg_name is not null Then
    		dbms_sql.define_column(vl_main_cursor, 3, vl_cohort_yr, 25);
    	   End If ;

    Begin
        vl_exec_ret := dbms_sql.execute(vl_main_cursor);
    Exception
        When Others Then
            vp_retcode := sqlcode ;
            VP_ERRBUF  := sqlerrm ;
           fnd_file.put_line(fnd_file.log, vp_errbuf) ;
 -- fv_utility.debug_mesg('WHEN OTHERS ERROR IN MAIN CURSOR EXECUTE:'||SQLERRM);
            Return ;
    End ;

    fnd_message.set_Name('FV', 'Processing starts.') ;
    fnd_file.put_line(fnd_file.log, fnd_message.get) ;

    LOOP --Main Select Loop

	-- Reset the Cursor Variable
	   v_fund_val 		:= 	Null	;
	   vl_cohort_yr 	:= 	Null	;
	   v_acct_num 		:= 	Null	;
           vl_main_amount	:= 	0	;
	   vl_new_amount	:= 	Null	;
       -- Fetch rows
           vl_main_fetch  :=  dbms_sql.fetch_rows(vl_main_cursor) ;

		IF  vl_main_fetch = 0 then
			IF vl_count = 0 Then
			   VP_ERRBUF  := 'No Data found for FACTS II process';
			   fnd_file.put_line(fnd_file.log, vp_errbuf);
			   VP_ERRBUF  := 'No Data found for FACTS II Transaction Register' ||':'||v_begin_period_num||'Year:'||v_fiscal_year
					||'SOB:'||vp_set_of_books_id||'TS:'||vp_treasury_Symbol;
			   -- fv_utility.debug_mesg(vp_errbuf);
			END IF;
            	exit;
        	ELSE
			vl_count := vl_count + 1;
	    		-- Fetch the Records into Variables
    	    		dbms_sql.column_value(vl_main_cursor, 1, v_acct_num);
    	    		dbms_sql.column_value(vl_main_cursor, 2, v_fund_val);

	   If v_cohort_Seg_name is not null Then
    		dbms_sql.column_value(vl_main_cursor, 3, vl_cohort_yr);
    	   End If ;
-- Start Process for the Amount in the main Cursor
--
------------------------------------------------------------
Begin
   	    	Begin
        	    vl_amount_cursor := DBMS_SQL.OPEN_CURSOR  ;
    		Exception
        	    When Others Then
            	vp_retcode := sqlcode ;
            	VP_ERRBUF  := sqlerrm || '[From Main Cursor ]';
            	fnd_file.put_line(fnd_file.log, vp_errbuf) ;
		Return ;
    		End ;


	   If v_cohort_Seg_name is not null Then
	    v_cohort_stmt := '  and glcc.' || v_cohort_seg_name ||
		' = nvl(' || ''''||vl_cohort_yr|| ''''||
                ' ,glcc.'|| v_cohort_seg_name || ')';
	else
	v_cohort_stmt := '';
	End if;

 vl_amount_select :=
	'SELECT NVL(SUM(nvl(BEGIN_BALANCE_DR,0) -  nvl(BEGIN_BALANCE_CR,0)),0)
	 FROM   GL_BALANCES     		GLB,
              GL_CODE_COMBINATIONS    	GLCC
	 WHERE  GLB.code_combination_id =   GLCC.code_combination_id
	 AND    GLB.TEMPLATE_ID IS NULL
	 AND	  GLB.actual_flag 	  = '||''''||vl_actual_flag||''''
	 || ' AND    GLB.SET_OF_BOOKS_ID =  ' || vp_set_of_books_id
	 || ' AND    GLB.PERIOD_NUM      =  ' || v_begin_period_num ||
       ' AND    GLB.PERIOD_YEAR =      ' || v_fiscal_year||
	 ' AND    GLCC.'||v_acc_seg_name||' = '||''''||v_acct_num||'''' ||
       ' AND    GLCC.'||v_bal_seg_name||' = '||''''||v_fund_val||'''' ||
		v_cohort_stmt||

    --  Start Added Where condintion for Bug 1553095 by SMBHAGAV on 19-04-2001
	' AND 	glb.currency_code = ' || '''' || vp_currency_code || '''' ;
    -- End Added Where condintion for Bug 1553095 by SMBHAGAV on 19-04-2001

	--pkpatel :Bug 1553095(Solution Altered)
     --	' AND  glb.currency_code = '|| '''' || g_currency_code || '''';


       	fnd_file.put_line(fnd_file.log, vl_amount_select) ;
    	Begin
            dbms_sql.parse(vl_amount_cursor,vl_amount_select,DBMS_SQL.V7);

	Exception
       	When Others Then
       		vp_retcode := sqlcode ;
       		VP_ERRBUF  := sqlerrm || '[ Parsing vl_amount_cursor ]' ;
       	fnd_file.put_line(fnd_file.log, vp_errbuf) ;
        Return ;
    	End ;

		dbms_sql.define_column(vl_amount_cursor, 1, vl_new_amount);

    		Begin
        	    vl_amount_ret := dbms_sql.execute(vl_amount_cursor);
    		Exception
        	    When Others Then
            		vp_retcode := sqlcode ;
            		VP_ERRBUF  := sqlerrm || '[ Open vl_amount_cursor]' ;
                fnd_file.put_line(fnd_file.log, vp_errbuf) ;
                        Return ;
    		End ;

		vl_amount_fetch :=  dbms_sql.fetch_rows(vl_amount_cursor) ;
    	dbms_sql.column_Value(vl_amount_cursor, 1, vl_new_amount	);
End;
		vl_main_amount := vl_new_amount;

                fnd_file.put_line(fnd_file.log,v_acct_num || ' amount: ' ||  to_char(vl_main_amount)) ;
-----------------------------------------------------------------------------
			-- fv_utility.debug_mesg('Account:'||v_acct_num);
			-- fv_utility.debug_mesg('Fund Va:'||v_fund_val);
			-- fv_utility.debug_mesg('Amount :'||vl_main_amount);
-----------------------------------------------------------------------------
			vl_attributes_found 		:= 	'N' ;

			RESET_ATTRIBUTES ;

		END IF; -- vl_main_fetch


	-- Process Account Number Validation . Just get the Parent acct.
        Begin
            Select      'X'
            into        vl_exists
            from        FV_FACTS_ATTRIBUTES
            where       facts_acct_number = v_acct_num
            and         set_of_books_id = vp_set_of_books_id;


	    -- Account Number exists in FV_FACTS_ATTRIBUTES table
	    -- and can be used to get FACTS attributes.
	        LOAD_FACTS_ATTRIBUTES (v_acct_num, v_fund_val)  ;
	        vl_attributes_found := 'Y' ;
    --VP_ERRBUF  := 'LOAD ATTRIBUTES FOR ACCT:'||v_acct_num||'-'||v_fund_val;
       -- fnd_file.put_line(fnd_file.log, vp_errbuf) ;
        Exception
            WHEN NO_DATA_FOUND Then
		-- fv_utility.debug_mesg('NO PROBLEM*** GET PARENT ATTRIBUTES');
		    --Reset the vl_sgl_acct_num
		vl_sgl_acct_num := Null;
		GET_SGL_PARENT(v_acct_num, vl_sgl_acct_num) ;
--   VP_ERRBUF  := 'LOAD ATTRIBUTES NO DATA:'||v_acct_num||'-'||vl_sgl_acct_num;
--   fnd_file.put_line(fnd_file.log, vp_errbuf) ;
		 	IF vl_sgl_acct_num IS NULL Then
		    		vl_attributes_found := 'N' ;
			ELSE
		    		vl_attributes_found := 'Y' ;
	      		LOAD_FACTS_ATTRIBUTES (vl_sgl_acct_num, v_fund_val)  ;
			END IF;
        End ;

		If  vp_retcode <> 0 Then
		-- fv_utility.debug_mesg('******** IN RET CODE 2 *********');
	    		Return ;
		End If ;

       -- Creating FACTS Record with Beginning Balance
	    	va_balance_type_val 	:= 'B' 			;
	    	va_legis_ind_val  	:= ' '			;
		v_amount		:= vl_main_amount	;
--Bug 2464961 assigning NULL to  vl_cohort_yr --
	   If v_cohort_Seg_name is  null Then
    		vl_cohort_yr := NULL ;
    	   End If ;
	    if (length(vl_cohort_yr) > 2) then
            va_cohort := substr(vl_cohort_yr,3,2);
	   else
            va_cohort := substr(vl_cohort_yr,1,2);
	   End if;


            CREATE_TBAL_RECORD 					;

          If vp_retcode <> 0 Then
		-- fv_utility.debug_mesg('******** IN RET CODE 3 *********');
             Return ;
          End If ;

	End loop;

	/* End of begining balance calculation */


	BEGIN

	    	-- Select the records for other Legislative Indicator values,
	    	-- derived from Budget Execution tables and store them in a
	    	-- cursor. Then roll them up and insert the summarized record
	    	-- into the temp table. Dynamic SQL used for implementation.

    	    	Begin
        	    vl_legis_cursor := DBMS_SQL.OPEN_CURSOR  ;
    		Exception
        	    When Others Then
            		vp_retcode := sqlcode ;
            		VP_ERRBUF  := sqlerrm ;
            		fnd_file.put_line(fnd_file.log, vp_errbuf) ;
	-- fv_utility.debug_mesg('WHEN OTHERS ERROR IN SUB CURSOR OPEN'||SQLERRM);
			Return ;
    		End ;
			-- Change the Date format to have DD-MON-YYYY
	     	vl_period_start_dt := to_char(vp_start_date,'DD-MON-YYYY');
 	     	vl_period_end_dt   := to_char(vp_end_date,'DD-MON-YYYY');

		-- fv_utility.debug_mesg('PERIOD START DATE:'||vl_period_start_dt);
		-- fv_utility.debug_mesg('PERIOD END   DATE:'||vl_period_end_dt);

/* This is the cursor we need to look into for the dates conflict */

               /* and     glh.Je_Source = nvl(:vp_source,glh.Je_Source)
                and     glc.Je_Category_name = nvl(:vp_category,glc.Je_Category_Name)
*/

/*Bug #2469438
  Modified the selct statement to read column user_je_source_name from table
    GL_JE_SOURCES instead of table GL_JE_HEADERS*/
/*Bug #2469438 Undo the above change*/

/* Bug 2464961
    Modified the select statement to select  gjl.entered_dr  , gjl.entered_cr
    Seperately.  these two column values would be stored in the
    table fv_facts_temp in AMOUNT1 and AMOUNT2 columns respectively */

    -- Bug 2512646 START

    Begin

   /* Getting Fiscal year segment name frmo fv_pya_fiscal_year_segment */

    SELECT application_column_name
    INTO v_fyr_segment_name
    FROM fv_pya_fiscalyear_segment
    WHERE set_of_books_id = vp_set_of_books_id;

	fnd_file.put_line(FND_FILE.LOG, 'Fiscal yr Segment   '||v_fyr_segment_name);

    Exception
    WHEN Others THEN
       vp_retcode := sqlcode ;
       VP_ERRBUF  := sqlerrm ;
       fnd_file.put_line(fnd_file.log, vp_errbuf) ;

    End;

    -- Bug 2512646 END


	vl_legis_select :=
			'Select gjl.je_header_id,substr(gjl.reference_6,1,7),
			gjl.reference_1,
			gjl.reference_2 ,gjl.reference_3, gjl.reference_4,
			gjl.reference_5, gjl.reference_9,
			glh.date_created ,glc.user_Je_Category_name,
			glh.Je_Source,
			gjl.entered_dr entered_dr,
	                gjl.entered_cr entered_cr,
				glb.Name, '||
   				'GLCC.'||v_acc_seg_name||
                                ',GLCC.'||v_bal_seg_name||
                                ',glcc.code_combination_id,glh.created_by,glh.creation_date'||
                                ',GLCC.' ||v_fyr_segment_name ||
				 v_cohort_select||
		    ' From    gl_je_lines	    gjl,
				gl_je_headers	    glh,
                                gl_je_batches       glb,
                                gl_je_categories    glc,
		   	      gl_code_combinations    glcc,
			      fv_fund_parameters ffp
		    Where   gjl.code_combination_id = glcc.code_combination_id
                    and     gjl.Period_Name NOT IN  (Select Period_Name From GL_Period_Statuses
                                                       Where Adjustment_Period_Flag = '||''''||'Y'||''''||
                                                     '  And   set_of_books_id = ' || vp_set_of_books_id || ')
		    AND     gjl.Je_Header_Id = glh.Je_Header_Id
                    and     glh.je_Category = glc.Je_Category_Name
                    and     glb.je_batch_id = glh.je_batch_id
                    and     glh.Je_Source = nvl('||''''||vp_source||''''||',glh.Je_Source)
                    and     glc.Je_Category_name = nvl('||''''||vp_category||''''||',glc.Je_Category_Name)
	            AND	    gjl.status = ' || '''' || 'P' || '''' ||
		    ' AND    (gjl.effective_date between to_date('||''''
			    ||vl_period_start_dt|| ''''||') AND to_date('|| ''''
			    ||vl_period_end_dt || '''' ||
		    ')) AND  gjl.set_of_books_id = ' || vp_set_of_books_id ||
		    ' AND   glcc.' || v_bal_seg_name || ' = ffp.fund_value ' ||
		    ' and  ffp.treasury_symbol_id = ' || v_treasury_symbol_id ||
    	  	' AND 	glh.currency_code = ' || '''' || vp_currency_code || '''' ;

    	IF v_pagebreak1 IS NOT NULL THEN
	    vl_legis_select := vl_legis_select ||
	    ' AND EXISTS (SELECT 1 FROM gl_code_combinations glcc2
		WHERE glcc.code_combination_id = glcc2.code_combination_id '
		|| ' AND glcc2.' || vl_pagebreak1_seg ||
		' BETWEEN '|| ''''|| v_pagebreak1_low  || '''' || ' AND '
			|| ''''||  v_pagebreak1_high  || '''';
	END IF;

	IF v_pagebreak2 IS NOT NULL THEN
	    vl_legis_select := vl_legis_select || ' AND glcc2.' || vl_pagebreak2_seg ||
		' BETWEEN '|| ''''|| v_pagebreak2_low  || '''' || ' AND '
			|| ''''||  v_pagebreak2_high  || '''';
	END IF;

	IF v_pagebreak3 IS NOT NULL THEN
	    vl_legis_select := vl_legis_select || ' AND glcc2.' || vl_pagebreak3_seg ||
		' BETWEEN '|| ''''|| v_pagebreak3_low  || '''' || ' AND '
			|| ''''||  v_pagebreak3_high  || '''';
	END IF;

	IF v_pagebreak1 IS NOT NULL THEN
		vl_legis_select := vl_legis_select || ')';
	END IF;
fnd_file.put_line(fnd_file.log,vl_legis_select);
    	Begin
       	    dbms_sql.parse(vl_legis_cursor,vl_legis_select,DBMS_SQL.V7);
  	Exception
            When Others Then
      		vp_retcode := sqlcode ;
      		VP_ERRBUF  := sqlerrm ;
               fnd_file.put_line(fnd_file.log, vp_errbuf) ;
 -- fv_utility.debug_mesg('WHEN OTHERS ERROR IN SUB CURSOR PARSE:'||SQLERRM);
               Return ;
	End ;

    	dbms_sql.define_column(vl_legis_cursor, 1,  p_je_header_id);
    	dbms_sql.define_column(vl_legis_cursor, 2,  vl_legis_ref, 240 );
	dbms_sql.define_column(vl_legis_cursor, 3,  vl_legis_ref1, 240 );
	dbms_sql.define_column(vl_legis_cursor, 4,  vl_legis_ref2, 240 );
	dbms_sql.define_column(vl_legis_cursor, 5,  vl_legis_ref3, 240 );
	dbms_sql.define_column(vl_legis_cursor, 6,  vl_legis_ref4, 240 );
	dbms_sql.define_column(vl_legis_cursor, 7,  vl_legis_ref5, 240 );
	dbms_sql.define_column(vl_legis_cursor, 8,  vl_legis_ref9, 240 );
	dbms_sql.define_column(vl_legis_cursor, 9,  vl_je_date);
	dbms_sql.define_column(vl_legis_cursor, 10,  vl_je_Category,25);
	dbms_sql.define_column(vl_legis_cursor, 11,  vl_je_Source,25);

--Start Bug 2464961--
	dbms_sql.define_column(vl_legis_cursor, 12, vl_legis_amount_dr   );
	dbms_sql.define_column(vl_legis_cursor, 13, vl_legis_amount_cr   );
	--dbms_sql.define_column(vl_legis_cursor, 11, vl_legis_amount   );
--End Bug 2464961--

	dbms_sql.define_column(vl_legis_cursor, 14, vl_je_name, 100	 );
        dbms_sql.define_column(vl_legis_cursor, 15, v_acct_num, 25);
        dbms_sql.define_column(vl_legis_cursor, 16, v_fund_val, 25);
        dbms_sql.define_column(vl_legis_cursor, 17, v_ccid);
        dbms_sql.define_column(vl_legis_cursor, 18, vl_doc_created_by);
        dbms_sql.define_column(vl_legis_cursor, 19, vl_doc_creation_date);
        dbms_sql.define_column(vl_legis_cursor, 20, v_seg_fiscal_yr,4);

	   If v_cohort_Seg_name is not null Then
	   -- Bug 2464961 changed 15 to 19 in the following line--
    		dbms_sql.define_column(vl_legis_cursor, 21, vl_cohort_yr, 25);
    	   End If ;
    		Begin
        	    vl_exec_ret := dbms_sql.execute(vl_legis_cursor);
    		Exception
        	    When Others Then
            		vp_retcode := sqlcode ;
            		VP_ERRBUF  := 'BAB'||sqlerrm ;
                        fnd_file.put_line(fnd_file.log, vp_errbuf) ;
 -- fv_utility.debug_mesg('WHEN OTHERS ERROR IN SUB CURSOR EXECUTE'||SQLERRM);
                         Return ;
    		End ;
		vll_inner_count := 0;
    	 LOOP -- Innner Loop

				-- Reset the Cursor Variable
		   	vl_legis_ref 	:= 	Null	;
			vl_legis_ref1 	:= 	Null	;
			vl_legis_ref2 	:= 	Null	;
			vl_legis_ref3 	:= 	Null	;
			vl_legis_ref4 	:= 	Null	;
			vl_legis_ref5 	:= 	Null	;
			vl_legis_ref9 	:= 	Null	;
			vl_je_date 	:= 	Null	;
			vl_je_Category	:=      Null 	;
			vl_je_source	:=	Null	;
		   	--vl_legis_amount	:= 	0	;
		   	--Start Bug No. 2464961--
		   	vl_legis_amount_dr :=   0       ;
		   	vl_legis_amount_cr :=   0       ;
		   	--End Bug No. 2464961--
	         	vl_je_name	:= 	Null	;
			vl_cohort_yr	:= 	Null	;
			va_cohort	:=  	Null	;
                        va_source       :=      Null    ;
                        va_category     :=      Null    ;
	                va_user_category :=     Null    ;
	 -- Bug 2532729
	 		p_refer2	:=	Null	;


                        RESET_ATTRIBUTES ;

		    IF dbms_sql.fetch_rows(vl_legis_cursor) = 0 then
			 -- fv_utility.debug_mesg('***EXITING SUB LOOP***');
            	 exit;
        	    ELSE
            		-- Fetch the Records into Variables
       	dbms_sql.column_value(vl_legis_cursor, 1, p_je_header_id	);
       	dbms_sql.column_value(vl_legis_cursor, 2 , vl_legis_ref	);
	dbms_sql.column_value(vl_legis_cursor, 3 , vl_legis_ref1	);
	dbms_sql.column_value(vl_legis_cursor, 4, vl_legis_ref2	);
	dbms_sql.column_value(vl_legis_cursor, 5, vl_legis_ref3	);
	dbms_sql.column_value(vl_legis_cursor, 6, vl_legis_ref4	);
	dbms_sql.column_value(vl_legis_cursor, 7, vl_legis_ref5	);
	dbms_sql.column_value(vl_legis_cursor, 8, vl_legis_ref9	);
	dbms_sql.column_value(vl_legis_cursor, 9, vl_je_date		);
	dbms_sql.column_value(vl_legis_cursor, 10, vl_je_category	);
	dbms_sql.column_value(vl_legis_cursor, 11, vl_je_source	);
	--Bug No. 2464961--
       	dbms_sql.column_Value(vl_legis_cursor, 12, vl_legis_amount_dr	);
       	dbms_sql.column_Value(vl_legis_cursor, 13, vl_legis_amount_cr	);
     	--dbms_sql.column_Value(vl_legis_cursor, 11, vl_legis_amount	);
        --Bug No. 2464961--

	dbms_sql.column_value(vl_legis_cursor, 14, vl_je_name		);
        dbms_sql.column_value(vl_legis_cursor, 15, v_acct_num);
        dbms_sql.column_value(vl_legis_cursor, 16, v_fund_val);
        dbms_sql.column_value(vl_legis_cursor, 17, v_ccid);
        dbms_sql.column_value(vl_legis_cursor, 18, vl_doc_created_by);
        dbms_sql.column_value(vl_legis_cursor, 19, vl_doc_creation_date);
        dbms_sql.column_value(vl_legis_cursor, 20, v_seg_fiscal_yr);



        -- Process Account Number Validation . Just get the Parent acct.
        Begin
            Select      'X'
            into        vl_exists
            from        FV_FACTS_ATTRIBUTES
            where       facts_acct_number = v_acct_num
            and         set_of_books_id = vp_set_of_books_id;


            -- Account Number exists in FV_FACTS_ATTRIBUTES table
            -- and can be used to get FACTS attributes.
                LOAD_FACTS_ATTRIBUTES (v_acct_num, v_fund_val)  ;
                vl_attributes_found := 'Y' ;
    		/* VP_ERRBUF  := 'LOAD ATTRIBUTES FOR ACCT:'||v_acct_num||
		'-'||v_fund_val; fnd_file.put_line(fnd_file.log, vp_errbuf) ;                   */
        Exception
            WHEN NO_DATA_FOUND Then
                -- fv_utility.debug_mesg('NO PROBLEM*** GET PARENT ATTRIBUTES');
                    --Reset the vl_sgl_acct_num
                vl_sgl_acct_num := Null;
                GET_SGL_PARENT(v_acct_num, vl_sgl_acct_num) ;
--   VP_ERRBUF  := 'LOAD ATTRIBUTES NO DATA:'||v_acct_num||'-'||vl_sgl_acct_num;
--   fnd_file.put_line(fnd_file.log, vp_errbuf) ;
                        IF vl_sgl_acct_num IS NULL Then
                                vl_attributes_found := 'N' ;
                        ELSE
                                vl_attributes_found := 'Y' ;
                        LOAD_FACTS_ATTRIBUTES (vl_sgl_acct_num, v_fund_val)  ;
                        END IF;
        End ;



			If v_cohort_Seg_name is not null Then
			--Bug 2598741 Changed to 21 in the following column value
	  	dbms_sql.column_value(vl_legis_cursor, 21, vl_cohort_yr);
			End If ;
	--Bug 2464961 assigning Null to vl_cohort_yr --
	   If v_cohort_Seg_name is null Then
    		vl_cohort_yr := NULL;
    	   End If ;
	    if (length(vl_cohort_yr) > 2) then
            va_cohort := substr(vl_cohort_yr,3,2);
	   else
            va_cohort := substr(vl_cohort_yr,1,2);
	   End if;

	-- fv_utility.debug_mesg('Inside Amount:'||to_char(vl_legis_amount));
	-- fv_utility.debug_mesg('Cohort Year  :'||vl_cohort_yr);
-- Add the Code call the doc Info Procedure
-- Create 2 new varbles to hold the info
-- Reset the variables and finally add the variable to put in the temp table.
-- bganesan
-- Reset the Variables

		va_document_number := NULL;
		va_document_date   := NULL;
                va_source          := vl_je_source;
                va_category        := vl_je_category;
/* Commented OUT NOCOPY as the logic has been added to the select statement
         IF upper(va_source) = 'MANUAL' THEN
            Begin
                Select User_Je_Category_Name
                Into   va_user_category
                From   GL_JE_Categories
                Where  Je_Category_Name = va_category;
                va_category := va_user_category;
            Exception
               When Others then
                 Null;
            End ;
         END IF;
*/


-- Bug 2532729 Start

	IF vl_je_source = 'Receivables' THEN
		p_refer2	:=	vl_legis_ref2;

		SELECT SUBSTR(p_refer2, 0, decode(INSTR(p_refer2, 'C'), 0, LENGTH(p_refer2),
	     	INSTR(p_refer2,'C')-1))
      		INTO   vl_legis_ref2
      		FROM   dual;
      	END IF;

-- Bug 2532729 End


	-- Call the Procedure to get the Document Info
		GET_DOC_INFO	(p_je_header_id  => p_je_header_id,
			P_je_source_name 	=> vl_je_source
			,P_je_category_name 	=> vl_je_Category
			,P_Name			=> vl_je_name
			,P_Date			=> vl_je_Date
			,P_created_by		=> vl_doc_created_by
			,P_creation_date	=> vl_doc_creation_date
			,P_Reference1		=> vl_legis_ref1
			,P_Reference2		=> vl_legis_ref2
			,P_Reference3		=> vl_legis_ref3
			,P_Reference4		=> vl_legis_ref4
			,P_Reference5		=> vl_legis_ref5
			,P_Reference9		=> vl_legis_ref9
			,P_Ref2			=> p_refer2
			,P_Doc_Num		=> va_document_number
			,P_Doc_Date		=> va_document_date
			,P_doc_created_by	=> v_doc_created_by
			,P_doc_creation_date   	=> v_doc_creation_date);

-- bganesan
-- Fixed Bug # 1326774
-- June 13, 2000

fnd_file.put_line(FND_FILE.LOG, ' BEFORE Acct - ' || v_acct_num || 'Fund - '
	|| v_fund_val || ' Flag ' || va_public_law_code_flag
	|| ' Value '|| va_public_law_code_val) ;

		If vl_attributes_found = 'Y' then
    			If    va_public_law_code_flag = 'N' Then
	    	            va_public_law_code_val := NULL ;
			Else
			-- Bug 2588376
			-- Pulic law code is retrived from BE table.
			    Begin

			    SELECT  public_law_code
	    		    INTO    va_public_law_code_val
	    		    FROM    fv_be_trx_dtls
	    		    WHERE   transaction_id  = vl_legis_ref1
	    		    AND     set_of_books_id = vp_set_of_books_id ;

	    		    End;

                           va_public_law_code_val := NVL(va_public_law_code_val,'000-000');

			End If ;
		Else
			va_public_law_code_val := NULL ;
		End If ;

	     	    END IF; -- dbms

-------------- Legislation Indicator Processing Starts ----------------
		IF va_legis_Ind_flag = 'Y'
		OR va_advance_flag = 'Y' OR va_transfer_ind = 'Y' Then

		    -- Get the Transaction Type Value
		    Begin

                  -- fnd_file.put_line(fnd_file.log, 'Legis1') ;
	    		Select  transaction_type_id
	    		Into    vl_tran_type
	    		From    Fv_be_trx_dtls
	    		where   transaction_id  = vl_legis_ref1
	    		and     set_of_books_id = vp_set_of_books_id ;


                   --fnd_file.put_line(fnd_file.log, 'legis2') ;
	    		-- Get the Legislation Indicator Value from
		  	-- fv_be_transaction_types table.
			Select legislative_indicator
			into   va_legis_ind_val
			From   FV_be_transaction_types
			where  apprn_transaction_type = vl_tran_type
			and    set_of_books_id  = vp_set_of_books_id ;


		    Exception
	    		When NO_DATA_FOUND Then
                 --  fnd_file.put_line(fnd_file.log, 'Legis No data') ;
			    va_legis_ind_val := 'A' ;
			When INVALID_NUMBER Then
			    va_legis_ind_val := 'A' ;
		    End ;


		     /* Bug No: 2494754 , Added the 'IF' statement below  START */

                  IF va_advance_flag = 'Y' THEN


                        -- Get the Advance Type Value
                        BEGIN


			    SELECT  advance_type
                            INTO    va_advance_type_val
                            FROM    fv_be_trx_dtls
                            WHERE   transaction_id  = vl_legis_ref1
                            AND     set_of_books_id = vp_set_of_books_id ;

                            IF v_debug THEN
                                fnd_file.put_line(fnd_file.log,
                                        'Advance Type - '||
                                        nvl(va_advance_type_val, 'Advance Type Null')) ;
                            END IF ;


                            -- If the advance_type value is null then set it to 'X'
                            IF va_advance_type_val IS NULL THEN
                                va_advance_type_val := 'X';
  			    END IF;

                            EXCEPTION
                                WHEN NO_DATA_FOUND THEN

                                -- This Exception fires when
                                -- the advance type
                                -- cannot be found.
                                va_advance_type_val := 'X';
                                WHEN INVALID_NUMBER THEN
                                va_advance_type_val := 'X';
                        END;

                    END IF; -- Advance Type processing


                       -- Transfer Acct specific processing
                    IF va_transfer_ind = 'Y' THEN


                        -- Get the Transfer Values
                        BEGIN


			    SELECT  dept_id,
                                    main_account
                            INTO    va_transfer_dept_id,
                                    va_transfer_main_acct
                            FROM    fv_be_trx_dtls
                            WHERE   transaction_id  = vl_legis_ref1
                            AND     set_of_books_id = vp_set_of_books_id ;

                            IF v_debug THEN
                                fnd_file.put_line(fnd_file.log,
                                  'Transfer Dept ID - '||
                                  nvl(va_transfer_dept_id, 'Transfer Dept ID Null')) ;
                                fnd_file.put_line(fnd_file.log,
                                  'Transfer Main Acct - '||
                                  nvl(va_transfer_main_acct, 'Transfer Main Acct Null')) ;

                            END IF ;

                            -- If the Transfer values are null then set default values
                            -- Since both dept_id and main_acct are null or both have
                            -- values test if one of them is null

                            IF va_transfer_dept_id IS NULL THEN
                                va_transfer_dept_id   := '00';
                                va_transfer_main_acct := '0000';
                            END IF;
                            EXCEPTION
                                WHEN NO_DATA_FOUND THEN
   				-- This Exception fires when
                                -- the transfer info
                                -- cannot be found.
                                va_transfer_dept_id   := '00';
                                va_transfer_main_acct := '0000';
                        END;

                    END IF; -- Transfer Acct processing

	-- Processing Budget Year Authority attribute

/* Bug No : 2494754                  END  */
/* Bug No : 2512646                  START  */

	IF vl_sgl_acct_num IS NOT NULL then

		BEGIN

		SELECT balance_type
    		INTO	va_balance_type_flag
    		FROM	FV_FACTS_ATTRIBUTES
    		WHERE	Facts_Acct_Number = vl_sgl_acct_num
		and set_of_books_id = vp_set_of_books_id ;

		EXCEPTION
			When Others Then

		    		vp_retcode := sqlcode ;
		    		vp_errbuf := '  Error! No Attributes Definied for the Account - ' ||
			  		vl_sgl_acct_num || ' [PROCESS_TBAL_TRANSCTIONS]'||sqlerrm ;

		                fnd_file.put_line(fnd_file.log, vp_errbuf) ;
			        Return ;

		END;

		IF va_balance_type_flag In ('S', 'E') Then
	    		va_balance_type_val := 'E' 	;
	    		v_record_category := 'REPORTED' ;
		End if;

		IF va_balance_type_flag IN ('S', 'B') Then
	    		va_balance_type_val := 'B' 		;
	   		v_record_category := 'REPORTED' 	;
		End if;

		v_year_budget_auth := NULL;


   		IF  v_record_category = 'REPORTED' AND vl_sgl_acct_num IS NOT NULL THEN


      			IF v_excptn_cat IS NULL THEN

      			BEGIN


        		SELECT disbursements_flag
        		INTO   vl_disbursements_flag
			FROM   fv_facts_ussgl_accounts
			WHERE  ussgl_account = v_acct_num;
			--ussgl_account = v_ussgl_acct;

			EXCEPTION
			When Others Then
		    		vp_retcode := sqlcode ;
		    		vp_errbuf := sqlerrm ||
					' [ PROCESS_TBAL_TRANSCTIONS vl_disbursements_flag -  ] ' ;
		                fnd_file.put_line(fnd_file.log, vp_errbuf) ;
			        Return ;
			END;

      			END IF;

		BEGIN
 		Select	FTS.Time_Frame, FFFA.financing_account
    			INTO v_time_frame, v_financing_acct
    		From  	FV_FACTS_FEDERAL_ACCOUNTS	FFFA,
	   	 	 FV_TREASURY_SYMBOLS 		FTS
    		Where  FFFA.Federal_acct_symbol_id 	= FTS.Federal_acct_symbol_id
    		AND	   FTS.treasury_symbol		= vp_treasury_symbol
    		AND    FTS.set_of_books_id		= vp_set_of_books_id
    		AND    FFFA.set_of_books_id		= vp_set_of_books_id ;

    		EXCEPTION
	   		When Others Then
		    		vp_retcode := sqlcode ;
		    		vp_errbuf := sqlerrm ||
					' [ PROCESS_TBAL_TRANSCTIONS  - v_time_frame ] ' ;
		                fnd_file.put_line(fnd_file.log, vp_errbuf) ;
			        --Return ;
    		END;

        		IF  v_time_frame             = 'NO_YEAR'
           			AND v_financing_acct      = 'N'
	   			AND vl_disbursements_flag = 'Y'
	   			AND (v_amount_dr > 0 OR v_amount_cr > 0) THEN



			BEGIN

           		SELECT fyr_segment_value
	   		INTO   vl_fyr_segment_value
	   		FROM   fv_pya_fiscalyear_map
	   		WHERE  period_year = v_fiscal_year
	   		AND    set_of_books_id = vp_set_of_books_id;

	   		EXCEPTION
	   		When Others Then
		    		vp_retcode := sqlcode ;
		    		vp_errbuf := sqlerrm ||
					' [ PROCESS_TBAL_TRANSCTIONS vl_fyr_segment_value -  ] ' ;
		                fnd_file.put_line(fnd_file.log, vp_errbuf) ;
			        --Return ;
	   		END;

				IF vl_fyr_segment_value IS NOT NULL THEN
					IF vl_fyr_segment_value = v_seg_fiscal_yr THEN
		   				v_year_budget_auth := 'NEW';
	        			ELSE
		  				 v_year_budget_auth := 'BAL';
					END IF;
	   			END IF;
			END IF;
  		 END IF;

	END IF;

/* Bug No : 2512646                  END  */


		    	va_balance_type_val := 'E'		;
		    	--Start Bug 2464961--
                        --v_amount	  := vl_legis_amount	;
  			v_amount_dr	  := vl_legis_amount_dr	;
  			v_amount_cr	  := vl_legis_amount_cr	;
                        --End Bug 2464961--

			If vl_attributes_found = 'N' then
		            RESET_ATTRIBUTES ;
			End If ;

			CREATE_TBAL_RECORD 			;

                	If vp_retcode <> 0 Then
		-- fv_utility.debug_mesg('******** IN RET CODE 4 *********');
                    	    Return ;
                	End If ;
-------------- Normal Processing ----------------
		ELSE     -- Legis Flag

			va_legis_ind_val 	:= ' ' 			;
			va_balance_type_val 	:= 'E'		;
			--Start Bug 2464961--
                        --v_amount	  := vl_legis_amount	;
  			v_amount_dr	  := vl_legis_amount_dr	;
  			v_amount_cr	  := vl_legis_amount_cr	;
                        --End Bug 2464961--

/* Commented for Bug 2539852
                        If vl_attributes_found = 'N' then
                            RESET_ATTRIBUTES ;
                        End If ;
*/

			CREATE_TBAL_RECORD 				;
	     	If vp_retcode <> 0 Then
			-- fv_utility.debug_mesg('******** IN RET CODE 5 *********');
                 	Return ;
                	End If ;
		END IF;   -- Legis Flag
		END LOOP; -- Inner Loop
		-- fv_utility.debug_mesg('***DONE SUB LOOP ****');
	   EXCEPTION
		-- Process any Exceptions in Legislative Indicator
		-- Processing
		When Others Then
		    vp_retcode := sqlcode ;
		    vp_errbuf := sqlerrm ||
			' [ PROCESS_TBAL_TRANSCTIONS-  ] ' ;
                   fnd_file.put_line(fnd_file.log, vp_errbuf) ;
		    -- fv_utility.debug_mesg('WHEN OTHERS IN SUB LOOP'||SQLERRM);
		    Return ;
End ;
    -----------------------------------------------------------------
    -- Submitting Transaction Registar Report
    -----------------------------------------------------------------
    vl_printer_name := FND_PROFILE.VALUE('PRINTER');
    vl_print_option := FND_REQUEST.SET_PRINT_OPTIONS(	 printer =>vl_printer_name
							,copies  => 1);

    vl_req_id := FND_REQUEST.SUBMIT_REQUEST ('FV','FVFCTRGR','','',FALSE,
                        vp_set_of_books_id,v_chart_of_accounts_id,vp_start_date,vp_end_date, v_fiscal_year,
			vp_treasury_symbol, v_treasury_symbol_id,vp_source,vp_category,
			v_pagebreak1,v_pagebreak1_low,v_pagebreak1_high,
			v_pagebreak2,v_pagebreak2_low,v_pagebreak2_high,
			v_pagebreak3,v_pagebreak3_low,v_pagebreak3_high,
			vp_currency_code) ;

    -- if concurrent request submission failed then abort process
    -- fv_utility.debug_mesg('Concurrent Request Id For FACTS Transaction
    -- Register Report : ' || vl_req_id);

    if vl_req_id = 0 then
	vp_errbuf := 'Error submitting Transaction Register Balance with Attributes Report ';
        vp_retcode := -1 ;
         fnd_file.put_line(fnd_file.log, vp_errbuf) ;
    Else
        vp_errbuf:= 'Transaction Register Report submitted successfully with the Request ID : '||
			   to_char(vl_req_id)	;
            fnd_file.put_line(fnd_file.log, vp_errbuf);
        IF vl_print_option THEN
		vp_errbuf:= 'Transaction Register Report will be send for printing to printer: '||vl_printer_name;
		fnd_file.put_line(fnd_file.log,vp_errbuf);
        END IF;
    end if;

EXCEPTION

	When Others Then
	    vp_retcode := sqlcode ;
	    vp_errbuf :=  'WHEN OTHERS IN PROCESS TBAL TRANSACTION:'||sqlerrm ;
            fnd_file.put_line(fnd_file.log, vp_errbuf) ;
 -- fv_utility.debug_mesg('WHEN OTHERS IN PROCESS TBAL TRANSACTION:'||SQLERRM);

END PROCESS_TBAL_TRANSACTIONS ;

-- -------------------------------------------------------------------
--		 PROCEDURE LOAD_FACTS_ATTRIBUTES
-- -------------------------------------------------------------------
-- This procedure selects the attributes for the Account number
-- segment from FV_FACTS_ATTRIBUTES table and load them into global
-- variables for usage in the FACTS Main process. It also calculates
-- one time pull up values for the account number that does not
-- require drill down into GL transactions.
-- ------------------------------------------------------------------
PROCEDURE LOAD_FACTS_ATTRIBUTES 	(acct_num varchar2,
			 		 fund_val Varchar2)
IS
	vl_financing_acct_flag  	Varchar2(1) 	;
	vl_established_fy		number 		;
	vl_resource_type		Varchar2(80) 	;
	vl_fund_category		Varchar2(1)	;
BEGIN


    Begin

        SELECT 	balance_type,
		public_law_code,
		reimburseable_flag,
		availability_time,
		bea_category,
		apportionment_category,
		substr(transaction_partner,1,1),
		borrowing_source,
		definite_indefinite_flag,
		legislative_indicator,
		authority_type,
		deficiency_flag,
		function_flag,
		advance_flag, /* Bug No: 2494754 */
		transfer_flag
    	INTO	va_balance_type_flag,
		va_public_law_code_flag,
		va_reimburseable_flag,
		va_availability_flag,
		va_bea_category_flag,
		va_appor_cat_flag,
		va_transaction_partner_val,
		va_borrowing_source_flag,
		va_def_indef_flag,
		va_legis_ind_flag,
		va_authority_type_flag,
		va_deficiency_flag,
		va_function_flag,
		va_advance_flag, /* Bug No: 2494754 */
		va_transfer_ind
    	FROM	FV_FACTS_ATTRIBUTES
      WHERE     Facts_Acct_Number = acct_num
      AND       set_of_books_id = vp_set_of_books_id;
    Exception

	When NO_DATA_FOUND Then
	    vp_retcode := -1 ;
	    vp_errbuf := 'Error! No Attributes Definied for the Account - ' ||
			      v_acct_num || ' [LOAD_FACTS_ATTRIBURES]' ;
	     fnd_file.put_line(fnd_file.log, vp_errbuf) ;
 -- fv_utility.debug_mesg('ERROR NO DATA FOUND [LOAD_FACTS_ATTRIBUTES]'||vp_errbuf);
             return;
	When Others Then
	    vp_retcode := sqlcode ;
	    vp_errbuf  := sqlerrm ;
        fnd_file.put_line(fnd_file.log, vp_errbuf) ;
  -- fv_utility.debug_mesg('WHEN OTHERS ERROR IN [LOAD_FACTS_ATTRIBUTES]'||SQLERRM);
          return;
    End ;


    -- Getting the One time Pull up Values
   --pkpatel :Changed to fix Bug 1575992
    Begin

    	Select 	UPPER(fts.resource_type),
			def_indef_flag,
			ffp.fund_category
    	INTO 		vl_resource_type,
			va_def_indef_val,
			vl_fund_category
    	From    	fv_treasury_symbols	  fts,
			fv_fund_parameters	  ffp
    	WHERE   	ffp.treasury_symbol_id 	= fts.treasury_symbol_id
    	AND     	ffp.fund_value		= fund_val
	AND		fts.treasury_symbol	= vp_treasury_symbol
    	AND 		fts.set_of_books_id 	= vp_set_of_books_id
    	AND 		ffp.set_of_books_id 	= vp_set_of_books_id  ;
    Exception

	When NO_DATA_FOUND Then
	    --vp_retcode := -1 ;
	    vp_errbuf := 'Error getting Fund Category value for the fund - '||
			  fund_val || ' [LOAD_FACTS_ATTRIBURES]' ;
           fnd_file.put_line(fnd_file.log, vp_errbuf) ;
		 -- fv_utility.debug_mesg('NO DATA FOUND '||vp_errbuf);
             --return;

	When Others Then
	    vp_retcode := sqlcode ;
	    vp_errbuf  := sqlerrm  || ' [LOAD_FACTS_ATTRIBURES]' ;
          fnd_file.put_line(fnd_file.log, vp_errbuf) ;
            -- fv_utility.debug_mesg('WHEN OTHERS'||vp_errbuf);
            return;
    End ;



    ------------------------------------------------
    -- Deriving Indefinite Definite Flag
    ------------------------------------------------
    If nvl(va_def_indef_flag,'X') <> 'Y' Then
	 va_def_indef_val := NULL;
    End If ;

    ------------------------------------------------
    -- Deriving Public Law Code Flag
    ------------------------------------------------
    If    va_public_law_code_flag = 'N' Then
	    va_public_law_code_val := NULL ;
    End If ;


    IF     va_availability_flag = 'N' Then
	   va_availability_flag := NULL;
    End If ;

    IF    va_transaction_partner_val = 'N' Then
	  va_transaction_partner_val := NULL;
    End If ;
    ------------------------------------------------
    -- Deriving Apportionment Category Code
    ------------------------------------------------


    If va_appor_cat_flag = 'Y' Then
	If vl_fund_category IN ('A','S') Then
	    va_appor_cat_val := 'A' ;
	ElsIf vl_fund_category IN ('B','T') Then
	    va_appor_cat_val := 'B' ;
	ElsIf vl_fund_category in ('R','C')  Then
	    va_appor_cat_val := 'C' ;
	Else
	    va_appor_cat_val := NUll;
	End If ;
    Else
        va_appor_cat_val := NULL;
    End If ;

    ------------------------------------------------
    -- Deriving Authority Type
    ------------------------------------------------
    If nvl(va_authority_type_flag,'N') <> 'N' then
        va_authority_type_val := va_authority_type_flag;
    Else
	va_authority_type_val := ' ' ;
    End If ;

    --------------------------------------------------------------------
    -- Deriving Reimburseable Flag Value
    --------------------------------------------------------------------

    If va_reimburseable_flag = 'Y' Then
    	If vl_fund_category IN ('A', 'B','C') Then
	    va_reimburseable_val := 'D' ;
	ElsIf vl_fund_category in ('R','S','T') then
	    va_reimburseable_val := 'R' ;
	Else
	    va_reimburseable_val := NULL;
	End If ;
    Else
	va_reimburseable_val := NULL;
    End If ;


    --------------------------------------------------------------------
    -- Deriving BEA Category and Borrowing Source Values
    --------------------------------------------------------------------
    If va_bea_category_flag = 'Y' OR va_borrowing_source_flag = 'Y' then
	Begin
	    Select RPAD(substr(ffba.bea_category,1,5), 5),
		     RPAD(substr(ffba.borrowing_source,1,6), 6)
	    Into   va_bea_category_val,
		     va_borrowing_source_val
	    From   fv_facts_budget_accounts	ffba,
		     fv_facts_federal_accounts	fffa,
		     fv_treasury_symbols		fts ,
		     fv_facts_bud_fed_accts	ffbfa
	    Where  fts.federal_acct_symbol_id  = fffa.federal_acct_symbol_id
	    AND    fffa.federal_acct_symbol_id = ffbfa.federal_acct_symbol_id
	    AND    ffbfa.budget_acct_code_id   = ffba.budget_acct_code_id
	    AND    fts.treasury_symbol	       = vp_treasury_symbol
	    AND    fts.set_of_books_id         = vp_set_of_books_id
	    AND    fffa.set_of_books_id        = vp_set_of_books_id
	    AND    ffbfa.set_of_books_id       = vp_set_of_books_id
	    AND    ffba.set_of_books_id        = vp_set_of_books_id ;

	    If va_bea_category_flag = 'N' then
		va_bea_category_val 	:= NULL;
	    End If ;

	    If va_borrowing_source_flag = 'N' then
		va_borrowing_source_val := NULL;
	    End If ;

	Exception
	    When NO_DATA_FOUND then
	--	vp_retcode := -1 ;
	--	vp_errbuf := 'Error Getting BEA Category/Borrowing Source
	--		      values [LOAD_FACTS_ATTRIBUTES]' ;
        --    	fnd_file.put_line(fnd_file.log, vp_errbuf) ;
	--	 	  -- fv_utility.debug_mesg('NO DATA FOUND'||vp_errbuf);
        --    	return;
	va_bea_category_val 	:= Null;
	va_borrowing_source_val := Null;
	End ;
    Else
	va_bea_category_val 	:= Null;
	va_borrowing_source_val := Null;
    End If ;


    va_def_liquid_flag := ' ' ;
    va_deficiency_flag := ' ' ;

    --------------------------------------------------------------------
    -- Deriving Budget Function
    --------------------------------------------------------------------
    If va_function_flag = 'Y'  then
        Begin
            Select RPAD(substr(ffba.budget_function,1,3), 3)
            Into   va_budget_function
            From   fv_facts_budget_accounts     ffba,
                   fv_facts_federal_accounts    fffa,
                   fv_treasury_symbols          fts ,
                   fv_facts_bud_fed_accts       ffbfa
            Where  fts.federal_acct_symbol_id  = fffa.federal_acct_symbol_id
            AND    fffa.federal_acct_symbol_id = ffbfa.federal_acct_symbol_id
            AND    ffbfa.budget_acct_code_id   = ffba.budget_acct_code_id
            AND    fts.treasury_symbol         = vp_treasury_symbol
            AND    fts.set_of_books_id         = vp_set_of_books_id
            AND    fffa.set_of_books_id        = vp_set_of_books_id
            AND    ffbfa.set_of_books_id       = vp_set_of_books_id
            AND    ffba.set_of_books_id        = vp_set_of_books_id ;
         Exception
            When NO_DATA_FOUND then

                -- Create Exception Record for Budget Function
             --   v_record_category := 'BUDGET_FNCTN_NOT_DEFINED' ;
                Create_tbal_Record                             ;
        End ;
    Else
        va_budget_function      := RPAD(' ', 3);
    End If ;


EXCEPTION
    When Others Then
	vp_retcode := sqlcode ;
	vp_errbuf := sqlerrm || ' [LOAD_FACTS_ATTRIBUTES]' ;
		 -- fv_utility.debug_mesg('WHEN OTHERS'||vp_errbuf);
        	 fnd_file.put_line(fnd_file.log, vp_errbuf) ;

END LOAD_FACTS_ATTRIBUTES ;


-- -------------------------------------------------------------------
--		 PROCEDURE RESET_ATTRIBUTES
-- -------------------------------------------------------------------
-- ------------------------------------------------------------------
Procedure RESET_ATTRIBUTES
is
Begin

                        -- Reset all the Attribute Variable
                        va_balance_type_flag            :=      Null    ;
                        va_public_law_code_flag         :=      Null    ;
                        va_reimburseable_flag           :=      Null    ;
                        va_availability_flag            :=      Null    ;
                        va_bea_category_flag            :=      Null    ;
                        va_appor_cat_flag               :=      Null    ;
                        va_transaction_partner_val      :=      Null    ;
                        va_borrowing_source_flag        :=      Null    ;
                        va_def_indef_flag               :=      Null    ;
                        va_legis_ind_flag               :=      Null    ;
                        va_authority_type_flag          :=      Null    ;
                        va_deficiency_flag              :=      Null    ;
                        va_function_flag                :=      Null    ;

                        va_balance_type_val             :=      Null    ;
                        va_def_indef_val                :=      Null    ;
                        va_public_law_code_val          :=      Null    ;
                        va_appor_cat_val                :=      Null    ;
                        va_authority_type_val           :=      Null    ;
                        va_reimburseable_val            :=      Null    ;
                        va_bea_category_val             :=      Null    ;
                        va_borrowing_source_val         :=      Null    ;
                        va_availability_flag            :=      Null    ;
                        va_legis_ind_val                :=      Null    ;
                        va_document_number              :=      NULL    ;
                        va_document_date                :=      NULL    ;

                        --Bug No : 2494754

       		  	va_availability_flag        := ' ';
		        va_function_flag            := ' ';
		        va_budget_function          := '   ';
		        va_advance_type_val         := ' ';
		        va_transfer_dept_id         := '  ';
		        va_transfer_main_acct       := '    ';

End Reset_Attributes ;










-- -------------------------------------------------------------------
--		 PROCEDURE GET_SGL_PARENT
-- -------------------------------------------------------------------
--    Gets the SGL Parent Account for the passed account number
-- ------------------------------------------------------------------
Procedure GET_SGL_PARENT(
                        Acct_num                Varchar2,
                        sgl_acct_num       OUT NOCOPY  Varchar2)
is
    vl_exists		varchar2(1)		;
    vl_acc_val_set_id	Number		;
Begin
    -- Getting the Value Set Id for the Account Segment
    Begin       /* Value Set Id */
        -- Getting the Value set Id for finding hierarchies
        select  flex_value_set_id
        into    vl_acc_val_set_id
        from    fnd_id_flex_segments
        where   application_column_name = v_acc_seg_name
        and     id_flex_code            = 'GL#'
        and     id_flex_num             = v_chart_of_accounts_id;

	--vp_errbuf := 'SGL Value Set Id :'||to_Char(vl_acc_val_set_id);
        --fnd_file.put_line(fnd_file.log, vp_errbuf) ;

    Exception
        When NO_DATA_FOUND Then
            vp_retcode := -1 ;
            vp_errbuf := 'Error getting Value Set Id for segment'
                            ||v_acc_seg_name||' [GET_SGL_PARENT]' ;
           fnd_file.put_line(fnd_file.log, vp_errbuf) ;
		 -- fv_utility.debug_mesg('WHEN NO DATA FOUND'||vp_errbuf);

            return;
    End ;  /* Value Set Id */

    -- Finding the parent of the Account Number in GL
    Begin   /* Finding Parent From GL */
	-- Finding the parent
--vp_errbuf := 'SGL Parent Account Before:'||sgl_acct_num||'-'||acct_num;
       -- fnd_file.put_line(fnd_file.log, vp_errbuf) ;
        Select parent_flex_value
        Into   sgl_acct_num
        From   fnd_flex_value_hierarchies
        where  (ACCT_NUM Between child_flex_value_low
                      and child_flex_value_high)
        and    parent_flex_value <> 'T'
        AND    flex_value_set_id = vl_acc_val_set_id
        and    parent_flex_value in
                        (Select ussgl_account
                         From   fv_facts_ussgl_accounts
                         Where  ussgl_account = parent_flex_value);

	--vp_errbuf := 'SGL Parent Account:'||sgl_acct_num||'-'||acct_num;
        --fnd_file.put_line(fnd_file.log, vp_errbuf) ;
		Begin
	  	  -- Look for parent in FV_FACTS_ATTRIBUTES table
	   		Select 'X'
	   	 	Into vl_exists
	    		From fv_facts_attributes
	    		where facts_acct_number = sgl_acct_num
                        and   set_of_books_id = vp_set_of_books_id;

	--vp_errbuf := 'SQL Account Exists:'||vl_exists;
        --fnd_file.put_line(fnd_file.log, vp_errbuf) ;
	    	-- Return the account Number
	    		Return ;
		Exception
	    		When NO_DATA_FOUND then
				sgl_acct_num := NULL 	;
--	vp_errbuf := 'SGL NO DATA'||vl_exists;
 --       fnd_file.put_line(fnd_file.log, vp_errbuf) ;
				Return			;
		End ;
    Exception
	When NO_DATA_FOUND or TOO_MANY_ROWS Then
	    -- No Parent Exists or Too Many Parents. Return Nulls
--	vp_errbuf := sqlerrm || ' [GET SGL ACCOUNT]' ;
 --       fnd_file.put_line(fnd_file.log, vp_errbuf) ;
		 Return ;
        When OTHERS Then
--	vp_errbuf := sqlerrm || ' [GET SGL ACCOUNT]' ;
--        fnd_file.put_line(fnd_file.log, vp_errbuf) ;
                Return;
    End ;

End GET_SGL_PARENT ;

-- -------------------------------------------------------------------
--		 PROCEDURE CREATE_TBAL_RECORD
-- -------------------------------------------------------------------
--    Inserts a new record into FV_FACTS_TEMP table with the current
--    values from the  global variables with record category TRIAL_BALANCE
-- ------------------------------------------------------------------
PROCEDURE   CREATE_TBAL_RECORD
IS
BEGIN

	-- If the Balance Type is 'B' then the amount is taken from the
	-- V_BEGIN_AMOUNT, otherwise in case of 'E', the amount is taken
	-- from V_AMOUNT

	/*Bug 2464961
	The following insert statement would store data into two columns.
	i.e. amount1 and amount2 for v_amount_dr and v_amount_cr respectively*/

	/* Bug No : 2494754 */

	INSERT INTO FV_FACTS_TEMP
		(TBAL_ACCT_NUM		,
		TBAL_FUND_VALUE		,
 		COHORT			,
 		BEGIN_END    		,
 		INDEF_DEF_FLAG		,
 		PUBLIC_LAW    		,
 		APPOR_CAT_CODE  	,
 		AUTHORITY_TYPE  	,
 		TRANSACTION_PARTNER   	,
 		REIMBURSEABLE_FLAG   	,
 		BEA_CATEGORY        	,
 		BORROWING_SOURCE   	,
 		AVAILABILITY_FLAG	,
 		LEGISLATION_FLAG	,
 		AMOUNT         		,
 		TREASURY_SYMBOL_ID     	,
 		FCT_INT_RECORD_CATEGORY ,
		DOCUMENT_NUMBER		,
		DOCUMENT_DATE		,
                SGL_ACCT_NUMBER		,
                APPOR_CAT_B_TXT		,
                BUDGET_FUNCTION		,
                ADVANCE_FLAG		,
                TRANSFER_DEPT_ID	,
                TRANSFER_MAIN_ACCT	,
                YEAR_BUDGET_AUTH	,
                CODE_COMBINATION_ID	,
                DOCUMENT_CREATED_BY	,
                DOCUMENT_CREATION_DATE	,
                DOCUMENT_SOURCE	        ,
                AMOUNT1                 ,
                AMOUNT2 )
	Values (v_acct_num		,
		v_fund_val		,
		va_cohort		,
		va_balance_type_val	,
    		va_def_indef_val	,
    		va_public_law_code_val	,
    		va_appor_cat_val	,
    		va_authority_type_val 	,
    		va_transaction_partner_val,
    		va_reimburseable_val	,
    		va_bea_category_val 	,
    		va_borrowing_source_val	,
    		va_availability_flag	,
    		va_legis_ind_val	,
		v_amount		,
		v_treasury_symbol_id	,
		'TRIAL_BALANCE' 	,
		va_document_number	,
		va_document_date	,
                va_source               ,
                va_category 		,
                va_budget_function      ,
                va_advance_type_val     ,
                va_transfer_dept_id     ,
                va_transfer_main_acct   ,
                v_year_budget_auth	,
                v_ccid			,
                v_doc_created_by	,
                v_doc_creation_date	,
                va_source               ,
                v_amount_dr             ,
                v_amount_cr             ) ;

EXCEPTION
    When Others Then
	vp_retcode 	:=	sqlcode ;
	vp_errbuf 	:= 	sqlerrm || ' [CREATE_TBAL_RECORD] ' ;
           fnd_file.put_line(fnd_file.log, vp_errbuf) ;
		 -- fv_utility.debug_mesg('WHEN OTHERS'||vp_errbuf);
      return;
END   CREATE_TBAL_RECORD ;

----



Procedure GET_DOC_INFO	(
			 p_je_header_id in number,
			 P_je_source_name 	IN Varchar2
			,P_je_category_name 	IN Varchar2
			,P_Name			IN Varchar2
			,P_Date			IN Date
			,P_created_by		IN Number
			,P_creation_date	IN Date
			,P_Reference1		IN Varchar2
			,P_Reference2		IN Varchar2
			,P_Reference3		IN Varchar2
			,P_Reference4		IN Varchar2
			,P_Reference5    	IN Varchar2
			,P_Reference9    	IN Varchar2
			,P_Ref2		    	IN Varchar2
			,P_Doc_Num	     OUT NOCOPY Varchar2
			,P_Doc_Date	     OUT NOCOPY Date
			,P_doc_created_by    OUT NOCOPY Number
			,P_doc_creation_date OUT NOCOPY Date) IS

p_refer2	Varchar2(240);
p_refer4	Varchar2(240);

-- Bug 2606958 Start
l_temp_cr_hist_id      Varchar2(240);
l_rev_exists           Varchar2(1) := 'N';
lv_document_num	       Varchar2(240);
lv_doc_date	       Date;
lv_doc_creation_date    Date;
lv_doc_created_by       Number;

l_doc_date_d 	       Date;
l_doc_creation_date_d  Date;
l_doc_created_by_d     Number;
l_void_date	       Date;
l_check_date	       Date;
l_inv_payment_id       Number;

-- Bug 2606958 End

-- Bug 2532729
l_cash_receipt_hist_id varchar2(240);
Cursor	Pur_Rec is
		Select 	 rt.Transaction_Date
				,rcv.Receipt_Num,rcv.created_by,rcv.creation_date
		From	 	 RCV_Transactions rt
				,RCV_Shipment_Headers rcv
		Where     	 rt.Shipment_Header_Id = rcv.Shipment_Header_Id
		And      	 to_char(rt.Transaction_ID)     = P_Reference5;

Cursor	Pay_Pur is
		Select 	 inv.Invoice_Num
			,inv.INvoice_Date,inv.created_by,inv.creation_date
		From  	 AP_Invoices_all inv
		Where    	 to_char(inv.Invoice_Id) = P_Reference2;

Cursor	Pay_Pay is
		Select 	Distinct api.invoice_num,
			apc.check_date,api.created_by,api.creation_date
		From	ap_checks_all apc,
			ap_invoices_all api,
			ap_invoice_payments_all apip
		where   to_char(apc.check_id) = p_reference3
		and	to_char(api.invoice_id) = p_reference2
		and	apc.check_id = apip.check_id
		and	api.invoice_id = apip.invoice_id ;

Cursor	Receivables is
		Select
		DECODE(l_rev_exists, 'Y', reversal_date, receipt_date),
		DECODE(l_rev_exists, 'Y', l_doc_created_by_d, created_by),
		DECODE(l_rev_exists, 'Y', l_doc_creation_date_d, creation_date)
		From		 AR_Cash_Receipts_All
		Where		 to_char(Cash_Receipt_Id) = p_refer2;

--Bug 2532729 Start

-- Bug 2606958 Start
Cursor Receivables_Exists is
        SELECT 'Y'
        FROM   ar_cash_receipt_history_all
        WHERE  cash_receipt_history_id =  to_number(l_cash_receipt_hist_id);

Cursor Receivables_Applications is
	SELECT cash_receipt_history_id
	FROM   ar_receivable_applications_all
	WHERE receivable_application_id = to_number(l_cash_receipt_hist_id);

Cursor Receivables_Hist is
        SELECT 'Y'
        FROM   ar_cash_receipt_history_all
        WHERE  cash_receipt_history_id =  to_number(l_cash_receipt_hist_id);


Cursor Receivables_History is
        SELECT 'Y', creation_date, created_by
        FROM   ar_cash_receipt_history_all
        WHERE  reversal_cash_receipt_hist_id =  to_number(l_cash_receipt_hist_id);

Cursor Receivables_Misc is
	SELECT 'Y', creation_date, created_by
	FROM   ar_misc_cash_distributions_all
	WHERE  misc_cash_distribution_id = l_cash_receipt_hist_id
	AND    created_from = 'ARP_REVERSE_RECEIPT.REVERSE';

Cursor Receivables_Distrib is
	SELECT 'Y'
	FROM   ar_misc_cash_distributions_all
	WHERE  misc_cash_distribution_id = to_number(l_cash_receipt_hist_id);

-- Bug 2606958 End

Cursor  Pay_Treas_Check is
	SELECT  void_date, checkrun_name
	FROM    ap_checks_all
	WHERE	check_id = p_reference3;

Cursor	Pay_Treas_Void  is
	SELECT  creation_date, created_by
	FROM    ap_invoice_payments_all
	WHERE   check_id = p_reference3
	AND     invoice_payment_id = (SELECT max(invoice_payment_id)
	                              FROM   ap_invoice_payments_all
           	                      WHERE  check_id = p_reference3);

Cursor  Pay_Treas  is
        SELECT  ftc.checkrun_name,
                ftc.treasury_doc_date,
                ftc.creation_date,
                ftc.created_by
        FROM    fv_treasury_confirmations_all ftc
        WHERE   to_char(ftc.treasury_confirmation_id) = p_reference1;

Cursor  Pay_Pay_Check is
	SELECT  void_date, check_date
	FROM    ap_checks_all
	WHERE	check_id = p_reference3;

Cursor  Pay_Pay_Void is
        SELECT NVL(MAX(invoice_payment_id),0)
        FROM ap_invoice_payments_all
        WHERE invoice_id = NVL(p_reference2, 0)
        AND   check_id = NVL(p_reference3,0)
        AND   invoice_payment_id > p_reference9;

Cursor Pay_Pay_Void_Values is
	SELECT api.invoice_num, apip.creation_date, apip.created_by
	FROM  ap_invoice_payments_all apip,
	      ap_invoices_all api
	WHERE api.invoice_id = NVL(p_reference2, 0)
	AND   api.invoice_id = apip.invoice_id
        AND   apip.check_id = NVL(p_reference3,0)
        AND   apip.invoice_payment_id = p_reference9;

Cursor  Pay_Pay_Non_Void is
        SELECT  api.invoice_num, apc.creation_date, apc.created_by
        FROM    ap_checks_all apc,
                ap_invoices_all api,
                ap_invoice_payments_all apip
        WHERE   to_char(apc.check_id) = p_reference3
        AND     to_char(api.invoice_id) = p_reference2
        AND     apc.check_id = apip.check_id
        AND     api.invoice_id = apip.invoice_id;


--Bug 2532729 End
--Start Bug 2464961--
--Modified the following Budget_Transac cursor definition--

Cursor	Budget_Transac  is
	SELECT	 h.doc_number, d.gl_date, d.creation_date, d.created_by
	FROM 	 fv_be_trx_dtls d, fv_be_trx_hdrs h
	WHERE 	 to_char(d.transaction_id) = p_reference1
	AND	 h.doc_id = d.doc_id;

--End Bug 2464961--


-- Check this Later
Cursor	Pur_Req is
	Select 	Start_Date_Active
		,created_by
		,creation_date
	From	PO_Requisition_Headers_All
	Where	to_Char(Requisition_Header_Id) =  P_Reference2;

Cursor	Pur_Pur is
	Select 	Start_Date
		,created_by
		,creation_date
	From		PO_Headers_all
	Where		Segment1 = P_Reference4;

--Start Bug 2464961--
Cursor  manual_csr is
	SELECT  default_effective_date
        FROM    gl_je_headers
	WHERE   je_header_id = p_je_header_id;

--End Bug 2464961--

-- Bug 2532729 Start

Cursor Receivables_Adjustment is
	SELECT apply_date, creation_date, created_by
	FROM ar_adjustments_all
	WHERE adjustment_id = p_refer2;

Cursor Receivables_CMA is
	SELECT apply_date, creation_date, created_by
	FROM ar_receivable_applications_all
	WHERE receivable_application_id = p_refer2;

Cursor Receivables_Memos_Inv is
	SELECT trx_date, creation_date, created_by
	FROM ra_customer_trx_all
	WHERE customer_trx_id = p_refer2;


-- Bug 2532729 End

BEGIN
-- Set the values to Null
--

lv_document_num := NULL;
lv_doc_Date	    := NULL;
lv_doc_created_by := P_created_by ;
lv_doc_creation_date := P_creation_date ;

-- Code for Purchasing
--
IF P_Je_Source_Name = 'Purchasing' THEN

	IF P_Je_Category_Name = 'Requisitions' THEN
		lv_document_num := P_Reference4;
		OPEN 	Pur_Req;
		FETCH	Pur_Req INTO lv_doc_date,lv_doc_created_by,lv_doc_creation_date;
		CLOSE Pur_Req;
	ELSIF P_Je_Category_Name = 'Purchases' THEN
		lv_document_num := P_Reference4;
		OPEN 	Pur_Pur;
		FETCH	Pur_Pur INTO lv_doc_date,lv_doc_created_by,lv_doc_creation_date;
		CLOSE Pur_Pur;
	ELSIF P_Je_Category_Name = 'Receiving' THEN
		OPEN 	Pur_Rec;
		FETCH	Pur_Rec INTO lv_doc_date,lv_document_num,lv_doc_created_by,lv_doc_creation_date;
		CLOSE Pur_Rec;
	ELSE
		lv_document_num := P_Name;
		lv_doc_date	    := P_Date;
	END IF;
-- Code for Payables
--
ELSIF P_Je_Source_Name = 'Payables' THEN

	IF P_Je_Category_Name = 'Purchase Invoices' THEN
		OPEN 	Pay_Pur;
		FETCH	Pay_Pur INTO lv_document_num,lv_doc_date,lv_doc_created_by,lv_doc_creation_date;
		CLOSE Pay_Pur;
	ELSIF P_Je_Category_Name = 'Payments' THEN

-- Bug 2532729 Start
		OPEN 	Pay_Pay_Check;
		FETCH Pay_Pay_Check INTO l_void_date, l_check_date;
		CLOSE   Pay_Pay_Check;

		IF l_void_date IS NULL THEN
			OPEN Pay_Pay;
			FETCH	Pay_Pay INTO lv_document_num,lv_doc_date,lv_doc_created_by,lv_doc_creation_date;
			CLOSE Pay_Pay;
		ELSE
			OPEN Pay_Pay_Void;
			FETCH Pay_Pay_Void INTO l_inv_payment_id;
			CLOSE Pay_Pay_Void;

			IF (l_inv_payment_id <> 0) THEN
				OPEN Pay_Pay_Non_Void;
				FETCH Pay_Pay_Non_Void INTO lv_document_num, lv_doc_creation_date, lv_doc_created_by;
				CLOSE Pay_Pay_Non_Void;

				lv_doc_date := l_check_date;
			ELSIF (l_inv_payment_id = 0) THEN
				OPEN Pay_Pay_Void_Values;
				Fetch Pay_Pay_Void_Values INTO lv_document_num, lv_doc_creation_date, lv_doc_created_by;
				CLOSE Pay_Pay_Void_Values;

				lv_doc_date := l_void_date;
			END IF;
		END IF;

	ELSIF P_Je_Category_Name = 'Treasury Confirmation' AND UPPER(p_name) NOT LIKE '%VOID%' THEN

			OPEN Pay_Treas;
			FETCH Pay_Treas INTO lv_document_num, lv_doc_date, lv_doc_creation_date,lv_doc_created_by;
			CLOSE Pay_Treas;

	ELSIF P_Je_Category_Name = 'Treasury Confirmation' AND UPPER(p_name) LIKE '%VOID%' THEN

			OPEN Pay_Treas_Check;
			FETCH Pay_Treas_Check INTO lv_doc_date, lv_document_num;
			CLOSE Pay_Treas_Check;

			OPEN Pay_Treas_Void;
			FETCH Pay_Treas_Void INTO lv_doc_creation_date, lv_doc_created_by;
			CLOSE Pay_Treas_Void;

-- Bug 2532729 End

	ELSE
		lv_document_num := P_Name;
		lv_doc_date	:= P_Date;
	END IF;
-- Code for Receivables
--
ELSIF P_Je_Source_Name = 'Receivables' THEN

-- Bug 2606958
	p_refer2 := p_reference2;
        lv_document_num := p_reference4;

--LGOEL: Added exception handler for statement below
	IF (p_reference2 is null) then
		IF (l_debug = 'Y') THEN
   		fv_utility.debug_mesg('    Ref2 is NULL ...');
		END IF;
	 	lv_document_num := p_refer4;
      	ELSE
-- Bug 2532729 Start

	IF (p_je_category_name = 'Adjustment') THEN
		OPEN Receivables_Adjustment;
		FETCH Receivables_Adjustment INTO lv_doc_date, lv_doc_creation_date, lv_doc_created_by;
		CLOSE Receivables_Adjustment;

	ELSIF (p_je_category_name = 'Credit Memo Applications') THEN
		OPEN Receivables_CMA;
		FETCH Receivables_CMA INTO lv_doc_date, lv_doc_creation_date, lv_doc_created_by;
		CLOSE Receivables_CMA;

	ELSIF (p_je_category_name IN ('Credit Memos', 'Debit Memos', 'Sales Invoices')) THEN
		OPEN Receivables_Memos_Inv;
		FETCH Receivables_Memos_Inv INTO lv_doc_date, lv_doc_creation_date, lv_doc_created_by;
		CLOSE Receivables_Memos_Inv;

	ELSE
-- Bug 2606958 Start
l_cash_receipt_hist_id :=  SUBSTR(p_ref2, INSTR(p_ref2,'C')+1, LENGTH(p_ref2));

            IF (p_je_category_name = 'Misc Receipts')
            THEN
               IF (l_debug = 'Y') THEN
                  fv_utility.debug_mesg('     Processing a Misc Receipt');
               END IF;
               p_refer2 := p_ref2;
               l_cash_receipt_hist_id := p_reference5;
            ELSE
               IF (l_debug = 'Y') THEN
                  fv_utility.debug_mesg('     Processing a Trade Receipt or Other');
               END IF;
               p_refer2 := p_reference2;
               l_cash_receipt_hist_id := SUBSTR(p_ref2, INSTR(p_ref2,'C')+1, LENGTH(p_ref2));
            END IF;

            IF (l_debug = 'Y') THEN
               fv_utility.debug_mesg('     Cash receipt id = '||p_refer2);
               fv_utility.debug_mesg('     Cash receipt hist id = ' ||l_cash_receipt_hist_id);
            END IF;

      	    OPEN    Receivables_Hist;
   	    FETCH   Receivables_Hist INTO l_rev_exists;
   	    CLOSE   Receivables_Hist;

  	    IF (l_rev_exists = 'N')
   	    THEN
	       l_doc_creation_date_d := NULL;
	       l_doc_created_by_d := NULL;

	       IF (p_je_category_name = 'Misc Receipts')
	       THEN
	          l_rev_exists := 'M';
	       ELSE
	          l_rev_exists := 'C';
	       END IF;

  	    ELSE
	       l_rev_exists := 'N';

               OPEN    Receivables_History;
               FETCH   Receivables_History into l_rev_exists, l_doc_creation_date_d, l_doc_created_by_d;
               CLOSE   Receivables_History;

	       IF (l_rev_exists = 'Y')
	       THEN
	          IF (l_debug = 'Y') THEN
   	          fv_utility.debug_mesg('     Cash Receipt Hist Id exits in Ar_Cash_Receipt_History_All ... REVERSAL');
	          END IF;
	       END IF;
	    END IF;

            IF (p_je_category_name <> 'Misc Receipts') AND (l_rev_exists = 'C')
            THEN
	       -- Find out if Reference_2 contains Receivable_Application_Id
	       OPEN    Receivables_Applications;
	       FETCH   Receivables_Applications into l_temp_cr_hist_id;
	       CLOSE   Receivables_Applications;

	       IF (l_temp_cr_hist_id IS NOT NULL)
	       THEN
	          l_cash_receipt_hist_id := l_temp_cr_hist_id;

	          IF (l_debug = 'Y') THEN
   	          fv_utility.debug_mesg('      Cash Receipt Hist Id exits in Ar_Receivable_Applications_All: ' ||l_cash_receipt_hist_id);
	          END IF;

		  -- Use cash_receipt_history_id obtained above to find if a row exits in Ar_Cash_Receipts_All
	          OPEN    Receivables_Exists;
                  FETCH   Receivables_Exists INTO l_rev_exists;
                  CLOSE   Receivables_Exists;

	          IF (l_rev_exists = 'Y')
	          THEN
	 	     IF (l_debug = 'Y') THEN
   	 	     fv_utility.debug_mesg('      Cash Receipt Hist Id exits in Ar_Cash_Receipt_History_All: ' ||l_cash_receipt_hist_id);
	 	     END IF;

		     l_rev_exists := 'N';

		     -- Select the document info from Ar_Cash_Receipt_History_All table
		     OPEN    Receivables_History;
		     FETCH   Receivables_History into l_rev_exists, l_doc_creation_date_d, l_doc_created_by_d;
		     CLOSE   Receivables_History;

		     IF (l_rev_exists = 'Y')
		     THEN
	 	        IF (l_debug = 'Y') THEN
   	 	        fv_utility.debug_mesg('      Reversal Cash Receipt Hist Id exists ... REVERSAL');
	 	        END IF;
		     END IF;

	          END IF;
	       END IF;	-- End If for l_temp_cr_hist_id

 	    ELSIF (p_je_category_name = 'Misc Receipts') AND (l_rev_exists = 'M')
	    THEN
	       -- Find out if Reference_2 contains Misc_Cash_Distribution_Id
	       OPEN    Receivables_Distrib;
	       FETCH   Receivables_Distrib into l_rev_exists;
	       CLOSE   Receivables_Distrib;

	       IF (l_rev_exists = 'Y')
	       THEN
	          IF (l_debug = 'Y') THEN
   	          fv_utility.debug_mesg('      Cash Receipt Hist Id exits in Ar_Misc_Cash_Distributions_All: ' ||l_cash_receipt_hist_id);
	          END IF;

	          l_rev_exists := 'N';

		  -- Select the document info from Ar_Misc_Cash_Distributions_All table
	          OPEN    Receivables_Misc;
	          FETCH   Receivables_Misc into l_rev_exists, l_doc_creation_date_d, l_doc_created_by_d;
	          CLOSE   Receivables_Misc;

		  IF (l_rev_exists = 'Y')
		  THEN
	 	     IF (l_debug = 'Y') THEN
   	 	     fv_utility.debug_mesg('      Misc Cash Disc Id has Reverse value in created from ... REVERSAL');
	 	     END IF;
		  END IF;

	       END IF;
 	    END IF; -- End If for l_rev_exists = C/M



	OPEN 	Receivables;
	FETCH	Receivables INTO lv_doc_date, l_doc_created_by_d, l_doc_creation_date_d;
	CLOSE   Receivables;

		lv_doc_creation_date := l_doc_creation_date_d;
   	    	lv_doc_created_by    := l_doc_created_by_d;

   	 	END IF; -- End if for p_je_category_name
      	END IF; -- End if for p_reference2

-- Bug 2606958 End
-- Bug 2532729 End

ELSIF P_Je_Source_Name = 'Budgetary Transaction' THEN
        OPEN    Budget_Transac;
        FETCH   Budget_Transac INTO lv_document_num, lv_doc_date,
                lv_doc_creation_date,lv_doc_created_by ;
        CLOSE   Budget_Transac;

--Start Bug No. 2464961--
ELSIF p_je_source_name = 'Manual' THEN

        OPEN    Manual_csr ;
        FETCH   Manual_csr INTO lv_doc_date;
        CLOSE   Manual_csr;

	IF (p_reference4 IS NOT NULL)
	THEN
	   lv_document_num      := p_reference4;
	ELSE
	   lv_document_num      := p_name;
	END IF;

-- Code for Misc
--
ELSE
	IF (p_reference4 IS NOT NULL)
	THEN
	   lv_document_num      := p_reference4;
	ELSE
	   lv_document_num      := p_name;
	END IF;

	lv_doc_date          := p_date;
	lv_doc_creation_date := p_creation_date;
	lv_doc_created_by    := p_created_by;

--End Bug  No. 2464961--
END IF ;


-- Check for values
-- If not put default

-- Test
-- fv_utility.debug_mesg('P_Doc_Num 11:'||lv_document_num);
-- fv_utility.debug_mesg('P_Doc_Date11:'||lv_Doc_Date);
--
IF lv_document_num IS NULL THEN
   lv_document_num := P_Name;
END IF;

IF lv_doc_date IS NULL THEN
   lv_doc_Date := P_Date;
END IF;

IF lv_doc_created_by IS NULL THEN
   lv_doc_created_by := P_created_by;
END IF;

IF lv_doc_creation_date IS NULL THEN
   lv_doc_creation_date := P_creation_date;
END IF;


-- Set the out varibales
--

	P_Doc_Num := lv_document_num;
	P_Doc_Date:= lv_Doc_Date;
	P_doc_created_by := lv_doc_created_by;
	P_doc_creation_date := lv_doc_creation_date ;

-- fv_utility.debug_mesg('Je_Source_Name:'||P_Je_Source_Name);
-- fv_utility.debug_mesg('Je_Category_Name:'||P_Je_Category_Name);
-- fv_utility.debug_mesg('P_Reference1:'||P_Reference1);
-- fv_utility.debug_mesg('P_Reference2:'||P_Reference2);
-- fv_utility.debug_mesg('P_Reference3:'||P_Reference3);
-- fv_utility.debug_mesg('P_Reference4:'||P_Reference4);
-- fv_utility.debug_mesg('P_Reference5:'||P_Reference5);+
-- fv_utility.debug_mesg('P_Name:'||P_Name);
-- fv_utility.debug_mesg('P_Date:'||P_Date);
-- fv_utility.debug_mesg('P_Doc_Num:'||P_Doc_Num);
-- fv_utility.debug_mesg('P_Doc_Date:'||P_Doc_Date);
-- fv_utility.debug_mesg('********************************');



EXCEPTION
	When Others Then
		vp_retcode 	:=	sqlcode ;
		vp_errbuf 	:= 	sqlerrm || ' [GET_DOC_INFO] ' ;
    	       	fnd_file.put_line(fnd_file.log, vp_errbuf) ;
		      -- fv_utility.debug_mesg('WHEN OTHERS'||vp_errbuf);
    		      return;
END GET_DOC_INFO;

-- -------------------------------------------------------------------
-- End Of the Package Body
-- -------------------------------------------------------------------
END FV_FACTS_TBAL_TRANSACTIONS ;


/
