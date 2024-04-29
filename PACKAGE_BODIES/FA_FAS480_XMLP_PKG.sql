--------------------------------------------------------
--  DDL for Package Body FA_FAS480_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FAS480_XMLP_PKG" AS
/* $Header: FAS480B.pls 120.0.12010000.1 2008/07/28 13:14:56 appldev ship $ */
function BookFormula return VARCHAR2 is
begin
DECLARE
  l_book       VARCHAR2(15);
  l_book_class VARCHAR2(15);
  l_accounting_flex_structure NUMBER(15);
  l_currency_code VARCHAR2(15);
  l_distribution_source_book VARCHAR2(15);
  l_fiscal_year_name VARCHAR2(30);
BEGIN
IF upper(p_mrcsobtype) = 'R'
THEN
  SELECT bc.book_type_code,
         bc.book_class,
         bc.accounting_flex_structure,
         bc.distribution_source_book,
         bc.fiscal_year_name,
         sob.currency_code
  INTO   l_book,
         l_book_class,
         l_accounting_flex_Structure,
         l_distribution_source_book,
         l_fiscal_year_name,
         l_currency_code
  FROM   FA_BOOK_CONTROLS_MRC_V bc,
         GL_SETS_OF_BOOKS sob
  WHERE  bc.book_type_code = P_BOOK
  AND    sob.set_of_books_id = bc.set_of_books_id;
ELSE
  SELECT bc.book_type_code,
         bc.book_class,
         bc.accounting_flex_structure,
         bc.distribution_source_book,
         bc.fiscal_year_name,
         sob.currency_code
  INTO   l_book,
         l_book_class,
         l_accounting_flex_Structure,
         l_distribution_source_book,
         l_fiscal_year_name,
         l_currency_code
  FROM   FA_BOOK_CONTROLS bc,
         GL_SETS_OF_BOOKS sob
  WHERE  bc.book_type_code = P_BOOK
  AND    sob.set_of_books_id = bc.set_of_books_id;
END IF;
  Book_Class := l_book_class;
  Accounting_Flex_Structure:=l_accounting_flex_structure;
  Distribution_Source_Book :=l_distribution_source_book;
  Fiscal_Year_Name := l_fiscal_year_name;
  Currency_Code := l_currency_code;
  return(l_book);
END;
RETURN NULL; end;
function report_nameformula(ACCT_BAL_LPROMPT in varchar2, Company_Name in varchar2) return varchar2 is
begin
DECLARE
  l_report_name VARCHAR2(80);
  l_conc_program_id NUMBER;
BEGIN
  /*SRW.REFERENCE(ACCT_BAL_LPROMPT);*/null;
--Added during DT Fix
P_CONC_REQUEST_ID := fnd_global.CONC_REQUEST_ID;
--End of DT Fix
  RP_ACCT_BAL_LPROMPT := ACCT_BAL_LPROMPT;
  RP_Company_Name := Company_Name;
  SELECT cr.concurrent_program_id
  INTO l_conc_program_id
  FROM FND_CONCURRENT_REQUESTS cr
  WHERE cr.program_application_id = 140
  AND   cr.request_id = P_CONC_REQUEST_ID;
  SELECT cp.user_concurrent_program_name
  INTO   l_report_name
  FROM    FND_CONCURRENT_PROGRAMS_VL cp
  WHERE
      cp.concurrent_program_id= l_conc_program_id
  and cp.application_id = 140;
  l_report_name := substr(l_report_name,1,instr(l_report_name,' (XML)'));
  RP_Report_Name := l_report_name;
  RETURN(l_report_name);
EXCEPTION
  WHEN OTHERS THEN
    RP_Report_Name := ':Tax Reserve Ledger Report:';
    RETURN(RP_Report_Name);
END;
RETURN NULL; end;
function BeforeReport return boolean is
begin
/*SRW.USER_EXIT('FND SRWINIT');*/null;
IF upper(p_mrcsobtype) = 'R'
THEN
  fnd_client_info.set_currency_context(p_ca_set_of_books_id);
END IF;
return (TRUE);
end;
function AfterReport return boolean is
begin
/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;
function Period1_PCFormula return Number is
begin
DECLARE
  l_period_POD  DATE;
  l_period_PCD  DATE;
  l_period_PC   NUMBER(15);
  l_period_FY   NUMBER(15);
  l_period_closed VARCHAR2(3);
BEGIN
IF upper(p_mrcsobtype) = 'R'
THEN
  SELECT period_counter,
         period_open_date,
         nvl(period_close_date, sysdate),
	decode(period_close_date, null, 'NO', 'YES'),
         fiscal_year
  INTO   l_period_PC,
         l_period_POD,
         l_period_PCD,
	l_period_closed,
         l_period_FY
  FROM   FA_DEPRN_PERIODS_MRC_V
  WHERE  book_type_code = P_BOOK
  AND    period_name    = P_PERIOD1;
ELSE
  SELECT period_counter,
         period_open_date,
         nvl(period_close_date, sysdate),
	decode(period_close_date, null, 'NO', 'YES'),
         fiscal_year
  INTO   l_period_PC,
         l_period_POD,
         l_period_PCD,
	l_period_closed,
         l_period_FY
  FROM   FA_DEPRN_PERIODS
  WHERE  book_type_code = P_BOOK
  AND    period_name    = P_PERIOD1;
END IF;
  Period1_POD := l_period_POD;
  Period1_PCD := l_period_PCD;
  Period1_FY  := l_period_FY;
  C_Period_Closed := l_period_closed;
  return(l_period_PC);
END;
RETURN NULL; end;
function d_lifeformula(LIFE in number, ADJ_RATE in number, BONUS_RATE in number, PROD in number) return varchar2 is
begin
/*SRW.REFERENCE(LIFE);*/null;
DECLARE
   l_life	number;
   l_adj_rate	number;
   l_bonus_rate	number;
   l_prod	number;
   l_d_life	varchar2(7);
BEGIN
	l_life := LIFE;
	l_adj_rate := ADJ_RATE;
	l_bonus_rate := BONUS_RATE;
	l_prod := PROD;
l_d_life := fadolif(l_life, l_adj_rate, l_bonus_rate, l_prod);
return(l_d_life);
END;
RETURN NULL; end;
function C_DO_INSERTFormula return Number is
begin
declare
  l_book	varchar2(15);
  l_period	varchar2(15);
  l_errbuf	varchar2(250);
  l_retcode	number;
begin
  l_book := P_Book;
  l_period := P_Period1;
     FA_RSVLDG (l_book, l_period, l_errbuf, l_retcode);
  if (l_retcode <> 0) then
	C_Insertion_Message := l_errbuf;
  end if;
  C_Errbuf := l_errbuf;
  C_RetCode := l_retcode;
return (1);
end;
RETURN NULL; end;
function AfterPForm return boolean is
begin
IF p_ca_set_of_books_id <> -1999
THEN
  BEGIN
   select mrc_sob_type_code, currency_code
   into p_mrcsobtype, lp_currency_code
   from gl_sets_of_books
   where set_of_books_id = p_ca_set_of_books_id;
  EXCEPTION
    WHEN OTHERS THEN
     p_mrcsobtype := 'P';
  END;
ELSE
   p_mrcsobtype := 'P';
END IF;
IF upper(p_mrcsobtype) = 'R'
THEN
  lp_fa_deprn_summary := 'FA_DEPRN_SUMMARY_MRC_V';
ELSE
  lp_fa_deprn_summary := 'FA_DEPRN_SUMMARY';
END IF;
  return (TRUE);
