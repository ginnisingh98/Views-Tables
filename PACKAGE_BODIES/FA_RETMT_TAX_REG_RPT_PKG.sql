--------------------------------------------------------
--  DDL for Package Body FA_RETMT_TAX_REG_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_RETMT_TAX_REG_RPT_PKG" AS
-- $Header: FASARTRPB.pls 120.2.12010000.2 2009/07/19 08:08:50 glchen ship $
-- ****************************************************************************************
-- Copyright (c)  2000  Oracle Solution Services (India)     Product Development
-- All rights reserved
-- ****************************************************************************************
--
-- PROGRAM NAME
-- FASARTRPB.pls
--
-- DESCRIPTION
--  This script creates the package body of FASARTRPB.pls.
--  This package is used to generate  Asset Retirement Tax Register(Russia).
--
-- USAGE
--   To install        How to Install
--   To execute        How to Execute
--
-- DEPENDENCIES
--   None.
--
--
-- LAST UPDATE DATE   19-DEC-2006
--   Date the program has been modified for the last time
--
-- HISTORY
-- =======
--
-- VERSION DATE        AUTHOR(S)         DESCRIPTION
-- ------- ----------- ---------------   ------------------------------------
-- 1.0    19-DEC-2006 SURESH SINGH M Creation
--
--****************************************************************************************
   FUNCTION beforereport  RETURN BOOLEAN
   IS
      manual_vend_num_type   VARCHAR2 (20);
      v_cnt_supp             NUMBER;

   BEGIN

	   BEGIN
		SELECT company_name
		  INTO lp_company_name
		  FROM fa_system_controls;
       EXCEPTION
	      WHEN OTHERS THEN
		   fnd_file.put_line(fnd_file.log,'Error in Fetching company name. Error => '||SQLERRM);
	   END;

	  BEGIN
		SELECT gl.currency_code
		  INTO lp_currency_code
		  FROM fa_book_controls fbc, gl_ledgers gl
		 WHERE book_type_code = p_book_name
		   AND fbc.set_of_books_id = gl.ledger_id;
       EXCEPTION
	      WHEN OTHERS THEN
		   fnd_file.put_line(fnd_file.log,'Error in Fetching currency code. Error => '||SQLERRM);
	   END;


      RETURN (TRUE);
   END;

   FUNCTION afterreport       RETURN BOOLEAN
   IS
   BEGIN

        RETURN (TRUE);
   END;



   FUNCTION afterpform    RETURN BOOLEAN  IS
      p_period_set_name        VARCHAR2 (100);
      v_view                   VARCHAR2 (30000);
      v_profile_option_value   VARCHAR2 (100);
	  period_from 				VARCHAR2 (100);
	  period_to 				VARCHAR2 (100);
	  v_free_charge				VARCHAR2 (100);
   BEGIN

         IF (P_FROM_PERIOD IS NOT NULL) THEN
 			SELECT TRUNC (fadp.calendar_period_open_date)
			  INTO period_from
			  FROM fa_deprn_periods fadp
			 WHERE fadp.book_type_code = p_book_name
			   AND fadp.period_name = p_from_period;
         END IF;


	      IF (P_TO_PERIOD IS NOT NULL)      THEN
			SELECT TRUNC (fadp.calendar_period_close_date)
			  INTO period_to
			  FROM fa_deprn_periods fadp
			 WHERE fadp.book_type_code = p_book_name
			   AND fadp.period_name = p_to_period;
         END IF;

					/*--------Checking  for periods  -------------------*/
     IF(period_from IS NOT NULL AND period_to IS NOT NULL) THEN

        lp_date_retired :=' AND fr.date_retired BETWEEN '||''''||period_from||''''||'AND'||''''||period_to||'''';
	 ELSE
	    lp_date_retired:='AND 1=1';
	 END IF;

     /*---------DFF Column free of charge----------*/
	 BEGIN
		SELECT fdfcu.application_column_name
		  INTO v_free_charge
		  FROM fnd_descr_flex_column_usages fdfcu
		 WHERE fdfcu.application_id = 140
		   AND UPPER (fdfcu.descriptive_flexfield_name) = 'FA_LOOKUPS'
		   AND UPPER (fdfcu.descriptive_flex_context_code) =
														UPPER ('Global Data Elements')
		   AND UPPER (fdfcu.end_user_column_name) = 'FREE_OF_CHARGE';
	 EXCEPTION
	 WHEN OTHERS THEN
	 fnd_file.put_line(fnd_file.log,'Error in Fetching DFF Column for Free of charge. Error => '||SQLERRM);
	 END;

	 IF(v_free_charge IS NOT NULL ) THEN
		lp_free_of_charge :='flb.'||v_free_charge ;
	 ELSE
     	 lp_free_of_charge :='''F''';
	 END IF;

	   RETURN (TRUE);
   END;
---End of afterpform   Trigger----------------------
/*------Organization  Name---------------------------*/

FUNCTION COMPANY_NAME return VARCHAR2 is
lp_com_name     VARCHAR2(100);
BEGIN

	   BEGIN
		SELECT company_name
		  INTO lp_com_name
		  FROM fa_system_controls;
       EXCEPTION
	      WHEN OTHERS THEN
		   fnd_file.put_line(fnd_file.log,'Error in Fetching company name. Error => '||SQLERRM);
	   END;

	RETURN lp_com_name;
END;
/*------Book Name---------------------------*/

FUNCTION CURRENCY_NAME return VARCHAR2 is
lp_curr_code     VARCHAR2(100);
BEGIN

	  BEGIN
		SELECT gl.currency_code
		  INTO lp_curr_code
		  FROM fa_book_controls fbc, gl_ledgers gl
		 WHERE book_type_code = p_book_name
		   AND fbc.set_of_books_id = gl.ledger_id;
       EXCEPTION
	      WHEN OTHERS THEN
		   fnd_file.put_line(fnd_file.log,'Error in Fetching currency code. Error => '||SQLERRM);
	   END;

RETURN lp_curr_code;
END;

FUNCTION FROM_PERIOD return VARCHAR2 is
lp_from_date     VARCHAR2(100);
BEGIN

	  BEGIN
			SELECT TRUNC (fadp.calendar_period_open_date)
			  INTO lp_from_date
			  FROM fa_deprn_periods fadp
			 WHERE fadp.book_type_code = p_book_name
			   AND fadp.period_name = p_from_period;
       EXCEPTION
	      WHEN OTHERS THEN
		   fnd_file.put_line(fnd_file.log,'Error in Fetching From Date. Error => '||SQLERRM);
	   END;

RETURN lp_from_date;
END;

FUNCTION TO_PERIOD return VARCHAR2 is
lp_to_date     VARCHAR2(100);
BEGIN

	  BEGIN
			SELECT TRUNC (fadp.calendar_period_close_date)
			  INTO lp_to_date
			  FROM fa_deprn_periods fadp
			 WHERE fadp.book_type_code = p_book_name
			   AND fadp.period_name = p_to_period;
       EXCEPTION
	      WHEN OTHERS THEN
		   fnd_file.put_line(fnd_file.log,'Error in Fetching To Date. Error => '||SQLERRM);
	   END;

RETURN lp_to_date;
END;
--Functions to refer Oracle report placeholders--


END FA_RETMT_TAX_REG_RPT_PKG;

/
