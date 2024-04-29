--------------------------------------------------------
--  DDL for Package Body FA_RES_LDG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_RES_LDG_PKG" AS
-- $Header: FARESLDGPB.pls 120.3.12010000.2 2009/07/19 08:07:23 glchen ship $
-- ****************************************************************************************
-- Copyright (c)  2000  Oracle Solution Services (India)     Product Development
-- All rights reserved
-- ****************************************************************************************
--
-- PROGRAM NAME
-- FARESLDGPB.pls
--
-- DESCRIPTION
--  This script creates the package body of FA_RES_LDG_PKG
--  This package is used to generate Bulgarian Reserve Ledger Report
--
-- USAGE
--   To install        How to Install
--   To execute        How to Execute
--
-- DEPENDENCIES
--   None.
--
--
-- LAST UPDATE DATE   26-JAN-2007
--   Date the program has been modified for the last time
--
-- HISTORY
-- =======
--
-- VERSION DATE        AUTHOR(S)         DESCRIPTION
-- ------- ----------- ---------------   ------------------------------------
-- 1.0    26-JAN-2007 Praveen Gollu M Creation
--
--****************************************************************************************
-------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION BookFormula RETURN VARCHAR2 IS
  lc_book       						VARCHAR2(15);
  lc_book_class 						VARCHAR2(15);
  ln_accounting_flex_structure 			NUMBER(15);
  lc_currency_code 						VARCHAR2(15);
  lc_distribution_source_book 			VARCHAR2(15);
  ln_precision 							NUMBER(15);
BEGIN
  SELECT BC.book_type_code
		,BC.book_class
		,BC.accounting_flex_structure
		,BC.distribution_source_book
		,SOB.currency_code
		,CUR.precision
  INTO   lc_book
		,lc_book_class
		,ln_accounting_flex_structure
		,lc_distribution_source_book
		,lc_currency_code
		,ln_precision
  FROM   fa_book_controls BC
		,gl_ledgers SOB
		,fnd_currencies CUR
  WHERE  BC.book_type_code 		= P_BOOK
  AND    SOB.ledger_id 			= BC.set_of_books_id
  AND    SOB.currency_code   	= CUR.currency_code;

gc_book_class 					:= lc_book_class;
gn_accounting_flex_structure	:= ln_accounting_flex_structure;
gc_distribution_source_book 	:= lc_distribution_source_book;
gc_currency_code 				:= lc_currency_code;
RETURN(lc_book);
END;
-------------------------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION Period1Formula RETURN VARCHAR2 IS
BEGIN

DECLARE
  lc_period_name 				VARCHAR2(15);
  ld_period_POD  				DATE;
  ld_period_PCD  				DATE;
  lc_period_closed 				VARCHAR2(4);
  ln_period_PC   				NUMBER(15);
  ln_period_FY   				NUMBER(15);
BEGIN
  SELECT 	FDP.period_name
			,FDP.period_counter
			,FDP.period_open_date
			,NVL(FDP.period_close_date, SYSDATE)
			,DECODE(FDP.period_close_date, NULL, 'NO', 'YES')
			,FDP.fiscal_year
  INTO   	lc_period_name
			,ln_period_PC
			,ld_period_POD
			,ld_period_PCD
			,lc_period_closed
			,ln_period_FY
  FROM   	fa_deprn_periods FDP
  WHERE  	FDP.book_type_code 	= P_BOOK
  AND    	FDP.period_name    	= P_PERIOD1;

gn_period1_pc 		:= ln_period_PC;
gd_period1_pod 	:= ld_period_POD;
gd_period1_pcd 	:= ld_period_PCD;
gc_period_closed 	:= lc_period_closed;
gn_period1_fy  	:= ln_period_FY;
RETURN(lc_period_name);
END;
RETURN NULL;
END;
-------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION BeforeReport RETURN BOOLEAN
IS
lc_book VARCHAR2(15);
BEGIN
lc_book :=BookFormula();
RETURN (TRUE);
END;
-------------------------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION AfterReport RETURN BOOLEAN IS
BEGIN
	BEGIN
		ROLLBACK;
	END;
RETURN (TRUE);
END;
-------------------------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION c_do_insertformula(Book IN VARCHAR2, Period1 IN VARCHAR2) RETURN NUMBER IS
BEGIN

DECLARE
  lc_book		VARCHAR2(15);
  lc_period		VARCHAR2(15);
  lc_errbuf		VARCHAR2(250);
  ln_retcode	NUMBER;
BEGIN

  lc_book := Book;
  lc_period := Period1;
  FA_RSVLDG (lc_book, lc_period, lc_errbuf, ln_retcode);
  C_Errbuf := lc_errbuf;
  C_RetCode := ln_retcode;

RETURN (1);
END;
RETURN NULL;
END;
-------------------------------------------------------------------------------------------------------------------------------------------------------------
FUNCTION d_lifeformula(LIFE IN NUMBER
						, ADJ_RATE IN NUMBER
						, BONUS_RATE IN NUMBER
						, PROD IN NUMBER) RETURN VARCHAR2 IS
BEGIN
DECLARE
   ln_life	NUMBER;
   ln_adj_rate	NUMBER;
   ln_bonus_rate	NUMBER;
   ln_prod	NUMBER;
   lc_d_life	VARCHAR2(7);

BEGIN
	ln_life := LIFE;
	ln_adj_rate := ADJ_RATE;
	ln_bonus_rate := BONUS_RATE;
	ln_prod := PROD;
    lc_d_life := fadolif(ln_life, ln_adj_rate, ln_bonus_rate, ln_prod);