end;
--Functions to refer Oracle report placeholders--
 Function Accounting_Flex_Structure_p return number is
	Begin
	 return Accounting_Flex_Structure;
	 END;
 Function ACCT_BAL_APROMPT_p return varchar2 is
	Begin
	 return ACCT_BAL_APROMPT;
	 END;
 Function Fiscal_Year_Name_p return varchar2 is
	Begin
	 return Fiscal_Year_Name;
	 END;
 Function Currency_Code_p return varchar2 is
	Begin
	 return Currency_Code;
	 END;
 Function Book_Class_p return varchar2 is
	Begin
	 return Book_Class;
	 END;
 Function Distribution_Source_Book_p return varchar2 is
	Begin
	 return Distribution_Source_Book;
	 END;
 Function Period1_PCD_p return date is
	Begin
	 return Period1_PCD;
	 END;
 Function Period1_POD_p return date is
	Begin
	 return Period1_POD;
	 END;
 Function Period1_FY_p return number is
	Begin
	 return Period1_FY;
	 END;
 Function C_ERRBUF_p return varchar2 is
	Begin
	 return C_ERRBUF;
	 END;
 Function C_RETCODE_p return number is
	Begin
	 return C_RETCODE;
	 END;
 Function RP_COMPANY_NAME_p return varchar2 is
	Begin
	 return RP_COMPANY_NAME;
	 END;
 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return RP_REPORT_NAME;
	 END;
 Function RP_ACCT_BAL_LPROMPT_p return varchar2 is
	Begin
	 return RP_ACCT_BAL_LPROMPT;
	 END;
 Function C_Period_Closed_p return varchar2 is
	Begin
	 return C_Period_Closed;
	 END;
 Function RP_BAL_LPROMPT_p return varchar2 is
	Begin
	 return RP_BAL_LPROMPT;
	 END;
 Function C_INSERTION_MESSAGE_p return varchar2 is
	Begin
	 return C_INSERTION_MESSAGE;
	 END;
FUNCTION fadolif(life NUMBER,
		adj_rate NUMBER,
		bonus_rate NUMBER,
		prod NUMBER)
RETURN CHAR IS
   retval CHAR(7);
   num_chars NUMBER;
   temp_retval number;
BEGIN
   IF life IS NOT NULL
   THEN
      -- Fix for bug 601202 -- added substrb after lpad.  changed '90' to '999'
      temp_retval := fnd_number.canonical_to_number((LPAD(SUBSTR(TO_CHAR(TRUNC(life/12, 0), '999'), 2, 3),3,' ') || '.' ||
		SUBSTR(TO_CHAR(MOD(life, 12), '00'), 2, 2)) );
      retval := to_char(temp_retval,'999D99');
   ELSIF adj_rate IS NOT NULL
   THEN
      /* Bug 1744591
         Changed 90D99 to 990D99 */
           retval := SUBSTR(TO_CHAR(ROUND((adj_rate + NVL(bonus_rate, 0))*100, 2), '990.99'),2,6) || '%';
   ELSIF prod IS NOT NULL
   THEN
	--test for length of production_capacity; if it's longer
	--than 7 characters, then display in exponential notation
      --IF prod <= 9999999
      --THEN
      --   retval := TO_CHAR(prod);
      --ELSE
      --   retval := SUBSTR(LTRIM(TO_CHAR(prod, '9.9EEEE')), 1, 7);
      --END IF;
	--display nothing for UOP assets
	retval := '';
   ELSE
	--should not occur
      retval := ' ';
   END IF;
   return(retval);
END;
/*PROCEDURE VERSION IS
  FDRCSID VARCHAR2(100);
  BEGIN
     FDRCSID := '$Header: FAS480B.pls 120.0.12010000.1 2008/07/28 13:14:56 appldev ship $';
  END VERSION;*/
procedure FA_RSVLDG
       (book            in  varchar2,
        period          in  varchar2,
        errbuf          out NOCOPY varchar2,
        retcode         out NOCOPY number)
is
--Below Setting Added during DT Fix
PRAGMA AUTONOMOUS_TRANSACTION;
--End of DT Fix
        operation       varchar2(200);
        dist_book       varchar2(15);
        ucd             date;
        upc             number;
        tod             date;
        tpc             number;
        h_set_of_books_id  number;
        h_reporting_flag   varchar2(1);
begin
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
       begin
          select  to_number(substrb(userenv('CLIENT_INFO'),45,10))
	  into    h_set_of_books_id from dual;
       exception
         when others then
           h_set_of_books_id := null;
       end;
       if (h_set_of_books_id is not null) then
         if not fa_cache_pkg.fazcsob
                (X_set_of_books_id   => h_set_of_books_id,
                 X_mrc_sob_type_code => h_reporting_flag) then
                   raise FND_API.G_EXC_UNEXPECTED_ERROR;
         end if;
       else
         h_reporting_flag := 'P';
       end if;
       operation := 'Selecting Book and Period information';
       if (h_reporting_flag = 'R') then
        SELECT
                BC.DISTRIBUTION_SOURCE_BOOK             dbk,
                nvl (DP.PERIOD_CLOSE_DATE, sysdate)     ucd,
                DP.PERIOD_COUNTER                       upc,
                min (DP_FY.PERIOD_OPEN_DATE)            tod,
                min (DP_FY.PERIOD_COUNTER)              tpc
        INTO
                dist_book,
                ucd,
                upc,
                tod,
                tpc
        FROM
                FA_DEPRN_PERIODS_MRC_V        DP,
                FA_DEPRN_PERIODS_MRC_V        DP_FY,
                FA_BOOK_CONTROLS_MRC_V        BC
        WHERE
                DP.BOOK_TYPE_CODE       =  book                 AND
                DP.PERIOD_NAME          =  period               AND
                DP_FY.BOOK_TYPE_CODE    =  book                 AND
                DP_FY.FISCAL_YEAR       =  DP.FISCAL_YEAR
        AND     BC.BOOK_TYPE_CODE       =  book
	GROUP BY
		BC.DISTRIBUTION_SOURCE_BOOK,
		DP.PERIOD_CLOSE_DATE,
		DP.PERIOD_COUNTER;
       else
        SELECT
                BC.DISTRIBUTION_SOURCE_BOOK             dbk,
                nvl (DP.PERIOD_CLOSE_DATE, sysdate)     ucd,
                DP.PERIOD_COUNTER                       upc,
                min (DP_FY.PERIOD_OPEN_DATE)            tod,
                min (DP_FY.PERIOD_COUNTER)              tpc
        INTO
                dist_book,
                ucd,
                upc,
                tod,
                tpc
        FROM
                FA_DEPRN_PERIODS        DP,
                FA_DEPRN_PERIODS        DP_FY,
                FA_BOOK_CONTROLS        BC
        WHERE
                DP.BOOK_TYPE_CODE       =  book                 AND
                DP.PERIOD_NAME          =  period               AND
                DP_FY.BOOK_TYPE_CODE    =  book                 AND
                DP_FY.FISCAL_YEAR       =  DP.FISCAL_YEAR
        AND     BC.BOOK_TYPE_CODE       =  book
	GROUP BY
		BC.DISTRIBUTION_SOURCE_BOOK,
		DP.PERIOD_CLOSE_DATE,
		DP.PERIOD_COUNTER;
       end if;
       operation := 'Inserting into FA_RESERVE_LEDGER_GT';
  -- run only if CRL not installed
  If (nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'N' ) then
   if (h_reporting_flag = 'R') then
    INSERT INTO FA_RESERVE_LEDGER_GT
       (ASSET_ID,
        DH_CCID,
        DEPRN_RESERVE_ACCT,
        DATE_PLACED_IN_SERVICE,
        METHOD_CODE,
        LIFE,
        RATE,
        CAPACITY,
        COST,
        DEPRN_AMOUNT,
        YTD_DEPRN,
        DEPRN_RESERVE,
        PERCENT,
        TRANSACTION_TYPE,
        PERIOD_COUNTER,
        DATE_EFFECTIVE,
	RESERVE_ACCT)
      SELECT
        DH.ASSET_ID                                             ASSET_ID,
        DH.CODE_COMBINATION_ID                                  DH_CCID,
        CB.DEPRN_RESERVE_ACCT                                   RSV_ACCOUNT,
        BOOKS.DATE_PLACED_IN_SERVICE                            START_DATE,
        BOOKS.DEPRN_METHOD_CODE                                 METHOD,
        BOOKS.LIFE_IN_MONTHS                                    LIFE,
        BOOKS.ADJUSTED_RATE                                     RATE,
        BOOKS.PRODUCTION_CAPACITY                               CAPACITY,
        DD_BONUS.COST                                                 COST,
        decode (DD_BONUS.PERIOD_COUNTER, upc, DD_BONUS.DEPRN_AMOUNT - DD_BONUS.BONUS_DEPRN_AMOUNT, 0)                                               DEPRN_AMOUNT,
        decode (sign (tpc - DD_BONUS.PERIOD_COUNTER), 1, 0, DD_BONUS.YTD_DEPRN - DD_BONUS.BONUS_YTD_DEPRN)
                                                                YTD_DEPRN,
        DD_BONUS.DEPRN_RESERVE - DD_BONUS.BONUS_DEPRN_RESERVE                                        DEPRN_RESERVE,
        decode (TH.TRANSACTION_TYPE_CODE, null,
                        DH.UNITS_ASSIGNED / AH.UNITS * 100)
                                                                PERCENT,
        decode (TH.TRANSACTION_TYPE_CODE, null,
                decode (TH_RT.TRANSACTION_TYPE_CODE,
                        'FULL RETIREMENT', 'F',
                        decode (BOOKS.DEPRECIATE_FLAG, 'NO', 'N')),
                'TRANSFER', 'T',
                'TRANSFER OUT', 'P',
                'RECLASS', 'R')                                 T_TYPE,
        DD_BONUS.PERIOD_COUNTER,
        NVL(TH.DATE_EFFECTIVE, ucd),
	''
