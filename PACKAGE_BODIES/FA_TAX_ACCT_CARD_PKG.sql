--------------------------------------------------------
--  DDL for Package Body FA_TAX_ACCT_CARD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_TAX_ACCT_CARD_PKG" AS
-- $Header: fastacpb.pls 120.1.12010000.2 2009/07/19 08:18:53 glchen ship $
-- ****************************************************************************************
-- Copyright (c)  2000  Oracle Solution Services (India)     Product Development
-- All rights reserved
-- ****************************************************************************************
--
-- PROGRAM NAME
-- fastacps.pls
--
-- DESCRIPTION
--  This script creates the package specification of fastacpb.pls
--  This package is used to generate Asset Tax Accounting Card - Russia.
--
-- USAGE
--   To install        How to Install
--   To execute        How to Execute
--
-- PROGRAM LIST                                 DESCRIPTION
--  beforereport                                      initializes the where clauses with appropriate values
--  get_dff_column_name                     fetches DFF column names
--
-- DEPENDENCIES
--   None.
--
--
-- LAST UPDATE DATE   26-FEB-2007
--   Date the program has been modified for the last time
--
-- HISTORY
-- =======
--
-- VERSION   DATE           AUTHOR(S)                 DESCRIPTION
-- ------- ----------- ------------------- ---------------------------
--  1.0    25-FEB-2007  Srikanth Mallikarjun Gupta     Creation
--****************************************************************************************

FUNCTION beforereport RETURN BOOLEAN IS
BEGIN
--*****************************************************
--To select company Name--
--*****************************************************

	BEGIN
	    SELECT   FSC.company_name
  	    INTO 	 lc_company_name
 	    FROM 	 fa_system_controls FSC;
	EXCEPTION
		WHEN OTHERS  THEN
			FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
	END;


--********************************************************
--To select Functional Currency--
--********************************************************


  BEGIN
        SELECT  GL.currency_code
 	    INTO    lc_currency_code
 	    FROM    fa_book_controls  FBC
 	 	       ,gl_ledgers        GL
 	    WHERE   book_type_code       = P_BOOK_NAME
 	    AND     FBC.set_of_books_id  = GL.ledger_id;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
		WHEN OTHERS  THEN
			FND_FILE.PUT_LINE(FND_FILE.LOG,SQLERRM);
	END;


--************************************************
--1)To fetch DFF STATE REGISTRATION DATE--
--************************************************

  lc_state_reg_date:= GET_DFF_COLUMN_NAME ('140','fa_additions','state registration date');
  FND_FILE.PUT_LINE(FND_FILE.LOG,'state registration date='||lc_state_reg_date);

--***********************************************
--2)To fetch DFF YEARS--
--***********************************************

   lc_years:= GET_DFF_COLUMN_NAME  ('140','fa_flat_rates','years');
   FND_FILE.PUT_LINE(FND_FILE.LOG,'years='||lc_years);

--***********************************************
--3)To fetch DFF MONTHS--
--***********************************************

   lc_months:= GET_DFF_COLUMN_NAME ('140','fa_flat_rates','months');
   FND_FILE.PUT_LINE(FND_FILE.LOG,'months='||lc_months);

--***********************************************
--4)To fetch DFF TAX BOOK COST--
--***********************************************

   lc_tax_book_cost:= GET_DFF_COLUMN_NAME ('140','fa_asset_invoices','tax book cost');
   FND_FILE.PUT_LINE(FND_FILE.LOG,'tax book cost='||lc_tax_book_cost);

--***********************************************
--5)To fetch DFF REFERENCE--
--***********************************************

   lc_reference:= GET_DFF_COLUMN_NAME ('140','fa_transaction_headers','reference');
   FND_FILE.PUT_LINE(FND_FILE.LOG,'reference='||lc_reference);

--***********************************************
--6)To fetch DFF EVENT_DATE--
--***********************************************
   lc_event_date:= GET_DFF_COLUMN_NAME ('140','fa_transaction_headers','event_date');
   FND_FILE.PUT_LINE(FND_FILE.LOG,'event_date='||lc_event_date);

--***********************************************
--7)To fetch DFF SUSPENSE_REASON--
--***********************************************

   lc_suspense_reason:= GET_DFF_COLUMN_NAME ('140','fa_transaction_headers','suspense_reason');
   FND_FILE.PUT_LINE(FND_FILE.LOG,'suspense_reason='||lc_suspense_reason);

--***********************************************
--8)To fetch DFF ADJUSTING COEFFICIENT--
--***********************************************
   lc_adjusting_coefficient:= GET_DFF_COLUMN_NAME ('140','fa_flat_rates','adjusting coefficient');
   FND_FILE.PUT_LINE(FND_FILE.LOG,'adjusting coefficient='||lc_adjusting_coefficient);

--***********************************************
--9)To fetch DFF ADJ_RATE_REASON
--***********************************************

   lc_adj_rate_reason:= GET_DFF_COLUMN_NAME ('140','fa_transaction_headers','adj_rate_reason');
   FND_FILE.PUT_LINE(FND_FILE.LOG,'adj_rate_reason='||lc_adj_rate_reason);

--***********************************************
--10)To fetch DFF BASE RATE--
--***********************************************
   lc_base_rate:= GET_DFF_COLUMN_NAME ('140','fa_flat_rates','base rate');
   FND_FILE.PUT_LINE(FND_FILE.LOG,'base rate='||lc_base_rate);


 RETURN TRUE;
 END beforereport;



--***********************************************
  -- FUNCTION To FETCH DFF COLUMN NAMES
--***********************************************


    FUNCTION 	get_dff_column_name (p_appln_id 			IN NUMBER
	    							,p_dff_name 			IN VARCHAR2
		    						,p_segment_name 		IN VARCHAR2
			    					) RETURN VARCHAR2
    AS
	p_dff_appln_colname VARCHAR2(40):=NULL;
	BEGIN
	    BEGIN
		   	SELECT 		FDFCU.application_column_name
		    INTO        p_dff_appln_colname
		    FROM   		fnd_descr_flex_column_usages FDFCU
		    WHERE  		FDFCU.application_id                       = p_appln_id
		    AND    		UPPER(FDFCU.descriptive_flexfield_name)    = UPPER(p_dff_name)
			AND         UPPER(FDFCU.descriptive_flex_context_code) = 'GLOBAL DATA ELEMENTS'
		    AND    		UPPER(FDFCU.end_user_column_name)          = UPPER(p_segment_name);
			EXCEPTION
		        WHEN NO_DATA_FOUND THEN
			    FND_FILE.PUT_LINE(FND_FILE.LOG,'DATA NOT FOUND .');
		        WHEN OTHERS  THEN
			    FND_FILE.PUT_LINE(FND_FILE.LOG,'DATA NOT FOUND .');
		end;
	    IF 	p_dff_appln_colname IS NULL THEN
		    FND_FILE.PUT_LINE(FND_FILE.LOG,p_segment_name||'not found');
		ELSE
		    RETURN (p_dff_appln_colname);
		END IF;
	END	get_dff_column_name;




END fa_tax_acct_card_pkg;

/
