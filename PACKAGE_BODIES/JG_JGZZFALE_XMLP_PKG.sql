--------------------------------------------------------
--  DDL for Package Body JG_JGZZFALE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_JGZZFALE_XMLP_PKG" AS
/* $Header: JGZZFALEB.pls 120.0 2008/01/08 07:54:47 vjaganat noship $ */
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION CF_PARENT_ACCT_DESCRFORMULA(PARENT_ACCOUNT IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*SRW.REFERENCE(PARENT_ACCOUNT)*/NULL;
    RETURN (SUBSTR(FA_RX_SHARED_PKG.GET_FLEX_VAL_MEANING(NULL
                                                       ,RP_ACCT_VALUESET_NAME
                                                       ,PARENT_ACCOUNT)
                 ,1
                 ,80));
    RETURN NULL;
  EXCEPTION
    WHEN OTHERS THEN
      /*SRW.MESSAGE(123
                 ,'Error retrieving parent account description.')*/NULL;
      /*SRW.MESSAGE(123
                 ,'Valueset Name: ' || RP_ACCT_VALUESET_NAME || ' Parent Account: ' || PARENT_ACCOUNT)*/NULL;
      RETURN NULL;
  END CF_PARENT_ACCT_DESCRFORMULA;

  FUNCTION RP_COMPANY_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_COMPANY_NAME;
  END RP_COMPANY_NAME_P;

  FUNCTION RP_REPORT_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_REPORT_NAME;
  END RP_REPORT_NAME_P;

  FUNCTION RP_SOB_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_SOB_NAME;
  END RP_SOB_NAME_P;

  FUNCTION RP_PRECISION_P RETURN NUMBER IS
  BEGIN
    RETURN RP_PRECISION;
  END RP_PRECISION_P;

  FUNCTION RP_SOB_ID_P RETURN NUMBER IS
  BEGIN
    RETURN RP_SOB_ID;
  END RP_SOB_ID_P;

  FUNCTION RP_CURRENCY_CODE_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_CURRENCY_CODE;
  END RP_CURRENCY_CODE_P;

  FUNCTION RP_ACCT_VALUESET_NAME_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_ACCT_VALUESET_NAME;
  END RP_ACCT_VALUESET_NAME_P;

  FUNCTION CP_DATE_FORMAT_P RETURN VARCHAR2 IS
  BEGIN
    RETURN CP_DATE_FORMAT;
  END CP_DATE_FORMAT_P;

  FUNCTION RP_BOOK_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_BOOK;
  END RP_BOOK_P;

  FUNCTION RP_BAL_SEG_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_BAL_SEG;
  END RP_BAL_SEG_P;

  FUNCTION RP_PERIOD_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_PERIOD;
  END RP_PERIOD_P;

  FUNCTION RP_OFFICIAL_RUN_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_OFFICIAL_RUN;
  END RP_OFFICIAL_RUN_P;

  FUNCTION RP_PARENT_TOTALS_P RETURN VARCHAR2 IS
  BEGIN
    RETURN RP_PARENT_TOTALS;
  END RP_PARENT_TOTALS_P;

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS

	gl_balancing_seg            number;
	gl_account_seg              number;
	fa_cost_ctr_seg             number;

	acct_flex_structure		number;
	asset_key_flex_struct		number;

	appcol_name		    VARCHAR2(240);
	seg_name 		    VARCHAR2(240);
	prompt			    VARCHAR2(240);
	value_set_name		    VARCHAR2(240);

	error_msg                   VARCHAR2(240);
	step			    VARCHAR2(2000);
	errbuf			    VARCHAR2(2000);
	retcode			    NUMBER := 0;
	submit_error		    EXCEPTION;


	begin
        P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
	RP_PERIOD	:= P_PERIOD;
	RP_BAL_SEG	:= P_BALANCING_SEGMENT;
	RP_BOOK	:= P_BOOK_TYPE_CODE;
	RP_OFFICIAL_RUN := P_STATUTORY_REPORT;
	RP_PARENT_TOTALS := P_SUMMARY;


	-- srw.do_sql ('alter session set sql_trace true');
	--SRW.USER_EXIT('FND SRWINIT');

	/*--------------------------------------------------*/
	/* Submit RX Report                                 */
	/*--------------------------------------------------*/

	step := 'Submitting Reserve Ledger Report';

	FARX_DP.deprn_run (
	    book 		=> P_BOOK_TYPE_CODE,
	    period 		=> P_PERIOD,
	    from_bal		=> NULL,
	    to_bal		=> NULL,
	    from_acct		=> NULL,
	    to_acct		=> NULL,
	    from_cc		=> NULL,
	    to_cc		=> NULL,
	    major_category	=> NULL,
	    minor_category	=> NULL,
	    cat_seg_num		=> NULL,
	    cat_seg_val		=> NULL,
	    prop_type		=> NULL,
	    request_id 		=> P_CONC_REQUEST_ID,
	    login_id		=> FND_GLOBAL.LOGIN_ID,
	    retcode 		=> retcode,
	    errbuf 		=> errbuf);

	if (retcode <> 0)
	then
	   /*srw.message('000','Error code '||retcode||' returned from the Reserve Ledger report');
	   srw.message('001','Error buf: '||errbuf);
	   raise submit_error;*/null;
	end if;


	/*--------------------------------------------------*/
	/* Get report title                                 */
	/*--------------------------------------------------*/

	step := 'Get report title';

	select
		nvl(max(lu.meaning), 'No Report Title in FND_LOOKUPS.MEANING for lookup_type JGZZ_JGSTRGRH_TITLE')
	into
		RP_REPORT_NAME
	from
		fnd_lookups lu
	where
		lu.lookup_type = 'JGZZ_JGSTRGRH_TITLE' and
		lu.lookup_code = 'LEDGER';


	/*--------------------------------------------------*/
	/* Get set of books, currency and other info        */
	/*--------------------------------------------------*/

	step := 'Get SOB, currency and other info';

	SELECT
		SC.COMPANY_NAME,
		BC.SET_OF_BOOKS_ID,
		SOB.NAME SOB_NAME,
		SOB.Currency_Code,
		CUR.Precision,
		SC.ASSET_KEY_FLEX_STRUCTURE,
		BC.Accounting_Flex_Structure
	INTO
		RP_COMPANY_NAME,
		RP_SOB_ID,
		RP_SOB_NAME,
		RP_CURRENCY_CODE,
		RP_PRECISION,
		asset_key_flex_struct,
		acct_flex_structure
	FROM
		FA_SYSTEM_CONTROLS	SC,
		FA_BOOK_CONTROLS 	BC,
		GL_LEDGERS_PUBLIC_V 	SOB,
		FND_CURRENCIES		CUR
	WHERE
		BC.Book_Type_Code = nvl(P_BOOK_TYPE_CODE, bc.book_type_code)
	AND	SOB.Ledger_ID = BC.Set_Of_Books_ID
	AND	CUR.Currency_Code = SOB.Currency_Code
	AND	rownum = 1;




	/*--------------------------------------------------*/
	/* Get Account Segement's ValueSet                  */
	/*--------------------------------------------------*/

	-- Get Account Segment Numbers

	fa_rx_shared_pkg.get_acct_segment_numbers (
		BOOK => P_Book_Type_Code,
		BALANCING_SEGNUM => gl_balancing_seg,
		ACCOUNT_SEGNUM => gl_account_seg,
		CC_SEGNUM => fa_cost_ctr_seg,
		CALLING_FN => 'FA_BALANCES_REPORT');

	-- Get ValueSetName
	if (FND_FLEX_APIS.GET_SEGMENT_INFO
				(101, 'GL#', Acct_Flex_Structure, Gl_Account_Seg,
				 appcol_name, seg_name, prompt, value_set_name))
	then
	    RP_ACCT_VALUESET_NAME := value_set_name;
	else
	    return(FALSE);
	end if;

	  --
	  -- BUG 876171: Get the date
	  --
	 /* SRW.USER_EXIT('FND DATE4FORMAT RESULT = ":CP_DATE_FORMAT"');  */

	return (TRUE);

	RETURN NULL; EXCEPTION
	   WHEN SUBMIT_ERROR THEN
		/*SRW.MESSAGE(123, 'Error occurred in Before Report Trigger, Step: ' || step || '==> ' || sqlerrm);*/null;
		RETURN(FALSE);
	   WHEN NO_DATA_FOUND THEN NULL;
	   RETURN NULL; WHEN OTHERS THEN
		/*SRW.MESSAGE(123, 'Error occurred in Before Report Trigger, Step: ' || step || '==> ' || sqlerrm);*/null;
		RETURN(FALSE);
END;
END JG_JGZZFALE_XMLP_PKG;



/