FROM
        FA_DEPRN_DETAIL_MRC_V   DD_BONUS,
        FA_ASSET_HISTORY        AH,
        FA_TRANSACTION_HEADERS  TH,
        FA_TRANSACTION_HEADERS  TH_RT,
        FA_BOOKS_MRC_V          BOOKS,
        FA_DISTRIBUTION_HISTORY DH,
        FA_CATEGORY_BOOKS       CB
WHERE
        CB.BOOK_TYPE_CODE               =  book                         AND
        CB.CATEGORY_ID                  =  AH.CATEGORY_ID
AND
        AH.ASSET_ID                     =  DH.ASSET_ID               AND
        AH.DATE_EFFECTIVE               < nvl(TH.DATE_EFFECTIVE, ucd)  AND
        nvl(AH.DATE_INEFFECTIVE,sysdate)
                                        >=  nvl(TH.DATE_EFFECTIVE, ucd)  AND
        AH.ASSET_TYPE                   = 'CAPITALIZED'
AND
        DD_BONUS.BOOK_TYPE_CODE               = book                          AND
        DD_BONUS.DISTRIBUTION_ID              = DH.DISTRIBUTION_ID        AND
        DD_BONUS.PERIOD_COUNTER               =
       (SELECT  max (DD_SUB.PERIOD_COUNTER)
        FROM    FA_DEPRN_DETAIL_MRC_V DD_SUB
        WHERE   DD_SUB.BOOK_TYPE_CODE   = book
        AND     DD_SUB.ASSET_ID         = DH.ASSET_ID
        AND     DD_SUB.DISTRIBUTION_ID  = DH.DISTRIBUTION_ID
        AND     DD_SUB.PERIOD_COUNTER   <= upc)
AND
        TH_RT.BOOK_TYPE_CODE            = book                          AND
        TH_RT.TRANSACTION_HEADER_ID     = BOOKS.TRANSACTION_HEADER_ID_IN
AND
        BOOKS.BOOK_TYPE_CODE            = book                          AND
        BOOKS.ASSET_ID                  = DH.ASSET_ID                AND
        nvl(BOOKS.PERIOD_COUNTER_FULLY_RETIRED, upc) >= tpc             AND
        BOOKS.DATE_EFFECTIVE            <= nvl(TH.DATE_EFFECTIVE, ucd)  AND
        nvl(BOOKS.DATE_INEFFECTIVE,sysdate+1) > nvl(TH.DATE_EFFECTIVE, ucd)
AND
        TH.BOOK_TYPE_CODE (+)           = dist_book                     AND
        TH.TRANSACTION_HEADER_ID (+)    = DH.TRANSACTION_HEADER_ID_OUT AND
        TH.DATE_EFFECTIVE (+)           BETWEEN tod and ucd
AND
        DH.BOOK_TYPE_CODE               = dist_book                     AND
        DH.DATE_EFFECTIVE               <= ucd AND
        nvl(DH.DATE_INEFFECTIVE, sysdate) > tod
UNION ALL
SELECT
        DH.ASSET_ID                                             ASSET_ID,
        DH.CODE_COMBINATION_ID                                  DH_CCID,
        CB.BONUS_DEPRN_RESERVE_ACCT                             RSV_ACCOUNT,
        BOOKS.DATE_PLACED_IN_SERVICE                            START_DATE,
        BOOKS.DEPRN_METHOD_CODE                                 METHOD,
        BOOKS.LIFE_IN_MONTHS                                    LIFE,
        BOOKS.ADJUSTED_RATE                                     RATE,
        BOOKS.PRODUCTION_CAPACITY                               CAPACITY,
        0                                                 COST,
        decode (DD.PERIOD_COUNTER, upc, DD.BONUS_DEPRN_AMOUNT, 0)
                                                                DEPRN_AMOUNT,
        decode (sign (tpc - DD.PERIOD_COUNTER), 1, 0, DD.BONUS_YTD_DEPRN)
                                                                YTD_DEPRN,
        DD.BONUS_DEPRN_RESERVE                                  DEPRN_RESERVE,
        0                                                       PERCENT,
        'B'                                 			T_TYPE,
        DD.PERIOD_COUNTER,
        NVL(TH.DATE_EFFECTIVE, ucd),
	CB.BONUS_DEPRN_EXPENSE_ACCT
FROM
        FA_DEPRN_DETAIL_MRC_V   DD,
        FA_ASSET_HISTORY        AH,
        FA_TRANSACTION_HEADERS  TH,
        FA_TRANSACTION_HEADERS  TH_RT,
        FA_BOOKS_MRC_V          BOOKS,
        FA_DISTRIBUTION_HISTORY DH,
        FA_CATEGORY_BOOKS       CB
WHERE
        CB.BOOK_TYPE_CODE               =  book                         AND
        CB.CATEGORY_ID                  =  AH.CATEGORY_ID
AND
        AH.ASSET_ID                     =  DH.ASSET_ID               AND
        AH.DATE_EFFECTIVE               < nvl(TH.DATE_EFFECTIVE, ucd)  AND
        nvl(AH.DATE_INEFFECTIVE,sysdate)
                                        >=  nvl(TH.DATE_EFFECTIVE, ucd)  AND
        AH.ASSET_TYPE                   = 'CAPITALIZED'
AND
        DD.BOOK_TYPE_CODE               = book                          AND
        DD.DISTRIBUTION_ID              = DH.DISTRIBUTION_ID        AND
        DD.PERIOD_COUNTER               =
       (SELECT  max (DD_SUB.PERIOD_COUNTER)
        FROM    FA_DEPRN_DETAIL_MRC_V DD_SUB
        WHERE   DD_SUB.BOOK_TYPE_CODE   = book
        AND     DD_SUB.ASSET_ID         = DH.ASSET_ID
        AND     DD_SUB.DISTRIBUTION_ID  = DH.DISTRIBUTION_ID
        AND     DD_SUB.PERIOD_COUNTER   <= upc)