RETURN(lc_d_life);
END;
RETURN NULL;
END;
-------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------------
--Functions to refer Oracle report placeholders--

 FUNCTION Accounting_Flex_Structure_p RETURN NUMBER IS
	BEGIN
		RETURN gn_accounting_flex_structure;
	END;
 FUNCTION Currency_Code_p RETURN VARCHAR2 IS
	BEGIN
		RETURN gc_currency_code;
	END;

-------------------------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE FA_RSVLDG
       (book            IN  VARCHAR2
	   ,period          IN  VARCHAR2
	   ,errbuf          OUT NOCOPY VARCHAR2
	   ,retcode         OUT NOCOPY NUMBER)
IS
		PRAGMA AUTONOMOUS_TRANSACTION;
        OPERATION       VARCHAR2(200);
        dist_book       VARCHAR2(15);
        ucd             DATE;
        upc             NUMBER;
        tod             DATE;
        tpc             NUMBER;

        h_set_of_books_id  NUMBER;
        h_reporting_flag   VARCHAR2(1);
BEGIN
/* not needed with global temp fix
       operation := 'Deleting from FA_RESERVE_LEDGER';
       DELETE FROM FA_RESERVE_LEDGER;

       if (SQL%ROWCOUNT > 0) then
            operation := 'Committing Delete';
            COMMIT;
       else
            operation := 'Rolling Back Delete';
            ROLLBACK;
       end if;
*/

       -- get mrc related info
      BEGIN
			SELECT  TO_NUMBER(SUBSTRB(USERENV('CLIENT_INFO'),45,10))
			INTO    h_set_of_books_id FROM dual;
			EXCEPTION
			WHEN OTHERS THEN
			h_set_of_books_id := NULL;
      END;

      IF (h_set_of_books_id IS NOT NULL) THEN
			IF NOT fa_cache_pkg.fazcsob
                (X_set_of_books_id   => h_set_of_books_id
				,X_mrc_sob_type_code => h_reporting_flag) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
      ELSE
			h_reporting_flag := 'P';
      END IF;

      OPERATION := 'Selecting Book and Period information';
      IF (h_reporting_flag = 'R') THEN
      SELECT    BC.distribution_source_book              dbk
				,NVL (DP.period_close_date, SYSDATE)     ucd
				,DP.period_counter                       upc
				,MIN (DP_FY.period_open_date)            tod
				,MIN (DP_FY.period_counter)              tpc
        INTO
                dist_book
				,ucd
				,upc
				,tod
				,tpc
        FROM
                fa_deprn_periods_mrc_v        	DP
				,fa_deprn_periods_mrc_v        	DP_FY
				,fa_book_controls_mrc_v        	BC
        WHERE
                DP.book_type_code       =  book
		AND     DP.period_name          =  period
		AND     DP_FY.book_type_code    =  book
		AND     DP_FY.fiscal_year       =  DP.fiscal_year
        AND     BC.book_type_code       =  book
		GROUP BY
				BC.distribution_source_book
				,DP.period_close_date
				,DP.period_counter;
       ELSE
        SELECT
                BC.distribution_source_book             	dbk
				,NVL (DP.period_close_date, SYSDATE)     	ucd
				,DP.period_counter                       	upc
				,MIN (DP_FY.period_open_date)            	tod
				,MIN (DP_FY.period_counter)              	tpc
        INTO
                dist_book
				,ucd
				,upc
				,tod
				,tpc
        FROM
                fa_deprn_periods        	DP
				,fa_deprn_periods        	DP_FY
				,fa_book_controls        	BC
        WHERE
                DP.book_type_code       =  book
		AND     DP.period_name          =  period
		AND		DP_FY.book_type_code    =  book
		AND     DP_FY.fiscal_year       =  DP.fiscal_year
        AND     BC.book_type_code       =  book
		GROUP BY
				BC.distribution_source_book
				,DP.period_close_date
				,DP.period_counter;
       END IF;

       OPERATION := 'Inserting into FA_RESERVE_LEDGER_GT';

  -- run only if CRL not installed
  IF (NVL(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'N' ) THEN

   IF (h_reporting_flag = 'R') THEN
--FND_FILE.PUT_LINE(FND_FILE.LOG,'1)INSERT INTO ');
    INSERT INTO FA_RESERVE_LEDGER_GT
				(asset_id
				,dh_ccid
				,deprn_reserve_acct
				,date_placed_in_service
				,method_code
				,life
				,rate
				,capacity
				,cost
				,deprn_amount
				,ytd_deprn
				,deprn_reserve
				,percent
				,transaction_type
				,period_counter
				,date_effective
				,reserve_acct)
    SELECT
		        DH.asset_id                             	asset_id
				,DH.code_combination_id                  	dh_ccid
				,CB.deprn_reserve_acct                   	rsv_account
				,BOOKS.date_placed_in_service            	start_date
				,BOOKS.deprn_method_code                 	method
				,BOOKS.life_in_months                    	life
				,BOOKS.adjusted_rate                     	rate
				,BOOKS.production_capacity               	capacity
				,DD_BONUS.cost                           	cost
				,DECODE (DD_BONUS.period_counter, upc,
					DD_BONUS.deprn_amount - DD_BONUS.bonus_deprn_amount, 0)		deprn_amount
				,DECODE (SIGN (tpc - DD_BONUS.period_counter)
					, 1, 0, DD_BONUS.ytd_deprn - DD_BONUS.bonus_ytd_deprn)		ytd_deprn
				,DD_BONUS.deprn_reserve - DD_BONUS.bonus_deprn_reserve          deprn_reserve
				,DECODE (TH.transaction_type_code, NULL
					,DH.units_assigned / AH.units * 100)						percent
				,DECODE (TH.transaction_type_code, NULL,
		            DECODE (TH_RT.transaction_type_code,
		            'FULL RETIREMENT', 'F',
		            DECODE (BOOKS.depreciate_flag, 'NO', 'N')),
		            'TRANSFER', 'T',
		            'TRANSFER OUT', 'P',
		            'RECLASS', 'R')                       t_type
				,DD_BONUS.period_counter
				,NVL(TH.date_effective, ucd)
				,''
	FROM
		        fa_deprn_detail_mrc_v   		DD_BONUS
				,fa_asset_history        		AH
				,fa_transaction_headers  		TH
				,fa_transaction_headers  		TH_RT
				,fa_books_mrc_v          		BOOKS
				,fa_distribution_history 		DH
				,fa_category_books       		CB
	WHERE
				CB.book_type_code               =  book
	AND			CB.category_id                  =  AH.category_id
	AND	        AH.asset_id                     =  DH.asset_id
	AND	        AH.date_effective               < NVL(TH.date_effective, ucd)
	AND	        NVL(AH.date_ineffective,SYSDATE)>=  NVL(TH.date_effective, ucd)
	AND	        AH.asset_type                   = 'CAPITALIZED'
	AND			DD_BONUS.book_type_code         = book
	AND			DD_BONUS.distribution_id        = DH.distribution_id
	AND         DD_BONUS.period_counter         = (SELECT  MAX (DD_SUB.period_counter)
											        FROM    fa_deprn_detail_mrc_v DD_SUB
											        WHERE   DD_SUB.book_type_code   = book
											        AND     DD_SUB.asset_id         = DH.asset_id
											        AND     DD_SUB.distribution_id  = DH.distribution_id
											        AND     DD_SUB.period_counter   <= upc)
	AND		    TH_RT.book_type_code            = book
	AND			TH_RT.transaction_header_id     = BOOKS.transaction_header_id_in
	AND         BOOKS.book_type_code            = book
	AND         BOOKS.asset_id                  = DH.asset_id
	AND         NVL(BOOKS.period_counter_fully_retired, upc) >= tpc
	AND         BOOKS.date_effective            <= NVL(TH.date_effective, ucd)
	AND         NVL(BOOKS.date_ineffective,SYSDATE+1) > NVL(TH.date_effective, ucd)
	AND         TH.book_type_code (+)           = dist_book
	AND         TH.transaction_header_id (+)    = DH.transaction_header_id_out
	AND         TH.date_effective (+)           BETWEEN tod AND ucd
	AND         DH.book_type_code               = dist_book
	AND			DH.date_effective               <= ucd
	AND			NVL(DH.date_ineffective, SYSDATE) > tod
	UNION ALL
	SELECT
		        DH.asset_id                                            		asset_id
				,DH.code_combination_id                                  	dh_ccid
				,CB.bonus_deprn_reserve_acct                             	rsv_account
				,BOOKS.date_placed_in_service                            	start_date
				,BOOKS.deprn_method_code                                 	method
				,BOOKS.life_in_months                                    	life
				,BOOKS.adjusted_rate                                    	rate
				,BOOKS.production_capacity                               	capacity
				,0                                                 			cost
				,DECODE (DD.period_counter, upc, DD.bonus_deprn_amount, 0)  deprn_amount
				,DECODE (SIGN (tpc - DD.period_counter)
					, 1, 0, DD.bonus_ytd_deprn)								ytd_deprn
				,DD.bonus_deprn_reserve                                  	deprn_reserve
				,0                                                       	percent
				,'B'                                 						t_type
				,DD.period_counter
				,NVL(TH.date_effective, ucd)
				,CB.bonus_deprn_expense_acct
	FROM
				fa_deprn_detail_mrc_v   	DD
				,fa_asset_history        	AH
				,fa_transaction_headers  	TH
				,fa_transaction_headers  	TH_RT
				,fa_books_mrc_v          	BOOKS
				,fa_distribution_history 	DH
				,fa_category_books       	CB
	WHERE
		        CB.book_type_code           =  	book
	AND			CB.category_id              =  	AH.category_id
	AND	        AH.asset_id                 =  	DH.asset_id
	AND			AH.date_effective           < 	NVL(TH.date_effective, ucd)
	AND			NVL(AH.date_ineffective,SYSDATE)
											>=  NVL(TH.DATE_EFFECTIVE, ucd)
	AND			AH.asset_type               = 'CAPITALIZED'
	AND			DD.book_type_code           = book
	AND		    DD.distribution_id          = DH.distribution_id
	AND         DD.period_counter           = (SELECT  max (DD_SUB.period_counter)
											  FROM    fa_deprn_detail_mrc_v DD_SUB
											  WHERE   DD_SUB.book_type_code   = book
											  AND     DD_SUB.asset_id         = DH.asset_id
											  AND     DD_SUB.distribution_id  = DH.distribution_id
											  AND     DD_SUB.period_counter   <= upc)
	AND		TH_RT.book_type_code            = book
	AND     TH_RT.transaction_header_id     = BOOKS.transaction_header_id_in
	AND     BOOKS.book_type_code            = book
	AND     BOOKS.asset_id                  = DH.asset_id
	AND     NVL(BOOKS.period_counter_fully_retired, upc) >= tpc
	AND     BOOKS.date_effective            <= NVL(TH.date_effective, ucd)
	AND     NVL(BOOKS.date_ineffective,SYSDATE+1) > NVL(TH.date_effective, ucd)
	AND		BOOKS.bonus_rule IS NOT NULL
	AND     TH.book_type_code (+)           = dist_book
	AND     TH.transaction_header_id (+)    = DH.transaction_header_id_out
	AND     TH.date_effective (+)           BETWEEN tod AND ucd
	AND     DH.book_type_code               = dist_book
	AND     DH.date_effective               <= ucd
	AND     NVL(DH.date_ineffective, SYSDATE) > tod;
	ELSE
   --FND_FILE.PUT_LINE(FND_FILE.LOG,'2)INSERT INTO ');
    INSERT INTO FA_RESERVE_LEDGER_GT
       (asset_id
	   ,dh_ccid
	   ,deprn_reserve_acct
	   ,date_placed_in_service
	   ,method_code
	   ,life
	   ,rate
	   ,capacity
	   ,cost
	   ,deprn_amount
	   ,ytd_deprn
	   ,deprn_reserve
	   ,percent
	   ,transaction_type
	   ,period_counter
	   ,date_effective
	   ,reserve_acct)
     SELECT
        DH.asset_id                                             	asset_id
		,DH.code_combination_id                                  	dh_ccid
		,CB.deprn_reserve_acct                                   	rsv_account
		,BOOKS.date_placed_in_service                            	start_date
		,BOOKS.deprn_method_code                                 	method
		,BOOKS.life_in_months                                    	life
		,BOOKS.adjusted_rate                                     	rate
		,BOOKS.production_capacity                               	capacity
		,DD_BONUS.cost                                              cost
		,DECODE (DD_BONUS.period_counter, upc, DD_BONUS.deprn_amount - DD_BONUS.bonus_deprn_amount, 0)       deprn_amount
		,DECODE (SIGN (tpc - DD_BONUS.period_counter), 1, 0, DD_BONUS.ytd_deprn - DD_BONUS.bonus_ytd_deprn)  ytd_deprn
		,DD_BONUS.deprn_reserve - DD_BONUS.bonus_deprn_reserve                                        		  deprn_reserve
		,DECODE (TH.transaction_type_code, NULL,
            DH.units_assigned / AH.units * 100)     				PERCENT
		,DECODE (TH.transaction_type_code, NULL,
            DECODE (TH_RT.transaction_type_code,
            'FULL RETIREMENT', 'F',
            DECODE (BOOKS.depreciate_flag, 'NO', 'N')),
            'TRANSFER', 'T',
            'TRANSFER OUT', 'P',
            'RECLASS', 'R')                                 		t_type
		,DD_BONUS.period_counter
		,NVL(TH.date_effective, ucd)
		,''
FROM
        fa_deprn_detail         	DD_BONUS
		,fa_asset_history        	AH
		,fa_transaction_headers  	TH
		,fa_transaction_headers  	TH_RT
		,fa_books                	BOOKS
		,fa_distribution_history 	DH
		,fa_category_books       	CB
WHERE
        CB.book_type_code           =  book
AND     CB.category_id              =  AH.category_id
AND     AH.asset_id                 =  DH.ASSET_ID
AND     AH.date_effective           < NVL(TH.date_effective, ucd)
AND     NVL(AH.date_ineffective,SYSDATE) >=  NVL(TH.date_effective, ucd)
AND     AH.asset_type               = 'CAPITALIZED'
AND     DD_BONUS.book_type_code     = book
AND     DD_BONUS.distribution_id    = DH.distribution_id
AND     DD_BONUS.period_counter     = (SELECT  MAX (DD_SUB.period_counter)
								        FROM    fa_deprn_detail DD_SUB
								        WHERE   DD_SUB.book_type_code   = book
								        AND     DD_SUB.asset_id         = DH.asset_id
								        AND     DD_SUB.distribution_id  = DH.distribution_id
								        AND     DD_SUB.period_counter   <= upc)
AND		TH_RT.book_type_code            = book
AND		TH_RT.transaction_header_id     = BOOKS.transaction_header_id_in
AND		BOOKS.book_type_code            = book
AND		BOOKS.asset_id                  = DH.asset_id
AND		NVL(BOOKS.period_counter_fully_retired, upc) >= tpc
AND		BOOKS.date_effective            <= NVL(TH.date_effective, ucd)
AND		NVL(BOOKS.date_ineffective,SYSDATE+1) > NVL(TH.date_effective, ucd)
AND		TH.book_type_code (+)           = dist_book
AND		TH.transaction_header_id (+)    = DH.transaction_header_id_out
AND		TH.date_effective (+)           BETWEEN tod AND ucd
AND		DH.book_type_code               = dist_book
AND		DH.date_effective               <= ucd
AND		NVL(DH.date_ineffective, SYSDATE) > tod
UNION ALL
SELECT
        DH.asset_id                                             	asset_id
		,DH.code_combination_id                                  	dh_ccid
		,CB.bonus_deprn_reserve_acct                             	rsv_account
		,BOOKS.date_placed_in_service                            	start_date
		,BOOKS.deprn_method_code                                 	method
		,BOOKS.life_in_months                                    	life
		,BOOKS.adjusted_rate                                     	rate
		,BOOKS.production_capacity                               	capacity
		,0                                                 			cost
		,DECODE (DD.period_counter, upc, DD.bonus_deprn_amount, 0)	deprn_amount
		,DECODE (SIGN (tpc - DD.period_counter), 1, 0, DD.bonus_ytd_deprn)	ytd_deprn
		,DD.bonus_deprn_reserve                                  	deprn_reserve
		,0                                                       	percent
		,'b'                                 						t_type
		,DD.period_counter
		,NVL(TH.date_effective, ucd)
		,CB.bonus_deprn_expense_acct
FROM
        fa_deprn_detail         	DD
		,fa_asset_history        	AH
		,fa_transaction_headers  	TH
		,fa_transaction_headers  	TH_RT
		,fa_books                	BOOKS
		,fa_distribution_history 	DH
		,fa_category_books       	CB
WHERE
        CB.book_type_code           = book
AND		CB.category_id              = AH.category_id
AND		AH.asset_id                 = DH.asset_id
AND		AH.date_effective           < NVL(TH.date_effective, ucd)
AND		NVL(AH.date_ineffective,SYSDATE)	>=  NVL(TH.date_effective, ucd)
AND		AH.asset_type                   = 'CAPITALIZED'
AND		DD.book_type_code               = book
AND		DD.distribution_id              = DH.distribution_id
AND		DD.period_counter               = (SELECT  MAX (DD_SUB.period_counter)
									        FROM    fa_deprn_detail DD_SUB
									        WHERE   DD_SUB.book_type_code   = book
									        AND     DD_SUB.asset_id         = DH.asset_id
									        AND     DD_SUB.distribution_id  = DH.distribution_id
									        AND     DD_SUB.period_counter   <= upc)
AND		TH_RT.book_type_code            = book
AND		TH_RT.transaction_header_id     = BOOKS.transaction_header_id_in
AND		BOOKS.book_type_code            = book
AND     BOOKS.asset_id                  = DH.asset_id
AND     nvl(BOOKS.period_counter_fully_retired, upc) >= tpc
AND     BOOKS.date_effective            <= nvl(TH.date_effective, ucd)
AND     nvl(BOOKS.date_ineffective,SYSDATE+1) > nvl(TH.date_effective, ucd)
AND		BOOKS.bonus_rule IS NOT NULL
AND		TH.book_type_code (+)           = dist_book
AND		TH.transaction_header_id (+)    = DH.transaction_header_id_out
AND		TH.date_effective (+)           BETWEEN tod AND ucd
AND		DH.book_type_code               = dist_book
AND		DH.date_effective               <= ucd
AND		NVL(DH.date_ineffective, SYSDATE) > tod;
END IF;


  -- run only if CRL installed
  ELSIF (NVL(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y' ) THEN

	IF (h_reporting_flag = 'R') THEN
   --FND_FILE.PUT_LINE(FND_FILE.LOG,'3)INSERT INTO ');
    INSERT INTO FA_RESERVE_LEDGER_GT
	       (asset_id
		   ,dh_ccid
		   ,deprn_reserve_acct
		   ,date_placed_in_service
		   ,method_code
		   ,life
		   ,rate
		   ,capacity
		   ,cost
		   ,deprn_amount
		   ,ytd_deprn
		   ,deprn_reserve
		   ,percent
		   ,transaction_type
		   ,period_counter
		   ,date_effective)
    SELECT
	        DH.asset_id                                             asset_id
			,DH.code_combination_id                                  dh_ccid
			,CB.deprn_reserve_acct                                   rsv_account
			,BOOKS.date_placed_in_service                            start_date
			,BOOKS.deprn_method_code                                 method
			,BOOKS.life_in_months                                    life
			,BOOKS.adjusted_rate                                     rate
			,BOOKS.production_capacity                               capacity
			,DD.cost                                                 cost
			,DECODE (DD.period_counter, upc, DD.deprn_amount, 0)     deprn_amount
			,DECODE (SIGN (tpc - DD.period_counter), 1, 0, DD.ytd_deprn)	ytd_deprn
			,DD.deprn_reserve                                        deprn_reserve
			,DECODE (TH.transaction_type_code, NULL,DH.units_assigned / AH.units * 100)	percent
			,DECODE (TH.transaction_type_code, NULL,DECODE (TH_RT.transaction_type_code,
	                'FULL RETIREMENT', 'F',DECODE (BOOKS.depreciate_flag, 'NO', 'N')),
	                'TRANSFER', 'T',
	                'TRANSFER OUT', 'P',
	                'RECLASS', 'R')	t_type
			,DD.period_counter
			,NVL(TH.date_effective, ucd)
    FROM
	        fa_deprn_detail_mrc_v   	DD
			,fa_asset_history        	AH
			,fa_transaction_headers  	TH
			,fa_transaction_headers  	TH_RT
			,fa_books_mrc_v          	BOOKS
			,fa_distribution_history 	DH
			,fa_category_books       	CB
	WHERE   BOOKS.group_asset_id IS NULL
	AND     CB.book_type_code               =  book
	AND     CB.category_id                  =  AH.category_id
	AND     AH.asset_id                     =  DH.asset_id
	AND     AH.date_effective               < NVL(TH.date_effective, ucd)
	AND     NVL(AH.date_ineffective,SYSDATE)>=  NVL(TH.date_effective, ucd)
	AND     AH.asset_type                   = 'CAPITALIZED'
	AND     DD.book_type_code               = book
	AND     DD.distribution_id              = DH.distribution_id
	AND     DD.period_counter               = (SELECT  MAX (DD_SUB.period_counter)
										        FROM    fa_deprn_detail_mrc_v DD_SUB
										        WHERE   DD_SUB.book_type_code   = book
										        AND     DD_SUB.asset_id         = DH.asset_id
										        AND     DD_SUB.distribution_id  = DH.distribution_id
										        AND     DD_SUB.period_counter   <= upc)
	AND     TH_RT.book_type_code            = book
	AND     TH_RT.transaction_header_id     = BOOKS.transaction_header_id_in
	AND     BOOKS.book_type_code            = book
	AND     BOOKS.asset_id                  = DH.asset_id
	AND     NVL(BOOKS.period_counter_fully_retired, upc) >= tpc
	AND     BOOKS.date_effective            <= NVL(TH.date_effective, ucd)
	AND     NVL(BOOKS.date_ineffective,SYSDATE+1) > NVL(TH.date_effective, ucd)
	AND     TH.book_type_code (+)           = dist_book
	AND     TH.transaction_header_id (+)    = DH.transaction_header_id_out
	AND     TH.date_effective (+)           BETWEEN tod AND ucd
	AND     DH.book_type_code               = dist_book
	AND     DH.date_effective               <= ucd
	AND     NVL(DH.date_ineffective, SYSDATE) > tod
	AND     BOOKS.group_asset_id IS NULL;
	ELSE
   --FND_FILE.PUT_LINE(FND_FILE.LOG,'4)INSERT INTO ');
    INSERT INTO FA_RESERVE_LEDGER_GT
	       (asset_id
		   ,dh_ccid
		   ,deprn_reserve_acct
		   ,date_placed_in_service
		   ,method_code
		   ,life
		   ,rate
		   ,capacity
		   ,cost
		   ,deprn_amount
		   ,ytd_deprn
		   ,deprn_reserve
		   ,percent
		   ,transaction_type
		   ,period_counter
		   ,date_effective)
    SELECT
	        DH.asset_id                                               	asset_id
			,DH.code_combination_id                                   	dh_ccid
			,CB.deprn_reserve_acct                                     	rsv_account
			,BOOKS.date_placed_in_service                              	start_date
			,BOOKS.deprn_method_code                                   	method
			,BOOKS.life_in_months                                      	life
			,BOOKS.adjusted_rate                                      	rate
			,BOOKS.production_capacity                                	capacity
			,DD.cost                                                  	cost
			,DECODE (DD.period_counter, upc, DD.deprn_amount, 0)      	deprn_amount
			,DECODE (SIGN (tpc - DD.period_counter), 1, 0, DD.ytd_deprn)	ytd_deprn
			,DD.deprn_reserve	deprn_reserve
			,DECODE (TH.transaction_type_code, NULL,DH.units_assigned / AH.units * 100)  percent
			,DECODE (TH.transaction_type_code, NULL,DECODE (TH_RT.transaction_type_code,'FULL RETIREMENT', 'F',
	                DECODE (BOOKS.depreciate_flag, 'NO', 'N')),'TRANSFER', 'T','TRANSFER OUT', 'P',
	                'RECLASS', 'R')         t_type
			,DD.period_counter
			,NVL(TH.date_effective, ucd)
    FROM
	        fa_deprn_detail         	DD
			,fa_asset_history        	AH
			,fa_transaction_headers  	TH
			,fa_transaction_headers  	TH_RT
			,fa_books                	BOOKS
			,fa_distribution_history 	DH
			,fa_category_books       	CB
	WHERE   BOOKS.group_asset_id IS NULL
	AND     CB.book_type_code               =  book
	AND     CB.category_id                  =  AH.category_id
	AND     AH.asset_id                     =  DH.asset_id
	AND     AH.date_effective               < NVL(TH.date_effective, ucd)
	AND     NVL(AH.date_ineffective,SYSDATE)>=  NVL(TH.date_effective, ucd)
	AND     AH.asset_type                   = 'CAPITALIZED'
	AND     DD.book_type_code               = book
	AND     DD.distribution_id              = DH.distribution_id
	AND     DD.period_counter               =(SELECT  MAX (DD_SUB.period_counter)
									        FROM    fa_deprn_detail DD_SUB
									        WHERE   DD_SUB.book_type_code   = book
									        AND     DD_SUB.asset_id         = DH.asset_id
									        AND     DD_SUB.distribution_id  = DH.distribution_id
									        AND     DD_SUB.period_counter   <= upc)
	AND     TH_RT.book_type_code            = book
	AND     TH_RT.transaction_header_id     = BOOKS.transaction_header_id_in
	AND     BOOKS.book_type_code            = book
	AND     BOOKS.asset_id                  = DH.asset_id
	AND     NVL(BOOKS.period_counter_fully_retired, upc) >= tpc
	AND     BOOKS.date_effective            <= NVL(TH.date_effective, ucd)
	AND		NVL(BOOKS.date_ineffective,SYSDATE+1) > NVL(TH.date_effective, ucd)
	AND     TH.book_type_code (+)           = dist_book
	AND		TH.transaction_header_id (+)    = DH.transaction_header_id_out
	AND		TH.date_effective (+)           BETWEEN tod AND	ucd
	AND     DH.book_type_code               = dist_book
	AND     DH.date_effective               <= ucd
	AND     NVL(DH.date_ineffective, SYSDATE) 	> tod
	AND     BOOKS.group_asset_id IS NULL;
    END IF;
	IF (h_reporting_flag = 'R') THEN
	--FND_FILE.PUT_LINE(FND_FILE.LOG,'5)INSERT INTO ');
    INSERT INTO FA_RESERVE_LEDGER_GT
		       (asset_id
			   ,dh_ccid
			   ,deprn_reserve_acct
			   ,date_placed_in_service
			   ,method_code
			   ,life
			   ,rate
			   ,capacity
			   ,cost
			   ,deprn_amount
			   ,ytd_deprn
			   ,deprn_reserve
			   ,percent
			   ,transaction_type
			   ,period_counter
			   ,date_effective)
    SELECT
		        GAR.group_asset_id				asset_id
				,GAD.deprn_expense_acct_ccid  	ch_ccid
				,GAD.deprn_reserve_acct_ccid    rsv_account
				,GAR.deprn_start_date			start_date
				,GAR.deprn_method_code			method
				,GAR.life_in_months				life
				,GAR.adjusted_rate				rate
				,GAR.production_capacity		capacity
				,DD.adjusted_cost				cost
				,DECODE (DD.period_counter, upc, DD.deprn_amount, 0)			deprn_amount
				,DECODE (SIGN (tpc - DD.period_counter), 1, 0, DD.ytd_deprn)	ytd_deprn
				,DD.deprn_reserve				deprn_reserve
				,100   							percent
				,'G' 							t_type
				,DD.period_counter
				,UCD
	FROM
		        fa_deprn_summary_mrc_v  	DD
				,fa_group_asset_rules    	GAR
				,fa_group_asset_default  	GAD
				,fa_deprn_periods_mrc_v  	DP
    WHERE
				DD.book_type_code   = 		book
    AND     	DD.asset_id         = 		GAR.group_asset_id
    AND     	GAD.super_group_id  IS NULL
    AND     	GAR.book_type_code  = 		DD.book_type_code
    AND     	GAD.book_type_code  = 		GAR.book_type_code
    AND     	GAD.group_asset_id  = 		GAR.group_asset_id
    AND     	DD.period_counter   = 		(SELECT  MAX (DD_SUB.period_counter)
											FROM    fa_deprn_detail_mrc_v DD_SUB
											WHERE   DD_SUB.book_type_code   = book
											AND     DD_SUB.asset_id         = GAR.group_asset_id
											AND     DD_SUB.period_counter   <= upc)
    AND     	DD.period_counter  	= 		DP.period_counter
    AND     	DD.book_type_code 	= 		DP.book_type_code
    AND     	GAR.date_effective	<=		DP.calendar_period_close_date
    AND     	NVL(GAR.date_ineffective, (DP.calendar_period_close_date + 1))> DP.calendar_period_close_date;
	ELSE
   --FND_FILE.PUT_LINE(FND_FILE.LOG,'6)INSERT INTO ');
    INSERT INTO FA_RESERVE_LEDGER_GT
				(asset_id
				,dh_ccid
				,deprn_reserve_acct
				,date_placed_in_service
				,method_code
				,life
				,rate
				,capacity
				,cost
				,deprn_amount
				,ytd_deprn
				,deprn_reserve
				,percent
				,transaction_type
				,period_counter
				,date_effective)
    SELECT		GAR.group_asset_id												asset_id
				,GAD.deprn_expense_acct_ccid  									ch_ccid
				,GAD.deprn_reserve_acct_ccid     								rsv_account
				,GAR.deprn_start_date											start_date
				,GAR.deprn_method_code											method
				,GAR.life_in_months												life
				,GAR.adjusted_rate												rate
				,GAR.production_capacity										capacity
				,DD.adjusted_cost												cost
				,DECODE (DD.period_counter, upc, DD.deprn_amount, 0)			deprn_amount
				,DECODE (SIGN (tpc - DD.period_counter), 1, 0, DD.ytd_deprn)	ytd_deprn
				,DD.deprn_reserve												deprn_reserve
				,100   percent
				,'G' t_type
				,DD.period_counter
				,UCD
      FROM
		        fa_deprn_summary         	DD
				,fa_group_asset_rules    	GAR
				,fa_group_asset_default  	GAD
				,fa_deprn_periods         	DP
      WHERE
				DD.book_type_code                  = book
      AND     	DD.asset_id                        = GAR.group_asset_id
      AND     	GAD.super_group_id                 IS NULL -- MPOWELL
      AND     	GAR.book_type_code                 = DD.book_type_code
      AND     	GAD.book_type_code                 = GAR.book_type_code
      AND     	GAD.group_asset_id                 = GAR.group_asset_id
      AND     	DD.period_counter                  = (SELECT  MAX (DD_SUB.period_counter)
											          FROM    fa_deprn_detail DD_SUB
											          WHERE   DD_SUB.book_type_code   = book
											          AND     DD_SUB.asset_id         = GAR.group_asset_id
											          AND     DD_SUB.period_counter   <= upc
											         )
     AND     	DD.period_counter                  = DP.period_counter
     AND     	DD.book_type_code                  = DP.book_type_code
     AND     	GAR.date_effective                 <= DP.calendar_period_close_date  -- mwoodwar
     AND     	NVL(GAR.date_ineffective, (DP.calendar_period_close_date + 1))
				> DP.calendar_period_close_date;
	END IF;



	IF (h_reporting_flag = 'R') THEN
	--FND_FILE.PUT_LINE(FND_FILE.LOG,'7)INSERT INTO ');
    INSERT INTO FA_RESERVE_LEDGER_GT
		       (asset_id
			   ,dh_ccid
			   ,deprn_reserve_acct
			   ,date_placed_in_service
			   ,method_code
			   ,life
			   ,rate
			   ,capacity
			   ,cost
			   ,deprn_amount
			   ,ytd_deprn
			   ,deprn_reserve
			   ,percent
			   ,transaction_type
			   ,period_counter
			   ,date_effective)
    SELECT
		        GAR.group_asset_id				asset_id
				,GAD.deprn_expense_acct_ccid  	dh_ccid
				,GAD.deprn_reserve_acct_ccid 	rsv_account
				,GAR.deprn_start_date			start_date
				,SGR.deprn_method_code			method
				,GAR.life_in_months				life
				,SGR.adjusted_rate				rate
				,GAR.production_capacity		capacity
				,DD.adjusted_cost				cost
				,DECODE (DD.period_counter, upc, DD.deprn_amount, 0)			deprn_amount
				,DECODE (SIGN (tpc - DD.period_counter), 1, 0, DD.ytd_deprn)	ytd_deprn
				,DD.deprn_reserve												deprn_reserve
				,100   							percent
				,'G' 							t_type
				,DD.period_counter
				,UCD
    FROM    	fa_deprn_summary_mrc_v     		DD
				,fa_group_asset_rules    		GAR
				,fa_group_asset_default  		GAD
				,fa_super_group_rules    		SGR
				,fa_deprn_periods_mrc_v  		DP
    WHERE 		DD.book_type_code  = book
    AND   		DD.asset_id        = GAR.group_asset_id
    AND   		GAR.book_type_code = DD.book_type_code
    AND   		GAD.super_group_id = SGR.super_group_id
    AND   		GAD.book_type_code = SGR.book_type_code
    AND   		GAD.book_type_code = GAR.book_type_code
    AND   		GAD.group_asset_id = GAR.group_asset_id
    AND   		DD.period_counter  = (SELECT  MAX (DD_SUB.period_counter)
							          FROM    fa_deprn_detail_mrc_v DD_SUB
							          WHERE   DD_SUB.book_type_code   = book
							          AND     DD_SUB.asset_id         = GAR.group_asset_id
							          AND     DD_SUB.period_counter   <= upc)
    AND   		DD.period_counter  = DP.period_counter
    AND   		DD.book_type_code  = DP.book_type_code
    AND   		GAR.date_effective <= DP.calendar_period_close_date
    AND   		nvl(GAR.date_ineffective, (DP.calendar_period_close_date + 1))> DP.calendar_period_close_date
    AND   		SGR.date_effective <= DP.calendar_period_close_date
    AND   		nvl(SGR.date_ineffective, (DP.calendar_period_close_date + 1))> DP.calendar_period_close_date;
    ELSE
	--FND_FILE.PUT_LINE(FND_FILE.LOG,'8)INSERT INTO ');
    INSERT INTO FA_RESERVE_LEDGER_GT
			(asset_id
			,dh_ccid
			,deprn_reserve_acct
			,date_placed_in_service
			,method_code
			,life
			,rate
			,capacity
			,cost
			,deprn_amount
			,ytd_deprn
			,deprn_reserve
			,percent
			,transaction_type
			,period_counter
			,date_effective)
    SELECT
	        GAR.group_asset_id				asset_id
			,GAD.deprn_expense_acct_ccid  	dh_ccid
			,GAD.deprn_reserve_acct_ccid 	rsv_account
			,GAR.deprn_start_date			start_date
			,SGR.deprn_method_code			method
			,GAR.life_in_months				life
			,SGR.adjusted_rate				rate
			,GAR.production_capacity		capacity
			,DD.adjusted_cost				cost
			,DECODE (DD.period_counter, upc, DD.deprn_amount, 0)				deprn_amount
			,DECODE (SIGN (tpc - DD.period_counter), 1, 0, DD.ytd_deprn)		ytd_deprn
			,DD.deprn_reserve				deprn_reserve
			,100   							percent
			,'G' 							t_type
			,DD.period_counter
			,UCD
     FROM   fa_deprn_summary         	DD
			,fa_group_asset_rules    	GAR
			,fa_group_asset_default  	GAD
			,fa_super_group_rules   	SGR
			,fa_deprn_periods         	DP
     WHERE 	DD.book_type_code  	= 		book
     AND   	DD.asset_id        	= 		GAR.group_asset_id
     AND   	GAR.book_type_code 	= 		DD.book_type_code
     AND   	GAD.super_group_id 	= 		SGR.super_group_id -- MPOWELL
     AND   	GAD.book_type_code 	= 		SGR.book_type_code -- MPOWELL
     AND   	GAD.book_type_code 	= 		GAR.book_type_code
     AND   	GAD.group_asset_id 	= 		GAR.group_asset_id
     AND   	DD.period_counter  	=		(SELECT  max (DD_SUB.period_counter)
								         FROM    fa_deprn_detail DD_SUB
								         WHERE   DD_SUB.book_type_code   = book
								         AND     DD_SUB.asset_id         = GAR.group_asset_id
								         AND     DD_SUB.period_counter   <= upc)
     AND   DD.period_counter    = 		DP.period_counter
     AND   DD.book_type_code    = 		DP.book_type_code
     AND   GAR.date_effective   <= 		DP.calendar_period_close_date
     AND   nvl(GAR.date_ineffective, (DP.calendar_period_close_date + 1))> DP.calendar_period_close_date
     AND   SGR.date_effective   <= 		DP.calendar_period_close_date
     AND   nvl(SGR.date_ineffective, (DP.calendar_period_close_date + 1))> DP.calendar_period_close_date;
    END IF;

	END IF;
	COMMIT;
EXCEPTION
    WHEN 	OTHERS THEN
			retcode := SQLCODE;
			errbuf := SQLERRM;
END FA_RSVLDG;

FUNCTION 		fadolif(life NUMBER,adj_rate NUMBER,bonus_rate NUMBER,prod NUMBER)
RETURN CHAR IS
			   retval CHAR(7);
			   num_chars NUMBER;
			   temp_retval NUMBER;
BEGIN
   IF life IS NOT NULL
   THEN
		temp_retval := fnd_number.canonical_to_number((LPAD(SUBSTR(TO_CHAR(TRUNC(life/12, 0), '999'), 2, 3),3,' ') || '.' ||
			SUBSTR(TO_CHAR(MOD(life, 12), '00'), 2, 2)) );
		retval := TO_CHAR(temp_retval,'999D99');
   ELSIF adj_rate IS NOT NULL
   THEN
		retval := SUBSTR(TO_CHAR(ROUND((adj_rate + NVL(bonus_rate, 0))*100, 2), '990.99'),2,6) || '%';
   ELSIF prod IS NOT NULL
   THEN
		retval := '';
   ELSE
	    retval := ' ';
   END IF;

   RETURN(retval);

END;

END FA_RES_LDG_PKG ;

/