AND
        TH_RT.BOOK_TYPE_CODE            = book                          AND
        TH_RT.TRANSACTION_HEADER_ID     = BOOKS.TRANSACTION_HEADER_ID_IN
AND
        BOOKS.BOOK_TYPE_CODE            = book                          AND
        BOOKS.ASSET_ID                  = DH.ASSET_ID                AND
        nvl(BOOKS.PERIOD_COUNTER_FULLY_RETIRED, upc) >= tpc             AND
        BOOKS.DATE_EFFECTIVE            <= nvl(TH.DATE_EFFECTIVE, ucd)  AND
        nvl(BOOKS.DATE_INEFFECTIVE,sysdate+1) > nvl(TH.DATE_EFFECTIVE, ucd) AND
	BOOKS.BONUS_RULE IS NOT NULL
AND
        TH.BOOK_TYPE_CODE (+)           = dist_book                     AND
        TH.TRANSACTION_HEADER_ID (+)    = DH.TRANSACTION_HEADER_ID_OUT AND
        TH.DATE_EFFECTIVE (+)           BETWEEN tod and ucd
AND
        DH.BOOK_TYPE_CODE               = dist_book                     AND
        DH.DATE_EFFECTIVE               <= ucd AND
        nvl(DH.DATE_INEFFECTIVE, sysdate) > tod
;
   else
    INSERT INTO FA_RESERVE_LEDGER_GT
       (ASSET_ID,
        DH_CCID,
        DEPRN_RESERVE_ACCT,
        DATE_PLACED_IN_SERVICE,
        METHOD_CODE,
        LIFE,
        RATE,
        CAPACITY,
        COST,
        DEPRN_AMOUNT,
        YTD_DEPRN,
        DEPRN_RESERVE,
        PERCENT,
        TRANSACTION_TYPE,
        PERIOD_COUNTER,
        DATE_EFFECTIVE,
	RESERVE_ACCT)
      SELECT
        DH.ASSET_ID                                             ASSET_ID,
        DH.CODE_COMBINATION_ID                                  DH_CCID,
        CB.DEPRN_RESERVE_ACCT                                   RSV_ACCOUNT,
        BOOKS.DATE_PLACED_IN_SERVICE                            START_DATE,
        BOOKS.DEPRN_METHOD_CODE                                 METHOD,
        BOOKS.LIFE_IN_MONTHS                                    LIFE,
        BOOKS.ADJUSTED_RATE                                     RATE,
        BOOKS.PRODUCTION_CAPACITY                               CAPACITY,
        DD_BONUS.COST                                                 COST,
        decode (DD_BONUS.PERIOD_COUNTER, upc, DD_BONUS.DEPRN_AMOUNT - DD_BONUS.BONUS_DEPRN_AMOUNT, 0)                                               DEPRN_AMOUNT,
        decode (sign (tpc - DD_BONUS.PERIOD_COUNTER), 1, 0, DD_BONUS.YTD_DEPRN - DD_BONUS.BONUS_YTD_DEPRN)
                                                                YTD_DEPRN,
        DD_BONUS.DEPRN_RESERVE - DD_BONUS.BONUS_DEPRN_RESERVE                                        DEPRN_RESERVE,
        decode (TH.TRANSACTION_TYPE_CODE, null,
                        DH.UNITS_ASSIGNED / AH.UNITS * 100)
                                                                PERCENT,
        decode (TH.TRANSACTION_TYPE_CODE, null,
                decode (TH_RT.TRANSACTION_TYPE_CODE,
                        'FULL RETIREMENT', 'F',
                        decode (BOOKS.DEPRECIATE_FLAG, 'NO', 'N')),
                'TRANSFER', 'T',
                'TRANSFER OUT', 'P',
                'RECLASS', 'R')                                 T_TYPE,
        DD_BONUS.PERIOD_COUNTER,
        NVL(TH.DATE_EFFECTIVE, ucd),
	''
FROM
        FA_DEPRN_DETAIL         DD_BONUS,
        FA_ASSET_HISTORY        AH,
        FA_TRANSACTION_HEADERS  TH,
        FA_TRANSACTION_HEADERS  TH_RT,
        FA_BOOKS                BOOKS,
        FA_DISTRIBUTION_HISTORY DH,
        FA_CATEGORY_BOOKS       CB
WHERE
        CB.BOOK_TYPE_CODE               =  book                         AND
        CB.CATEGORY_ID                  =  AH.CATEGORY_ID
AND
        AH.ASSET_ID                     =  DH.ASSET_ID               AND
        AH.DATE_EFFECTIVE               < nvl(TH.DATE_EFFECTIVE, ucd)  AND
        nvl(AH.DATE_INEFFECTIVE,sysdate)
                                        >=  nvl(TH.DATE_EFFECTIVE, ucd)  AND
        AH.ASSET_TYPE                   = 'CAPITALIZED'
AND
        DD_BONUS.BOOK_TYPE_CODE               = book                          AND
        DD_BONUS.DISTRIBUTION_ID              = DH.DISTRIBUTION_ID        AND
        DD_BONUS.PERIOD_COUNTER               =
       (SELECT  max (DD_SUB.PERIOD_COUNTER)
        FROM    FA_DEPRN_DETAIL DD_SUB
        WHERE   DD_SUB.BOOK_TYPE_CODE   = book
        AND     DD_SUB.ASSET_ID         = DH.ASSET_ID
        AND     DD_SUB.DISTRIBUTION_ID  = DH.DISTRIBUTION_ID
        AND     DD_SUB.PERIOD_COUNTER   <= upc)
AND
        TH_RT.BOOK_TYPE_CODE            = book                          AND
        TH_RT.TRANSACTION_HEADER_ID     = BOOKS.TRANSACTION_HEADER_ID_IN
AND
        BOOKS.BOOK_TYPE_CODE            = book                          AND
        BOOKS.ASSET_ID                  = DH.ASSET_ID                AND
        nvl(BOOKS.PERIOD_COUNTER_FULLY_RETIRED, upc) >= tpc             AND
        BOOKS.DATE_EFFECTIVE            <= nvl(TH.DATE_EFFECTIVE, ucd)  AND
        nvl(BOOKS.DATE_INEFFECTIVE,sysdate+1) > nvl(TH.DATE_EFFECTIVE, ucd)
AND
        TH.BOOK_TYPE_CODE (+)           = dist_book                     AND
        TH.TRANSACTION_HEADER_ID (+)    = DH.TRANSACTION_HEADER_ID_OUT AND
        TH.DATE_EFFECTIVE (+)           BETWEEN tod and ucd
AND
        DH.BOOK_TYPE_CODE               = dist_book                     AND
        DH.DATE_EFFECTIVE               <= ucd AND
        nvl(DH.DATE_INEFFECTIVE, sysdate) > tod
UNION ALL
SELECT
        DH.ASSET_ID                                             ASSET_ID,
        DH.CODE_COMBINATION_ID                                  DH_CCID,
        CB.BONUS_DEPRN_RESERVE_ACCT                             RSV_ACCOUNT,
        BOOKS.DATE_PLACED_IN_SERVICE                            START_DATE,
        BOOKS.DEPRN_METHOD_CODE                                 METHOD,
        BOOKS.LIFE_IN_MONTHS                                    LIFE,
        BOOKS.ADJUSTED_RATE                                     RATE,
        BOOKS.PRODUCTION_CAPACITY                               CAPACITY,
        0                                                 COST,
        decode (DD.PERIOD_COUNTER, upc, DD.BONUS_DEPRN_AMOUNT, 0)
                                                                DEPRN_AMOUNT,
        decode (sign (tpc - DD.PERIOD_COUNTER), 1, 0, DD.BONUS_YTD_DEPRN)
                                                                YTD_DEPRN,
        DD.BONUS_DEPRN_RESERVE                                  DEPRN_RESERVE,
        0                                                       PERCENT,
        'B'                                 			T_TYPE,
        DD.PERIOD_COUNTER,
        NVL(TH.DATE_EFFECTIVE, ucd),
	CB.BONUS_DEPRN_EXPENSE_ACCT
FROM
        FA_DEPRN_DETAIL         DD,
        FA_ASSET_HISTORY        AH,
        FA_TRANSACTION_HEADERS  TH,
        FA_TRANSACTION_HEADERS  TH_RT,
        FA_BOOKS                BOOKS,
        FA_DISTRIBUTION_HISTORY DH,
        FA_CATEGORY_BOOKS       CB
WHERE
        CB.BOOK_TYPE_CODE               =  book                         AND
        CB.CATEGORY_ID                  =  AH.CATEGORY_ID
AND
        AH.ASSET_ID                     =  DH.ASSET_ID               AND
        AH.DATE_EFFECTIVE               < nvl(TH.DATE_EFFECTIVE, ucd)  AND
        nvl(AH.DATE_INEFFECTIVE,sysdate)
                                        >=  nvl(TH.DATE_EFFECTIVE, ucd)  AND
        AH.ASSET_TYPE                   = 'CAPITALIZED'
AND
        DD.BOOK_TYPE_CODE               = book                          AND
        DD.DISTRIBUTION_ID              = DH.DISTRIBUTION_ID        AND
        DD.PERIOD_COUNTER               =
       (SELECT  max (DD_SUB.PERIOD_COUNTER)
        FROM    FA_DEPRN_DETAIL DD_SUB
        WHERE   DD_SUB.BOOK_TYPE_CODE   = book
        AND     DD_SUB.ASSET_ID         = DH.ASSET_ID
        AND     DD_SUB.DISTRIBUTION_ID  = DH.DISTRIBUTION_ID
        AND     DD_SUB.PERIOD_COUNTER   <= upc)
AND
        TH_RT.BOOK_TYPE_CODE            = book                          AND
        TH_RT.TRANSACTION_HEADER_ID     = BOOKS.TRANSACTION_HEADER_ID_IN
AND
        BOOKS.BOOK_TYPE_CODE            = book                          AND
        BOOKS.ASSET_ID                  = DH.ASSET_ID                AND
        nvl(BOOKS.PERIOD_COUNTER_FULLY_RETIRED, upc) >= tpc             AND
        BOOKS.DATE_EFFECTIVE            <= nvl(TH.DATE_EFFECTIVE, ucd)  AND
        nvl(BOOKS.DATE_INEFFECTIVE,sysdate+1) > nvl(TH.DATE_EFFECTIVE, ucd) AND
	BOOKS.BONUS_RULE IS NOT NULL
AND
        TH.BOOK_TYPE_CODE (+)           = dist_book                     AND
        TH.TRANSACTION_HEADER_ID (+)    = DH.TRANSACTION_HEADER_ID_OUT AND
        TH.DATE_EFFECTIVE (+)           BETWEEN tod and ucd
AND
        DH.BOOK_TYPE_CODE               = dist_book                     AND
        DH.DATE_EFFECTIVE               <= ucd AND
        nvl(DH.DATE_INEFFECTIVE, sysdate) > tod
;
  end if;
  -- run only if CRL installed
  elsif (nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y' ) then
    -- Insert Non-Group Details
   if (h_reporting_flag = 'R') then
    INSERT INTO FA_RESERVE_LEDGER_GT
       (ASSET_ID,
        DH_CCID,
        DEPRN_RESERVE_ACCT,
        DATE_PLACED_IN_SERVICE,
        METHOD_CODE,
        LIFE,
        RATE,
        CAPACITY,
        COST,
        DEPRN_AMOUNT,
        YTD_DEPRN,
        DEPRN_RESERVE,
        PERCENT,
        TRANSACTION_TYPE,
        PERIOD_COUNTER,
        DATE_EFFECTIVE)
    SELECT
        DH.ASSET_ID                                             ASSET_ID,
        DH.CODE_COMBINATION_ID                                  DH_CCID,
        CB.DEPRN_RESERVE_ACCT                                   RSV_ACCOUNT,
        BOOKS.DATE_PLACED_IN_SERVICE                            START_DATE,
        BOOKS.DEPRN_METHOD_CODE                                 METHOD,
        BOOKS.LIFE_IN_MONTHS                                    LIFE,
        BOOKS.ADJUSTED_RATE                                     RATE,
        BOOKS.PRODUCTION_CAPACITY                               CAPACITY,
        DD.COST                                                 COST,
        decode (DD.PERIOD_COUNTER, upc, DD.DEPRN_AMOUNT, 0)
                                                                DEPRN_AMOUNT,
        decode (sign (tpc - DD.PERIOD_COUNTER), 1, 0, DD.YTD_DEPRN)
                                                                YTD_DEPRN,
        DD.DEPRN_RESERVE                                        DEPRN_RESERVE,
        decode (TH.TRANSACTION_TYPE_CODE, null,
                        DH.UNITS_ASSIGNED / AH.UNITS * 100)
                                                                PERCENT,
        decode (TH.TRANSACTION_TYPE_CODE, null,
                decode (TH_RT.TRANSACTION_TYPE_CODE,
                        'FULL RETIREMENT', 'F',
                        decode (BOOKS.DEPRECIATE_FLAG, 'NO', 'N')),
                'TRANSFER', 'T',
                'TRANSFER OUT', 'P',
                'RECLASS', 'R')                                 T_TYPE,
        DD.PERIOD_COUNTER,
        NVL(TH.DATE_EFFECTIVE, ucd)
     FROM
        FA_DEPRN_DETAIL_MRC_V   DD,
        FA_ASSET_HISTORY        AH,
        FA_TRANSACTION_HEADERS  TH,
        FA_TRANSACTION_HEADERS  TH_RT,
        FA_BOOKS_MRC_V          BOOKS,
        FA_DISTRIBUTION_HISTORY DH,
        FA_CATEGORY_BOOKS       CB
     WHERE
        -- start cua  - exclude the group Assets
        books.group_asset_id is null
            AND  -- end cua
        CB.BOOK_TYPE_CODE               =  book                         AND
        CB.CATEGORY_ID                  =  AH.CATEGORY_ID
AND
        AH.ASSET_ID                     =  DH.ASSET_ID               AND
        AH.DATE_EFFECTIVE               < nvl(TH.DATE_EFFECTIVE, ucd)  AND
        nvl(AH.DATE_INEFFECTIVE,sysdate)
                                        >=  nvl(TH.DATE_EFFECTIVE, ucd)  AND
        AH.ASSET_TYPE                   = 'CAPITALIZED'
AND
        DD.BOOK_TYPE_CODE               = book                          AND
        DD.DISTRIBUTION_ID              = DH.DISTRIBUTION_ID        AND
        DD.PERIOD_COUNTER               =
       (SELECT  max (DD_SUB.PERIOD_COUNTER)
        FROM    FA_DEPRN_DETAIL_MRC_V DD_SUB
        WHERE   DD_SUB.BOOK_TYPE_CODE   = book
        AND     DD_SUB.ASSET_ID         = DH.ASSET_ID
        AND     DD_SUB.DISTRIBUTION_ID  = DH.DISTRIBUTION_ID
        AND     DD_SUB.PERIOD_COUNTER   <= upc)
AND
        TH_RT.BOOK_TYPE_CODE            = book                          AND
        TH_RT.TRANSACTION_HEADER_ID     = BOOKS.TRANSACTION_HEADER_ID_IN
AND
        BOOKS.BOOK_TYPE_CODE            = book                          AND
        BOOKS.ASSET_ID                  = DH.ASSET_ID                AND
        nvl(BOOKS.PERIOD_COUNTER_FULLY_RETIRED, upc) >= tpc             AND
        BOOKS.DATE_EFFECTIVE            <= nvl(TH.DATE_EFFECTIVE, ucd)  AND
        nvl(BOOKS.DATE_INEFFECTIVE,sysdate+1) > nvl(TH.DATE_EFFECTIVE, ucd)
AND
        TH.BOOK_TYPE_CODE (+)           = dist_book                     AND
        TH.TRANSACTION_HEADER_ID (+)    = DH.TRANSACTION_HEADER_ID_OUT AND
        TH.DATE_EFFECTIVE (+)           BETWEEN tod and ucd
AND
        DH.BOOK_TYPE_CODE               = dist_book                     AND
        DH.DATE_EFFECTIVE               <= ucd AND
        nvl(DH.DATE_INEFFECTIVE, sysdate) > tod AND
        -- start cua  - exclude the group Assets
        books.group_asset_id is null;
   else
    INSERT INTO FA_RESERVE_LEDGER_GT
       (ASSET_ID,
        DH_CCID,
        DEPRN_RESERVE_ACCT,
        DATE_PLACED_IN_SERVICE,
        METHOD_CODE,
        LIFE,
        RATE,
        CAPACITY,
        COST,
        DEPRN_AMOUNT,
        YTD_DEPRN,
        DEPRN_RESERVE,
        PERCENT,
        TRANSACTION_TYPE,
        PERIOD_COUNTER,
        DATE_EFFECTIVE)
    SELECT
        DH.ASSET_ID                                             ASSET_ID,
        DH.CODE_COMBINATION_ID                                  DH_CCID,
        CB.DEPRN_RESERVE_ACCT                                   RSV_ACCOUNT,
        BOOKS.DATE_PLACED_IN_SERVICE                            START_DATE,
        BOOKS.DEPRN_METHOD_CODE                                 METHOD,
        BOOKS.LIFE_IN_MONTHS                                    LIFE,
        BOOKS.ADJUSTED_RATE                                     RATE,
        BOOKS.PRODUCTION_CAPACITY                               CAPACITY,
        DD.COST                                                 COST,
        decode (DD.PERIOD_COUNTER, upc, DD.DEPRN_AMOUNT, 0)
                                                                DEPRN_AMOUNT,
        decode (sign (tpc - DD.PERIOD_COUNTER), 1, 0, DD.YTD_DEPRN)
                                                                YTD_DEPRN,
        DD.DEPRN_RESERVE                                        DEPRN_RESERVE,
        decode (TH.TRANSACTION_TYPE_CODE, null,
                        DH.UNITS_ASSIGNED / AH.UNITS * 100)
                                                                PERCENT,
        decode (TH.TRANSACTION_TYPE_CODE, null,
                decode (TH_RT.TRANSACTION_TYPE_CODE,
                        'FULL RETIREMENT', 'F',
                        decode (BOOKS.DEPRECIATE_FLAG, 'NO', 'N')),
                'TRANSFER', 'T',
                'TRANSFER OUT', 'P',
                'RECLASS', 'R')                                 T_TYPE,
        DD.PERIOD_COUNTER,
        NVL(TH.DATE_EFFECTIVE, ucd)
     FROM
        FA_DEPRN_DETAIL         DD,
        FA_ASSET_HISTORY        AH,
        FA_TRANSACTION_HEADERS  TH,
        FA_TRANSACTION_HEADERS  TH_RT,
        FA_BOOKS                BOOKS,
        FA_DISTRIBUTION_HISTORY DH,
        FA_CATEGORY_BOOKS       CB
     WHERE
        -- start cua  - exclude the group Assets
        books.group_asset_id is null
            AND  -- end cua
        CB.BOOK_TYPE_CODE               =  book                         AND
        CB.CATEGORY_ID                  =  AH.CATEGORY_ID
AND
        AH.ASSET_ID                     =  DH.ASSET_ID               AND
        AH.DATE_EFFECTIVE               < nvl(TH.DATE_EFFECTIVE, ucd)  AND
        nvl(AH.DATE_INEFFECTIVE,sysdate)
                                        >=  nvl(TH.DATE_EFFECTIVE, ucd)  AND
        AH.ASSET_TYPE                   = 'CAPITALIZED'
AND
        DD.BOOK_TYPE_CODE               = book                          AND
        DD.DISTRIBUTION_ID              = DH.DISTRIBUTION_ID        AND
        DD.PERIOD_COUNTER               =
       (SELECT  max (DD_SUB.PERIOD_COUNTER)
        FROM    FA_DEPRN_DETAIL DD_SUB
        WHERE   DD_SUB.BOOK_TYPE_CODE   = book
        AND     DD_SUB.ASSET_ID         = DH.ASSET_ID
        AND     DD_SUB.DISTRIBUTION_ID  = DH.DISTRIBUTION_ID
        AND     DD_SUB.PERIOD_COUNTER   <= upc)
AND
        TH_RT.BOOK_TYPE_CODE            = book                          AND
        TH_RT.TRANSACTION_HEADER_ID     = BOOKS.TRANSACTION_HEADER_ID_IN
AND
        BOOKS.BOOK_TYPE_CODE            = book                          AND
        BOOKS.ASSET_ID                  = DH.ASSET_ID                AND
        nvl(BOOKS.PERIOD_COUNTER_FULLY_RETIRED, upc) >= tpc             AND
        BOOKS.DATE_EFFECTIVE            <= nvl(TH.DATE_EFFECTIVE, ucd)  AND
        nvl(BOOKS.DATE_INEFFECTIVE,sysdate+1) > nvl(TH.DATE_EFFECTIVE, ucd)
AND
        TH.BOOK_TYPE_CODE (+)           = dist_book                     AND
        TH.TRANSACTION_HEADER_ID (+)    = DH.TRANSACTION_HEADER_ID_OUT AND
        TH.DATE_EFFECTIVE (+)           BETWEEN tod and ucd
AND
        DH.BOOK_TYPE_CODE               = dist_book                     AND
        DH.DATE_EFFECTIVE               <= ucd AND
        nvl(DH.DATE_INEFFECTIVE, sysdate) > tod AND
        -- start cua  - exclude the group Assets
        books.group_asset_id is null;
    end if;
        -- end cua
    -- Insert the Group Depreciation Details
   if (h_reporting_flag = 'R') then
    INSERT INTO FA_RESERVE_LEDGER_GT
       (ASSET_ID,
        DH_CCID,
	DEPRN_RESERVE_ACCT,
        DATE_PLACED_IN_SERVICE,
        METHOD_CODE,
        LIFE,
	RATE,
	CAPACITY,
	COST,
	DEPRN_AMOUNT,
	YTD_DEPRN,
	DEPRN_RESERVE,
	PERCENT,
	TRANSACTION_TYPE,
	PERIOD_COUNTER,
	DATE_EFFECTIVE)
     SELECT
        GAR.GROUP_ASSET_ID		ASSET_ID,
        GAD.DEPRN_EXPENSE_ACCT_CCID  	CH_CCID,
	GAD.DEPRN_RESERVE_ACCT_CCID     RSV_ACCOUNT,
        GAR.DEPRN_START_DATE		START_DATE,
        GAR.DEPRN_METHOD_CODE		METHOD,
        GAR.LIFE_IN_MONTHS		LIFE,
        GAR.ADJUSTED_RATE		RATE,
	GAR.PRODUCTION_CAPACITY		CAPACITY,
        DD.ADJUSTED_COST		COST,
        decode (DD.PERIOD_COUNTER, upc, DD.DEPRN_AMOUNT, 0)
								DEPRN_AMOUNT,
        decode (sign (tpc - DD.PERIOD_COUNTER), 1, 0, DD.YTD_DEPRN)
								YTD_DEPRN,
        DD.DEPRN_RESERVE					DEPRN_RESERVE,
       /* round (decode (TH.TRANSACTION_TYPE_CODE, null,
			DH.UNITS_ASSIGNED / AH.UNITS * 100),2)
								PERCENT,
        decode (TH.TRANSACTION_TYPE_CODE, null,
		decode (TH_RT.TRANSACTION_TYPE_CODE,
			'FULL RETIREMENT', 'F',
			decode (BOOKS.DEPRECIATE_FLAG, 'NO', 'N')),
                'TRANSFER', 'T',
                'TRANSFER OUT', 'P',
		'RECLASS', 'R')					T_TYPE,
        DD.PERIOD_COUNTER,
        NVL(TH.DATE_EFFECTIVE, ucd) */
        100   PERCENT,
        'G' T_TYPE,
        DD.PERIOD_COUNTER,
        UCD
      FROM
        FA_DEPRN_SUMMARY_MRC_V  DD,
        FA_GROUP_ASSET_RULES    GAR,
        FA_GROUP_ASSET_DEFAULT  GAD,
        FA_DEPRN_PERIODS_MRC_V  DP
      WHERE
              DD.BOOK_TYPE_CODE                  = book
      AND     DD.ASSET_ID                        = GAR.GROUP_ASSET_ID
      AND     GAD.SUPER_GROUP_ID                 is null -- MPOWELL
      AND     GAR.BOOK_TYPE_CODE                 = DD.BOOK_TYPE_CODE
      AND     GAD.BOOK_TYPE_CODE                 = GAR.BOOK_TYPE_CODE
      AND     GAD.GROUP_ASSET_ID                 = GAR.GROUP_ASSET_ID
      AND     DD.PERIOD_COUNTER                  =
         (SELECT  max (DD_SUB.PERIOD_COUNTER)
          FROM    FA_DEPRN_DETAIL_MRC_V DD_SUB
          WHERE   DD_SUB.BOOK_TYPE_CODE   = book
          AND     DD_SUB.ASSET_ID         = GAR.GROUP_ASSET_ID
          AND     DD_SUB.PERIOD_COUNTER   <= upc
         )
     AND     DD.PERIOD_COUNTER                  = DP.PERIOD_COUNTER
     AND     DD.BOOK_TYPE_CODE                  = DP.BOOK_TYPE_CODE
     AND     GAR.DATE_EFFECTIVE                 <= DP.CALENDAR_PERIOD_CLOSE_DATE  -- mwoodwar
     AND     nvl(GAR.DATE_INEFFECTIVE, (DP.CALENDAR_PERIOD_CLOSE_DATE + 1))
        > DP.CALENDAR_PERIOD_CLOSE_DATE;  -- mwoodwar
   else
    INSERT INTO FA_RESERVE_LEDGER_GT
       (ASSET_ID,
        DH_CCID,
	DEPRN_RESERVE_ACCT,
        DATE_PLACED_IN_SERVICE,
        METHOD_CODE,
        LIFE,
	RATE,
	CAPACITY,
	COST,
	DEPRN_AMOUNT,
	YTD_DEPRN,
	DEPRN_RESERVE,
	PERCENT,
	TRANSACTION_TYPE,
	PERIOD_COUNTER,
	DATE_EFFECTIVE)
     SELECT
        GAR.GROUP_ASSET_ID		ASSET_ID,
        GAD.DEPRN_EXPENSE_ACCT_CCID  	CH_CCID,
	GAD.DEPRN_RESERVE_ACCT_CCID     RSV_ACCOUNT,
        GAR.DEPRN_START_DATE		START_DATE,
        GAR.DEPRN_METHOD_CODE		METHOD,
        GAR.LIFE_IN_MONTHS		LIFE,
        GAR.ADJUSTED_RATE		RATE,
	GAR.PRODUCTION_CAPACITY		CAPACITY,
        DD.ADJUSTED_COST		COST,
        decode (DD.PERIOD_COUNTER, upc, DD.DEPRN_AMOUNT, 0)
								DEPRN_AMOUNT,
        decode (sign (tpc - DD.PERIOD_COUNTER), 1, 0, DD.YTD_DEPRN)
								YTD_DEPRN,
        DD.DEPRN_RESERVE					DEPRN_RESERVE,
       /* round (decode (TH.TRANSACTION_TYPE_CODE, null,
			DH.UNITS_ASSIGNED / AH.UNITS * 100),2)
								PERCENT,
        decode (TH.TRANSACTION_TYPE_CODE, null,
		decode (TH_RT.TRANSACTION_TYPE_CODE,
			'FULL RETIREMENT', 'F',
			decode (BOOKS.DEPRECIATE_FLAG, 'NO', 'N')),
                'TRANSFER', 'T',
                'TRANSFER OUT', 'P',
		'RECLASS', 'R')					T_TYPE,
        DD.PERIOD_COUNTER,
        NVL(TH.DATE_EFFECTIVE, ucd) */
        100   PERCENT,
        'G' T_TYPE,
        DD.PERIOD_COUNTER,
        UCD
      FROM
        FA_DEPRN_SUMMARY         DD,
        FA_GROUP_ASSET_RULES    GAR,
        FA_GROUP_ASSET_DEFAULT  GAD,
        FA_DEPRN_PERIODS         DP
      WHERE
              DD.BOOK_TYPE_CODE                  = book
      AND     DD.ASSET_ID                        = GAR.GROUP_ASSET_ID
      AND     GAD.SUPER_GROUP_ID                 is null -- MPOWELL
      AND     GAR.BOOK_TYPE_CODE                 = DD.BOOK_TYPE_CODE
      AND     GAD.BOOK_TYPE_CODE                 = GAR.BOOK_TYPE_CODE
      AND     GAD.GROUP_ASSET_ID                 = GAR.GROUP_ASSET_ID
      AND     DD.PERIOD_COUNTER                  =
         (SELECT  max (DD_SUB.PERIOD_COUNTER)
          FROM    FA_DEPRN_DETAIL DD_SUB
          WHERE   DD_SUB.BOOK_TYPE_CODE   = book
          AND     DD_SUB.ASSET_ID         = GAR.GROUP_ASSET_ID
          AND     DD_SUB.PERIOD_COUNTER   <= upc
         )
     AND     DD.PERIOD_COUNTER                  = DP.PERIOD_COUNTER
     AND     DD.BOOK_TYPE_CODE                  = DP.BOOK_TYPE_CODE
     AND     GAR.DATE_EFFECTIVE                 <= DP.CALENDAR_PERIOD_CLOSE_DATE  -- mwoodwar
     AND     nvl(GAR.DATE_INEFFECTIVE, (DP.CALENDAR_PERIOD_CLOSE_DATE + 1))
        > DP.CALENDAR_PERIOD_CLOSE_DATE;  -- mwoodwar
   end if;
     -- Insert the SuperGroup Depreciation Details    MPOWELL
   if (h_reporting_flag = 'R') then
     INSERT INTO FA_RESERVE_LEDGER_GT
       (ASSET_ID,
        DH_CCID,
	DEPRN_RESERVE_ACCT,
        DATE_PLACED_IN_SERVICE,
        METHOD_CODE,
        LIFE,
	RATE,
	CAPACITY,
	COST,
	DEPRN_AMOUNT,
	YTD_DEPRN,
	DEPRN_RESERVE,
	PERCENT,
	TRANSACTION_TYPE,
	PERIOD_COUNTER,
	DATE_EFFECTIVE)
     SELECT
        GAR.GROUP_ASSET_ID		ASSET_ID,
        GAD.DEPRN_EXPENSE_ACCT_CCID  	DH_CCID,
	GAD.DEPRN_RESERVE_ACCT_CCID 	RSV_ACCOUNT,
        GAR.DEPRN_START_DATE		START_DATE,
        SGR.DEPRN_METHOD_CODE		METHOD,     -- MPOWELL
        GAR.LIFE_IN_MONTHS		LIFE,
        SGR.ADJUSTED_RATE		RATE,     -- MPOWELL
	GAR.PRODUCTION_CAPACITY		CAPACITY,
        DD.ADJUSTED_COST		COST,
        decode (DD.PERIOD_COUNTER, upc, DD.DEPRN_AMOUNT, 0)
					DEPRN_AMOUNT,
        decode (sign (tpc - DD.PERIOD_COUNTER), 1, 0, DD.YTD_DEPRN)
					YTD_DEPRN,
        DD.DEPRN_RESERVE		DEPRN_RESERVE,
        100   PERCENT,
        'G' T_TYPE,
        DD.PERIOD_COUNTER,
        UCD
     FROM    FA_DEPRN_SUMMARY_MRC_V     DD,
        fa_GROUP_ASSET_RULES    GAR,
        fa_GROUP_ASSET_DEFAULT  GAD,
        fa_SUPER_GROUP_RULES    SGR,
        FA_DEPRN_PERIODS_MRC_V  DP
     WHERE DD.BOOK_TYPE_CODE  = book
     AND   DD.ASSET_ID        = GAR.GROUP_ASSET_ID
     AND   GAR.BOOK_TYPE_CODE = DD.BOOK_TYPE_CODE
     AND   GAD.SUPER_GROUP_ID = SGR.SUPER_GROUP_ID -- MPOWELL
     AND   GAD.BOOK_TYPE_CODE = SGR.BOOK_TYPE_CODE -- MPOWELL
     AND   GAD.BOOK_TYPE_CODE = GAR.BOOK_TYPE_CODE
     AND   GAD.GROUP_ASSET_ID = GAR.GROUP_ASSET_ID
     AND   DD.PERIOD_COUNTER  =
         (SELECT  max (DD_SUB.PERIOD_COUNTER)
          FROM    FA_DEPRN_DETAIL_MRC_V DD_SUB
          WHERE   DD_SUB.BOOK_TYPE_CODE   = book
          AND     DD_SUB.ASSET_ID         = GAR.GROUP_ASSET_ID
          AND     DD_SUB.PERIOD_COUNTER   <= upc)
     AND   DD.PERIOD_COUNTER                  = DP.PERIOD_COUNTER
     AND   DD.BOOK_TYPE_CODE                  = DP.BOOK_TYPE_CODE
     AND   GAR.DATE_EFFECTIVE                 <= DP.CALENDAR_PERIOD_CLOSE_DATE
     AND   nvl(GAR.DATE_INEFFECTIVE, (DP.CALENDAR_PERIOD_CLOSE_DATE + 1))
      > DP.CALENDAR_PERIOD_CLOSE_DATE
     AND   SGR.DATE_EFFECTIVE                 <= DP.CALENDAR_PERIOD_CLOSE_DATE
     AND   nvl(SGR.DATE_INEFFECTIVE, (DP.CALENDAR_PERIOD_CLOSE_DATE + 1))
      > DP.CALENDAR_PERIOD_CLOSE_DATE;
    else
     INSERT INTO FA_RESERVE_LEDGER_GT
       (ASSET_ID,
        DH_CCID,
	DEPRN_RESERVE_ACCT,
        DATE_PLACED_IN_SERVICE,
        METHOD_CODE,
        LIFE,
	RATE,
	CAPACITY,
	COST,
	DEPRN_AMOUNT,
	YTD_DEPRN,
	DEPRN_RESERVE,
	PERCENT,
	TRANSACTION_TYPE,
	PERIOD_COUNTER,
	DATE_EFFECTIVE)
     SELECT
        GAR.GROUP_ASSET_ID		ASSET_ID,
        GAD.DEPRN_EXPENSE_ACCT_CCID  	DH_CCID,
	GAD.DEPRN_RESERVE_ACCT_CCID 	RSV_ACCOUNT,
        GAR.DEPRN_START_DATE		START_DATE,
        SGR.DEPRN_METHOD_CODE		METHOD,     -- MPOWELL
        GAR.LIFE_IN_MONTHS		LIFE,
        SGR.ADJUSTED_RATE		RATE,     -- MPOWELL
	GAR.PRODUCTION_CAPACITY		CAPACITY,
        DD.ADJUSTED_COST		COST,
        decode (DD.PERIOD_COUNTER, upc, DD.DEPRN_AMOUNT, 0)
					DEPRN_AMOUNT,
        decode (sign (tpc - DD.PERIOD_COUNTER), 1, 0, DD.YTD_DEPRN)
					YTD_DEPRN,
        DD.DEPRN_RESERVE		DEPRN_RESERVE,
        100   PERCENT,
        'G' T_TYPE,
        DD.PERIOD_COUNTER,
        UCD
     FROM    FA_DEPRN_SUMMARY         DD,
        fa_GROUP_ASSET_RULES    GAR,
        fa_GROUP_ASSET_DEFAULT  GAD,
        fa_SUPER_GROUP_RULES    SGR,
        FA_DEPRN_PERIODS         DP
     WHERE DD.BOOK_TYPE_CODE  = book
     AND   DD.ASSET_ID        = GAR.GROUP_ASSET_ID
     AND   GAR.BOOK_TYPE_CODE = DD.BOOK_TYPE_CODE
     AND   GAD.SUPER_GROUP_ID = SGR.SUPER_GROUP_ID -- MPOWELL
     AND   GAD.BOOK_TYPE_CODE = SGR.BOOK_TYPE_CODE -- MPOWELL
     AND   GAD.BOOK_TYPE_CODE = GAR.BOOK_TYPE_CODE
     AND   GAD.GROUP_ASSET_ID = GAR.GROUP_ASSET_ID
     AND   DD.PERIOD_COUNTER  =
         (SELECT  max (DD_SUB.PERIOD_COUNTER)
          FROM    FA_DEPRN_DETAIL DD_SUB
          WHERE   DD_SUB.BOOK_TYPE_CODE   = book
          AND     DD_SUB.ASSET_ID         = GAR.GROUP_ASSET_ID
          AND     DD_SUB.PERIOD_COUNTER   <= upc)
     AND   DD.PERIOD_COUNTER                  = DP.PERIOD_COUNTER
     AND   DD.BOOK_TYPE_CODE                  = DP.BOOK_TYPE_CODE
     AND   GAR.DATE_EFFECTIVE                 <= DP.CALENDAR_PERIOD_CLOSE_DATE
     AND   nvl(GAR.DATE_INEFFECTIVE, (DP.CALENDAR_PERIOD_CLOSE_DATE + 1))
      > DP.CALENDAR_PERIOD_CLOSE_DATE
     AND   SGR.DATE_EFFECTIVE                 <= DP.CALENDAR_PERIOD_CLOSE_DATE
     AND   nvl(SGR.DATE_INEFFECTIVE, (DP.CALENDAR_PERIOD_CLOSE_DATE + 1))
      > DP.CALENDAR_PERIOD_CLOSE_DATE;
    end if;
   end if;    --end of CRL check
--Added during DT Fix
COMMIT;
--End of DT Fix
exception
    when others then
        retcode := SQLCODE;
        errbuf := SQLERRM;
	--srw.message (1000, errbuf);
	--srw.message (1000, operation);
end ;
/*  FIX ENDS  */
END FA_FAS480_XMLP_PKG ;



/
