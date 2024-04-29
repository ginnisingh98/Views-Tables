--------------------------------------------------------
--  DDL for Package Body FA_FASCOSTS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FASCOSTS_XMLP_PKG" AS
/* $Header: FASCOSTSB.pls 120.0.12010000.1 2008/07/28 13:16:36 appldev ship $ */

function report_nameformula(Company_Name in varchar2) return varchar2 is
begin
 P_CONC_REQUEST_ID := fnd_global.CONC_REQUEST_ID;

DECLARE
  l_report_name VARCHAR2(80);
  l_conc_program_id NUMBER;
BEGIN
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
  Period_From := P_PERIOD1;
  Period_To := P_PERIOD2;

  RETURN(l_report_name);

EXCEPTION
  WHEN OTHERS THEN
IF (P_REPORT_TYPE = 'CIP COST') THEN
      RP_Report_Name := ':CIP Summary Report:';
ELSE  RP_Report_Name := ':Cost Summary Report:';
END IF;
Period_From := P_PERIOD1;
Period_To := P_PERIOD2;
RETURN(RP_REPORT_NAME);


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

BEGIN
  ROLLBACK;
EXCEPTION
  WHEN OTHERS THEN NULL;
END;  return (TRUE);
end;

function Period1_PCFormula return Number is
begin

DECLARE
  l_period_POD  DATE;
  l_period_PCD  DATE;
  l_period_PC   NUMBER(15);
  l_period_FY   NUMBER(15);
BEGIN



IF upper(p_mrcsobtype) = 'R'  then
  SELECT period_counter,
         period_open_date,
         nvl(period_close_date, sysdate),
         fiscal_year
  INTO   l_period_PC,
         l_period_POD,
         l_period_PCD,
         l_period_FY
  FROM   FA_DEPRN_PERIODS_MRC_V
  WHERE  book_type_code = P_BOOK
  AND    period_name    = P_PERIOD1;
else
  SELECT period_counter,
         period_open_date,
         nvl(period_close_date, sysdate),
         fiscal_year
  INTO   l_period_PC,
         l_period_POD,
         l_period_PCD,
         l_period_FY
  FROM   FA_DEPRN_PERIODS
  WHERE  book_type_code = P_BOOK
  AND    period_name    = P_PERIOD1;
end if;

  Period1_POD := l_period_POD;
  Period1_PCD := l_period_PCD;
  Period1_FY  := l_period_FY;
  return(l_period_PC);
END;
RETURN NULL; end;

function Period2_PCFormula return Number is
begin

DECLARE
  l_period_POD  DATE;
  l_period_PCD  DATE;
  l_period_PC   NUMBER(15);
  l_period_FY   NUMBER(15);
BEGIN



IF upper(p_mrcsobtype) = 'R'  then
  SELECT period_counter,
         period_open_date,
         nvl(period_close_date, sysdate),
         fiscal_year
  INTO   l_period_PC,
         l_period_POD,
         l_period_PCD,
         l_period_FY
  FROM   FA_DEPRN_PERIODS_MRC_V
  WHERE  book_type_code = P_BOOK
  AND    period_name    = P_PERIOD2;
else
  SELECT period_counter,
         period_open_date,
         nvl(period_close_date, sysdate),
         fiscal_year
  INTO   l_period_PC,
         l_period_POD,
         l_period_PCD,
         l_period_FY
  FROM   FA_DEPRN_PERIODS
  WHERE  book_type_code = P_BOOK
  AND    period_name    = P_PERIOD2;
end if;

  Period2_POD := l_period_POD;
  Period2_PCD := l_period_PCD;
  Period2_FY  := l_period_FY;
  return(l_period_PC);
END;
RETURN NULL; end;

function DO_INSERTFormula return Number is
begin

BEGIN
IF (P_REPORT_TYPE = 'COST' OR P_REPORT_TYPE = 'CIP COST') THEN
	Insert_Info (P_BOOK, P_PERIOD1,
		P_PERIOD2, P_REPORT_TYPE, P_ADJ_MODE);
RETURN(1);
ELSE RETURN(0);
END IF;
END;
RETURN NULL; end;

function out_of_balanceformula(BEGIN_P in number, ADDITION in number, REVALUATION in number, RECLASS in number, RETIREMENT in number, ADJUSTMENT in number, TRANSFER in number, CAPITALIZATION in number, END_P in number) return varchar2 is
begin

DECLARE

MOCK_TOTAL	NUMBER;

BEGIN

MOCK_TOTAL := NVL(BEGIN_P,0) + NVL(ADDITION,0) + NVL(REVALUATION,0)
	 + NVL(RECLASS,0) - NVL(RETIREMENT,0) + NVL(ADJUSTMENT,0)
	+ NVL(TRANSFER,0) - NVL(CAPITALIZATION,0);

IF (MOCK_TOTAL = NVL(END_P,0))
THEN RETURN (' ');
ELSE RETURN('*');
END IF;
END;
RETURN NULL; end;

function acct_out_of_balanceformula(ACCT_BEGIN in number, ACCT_ADD in number, ACCT_REVAL in number, ACCT_RECLASS in number, ACCT_RETIRE in number, ACCT_ADJUST in number, ACCT_TRANS in number, ACCT_CAPITAL in number, ACCT_END in number)
return varchar2 is
begin

DECLARE

MOCK_TOTAL	NUMBER;

BEGIN

MOCK_TOTAL := NVL(ACCT_BEGIN,0) + NVL(ACCT_ADD,0) + NVL(ACCT_REVAL,0)
	 + NVL(ACCT_RECLASS,0) - NVL(ACCT_RETIRE,0) + NVL(ACCT_ADJUST,0)
	+ NVL(ACCT_TRANS,0) - NVL(ACCT_CAPITAL,0);

IF (MOCK_TOTAL = NVL(ACCT_END,0))
THEN RETURN (' ');
ELSE RETURN('*');
END IF;
END;
RETURN NULL; end;

function bal_out_of_balanceformula(BAL_BEGIN in number, BAL_ADD in number, BAL_REVAL in number, BAL_RECLASS in number, BAL_RETIRE in number, BAL_ADJUST in number, BAL_TRANS in number, BAL_CAPITAL in number, BAL_END in number) return varchar2 is
begin

DECLARE

MOCK_TOTAL	NUMBER;

BEGIN

MOCK_TOTAL := NVL(BAL_BEGIN,0) + NVL(BAL_ADD,0) + NVL(BAL_REVAL,0)
	 + NVL(BAL_RECLASS,0) - NVL(BAL_RETIRE,0) + NVL(BAL_ADJUST,0)
	+ NVL(BAL_TRANS,0) - NVL(BAL_CAPITAL,0);

IF (MOCK_TOTAL = NVL(BAL_END,0))
THEN RETURN (' ');
ELSE RETURN('*');
END IF;
END;
RETURN NULL; end;

function rp_out_of_balanceformula(RP_BEGIN in number, RP_ADD in number, RP_REVAL in number, RP_RECLASS in number, RP_RETIRE in number, RP_ADJUST in number, RP_TRANS in number, RP_CAPITAL in number, RP_END in number) return varchar2 is
begin

DECLARE

MOCK_TOTAL	NUMBER;

BEGIN

MOCK_TOTAL := NVL(RP_BEGIN,0) + NVL(RP_ADD,0) + NVL(RP_REVAL,0)
	 + NVL(RP_RECLASS,0) - NVL(RP_RETIRE,0) + NVL(RP_ADJUST,0)
	+ NVL(RP_TRANS,0) - NVL(RP_CAPITAL,0);

IF (MOCK_TOTAL = NVL(RP_END,0))
THEN RETURN (' ');
ELSE RETURN('*');
END IF;
END;
RETURN NULL; end;

function caprevalformula(REVALUATION in number, CAPITALIZATION in number) return number is
begin

IF (P_REPORT_TYPE = 'COST') THEN
   RETURN(REVALUATION);
ELSE
   RETURN(CAPITALIZATION);
END IF;
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
  lp_fa_book_controls := 'FA_BOOK_CONTROLS_MRC_V';
ELSE
  lp_fa_book_controls := 'FA_BOOK_CONTROLS';
END IF;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function ACCT_BAL_APROMPT_p return varchar2 is
	Begin
	 return ACCT_BAL_APROMPT;
	 END;
 Function ACCT_CC_APROMPT_p return varchar2 is
	Begin
	 return ACCT_CC_APROMPT;
	 END;
 Function CAT_MAJ_RPROMPT_p return varchar2 is
	Begin
	 return CAT_MAJ_RPROMPT;
	 END;
 Function Period1_POD_p return date is
	Begin
	 return Period1_POD;
	 END;
 Function Period1_PCD_p return date is
	Begin
	 return Period1_PCD;
	 END;
 Function Period1_FY_p return number is
	Begin
	 return Period1_FY;
	 END;
 Function Period2_POD_p return date is
	Begin
	 return Period2_POD;
	 END;
 Function Period2_PCD_p return date is
	Begin
	 return Period2_PCD;
	 END;
 Function Period2_FY_p return number is
	Begin
	 return Period2_FY;
	 END;
 Function RP_COMPANY_NAME_p return varchar2 is
	Begin
	 return RP_COMPANY_NAME;
	 END;
 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return RP_REPORT_NAME;
	 END;
	 --MODIFIED
 Function RP_BAL_LPROMPT_p(ACCT_BAL_LPROMPT VARCHAR2) return varchar2 is
	Begin
RP_BAL_LPROMPT:=ACCT_BAL_LPROMPT;
	 return RP_BAL_LPROMPT;
	 END;
 Function RP_CTR_APROMPT_p return varchar2 is
	Begin
	 return RP_CTR_APROMPT;
	 END;
 Function PERIOD_FROM_p return varchar2 is
	Begin
	 return PERIOD_FROM;
	 END;
 Function PERIOD_TO_p return varchar2 is
	Begin
	 return PERIOD_TO;
	 END;
 Function LP_FA_BOOK_CONTROLS_P return varchar2 is
	Begin
	 return LP_FA_BOOK_CONTROLS;
	 END;




	 --added during the pls compilation--


procedure Get_Adjustments
   (Book	in	varchar2,
    Distribution_Source_Book in varchar2,
    Period1_PC	in	number,
    Period2_PC	in	number,
    Report_Type	in	varchar2,
    Balance_Type in	varchar2)
  is

  --Added during DT Fix
PRAGMA AUTONOMOUS_TRANSACTION;
--End of DT Fix
     h_set_of_books_id  number;
     h_reporting_flag   varchar2(1);
 begin

  -- get mrc related info
  begin
    -- h_set_of_books_id := to_number(substrb(userenv('CLIENT_INFO'),45,10));
    select to_number(substrb(userenv('CLIENT_INFO'),45,10))
    into h_set_of_books_id from dual;

    if (h_set_of_books_id = -1)   then
       h_set_of_books_id := null;
    end if;

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
   select set_of_books_id
     into h_set_of_books_id
     from fa_book_controls
    where book_type_code = book;

    h_reporting_flag := 'P';
  end if;

  -- Fix for Bug #1892406.  Run only if CRL not installed.
  If (nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'N' ) then


   if (h_reporting_flag = 'R') then

    INSERT INTO FA_BALANCES_REPORT_GT
       (Asset_ID,
        Distribution_CCID,
        Adjustment_CCID,
        Category_Books_Account,
        Source_Type_Code,
        Amount)
    SELECT
        DH.Asset_ID,
        DH.Code_Combination_ID,
        lines.code_combination_id, --AJ.Code_Combination_ID,
        null,
        AJ.Source_Type_Code,
        SUM (DECODE (AJ.Debit_Credit_Flag, Balance_Type, 1, -1) *
                AJ.Adjustment_Amount)
    FROM
        FA_LOOKUPS              RT,
        FA_DISTRIBUTION_HISTORY DH,
        FA_TRANSACTION_HEADERS  TH,
        FA_ASSET_HISTORY        AH,
        FA_ADJUSTMENTS_MRC_V    AJ

        /* SLA Changes */
        ,xla_ae_headers headers
        ,xla_ae_lines lines
        ,xla_distribution_links links
    WHERE
        RT.Lookup_Type          = 'REPORT TYPE' AND
        RT.Lookup_Code          = Report_Type
    AND
        DH.Book_Type_Code       = Distribution_Source_Book
    AND
        AJ.Asset_ID             = DH.Asset_ID           AND
        AJ.Book_Type_Code       = Book                  AND
        AJ.Distribution_ID      = DH.Distribution_ID    AND
        AJ.Adjustment_Type      in
                (Report_Type, DECODE(Report_Type,
                        'REVAL RESERVE', 'REVAL AMORT')) AND
        AJ.Period_Counter_Created BETWEEN
                        Period1_PC AND Period2_PC
    AND
        TH.Transaction_Header_ID        = AJ.Transaction_Header_ID
    AND
        AH.Asset_ID             = DH.Asset_ID           AND
        ((AH.Asset_Type         <> 'EXPENSED' AND
                Report_Type IN ('COST', 'CIP COST')) OR
         (AH.Asset_Type in ('CAPITALIZED','CIP') AND
                Report_Type IN ('RESERVE', 'REVAL RESERVE')))   AND
        TH.Transaction_Header_ID BETWEEN
                AH.Transaction_Header_ID_In AND
                NVL (AH.Transaction_Header_ID_Out - 1,
                        TH.Transaction_Header_ID)
    AND
        (DECODE (RT.Lookup_Code, AJ.Adjustment_Type, 1, 0) *
                AJ.Adjustment_Amount) <> 0

    /* SLA Changes */
    and links.Source_distribution_id_num_1 = aj.transaction_header_id
    and links.Source_distribution_id_num_2 = aj.adjustment_line_id
    and links.application_id               = 140
    and links.source_distribution_type     = 'TRX'
    and headers.application_id             = 140
    and headers.ae_header_id               = links.ae_header_id
    and headers.ledger_id                  = h_set_of_books_id
    and lines.ae_header_id                 = links.ae_header_id
    and lines.ae_line_num                  = links.ae_line_num
    and lines.application_id               = 140
    GROUP BY
        DH.Asset_ID,
        DH.Code_Combination_ID,
        lines.code_combination_id, --AJ.Code_Combination_ID,
        AJ.Source_Type_Code;

   else

    INSERT INTO FA_BALANCES_REPORT_GT
       (Asset_ID,
        Distribution_CCID,
        Adjustment_CCID,
        Category_Books_Account,
        Source_Type_Code,
        Amount)
    SELECT
        DH.Asset_ID,
        DH.Code_Combination_ID,
        lines.code_combination_id, --AJ.Code_Combination_ID,
        null,
        AJ.Source_Type_Code,
        SUM (DECODE (AJ.Debit_Credit_Flag, Balance_Type, 1, -1) *
                AJ.Adjustment_Amount)
    FROM
        FA_LOOKUPS              RT,
        FA_DISTRIBUTION_HISTORY DH,
        FA_TRANSACTION_HEADERS  TH,
        FA_ASSET_HISTORY        AH,
        FA_ADJUSTMENTS          AJ

        /* SLA Changes */
        ,xla_ae_headers headers
        ,xla_ae_lines lines
        ,xla_distribution_links links

    WHERE
        RT.Lookup_Type          = 'REPORT TYPE' AND
        RT.Lookup_Code          = Report_Type
    AND
        DH.Book_Type_Code       = Distribution_Source_Book
    AND
        AJ.Asset_ID             = DH.Asset_ID           AND
        AJ.Book_Type_Code       = Book                  AND
        AJ.Distribution_ID      = DH.Distribution_ID    AND
        AJ.Adjustment_Type      in
                (Report_Type, DECODE(Report_Type,
                        'REVAL RESERVE', 'REVAL AMORT')) AND
        AJ.Period_Counter_Created BETWEEN
                        Period1_PC AND Period2_PC
    AND
        TH.Transaction_Header_ID        = AJ.Transaction_Header_ID
    AND
        AH.Asset_ID             = DH.Asset_ID           AND
        ((AH.Asset_Type         <> 'EXPENSED' AND
                Report_Type IN ('COST', 'CIP COST')) OR
         (AH.Asset_Type  in ('CAPITALIZED','CIP') AND
                Report_Type IN ('RESERVE', 'REVAL RESERVE')))   AND
        TH.Transaction_Header_ID BETWEEN
                AH.Transaction_Header_ID_In AND
                NVL (AH.Transaction_Header_ID_Out - 1,
                        TH.Transaction_Header_ID)
    AND
        (DECODE (RT.Lookup_Code, AJ.Adjustment_Type, 1, 0) *
                AJ.Adjustment_Amount) <> 0

    /* SLA Changes */
    and links.Source_distribution_id_num_1 = aj.transaction_header_id
    and links.Source_distribution_id_num_2 = aj.adjustment_line_id
    and links.application_id               = 140
    and links.source_distribution_type     = 'TRX'
    and headers.application_id             = 140
    and headers.ae_header_id               = links.ae_header_id
    and headers.ledger_id                  = h_set_of_books_id
    and lines.ae_header_id                 = links.ae_header_id
    and lines.ae_line_num                  = links.ae_line_num
    and lines.application_id               = 140
    GROUP BY
        DH.Asset_ID,
        DH.Code_Combination_ID,
        lines.code_combination_id, --AJ.Code_Combination_ID,
        AJ.Source_Type_Code;
   end if;

  -- Fix for Bug #1892406.  Run only if CRL installed.
  elsif (nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y' ) then

   if (h_reporting_flag = 'R') then

    INSERT INTO FA_BALANCES_REPORT_GT
       (Asset_ID,
	Distribution_CCID,
	Adjustment_CCID,
	Category_Books_Account,
	Source_Type_Code,
	Amount)
    SELECT
	DH.Asset_ID,
	DH.Code_Combination_ID,
	lines.code_combination_id, --AJ.Code_Combination_ID,
	null,
	AJ.Source_Type_Code,
	SUM (DECODE (AJ.Debit_Credit_Flag, Balance_Type, 1, -1) *
		AJ.Adjustment_Amount)
    FROM
	FA_LOOKUPS		RT,
	FA_DISTRIBUTION_HISTORY	DH,
	FA_TRANSACTION_HEADERS	TH,
	FA_ASSET_HISTORY	AH,
	FA_ADJUSTMENTS_MRC_V	AJ

        /* SLA Changes */
        ,xla_ae_headers headers
        ,xla_ae_lines lines
        ,xla_distribution_links links

    WHERE
	RT.Lookup_Type		= 'REPORT TYPE' AND
	RT.Lookup_Code		= Report_Type
    AND
	DH.Book_Type_Code	= Distribution_Source_Book
    AND
	AJ.Asset_ID		= DH.Asset_ID		AND
	AJ.Book_Type_Code	= Book			AND
	AJ.Distribution_ID	= DH.Distribution_ID	AND
	AJ.Adjustment_Type	in
		(Report_Type, DECODE(Report_Type,
			'REVAL RESERVE', 'REVAL AMORT')) AND
	AJ.Period_Counter_Created BETWEEN
			Period1_PC AND Period2_PC
    AND
	TH.Transaction_Header_ID	= AJ.Transaction_Header_ID
    AND
	AH.Asset_ID		= DH.Asset_ID		AND
	((AH.Asset_Type		<> 'EXPENSED' AND
		Report_Type IN ('COST', 'CIP COST')) OR
	 (AH.Asset_Type	in ('CAPITALIZED','CIP') AND
		Report_Type IN ('RESERVE', 'REVAL RESERVE')))	AND
	TH.Transaction_Header_ID BETWEEN
		AH.Transaction_Header_ID_In AND
		NVL (AH.Transaction_Header_ID_Out - 1,
			TH.Transaction_Header_ID)
    AND
	(DECODE (RT.Lookup_Code, AJ.Adjustment_Type, 1, 0) *
		AJ.Adjustment_Amount) <> 0
         -- start of cua
               and not exists ( select 'x' from fa_books_mrc_v bks
                                        where bks.book_type_code = Book
                                        and   bks.asset_id = aj.asset_id
                                        and   bks.group_asset_id is not null
                                        and   bks.date_ineffective is not null )
         -- end of cua
    /* SLA Changes */
    and links.Source_distribution_id_num_1 = aj.transaction_header_id
    and links.Source_distribution_id_num_2 = aj.adjustment_line_id
    and links.application_id               = 140
    and links.source_distribution_type     = 'TRX'
    and headers.application_id             = 140
    and headers.ae_header_id               = links.ae_header_id
    and headers.ledger_id                  = h_set_of_books_id
    and lines.ae_header_id                 = links.ae_header_id
    and lines.ae_line_num                  = links.ae_line_num
    and lines.application_id               = 140    GROUP BY
	DH.Asset_ID,
	DH.Code_Combination_ID,
	lines.code_combination_id, --AJ.Code_Combination_ID,
	AJ.Source_Type_Code;

   else

    INSERT INTO FA_BALANCES_REPORT_GT
       (Asset_ID,
	Distribution_CCID,
	Adjustment_CCID,
	Category_Books_Account,
	Source_Type_Code,
	Amount)
    SELECT
	DH.Asset_ID,
	DH.Code_Combination_ID,
	lines.code_combination_id, --AJ.Code_Combination_ID,
	null,
	AJ.Source_Type_Code,
	SUM (DECODE (AJ.Debit_Credit_Flag, Balance_Type, 1, -1) *
		AJ.Adjustment_Amount)
    FROM
	FA_LOOKUPS		RT,
	FA_DISTRIBUTION_HISTORY	DH,
	FA_TRANSACTION_HEADERS	TH,
	FA_ASSET_HISTORY	AH,
	FA_ADJUSTMENTS   	AJ

        /* SLA Changes */
        ,xla_ae_headers headers
        ,xla_ae_lines lines
        ,xla_distribution_links links

    WHERE
	RT.Lookup_Type		= 'REPORT TYPE' AND
	RT.Lookup_Code		= Report_Type
    AND
	DH.Book_Type_Code	= Distribution_Source_Book
    AND
	AJ.Asset_ID		= DH.Asset_ID		AND
	AJ.Book_Type_Code	= Book			AND
	AJ.Distribution_ID	= DH.Distribution_ID	AND
	AJ.Adjustment_Type	in
		(Report_Type, DECODE(Report_Type,
			'REVAL RESERVE', 'REVAL AMORT')) AND
	AJ.Period_Counter_Created BETWEEN
			Period1_PC AND Period2_PC
    AND
	TH.Transaction_Header_ID	= AJ.Transaction_Header_ID
    AND
	AH.Asset_ID		= DH.Asset_ID		AND
	((AH.Asset_Type		<> 'EXPENSED' AND
		Report_Type IN ('COST', 'CIP COST')) OR
	 (AH.Asset_Type	in ('CAPITALIZED','CIP') AND
		Report_Type IN ('RESERVE', 'REVAL RESERVE')))	AND
	TH.Transaction_Header_ID BETWEEN
		AH.Transaction_Header_ID_In AND
		NVL (AH.Transaction_Header_ID_Out - 1,
			TH.Transaction_Header_ID)
    AND
	(DECODE (RT.Lookup_Code, AJ.Adjustment_Type, 1, 0) *
		AJ.Adjustment_Amount) <> 0
         -- start of cua
               and not exists ( select 'x' from fa_books bks
                                        where bks.book_type_code = Book
                                        and   bks.asset_id = aj.asset_id
                                        and   bks.group_asset_id is not null
                                        and   bks.date_ineffective is not null )
         -- end of cua
    /* SLA Changes */
    and links.Source_distribution_id_num_1 = aj.transaction_header_id
    and links.Source_distribution_id_num_2 = aj.adjustment_line_id
    and links.application_id               = 140
    and links.source_distribution_type     = 'TRX'
    and headers.application_id             = 140
    and headers.ae_header_id               = links.ae_header_id
    and headers.ledger_id                  = h_set_of_books_id
    and lines.ae_header_id                 = links.ae_header_id
    and lines.ae_line_num                  = links.ae_line_num
    and lines.application_id               = 140
    GROUP BY
	DH.Asset_ID,
	DH.Code_Combination_ID,
	lines.code_combination_id, --AJ.Code_Combination_ID,
	AJ.Source_Type_Code;

   end if;

  end if;

    IF REPORT_TYPE = 'RESERVE' then
     if (h_reporting_flag = 'R') then
	insert into FA_BALANCES_REPORT_GT
	(Asset_id,
	Distribution_CCID,
	Adjustment_CCID,
	Category_books_account,
	Source_type_code,
	amount)
	SELECT
	dh.asset_id,
	dh.code_combination_id,
	null,
	CB.Deprn_Reserve_Acct,
	'ADDITION',
	sum(DD.DEPRN_RESERVE)
	FROM FA_DISTRIBUTION_HISTORY DH,
	     FA_CATEGORY_BOOKS CB,
	     FA_ASSET_HISTORY AH,
	     FA_DEPRN_DETAIL_MRC_V DD
	WHERE NOT EXISTS (SELECT ASSET_ID
                          FROM  FA_BALANCES_REPORT_GT
                          WHERE ASSET_ID = DH.ASSET_ID
                          AND   DISTRIBUTION_CCID = DH.CODE_COMBINATION_ID
                          AND   SOURCE_TYPE_CODE = 'ADDITION')
        AND   DD.BOOK_TYPE_CODE = BOOK
	AND   (DD.PERIOD_COUNTER+1) BETWEEN
		PERIOD1_PC AND PERIOD2_PC
	AND   DD.DEPRN_SOURCE_CODE = 'B'
	AND   DD.ASSET_ID = DH.ASSET_ID
	AND   DD.DEPRN_RESERVE <> 0
	AND   DD.DISTRIBUTION_ID = DH.DISTRIBUTION_ID
	AND   DH.ASSET_ID = AH.ASSET_ID
	AND   AH.DATE_EFFECTIVE <
			NVL(DH.DATE_INEFFECTIVE, SYSDATE)
	AND   NVL(DH.DATE_INEFFECTIVE,SYSDATE) <=
			NVL(AH.DATE_INEFFECTIVE,SYSDATE)
	AND   DD.BOOK_TYPE_CODE = CB.BOOK_TYPE_CODE
	AND   AH.CATEGORY_ID = CB.CATEGORY_ID
	GROUP BY
	Dh.ASSET_ID,
	DH.CODE_COMBINATION_ID,
	CB.DEPRN_RESERVE_ACCT;
      else
	insert into FA_BALANCES_REPORT_GT
	(Asset_id,
	Distribution_CCID,
	Adjustment_CCID,
	Category_books_account,
	Source_type_code,
	amount)
	SELECT
	dh.asset_id,
	dh.code_combination_id,
	null,
	CB.Deprn_Reserve_Acct,
	'ADDITION',
	sum(DD.DEPRN_RESERVE)
	FROM FA_DISTRIBUTION_HISTORY DH,
	     FA_CATEGORY_BOOKS CB,
	     FA_ASSET_HISTORY AH,
	     FA_DEPRN_DETAIL DD
	WHERE NOT EXISTS (SELECT ASSET_ID
                          FROM  FA_BALANCES_REPORT_GT
                          WHERE ASSET_ID = DH.ASSET_ID
                          AND   DISTRIBUTION_CCID = DH.CODE_COMBINATION_ID
                          AND   SOURCE_TYPE_CODE = 'ADDITION')
        AND   DD.BOOK_TYPE_CODE = BOOK
	AND   (DD.PERIOD_COUNTER+1) BETWEEN
		PERIOD1_PC AND PERIOD2_PC
	AND   DD.DEPRN_SOURCE_CODE = 'B'
	AND   DD.ASSET_ID = DH.ASSET_ID
	AND   DD.DEPRN_RESERVE <> 0
	AND   DD.DISTRIBUTION_ID = DH.DISTRIBUTION_ID
	AND   DH.ASSET_ID = AH.ASSET_ID
	AND   AH.DATE_EFFECTIVE <
			NVL(DH.DATE_INEFFECTIVE, SYSDATE)
	AND   NVL(DH.DATE_INEFFECTIVE,SYSDATE) <=
			NVL(AH.DATE_INEFFECTIVE,SYSDATE)
	AND   DD.BOOK_TYPE_CODE = CB.BOOK_TYPE_CODE
	AND   AH.CATEGORY_ID = CB.CATEGORY_ID
	GROUP BY
	Dh.ASSET_ID,
	DH.CODE_COMBINATION_ID,
	CB.DEPRN_RESERVE_ACCT;
      end if;

    end if;
    --Added during DT Fix
commit;
--End of DT Fix

  end Get_Adjustments;


PROCEDURE get_adjustments_for_group
   (Book	in	varchar2,
    Distribution_Source_Book in varchar2,
    Period1_PC	in	number,
    Period2_PC	in	number,
    Report_Type	in	varchar2,
    Balance_Type in	varchar2)
  is
  --Added during DT Fix
PRAGMA AUTONOMOUS_TRANSACTION;
--End of DT Fix
     h_set_of_books_id  number;
     h_reporting_flag   varchar2(1);
  begin

  -- get mrc related info
  begin
    --h_set_of_books_id := to_number(substrb(userenv('CLIENT_INFO'),45,10));
    select to_number(substrb(userenv('CLIENT_INFO'),45,10))
    into h_set_of_books_id from dual;

    if (h_set_of_books_id = -1) then
       h_set_of_books_id := null;
    end if;

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
   select set_of_books_id
     into h_set_of_books_id
     from fa_book_controls
    where book_type_code = book;

    h_reporting_flag := 'P';
  end if;

  -- run only if CRL installed
  if ( nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y') then

   if (h_reporting_flag = 'R') then

    INSERT INTO FA_BALANCES_REPORT_GT
       (Asset_ID,
	Distribution_CCID,
	Adjustment_CCID,
	Category_Books_Account,
	Source_Type_Code,
	Amount)
    SELECT
	AJ.Asset_ID,
        -- Changed for BMA1
        -- nvl(GAD.DEPRN_EXPENSE_ACCT_CCID, -2000),
        GAD.DEPRN_EXPENSE_ACCT_CCID,
	decode(aj.adjustment_type,'COST',GAD.ASSET_COST_ACCT_CCID,lines.code_combination_id /*AJ.Code_Combination_ID*/ ),
	null,
	AJ.Source_Type_Code,
	SUM (DECODE (AJ.Debit_Credit_Flag, Balance_Type, 1, -1) *
		AJ.Adjustment_Amount)
    FROM
	FA_LOOKUPS		RT,
	FA_ADJUSTMENTS_MRC_V	AJ,
        fa_books_mrc_v          bk,
        fa_group_asset_default  gad

        /* SLA Changes */
        ,xla_ae_headers headers
        ,xla_ae_lines lines
        ,xla_distribution_links links
    WHERE
        bk.asset_id = aj.asset_id
        and bk.book_type_code = book
        and bk.group_asset_id = gad.group_asset_id
        and bk.book_type_code = gad.book_type_code
        and bk.date_ineffective is null
	and aj.asset_id in (select asset_id from fa_books_mrc_v
                         where group_asset_id is not null
                              and date_ineffective is null)
     and
        RT.Lookup_Type		= 'REPORT TYPE' AND
	RT.Lookup_Code		= Report_Type
    AND
	AJ.Asset_ID		= BK.Asset_ID		AND
	AJ.Book_Type_Code	= Book			AND
	AJ.Adjustment_Type	in
		(Report_Type, DECODE(Report_Type,
			'REVAL RESERVE', 'REVAL AMORT')) AND
	AJ.Period_Counter_Created BETWEEN
			Period1_PC AND Period2_PC
    	AND
	(DECODE (RT.Lookup_Code, AJ.Adjustment_Type, 1, 0) *
		AJ.Adjustment_Amount) <> 0

    /* SLA Changes */
    and links.Source_distribution_id_num_1 = aj.transaction_header_id
    and links.Source_distribution_id_num_2 = aj.adjustment_line_id
    and links.application_id               = 140
    and links.source_distribution_type     = 'TRX'
    and headers.application_id             = 140
    and headers.ae_header_id               = links.ae_header_id
    and headers.ledger_id                  = h_set_of_books_id
    and lines.ae_header_id                 = links.ae_header_id
    and lines.ae_line_num                  = links.ae_line_num
    and lines.application_id               = 140
    GROUP BY
	AJ.Asset_ID,
        -- Changed for BMA1
        -- nvl(GAD.DEPRN_EXPENSE_ACCT_CCID, -2000),
        GAD.DEPRN_EXPENSE_ACCT_CCID,
	decode(aj.adjustment_type,'COST',GAD.ASSET_COST_ACCT_CCID,lines.code_combination_id /*AJ.Code_Combination_ID*/ ),
	aJ.Source_Type_Code;
   else

    INSERT INTO FA_BALANCES_REPORT_GT
       (Asset_ID,
	Distribution_CCID,
	Adjustment_CCID,
	Category_Books_Account,
	Source_Type_Code,
	Amount)
    SELECT
	AJ.Asset_ID,
        -- Changed for BMA1
        -- nvl(GAD.DEPRN_EXPENSE_ACCT_CCID, -2000),
        GAD.DEPRN_EXPENSE_ACCT_CCID,
	decode(aj.adjustment_type,'COST',GAD.ASSET_COST_ACCT_CCID,lines.code_combination_id /*AJ.Code_Combination_ID*/ ),
	null,
	AJ.Source_Type_Code,
	SUM (DECODE (AJ.Debit_Credit_Flag, Balance_Type, 1, -1) *
		AJ.Adjustment_Amount)
    FROM
	FA_LOOKUPS		RT,
	FA_ADJUSTMENTS		AJ,
        fa_books                bk,
        fa_group_asset_default  gad

        /* SLA Changes */
        ,xla_ae_headers headers
        ,xla_ae_lines lines
        ,xla_distribution_links links
    WHERE
        bk.asset_id = aj.asset_id
        and bk.book_type_code = book
        and bk.group_asset_id = gad.group_asset_id
        and bk.book_type_code = gad.book_type_code
        and bk.date_ineffective is null
	and aj.asset_id in (select asset_id from fa_books
                         where group_asset_id is not null
                              and date_ineffective is null)
     and
        RT.Lookup_Type		= 'REPORT TYPE' AND
	RT.Lookup_Code		= Report_Type
    AND
	AJ.Asset_ID		= BK.Asset_ID		AND
	AJ.Book_Type_Code	= Book			AND
	AJ.Adjustment_Type	in
		(Report_Type, DECODE(Report_Type,
			'REVAL RESERVE', 'REVAL AMORT')) AND
	AJ.Period_Counter_Created BETWEEN
			Period1_PC AND Period2_PC
    	AND
	(DECODE (RT.Lookup_Code, AJ.Adjustment_Type, 1, 0) *
		AJ.Adjustment_Amount) <> 0

    /* SLA Changes */
    and links.Source_distribution_id_num_1 = aj.transaction_header_id
    and links.Source_distribution_id_num_2 = aj.adjustment_line_id
    and links.application_id               = 140
    and links.source_distribution_type     = 'TRX'
    and headers.application_id             = 140
    and headers.ae_header_id               = links.ae_header_id
    and headers.ledger_id                  = h_set_of_books_id
    and lines.ae_header_id                 = links.ae_header_id
    and lines.ae_line_num                  = links.ae_line_num
    and lines.application_id               = 140
    GROUP BY
	AJ.Asset_ID,
        -- Changed for BMA1
        -- nvl(GAD.DEPRN_EXPENSE_ACCT_CCID, -2000),
        GAD.DEPRN_EXPENSE_ACCT_CCID,
	decode(aj.adjustment_type,'COST',GAD.ASSET_COST_ACCT_CCID,lines.code_combination_id  /* AJ.Code_Combination_ID*/ ),
	aJ.Source_Type_Code;
    end if;


   end if;
    --Added during DT Fix
	commit;
--End of DT Fix

  end Get_Adjustments_for_group;


procedure Get_Balance
   (Book	in	varchar2,
    Distribution_Source_Book in varchar2,
    Period_PC	in	number,
    Earliest_PC	in	number,
    Period_Date	in	date,
    Additions_Date in	date,
    Report_Type	in	varchar2,
    Balance_Type in	varchar2,
    Begin_or_End in	varchar2)
  is

  --Added during DT Fix
PRAGMA AUTONOMOUS_TRANSACTION;
--End of DT Fix

     P_Date date := Period_Date;
     A_Date date := Additions_Date;
     h_set_of_books_id  number;
     h_reporting_flag   varchar2(1);
  begin

  -- get mrc related info
  begin
    -- h_set_of_books_id := to_number(substrb(userenv('CLIENT_INFO'),45,10));
    select to_number(substrb(userenv('CLIENT_INFO'),45,10))
    into h_set_of_books_id from dual;

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


  -- Fix for Bug #1892406.  Run only if CRL not installed.
  If (nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'N' ) then

   if (h_reporting_flag = 'R') then

    INSERT INTO FA_BALANCES_REPORT_GT
       (Asset_ID,
        Distribution_CCID,
        Adjustment_CCID,
        Category_Books_Account,
        Source_Type_Code,
        Amount)
    SELECT
        DH.Asset_ID,
        DH.Code_Combination_ID,
        null,
        DECODE (Report_Type,
                'COST', CB.Asset_Cost_Acct,
                'CIP COST', CB.CIP_Cost_Acct,
                'RESERVE', CB.Deprn_Reserve_Acct,
                'REVAL RESERVE', CB.Reval_Reserve_Acct),
        DECODE(Report_Type,
                'RESERVE', DECODE(DD.Deprn_Source_Code,
                        'D', Begin_or_End, 'ADDITION'),
                'REVAL RESERVE',
        DECODE(DD.Deprn_Source_Code,
                        'D', Begin_or_End, 'ADDITION'),
                Begin_or_End),
        DECODE (Report_Type,
                'COST', DD.Cost,
                'CIP COST', DD.Cost,
                'RESERVE', DD.Deprn_Reserve,
                'REVAL RESERVE', DD.Reval_Reserve)
    FROM
        FA_DISTRIBUTION_HISTORY DH,
        FA_DEPRN_DETAIL_MRC_V   DD,
        FA_ASSET_HISTORY        AH,
        FA_CATEGORY_BOOKS       CB,
        FA_BOOKS_MRC_V          BK
    WHERE
        DH.Book_Type_Code       = Distribution_Source_Book AND
        DECODE(DD.Deprn_Source_Code, 'D', P_Date,
                        A_Date) BETWEEN
                 DH.Date_Effective AND
                        NVL(DH.Date_Ineffective, SYSDATE)
    AND
        DD.Asset_ID             = DH.Asset_ID           AND
        DD.Book_Type_Code       = Book                  AND
        DD.Distribution_ID      = DH.Distribution_ID    AND
        DD.Period_Counter       <= Period_PC            AND
        -- Bug fix 5076193 (CIP Assets dont appear in CIP Detail Report)
	DECODE(Report_Type, 'CIP COST', DD.Deprn_Source_Code,
	                    DECODE(Begin_or_End,
                                   'BEGIN', DD.Deprn_Source_Code, 'D')) =
                              DD.Deprn_Source_Code AND
/*        DECODE(Begin_or_End,
                'BEGIN', DD.Deprn_Source_Code, 'D') =
                        DD.Deprn_Source_Code AND */
        -- End bug fix 5076193
        DD.Period_Counter       =
       (SELECT  MAX (SUB_DD.Period_Counter)
        FROM    FA_DEPRN_DETAIL_MRC_V SUB_DD
        WHERE   SUB_DD.Book_Type_Code   = Book                  AND
                SUB_DD.Distribution_ID  = DH.Distribution_ID    AND
                DH.Distribution_ID      =  DD.Distribution_ID   AND
                SUB_DD.Period_Counter   <= Period_PC)
    AND
        AH.Asset_ID             = DH.Asset_ID                   AND
        ((AH.Asset_Type         <> 'EXPENSED' AND
                Report_Type IN ('COST', 'CIP COST')) OR
         (AH.Asset_Type in ('CAPITALIZED','CIP') AND
                Report_Type IN ('RESERVE', 'REVAL RESERVE')))   AND
        DECODE(DD.Deprn_Source_Code, 'D', P_Date,
                        A_Date) BETWEEN
                AH.Date_Effective AND
                        NVL(AH.Date_Ineffective, SYSDATE)
    AND
        CB.Category_ID          = AH.Category_ID        AND
        CB.Book_Type_Code       = DD.book_type_code   -- changed from book var to column
    AND
        BK.Book_Type_Code       = CB.book_type_code     AND  -- changed from book var to column
        BK.Asset_ID             = DD.Asset_ID   AND
        DECODE(DD.Deprn_Source_Code, 'D', P_Date,
                        A_Date) BETWEEN
                BK.Date_Effective AND
                        NVL(BK.Date_Ineffective, SYSDATE) AND
        NVL(BK.Period_Counter_Fully_Retired, Period_PC+1)
                > Earliest_PC
    AND
        DECODE (Report_Type,
                'COST', DECODE (AH.Asset_Type,
                                'CAPITALIZED', CB.Asset_Cost_Acct,
                                null),
                'CIP COST',
                        DECODE (AH.Asset_Type,
                                'CIP', CB.CIP_Cost_Acct,
                                null),
                'RESERVE', CB.Deprn_Reserve_Acct,
                'REVAL RESERVE', CB.Reval_Reserve_Acct) is not null;
   else
-- split for 'COST','CIP COST' and 'RESERVE','REVAL RESERVE' for better performance.
      if report_type in ('COST', 'CIP COST') then
    	INSERT INTO FA_BALANCES_REPORT_GT
       (Asset_ID,
        Distribution_CCID,
        Adjustment_CCID,
        Category_Books_Account,
        Source_Type_Code,
        Amount)
    	SELECT
           DH.Asset_ID,
       	   DH.Code_Combination_ID,
       	   null,
           DECODE (Report_Type,
                'COST', CB.Asset_Cost_Acct,
                'CIP COST', CB.CIP_Cost_Acct,
                'RESERVE', CB.Deprn_Reserve_Acct,
                'REVAL RESERVE', CB.Reval_Reserve_Acct),
           DECODE(Report_Type,
                'RESERVE', DECODE(DD.Deprn_Source_Code,
                        'D', Begin_or_End, 'ADDITION'),
                'REVAL RESERVE',
           DECODE(DD.Deprn_Source_Code,
                        'D', Begin_or_End, 'ADDITION'),
                Begin_or_End),
           DECODE (Report_Type,
                'COST', DD.Cost,
                'CIP COST', DD.Cost,
                'RESERVE', DD.Deprn_Reserve,
                'REVAL RESERVE', DD.Reval_Reserve)
    FROM
        FA_DISTRIBUTION_HISTORY DH,
        FA_DEPRN_DETAIL         DD,
        FA_ASSET_HISTORY        AH,
        FA_CATEGORY_BOOKS       CB,
        FA_BOOKS                BK
    WHERE
        DH.Book_Type_Code       = Distribution_Source_Book AND
        DECODE(DD.Deprn_Source_Code, 'D', P_Date,
                        A_Date) BETWEEN
                 DH.Date_Effective AND
                        NVL(DH.Date_Ineffective, SYSDATE)
    AND
        DD.Asset_ID             = DH.Asset_ID           AND
        DD.Book_Type_Code       = Book                  AND
        DD.Distribution_ID      = DH.Distribution_ID    AND
        DD.Period_Counter       <= Period_PC            AND
        -- Bug fix 5076193 (CIP Assets dont appear in CIP Detail Report)
	DECODE(Report_Type, 'CIP COST', DD.Deprn_Source_Code,
	       DECODE(Begin_or_End,
                      'BEGIN', DD.Deprn_Source_Code, 'D')) =
                     DD.Deprn_Source_Code AND
/*        DECODE(Begin_or_End,
                'BEGIN', DD.Deprn_Source_Code, 'D') =
                        DD.Deprn_Source_Code AND  */
        -- End bug fix 5076193
        DD.Period_Counter       =
       (SELECT  MAX (SUB_DD.Period_Counter)
        FROM    FA_DEPRN_DETAIL SUB_DD
        WHERE   SUB_DD.Book_Type_Code   = Book                  AND
                SUB_DD.Distribution_ID  = DH.Distribution_ID    AND
                DH.Distribution_ID      =  DD.Distribution_ID   AND
                SUB_DD.Period_Counter   <= Period_PC)
    AND
        AH.Asset_ID             = DH.Asset_ID                   AND
        AH.Asset_Type         <> 'EXPENSED'
    AND
        DECODE(DD.Deprn_Source_Code, 'D', P_Date,
                        A_Date) BETWEEN
                AH.Date_Effective AND
                        NVL(AH.Date_Ineffective, SYSDATE)
    AND
        CB.Category_ID          = AH.Category_ID        AND
        CB.Book_Type_Code       = DD.book_type_code   -- changed from book var to column
    AND
        BK.Book_Type_Code       = CB.book_type_code     AND  -- changed from book var to column
        BK.Asset_ID             = DD.Asset_ID   AND
        DECODE(DD.Deprn_Source_Code, 'D', P_Date,
                        A_Date) BETWEEN
                BK.Date_Effective AND
                        NVL(BK.Date_Ineffective, SYSDATE) AND
        NVL(BK.Period_Counter_Fully_Retired, Period_PC+1)
                > Earliest_PC
    AND
        DECODE (Report_Type,
                'COST', DECODE (AH.Asset_Type,
                                'CAPITALIZED', CB.Asset_Cost_Acct,
                                null),
                'CIP COST',
                        DECODE (AH.Asset_Type,
                                'CIP', CB.CIP_Cost_Acct,
                                null),
                'RESERVE', CB.Deprn_Reserve_Acct,
                'REVAL RESERVE', CB.Reval_Reserve_Acct) is not null;
      else -- report_type in ('RESERVE','REVAL RESERVE')

    	INSERT INTO FA_BALANCES_REPORT_GT
       (Asset_ID,
        Distribution_CCID,
        Adjustment_CCID,
        Category_Books_Account,
        Source_Type_Code,
        Amount)
    	SELECT
           DH.Asset_ID,
       	   DH.Code_Combination_ID,
       	   null,
           DECODE (Report_Type,
                'COST', CB.Asset_Cost_Acct,
                'CIP COST', CB.CIP_Cost_Acct,
                'RESERVE', CB.Deprn_Reserve_Acct,
                'REVAL RESERVE', CB.Reval_Reserve_Acct),
           DECODE(Report_Type,
                'RESERVE', DECODE(DD.Deprn_Source_Code,
                        'D', Begin_or_End, 'ADDITION'),
                'REVAL RESERVE',
           DECODE(DD.Deprn_Source_Code,
                        'D', Begin_or_End, 'ADDITION'),
                Begin_or_End),
           DECODE (Report_Type,
                'COST', DD.Cost,
                'CIP COST', DD.Cost,
                'RESERVE', DD.Deprn_Reserve,
                'REVAL RESERVE', DD.Reval_Reserve)
    FROM
        FA_DISTRIBUTION_HISTORY DH,
        FA_DEPRN_DETAIL         DD,
        FA_ASSET_HISTORY        AH,
        FA_CATEGORY_BOOKS       CB,
        FA_BOOKS                BK
    WHERE
        DH.Book_Type_Code       = Distribution_Source_Book AND
        DECODE(DD.Deprn_Source_Code, 'D', P_Date,
                        A_Date) BETWEEN
                 DH.Date_Effective AND
                        NVL(DH.Date_Ineffective, SYSDATE)
    AND
        DD.Asset_ID             = DH.Asset_ID           AND
        DD.Book_Type_Code       = Book                  AND
        DD.Distribution_ID      = DH.Distribution_ID    AND
        DD.Period_Counter       <= Period_PC            AND
        DECODE(Begin_or_End,
                'BEGIN', DD.Deprn_Source_Code, 'D') =
                        DD.Deprn_Source_Code AND
        DD.Period_Counter       =
       (SELECT  MAX (SUB_DD.Period_Counter)
        FROM    FA_DEPRN_DETAIL SUB_DD
        WHERE   SUB_DD.Book_Type_Code   = Book                  AND
                SUB_DD.Distribution_ID  = DH.Distribution_ID    AND
                DH.Distribution_ID      =  DD.Distribution_ID   AND
                SUB_DD.Period_Counter   <= Period_PC)
    AND
        AH.Asset_ID             = DH.Asset_ID                   AND
        AH.Asset_Type        in ( 'CAPITALIZED' ,'CIP') 	 AND
        DECODE(DD.Deprn_Source_Code, 'D', P_Date,
                        A_Date) BETWEEN
                AH.Date_Effective AND
                        NVL(AH.Date_Ineffective, SYSDATE)
    AND
        CB.Category_ID          = AH.Category_ID        AND
        CB.Book_Type_Code       = DD.book_type_code   -- changed from book var to column
    AND
        BK.Book_Type_Code       = CB.book_type_code     AND  -- changed from book var to column
        BK.Asset_ID             = DD.Asset_ID   AND
        DECODE(DD.Deprn_Source_Code, 'D', P_Date,
                        A_Date) BETWEEN
                BK.Date_Effective AND
                        NVL(BK.Date_Ineffective, SYSDATE) AND
        NVL(BK.Period_Counter_Fully_Retired, Period_PC+1)
                > Earliest_PC
    AND
        DECODE (Report_Type,
                'COST', DECODE (AH.Asset_Type,
                                'CAPITALIZED', CB.Asset_Cost_Acct,
                                null),
                'CIP COST',
                        DECODE (AH.Asset_Type,
                                'CIP', CB.CIP_Cost_Acct,
                                null),
                'RESERVE', CB.Deprn_Reserve_Acct,
                'REVAL RESERVE', CB.Reval_Reserve_Acct) is not null;

      end if;

   end if;

  -- Fix for Bug #1892406.  Run only if CRL installed.
  elsif (nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y' ) then

   if (h_reporting_flag = 'R') then
    INSERT INTO FA_BALANCES_REPORT_GT
       (Asset_ID,
	Distribution_CCID,
	Adjustment_CCID,
	Category_Books_Account,
	Source_Type_Code,
	Amount)
    SELECT
	DH.Asset_ID,
	DH.Code_Combination_ID,
	null,
	DECODE (Report_Type,
		'COST', CB.Asset_Cost_Acct,
		'CIP COST', CB.CIP_Cost_Acct,
		'RESERVE', CB.Deprn_Reserve_Acct,
		'REVAL RESERVE', CB.Reval_Reserve_Acct),
	DECODE(Report_Type,
		'RESERVE', DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		'REVAL RESERVE',
	DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		Begin_or_End),
	DECODE (Report_Type,
		'COST', DD.Cost,
		'CIP COST', DD.Cost,
		'RESERVE', DD.Deprn_Reserve,
		'REVAL RESERVE', DD.Reval_Reserve)
    FROM
        FA_DISTRIBUTION_HISTORY DH,
        FA_DEPRN_DETAIL_MRC_V   DD,
        FA_ASSET_HISTORY        AH,
        FA_CATEGORY_BOOKS       CB,
        FA_BOOKS_MRC_V          BK
    WHERE
	DH.Book_Type_Code	= Distribution_Source_Book AND
	DECODE(DD.Deprn_Source_Code, 'D', P_Date,
			A_Date) BETWEEN
		 DH.Date_Effective AND
			NVL(DH.Date_Ineffective, SYSDATE)
    AND
	DD.Asset_ID		= DH.Asset_ID		AND
	DD.Book_Type_Code	= Book			AND
	DD.Distribution_ID	= DH.Distribution_ID	AND
	DD.Period_Counter 	<= Period_PC		AND
        -- Bug fix 5076193 (CIP Assets dont appear in CIP Detail Report)
	DECODE(Report_Type, 'CIP COST', DD.Deprn_Source_Code,
	                  DECODE(Begin_or_End,
		                  'BEGIN', DD.Deprn_Source_Code, 'D')) =
			        DD.Deprn_Source_Code AND
/*	DECODE(Begin_or_End,
		'BEGIN', DD.Deprn_Source_Code, 'D') =
			DD.Deprn_Source_Code AND  */
        -- end bug fix 5076193
	DD.Period_Counter	=
       (SELECT	MAX (SUB_DD.Period_Counter)
	FROM	FA_DEPRN_DETAIL_MRC_V	SUB_DD
	WHERE	SUB_DD.Book_Type_Code	= Book			AND
		SUB_DD.Distribution_ID	= DH.Distribution_ID	AND
                DH.Distribution_ID      = DD.Distribution_ID   AND
		SUB_DD.Period_Counter	<= Period_PC)
    AND
	AH.Asset_ID		= DH.Asset_ID			AND
	((AH.Asset_Type		<> 'EXPENSED' AND
		Report_Type IN ('COST', 'CIP COST')) OR
	 (AH.Asset_Type	in ('CAPITALIZED','CIP') AND
		Report_Type IN ('RESERVE', 'REVAL RESERVE')))	AND
	DECODE(DD.Deprn_Source_Code, 'D', P_Date,
			A_Date) BETWEEN
		AH.Date_Effective AND
			NVL(AH.Date_Ineffective, SYSDATE)
    AND
	CB.Category_ID		= AH.Category_ID	AND
        CB.Book_Type_Code       = DD.book_type_code   -- changed from book var to column
    AND
        BK.Book_Type_Code       = CB.book_type_code     AND  -- changed from book var to column
	BK.Asset_ID		= DD.Asset_ID	AND
	DECODE(DD.Deprn_Source_Code, 'D', P_Date,
			A_Date) BETWEEN
		BK.Date_Effective AND
			NVL(BK.Date_Ineffective, SYSDATE) AND
	NVL(BK.Period_Counter_Fully_Retired, Period_PC+1)
		> Earliest_PC
    AND
	DECODE (Report_Type,
		'COST', DECODE (AH.Asset_Type,
				'CAPITALIZED', CB.Asset_Cost_Acct,
				null),
		'CIP COST',
			DECODE (AH.Asset_Type,
				'CIP', CB.CIP_Cost_Acct,
				null),
		'RESERVE', CB.Deprn_Reserve_Acct,
		'REVAL RESERVE', CB.Reval_Reserve_Acct) is not null
        -- start of CUA - This is to exclude the Group Asset Members
                and bk.GROUP_ASSET_ID IS NULL;
   else
    INSERT INTO FA_BALANCES_REPORT_GT
       (Asset_ID,
	Distribution_CCID,
	Adjustment_CCID,
	Category_Books_Account,
	Source_Type_Code,
	Amount)
    SELECT
	DH.Asset_ID,
	DH.Code_Combination_ID,
	null,
	DECODE (Report_Type,
		'COST', CB.Asset_Cost_Acct,
		'CIP COST', CB.CIP_Cost_Acct,
		'RESERVE', CB.Deprn_Reserve_Acct,
		'REVAL RESERVE', CB.Reval_Reserve_Acct),
	DECODE(Report_Type,
		'RESERVE', DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		'REVAL RESERVE',
	DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		Begin_or_End),
	DECODE (Report_Type,
		'COST', DD.Cost,
		'CIP COST', DD.Cost,
		'RESERVE', DD.Deprn_Reserve,
		'REVAL RESERVE', DD.Reval_Reserve)
    FROM
        FA_DISTRIBUTION_HISTORY DH,
        FA_DEPRN_DETAIL         DD,
        FA_ASSET_HISTORY        AH,
        FA_CATEGORY_BOOKS       CB,
        FA_BOOKS                BK
    WHERE
	DH.Book_Type_Code	= Distribution_Source_Book AND
	DECODE(DD.Deprn_Source_Code, 'D', P_Date,
			A_Date) BETWEEN
		 DH.Date_Effective AND
			NVL(DH.Date_Ineffective, SYSDATE)
    AND
	DD.Asset_ID		= DH.Asset_ID		AND
	DD.Book_Type_Code	= Book			AND
	DD.Distribution_ID	= DH.Distribution_ID	AND
	DD.Period_Counter 	<= Period_PC		AND
        -- Bug fix 5076193 (CIP Assets dont appear in CIP Detail Report)
	DECODE(Report_Type, 'CIP COST', DD.Deprn_Source_Code,
	                   DECODE(Begin_or_End,
		                  'BEGIN', DD.Deprn_Source_Code, 'D')) =
			         DD.Deprn_Source_Code AND
/*	DECODE(Begin_or_End,
		'BEGIN', DD.Deprn_Source_Code, 'D') =
			DD.Deprn_Source_Code AND  */
-- End bug fix 5076193
	DD.Period_Counter	=
       (SELECT	MAX (SUB_DD.Period_Counter)
	FROM	FA_DEPRN_DETAIL	SUB_DD
	WHERE	SUB_DD.Book_Type_Code	= Book			AND
		SUB_DD.Distribution_ID	= DH.Distribution_ID	AND
                DH.Distribution_ID      = DD.Distribution_ID   AND
		SUB_DD.Period_Counter	<= Period_PC)
    AND
	AH.Asset_ID		= DH.Asset_ID			AND
	((AH.Asset_Type		<> 'EXPENSED' AND
		Report_Type IN ('COST', 'CIP COST')) OR
	 (AH.Asset_Type	in ('CAPITALIZED','CIP') AND
		Report_Type IN ('RESERVE', 'REVAL RESERVE')))	AND
	DECODE(DD.Deprn_Source_Code, 'D', P_Date,
			A_Date) BETWEEN
		AH.Date_Effective AND
			NVL(AH.Date_Ineffective, SYSDATE)
    AND
	CB.Category_ID		= AH.Category_ID	AND
        CB.Book_Type_Code       = DD.book_type_code   -- changed from book var to column
    AND
        BK.Book_Type_Code       = CB.book_type_code     AND  -- changed from book var to column
	BK.Asset_ID		= DD.Asset_ID	AND
	DECODE(DD.Deprn_Source_Code, 'D', P_Date,
			A_Date) BETWEEN
		BK.Date_Effective AND
			NVL(BK.Date_Ineffective, SYSDATE) AND
	NVL(BK.Period_Counter_Fully_Retired, Period_PC+1)
		> Earliest_PC
    AND
	DECODE (Report_Type,
		'COST', DECODE (AH.Asset_Type,
				'CAPITALIZED', CB.Asset_Cost_Acct,
				null),
		'CIP COST',
			DECODE (AH.Asset_Type,
				'CIP', CB.CIP_Cost_Acct,
				null),
		'RESERVE', CB.Deprn_Reserve_Acct,
		'REVAL RESERVE', CB.Reval_Reserve_Acct) is not null
        -- start of CUA - This is to exclude the Group Asset Members
                and bk.GROUP_ASSET_ID IS NULL;
   end if;
        -- end of cua

  end if;
--Added during DT Fix
commit;
--End of DT Fix
  end Get_Balance;


procedure get_balance_group_begin
   (Book	in	varchar2,
    Distribution_Source_Book in varchar2,
    Period_PC	in	number,
    Earliest_PC	in	number,
    Period_Date	in	date,
    Additions_Date in	date,
    Report_Type	in	varchar2,
    Balance_Type in	varchar2,
    Begin_or_End in	varchar2)
  is

  --Added during DT Fix
PRAGMA AUTONOMOUS_TRANSACTION;
--End of DT Fix
    P_Date date := Period_Date;
    A_Date date := Additions_Date;
    h_set_of_books_id  number;
    h_reporting_flag   varchar2(1);
  begin

  -- get mrc related info
  begin
    --h_set_of_books_id := to_number(substrb(userenv('CLIENT_INFO'),45,10));
    select to_number(substrb(userenv('CLIENT_INFO'),45,10))
    into h_set_of_books_id from dual;

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


      -- run only if CRL installed
   if ( nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y') then

    if ( report_type not in ('RESERVE') ) THEN
     if (h_reporting_flag = 'R') then
      INSERT INTO FA_BALANCES_REPORT_GT
       (Asset_ID,
	Distribution_CCID,
	Adjustment_CCID,
	Category_Books_Account,
	Source_Type_Code,
	Amount)
      SELECT
	DH.Asset_ID,
      --DH.Code_Combination_ID,
        nvl(GAD.DEPRN_EXPENSE_ACCT_CCID, DH.Code_Combination_ID),
        -- Changed for BMA1
	-- nvl(gad.asset_cost_acct_ccid,1127),
        gad.asset_cost_acct_ccid,
        null,
	DECODE(Report_Type,
		'RESERVE', DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		'REVAL RESERVE',
	DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		Begin_or_End),
	DECODE (Report_Type,
-- Commented by Prabakar
		'COST', decode(nvl(bk.group_asset_id,-2),-2,DD.Cost,bk.cost),
-- 	        'COST', DD.Cost,
		'CIP COST', DD.Cost,
		'RESERVE', DD.Deprn_Reserve,
		'REVAL RESERVE', DD.Reval_Reserve)
    FROM
	FA_BOOKS_MRC_V		BK,
	FA_CATEGORY_BOOKS	CB,
	FA_ASSET_HISTORY	AH,
	FA_DEPRN_DETAIL_MRC_V	DD,
	FA_DISTRIBUTION_HISTORY	DH,
    -- Commented by Prabakar
        fa_GROUP_ASSET_DEFAULT   GAD
    WHERE
   -- Commented by Prabakar
        GAD.BOOK_TYPE_CODE = BK.BOOK_TYPE_CODE
        AND GAD.GROUP_ASSET_ID = BK.GROUP_ASSET_ID
     and
-- This is to include only the Group Asset Members
        bk.GROUP_ASSET_ID IS not NULL AND
        DH.Book_Type_Code	= Distribution_Source_Book AND
	DECODE(DD.Deprn_Source_Code, 'D', P_Date,
			A_Date) BETWEEN
		 DH.Date_Effective AND
			NVL(DH.Date_Ineffective, SYSDATE)
    AND
	DD.Asset_ID		= DH.Asset_ID		AND
	DD.Book_Type_Code	= Book			AND
	DD.Distribution_ID	= DH.Distribution_ID	AND
	DD.Period_Counter 	<= Period_PC		AND
	DECODE(Begin_or_End,
		'BEGIN', DD.Deprn_Source_Code, 'D') =
			DD.Deprn_Source_Code AND
	DD.Period_Counter	=
       (SELECT	MAX (SUB_DD.Period_Counter)
	FROM	FA_DEPRN_DETAIL_MRC_V	SUB_DD
	WHERE	SUB_DD.Book_Type_Code	= Book			AND
		SUB_DD.Distribution_ID	= DH.Distribution_ID	AND
		SUB_DD.Period_Counter	<= Period_PC)
    AND
	AH.Asset_ID		= DH.Asset_ID		AND
	((AH.Asset_Type		<> 'EXPENSED' AND
		Report_Type IN ('COST', 'CIP COST')) OR
	 (AH.Asset_Type	in ('CAPITALIZED','CIP') AND
		Report_Type IN ('RESERVE', 'REVAL RESERVE')))	AND
	DECODE(DD.Deprn_Source_Code, 'D', P_Date,
			A_Date) BETWEEN
		AH.Date_Effective AND
			NVL(AH.Date_Ineffective, SYSDATE)
    AND
	CB.Category_ID		= AH.Category_ID	AND
	CB.Book_Type_Code	= Book
    AND
    	BK.Book_Type_Code	= Book		AND
	BK.Asset_ID		= DD.Asset_ID	AND
      -- Commented by Prabakar
     ( bk.transaction_header_id_in
            = ( select min(fab.transaction_header_id_in) from fa_books_groups_mrc_v bg, fa_books_mrc_v fab
                        where  bg.group_asset_id = nvl(bk.group_asset_id,-2)
                               and bg.book_type_code = fab.book_type_code
                               and fab.transaction_header_id_in <=  bg.transaction_header_id_in
                               and nvl(fab.transaction_header_id_out,bg.transaction_header_id_in) >= bg.transaction_header_id_in
                               and bg.period_counter = Period_pc + 1
                               and fab.asset_id = bk.asset_id
                               and fab.book_type_code = bk.book_type_code
                               and bg.BEGINNING_BALANCE_FLAG     is not null    )
           )
        AND
	DECODE (Report_Type,
		'COST', DECODE (AH.Asset_Type,
				'CAPITALIZED', CB.Asset_Cost_Acct,
				null),
		'CIP COST',
			DECODE (AH.Asset_Type,
				'CIP', CB.CIP_Cost_Acct,
				null),
		'RESERVE', CB.Deprn_Reserve_Acct,
		'REVAL RESERVE', CB.Reval_Reserve_Acct) is not null;
     else
      INSERT INTO FA_BALANCES_REPORT_GT
       (Asset_ID,
	Distribution_CCID,
	Adjustment_CCID,
	Category_Books_Account,
	Source_Type_Code,
	Amount)
      SELECT
	DH.Asset_ID,
      --DH.Code_Combination_ID,
        nvl(GAD.DEPRN_EXPENSE_ACCT_CCID, DH.Code_Combination_ID),
        -- Changed for BMA1
	-- nvl(gad.asset_cost_acct_ccid,1127),
        gad.asset_cost_acct_ccid,
        null,
	DECODE(Report_Type,
		'RESERVE', DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		'REVAL RESERVE',
	DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		Begin_or_End),
	DECODE (Report_Type,
-- Commented by Prabakar
		'COST', decode(nvl(bk.group_asset_id,-2),-2,DD.Cost,bk.cost),
-- 	        'COST', DD.Cost,
		'CIP COST', DD.Cost,
		'RESERVE', DD.Deprn_Reserve,
		'REVAL RESERVE', DD.Reval_Reserve)
    FROM
	FA_BOOKS		BK,
	FA_CATEGORY_BOOKS	CB,
	FA_ASSET_HISTORY	AH,
	FA_DEPRN_DETAIL		DD,
	FA_DISTRIBUTION_HISTORY	DH,
    -- Commented by Prabakar
        fa_GROUP_ASSET_DEFAULT   GAD
    WHERE
   -- Commented by Prabakar
        GAD.BOOK_TYPE_CODE = BK.BOOK_TYPE_CODE
        AND GAD.GROUP_ASSET_ID = BK.GROUP_ASSET_ID
     and
-- This is to include only the Group Asset Members
        bk.GROUP_ASSET_ID IS not NULL AND
        DH.Book_Type_Code	= Distribution_Source_Book AND
	DECODE(DD.Deprn_Source_Code, 'D', P_Date,
			A_Date) BETWEEN
		 DH.Date_Effective AND
			NVL(DH.Date_Ineffective, SYSDATE)
    AND
	DD.Asset_ID		= DH.Asset_ID		AND
	DD.Book_Type_Code	= Book			AND
	DD.Distribution_ID	= DH.Distribution_ID	AND
	DD.Period_Counter 	<= Period_PC		AND
	DECODE(Begin_or_End,
		'BEGIN', DD.Deprn_Source_Code, 'D') =
			DD.Deprn_Source_Code AND
	DD.Period_Counter	=
       (SELECT	MAX (SUB_DD.Period_Counter)
	FROM	FA_DEPRN_DETAIL	SUB_DD
	WHERE	SUB_DD.Book_Type_Code	= Book			AND
		SUB_DD.Distribution_ID	= DH.Distribution_ID	AND
		SUB_DD.Period_Counter	<= Period_PC)
    AND
	AH.Asset_ID		= DH.Asset_ID		AND
	((AH.Asset_Type		<> 'EXPENSED' AND
		Report_Type IN ('COST', 'CIP COST')) OR
	 (AH.Asset_Type	in ('CAPITALIZED','CIP') AND
		Report_Type IN ('RESERVE', 'REVAL RESERVE')))	AND
	DECODE(DD.Deprn_Source_Code, 'D', P_Date,
			A_Date) BETWEEN
		AH.Date_Effective AND
			NVL(AH.Date_Ineffective, SYSDATE)
    AND
	CB.Category_ID		= AH.Category_ID	AND
	CB.Book_Type_Code	= Book
    AND
    	BK.Book_Type_Code	= Book		AND
	BK.Asset_ID		= DD.Asset_ID	AND
      -- Commented by Prabakar
     ( bk.transaction_header_id_in
            = ( select min(fab.transaction_header_id_in) from fa_books_groups bg, fa_books fab
                        where  bg.group_asset_id = nvl(bk.group_asset_id,-2)
                               and bg.book_type_code = fab.book_type_code
                               and fab.transaction_header_id_in <=  bg.transaction_header_id_in
                               and nvl(fab.transaction_header_id_out,bg.transaction_header_id_in) >= bg.transaction_header_id_in
                               and bg.period_counter = Period_pc + 1
                               and fab.asset_id = bk.asset_id
                               and fab.book_type_code = bk.book_type_code
                               and bg.BEGINNING_BALANCE_FLAG     is not null    )
           )
        AND
	DECODE (Report_Type,
		'COST', DECODE (AH.Asset_Type,
				'CAPITALIZED', CB.Asset_Cost_Acct,
				null),
		'CIP COST',
			DECODE (AH.Asset_Type,
				'CIP', CB.CIP_Cost_Acct,
				null),
		'RESERVE', CB.Deprn_Reserve_Acct,
		'REVAL RESERVE', CB.Reval_Reserve_Acct) is not null;
      end if;
ELSE

-- Get the Depreciation reserve begin balance

   if (h_reporting_flag = 'R') then
    INSERT INTO FA_BALANCES_REPORT_GT
       (Asset_ID,
	Distribution_CCID,
	Adjustment_CCID,
	Category_Books_Account,
	Source_Type_Code,
	Amount)
    SELECT
        GAR.GROUP_ASSET_ID						ASSET_ID,
        GAD.DEPRN_EXPENSE_ACCT_CCID  				,
	GAD.DEPRN_RESERVE_ACCT_CCID 		                ,
        null,
        /* DECODE(Report_Type,
		'RESERVE', DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		'REVAL RESERVE',
	DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		Begin_or_End),
        */
        'BEGIN',
        DD.DEPRN_RESERVE
    FROM
        FA_DEPRN_SUMMARY_MRC_V  DD,
        fa_GROUP_ASSET_RULES    GAR,
        fa_GROUP_ASSET_DEFAULT  GAD
WHERE
        DD.BOOK_TYPE_CODE               = book
   AND     DD.ASSET_ID                     = GAR.GROUP_ASSET_ID
AND        GAR.BOOK_TYPE_CODE              = DD.BOOK_TYPE_CODE
 AND       GAD.BOOK_TYPE_CODE              = GAR.BOOK_TYPE_CODE
 AND       GAD.GROUP_ASSET_ID              = GAR.GROUP_ASSET_ID
  AND      DD.PERIOD_COUNTER               =
         (SELECT  max (DD_SUB.PERIOD_COUNTER)
        FROM    FA_DEPRN_DETAIL_MRC_V DD_SUB
        WHERE   DD_SUB.BOOK_TYPE_CODE   = book
        AND     DD_SUB.ASSET_ID         = GAR.GROUP_ASSET_ID
        AND     DD_SUB.PERIOD_COUNTER   <= PERIOD_PC);
  else
    INSERT INTO FA_BALANCES_REPORT_GT
       (Asset_ID,
	Distribution_CCID,
	Adjustment_CCID,
	Category_Books_Account,
	Source_Type_Code,
	Amount)
    SELECT
        GAR.GROUP_ASSET_ID						ASSET_ID,
        GAD.DEPRN_EXPENSE_ACCT_CCID  				,
	GAD.DEPRN_RESERVE_ACCT_CCID 		                ,
        null,
        /* DECODE(Report_Type,
		'RESERVE', DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		'REVAL RESERVE',
	DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		Begin_or_End),
        */
        'BEGIN',
        DD.DEPRN_RESERVE
    FROM
        FA_DEPRN_SUMMARY         DD,
        fa_GROUP_ASSET_RULES    GAR,
        fa_GROUP_ASSET_DEFAULT  GAD
WHERE
        DD.BOOK_TYPE_CODE               = book
   AND     DD.ASSET_ID                     = GAR.GROUP_ASSET_ID
AND        GAR.BOOK_TYPE_CODE              = DD.BOOK_TYPE_CODE
 AND       GAD.BOOK_TYPE_CODE              = GAR.BOOK_TYPE_CODE
 AND       GAD.GROUP_ASSET_ID              = GAR.GROUP_ASSET_ID
  AND      DD.PERIOD_COUNTER               =
         (SELECT  max (DD_SUB.PERIOD_COUNTER)
        FROM    FA_DEPRN_DETAIL DD_SUB
        WHERE   DD_SUB.BOOK_TYPE_CODE   = book
        AND     DD_SUB.ASSET_ID         = GAR.GROUP_ASSET_ID
        AND     DD_SUB.PERIOD_COUNTER   <= PERIOD_PC);
  end if;
--NULL;
END IF;

  end if;  --end of CRL check

   --Added during DT Fix
commit;
--End of DT Fix
  end get_balance_group_begin;


procedure get_balance_group_end
   (Book	in	varchar2,
    Distribution_Source_Book in varchar2,
    Period_PC	in	number,
    Earliest_PC	in	number,
    Period_Date	in	date,
    Additions_Date in	date,
    Report_Type	in	varchar2,
    Balance_Type in	varchar2,
    Begin_or_End in	varchar2)
  is


--Added during DT Fix
PRAGMA AUTONOMOUS_TRANSACTION;
--End of DT Fix
    P_Date date := Period_Date;
    A_Date date := Additions_Date;
    h_set_of_books_id  number;
    h_reporting_flag   varchar2(1);
 begin

  -- get mrc related info
  begin
    --h_set_of_books_id := to_number(substrb(userenv('CLIENT_INFO'),45,10));
    select to_number(substrb(userenv('CLIENT_INFO'),45,10))
    into h_set_of_books_id from dual;

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

   -- run only if CRL installed
   if ( nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y') then

    IF REPORT_TYPE NOT IN ('RESERVE') THEN
     if (h_reporting_flag = 'R') then
      INSERT INTO FA_BALANCES_REPORT_GT
       (Asset_ID,
	Distribution_CCID,
	Adjustment_CCID,
	Category_Books_Account,
	Source_Type_Code,
	Amount)
      SELECT
	DH.Asset_ID,
	-- DH.Code_Combination_ID,
        nvl(GAD.DEPRN_EXPENSE_ACCT_CCID, DH.Code_Combination_ID),
        -- Changed for BMA1
        -- nvl(gad.asset_cost_acct_ccid,1127),
        gad.asset_cost_acct_ccid,
	null,
	DECODE(Report_Type,
		'RESERVE', DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		'REVAL RESERVE',
	DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		Begin_or_End),
	DECODE (Report_Type,
                'COST', decode(nvl(bk.group_asset_id,-2),-2,DD.Cost,bk.cost),
		'CIP COST', DD.Cost,
		'RESERVE', DD.Deprn_Reserve,
		'REVAL RESERVE', DD.Reval_Reserve)
      FROM
	FA_BOOKS_MRC_V		BK,
	FA_CATEGORY_BOOKS	CB,
	FA_ASSET_HISTORY	AH,
	FA_DEPRN_DETAIL_MRC_V   DD,
	FA_DISTRIBUTION_HISTORY	DH,
    -- Commented by Prabakar
        fa_GROUP_ASSET_DEFAULT   GAD
      WHERE
   -- Commented by Prabakar
        GAD.BOOK_TYPE_CODE = BK.BOOK_TYPE_CODE
        AND GAD.GROUP_ASSET_ID = BK.GROUP_ASSET_ID
    -- This is to include only the Group Asset Members
    and   bk.GROUP_ASSET_ID IS not NULL AND
        DH.Book_Type_Code	= Distribution_Source_Book AND
	DECODE(DD.Deprn_Source_Code, 'D', P_Date,
			A_Date) BETWEEN
		 DH.Date_Effective AND
			NVL(DH.Date_Ineffective, SYSDATE)
    AND
	DD.Asset_ID		= DH.Asset_ID	AND
	DD.Book_Type_Code	= Book			AND
	DD.Distribution_ID	= DH.Distribution_ID	AND
	DD.Period_Counter 	<= Period_PC		AND
	DECODE(Begin_or_End,
		'BEGIN', DD.Deprn_Source_Code, 'D') =
			DD.Deprn_Source_Code AND
	DD.Period_Counter	=
       (SELECT	MAX (SUB_DD.Period_Counter)
	FROM	FA_DEPRN_DETAIL_MRC_V	SUB_DD
	WHERE	SUB_DD.Book_Type_Code	= Book			AND
		SUB_DD.Distribution_ID	= DH.Distribution_ID	AND
		SUB_DD.Period_Counter	<= Period_PC)
        AND
	AH.Asset_ID		= DH.Asset_ID			AND
	((AH.Asset_Type		<> 'EXPENSED' AND
		Report_Type IN ('COST', 'CIP COST')) OR
	 (AH.Asset_Type	in ('CAPITALIZED','CIP') AND
		Report_Type IN ('RESERVE', 'REVAL RESERVE')))	AND
	DECODE(DD.Deprn_Source_Code, 'D', P_Date,
			A_Date) BETWEEN
		AH.Date_Effective AND
			NVL(AH.Date_Ineffective, SYSDATE)
    AND
	CB.Category_ID		= AH.Category_ID	AND
	CB.Book_Type_Code	= Book
    AND
    	BK.Book_Type_Code	= Book		AND
	BK.Asset_ID		= DD.Asset_ID	AND
      -- Commented by Prabakar
     ( bk.transaction_header_id_in
            = ( select min(fab.transaction_header_id_in) from fa_books_groups_mrc_v bg, fa_books_mrc_v fab
                        where  bg.group_asset_id = nvl(bk.group_asset_id,-2)
                               and bg.book_type_code = fab.book_type_code
                               and fab.transaction_header_id_in <=  bg.transaction_header_id_in
                               and nvl(fab.transaction_header_id_out,bg.transaction_header_id_in) >= bg.transaction_header_id_in
                               and bg.period_counter = Period_pc  + 1
                               and fab.asset_id = bk.asset_id
                               and fab.book_type_code = bk.book_type_code
                               and bg.BEGINNING_BALANCE_FLAG     is not null    )
           )
        AND
	DECODE (Report_Type,
		'COST', DECODE (AH.Asset_Type,
				'CAPITALIZED', CB.Asset_Cost_Acct,
				null),
		'CIP COST',
			DECODE (AH.Asset_Type,
				'CIP', CB.CIP_Cost_Acct,
				null),
		'RESERVE', CB.Deprn_Reserve_Acct,
		'REVAL RESERVE', CB.Reval_Reserve_Acct) is not null;
     else
      INSERT INTO FA_BALANCES_REPORT_GT
       (Asset_ID,
	Distribution_CCID,
	Adjustment_CCID,
	Category_Books_Account,
	Source_Type_Code,
	Amount)
      SELECT
	DH.Asset_ID,
	-- DH.Code_Combination_ID,
        nvl(GAD.DEPRN_EXPENSE_ACCT_CCID, DH.Code_Combination_ID),
        -- Changed for BMA1
        -- nvl(gad.asset_cost_acct_ccid,1127),
        gad.asset_cost_acct_ccid,
	null,
	DECODE(Report_Type,
		'RESERVE', DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		'REVAL RESERVE',
	DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		Begin_or_End),
	DECODE (Report_Type,
                'COST', decode(nvl(bk.group_asset_id,-2),-2,DD.Cost,bk.cost),
		'CIP COST', DD.Cost,
		'RESERVE', DD.Deprn_Reserve,
		'REVAL RESERVE', DD.Reval_Reserve)
      FROM
	FA_BOOKS		BK,
	FA_CATEGORY_BOOKS	CB,
	FA_ASSET_HISTORY	AH,
	FA_DEPRN_DETAIL		DD,
	FA_DISTRIBUTION_HISTORY	DH,
    -- Commented by Prabakar
        fa_GROUP_ASSET_DEFAULT   GAD
      WHERE
   -- Commented by Prabakar
        GAD.BOOK_TYPE_CODE = BK.BOOK_TYPE_CODE
        AND GAD.GROUP_ASSET_ID = BK.GROUP_ASSET_ID
    -- This is to include only the Group Asset Members
    and   bk.GROUP_ASSET_ID IS not NULL AND
        DH.Book_Type_Code	= Distribution_Source_Book AND
	DECODE(DD.Deprn_Source_Code, 'D', P_Date,
			A_Date) BETWEEN
		 DH.Date_Effective AND
			NVL(DH.Date_Ineffective, SYSDATE)
    AND
	DD.Asset_ID		= DH.Asset_ID	AND
	DD.Book_Type_Code	= Book			AND
	DD.Distribution_ID	= DH.Distribution_ID	AND
	DD.Period_Counter 	<= Period_PC		AND
	DECODE(Begin_or_End,
		'BEGIN', DD.Deprn_Source_Code, 'D') =
			DD.Deprn_Source_Code AND
	DD.Period_Counter	=
       (SELECT	MAX (SUB_DD.Period_Counter)
	FROM	FA_DEPRN_DETAIL	SUB_DD
	WHERE	SUB_DD.Book_Type_Code	= Book			AND
		SUB_DD.Distribution_ID	= DH.Distribution_ID	AND
		SUB_DD.Period_Counter	<= Period_PC)
        AND
	AH.Asset_ID		= DH.Asset_ID			AND
	((AH.Asset_Type		<> 'EXPENSED' AND
		Report_Type IN ('COST', 'CIP COST')) OR
	 (AH.Asset_Type	in ('CAPITALIZED','CIP') AND
		Report_Type IN ('RESERVE', 'REVAL RESERVE')))	AND
	DECODE(DD.Deprn_Source_Code, 'D', P_Date,
			A_Date) BETWEEN
		AH.Date_Effective AND
			NVL(AH.Date_Ineffective, SYSDATE)
    AND
	CB.Category_ID		= AH.Category_ID	AND
	CB.Book_Type_Code	= Book
    AND
    	BK.Book_Type_Code	= Book		AND
	BK.Asset_ID		= DD.Asset_ID	AND
      -- Commented by Prabakar
     ( bk.transaction_header_id_in
            = ( select min(fab.transaction_header_id_in) from fa_books_groups bg, fa_books fab
                        where  bg.group_asset_id = nvl(bk.group_asset_id,-2)
                               and bg.book_type_code = fab.book_type_code
                               and fab.transaction_header_id_in <=  bg.transaction_header_id_in
                               and nvl(fab.transaction_header_id_out,bg.transaction_header_id_in) >= bg.transaction_header_id_in
                               and bg.period_counter = Period_pc  + 1
                               and fab.asset_id = bk.asset_id
                               and fab.book_type_code = bk.book_type_code
                               and bg.BEGINNING_BALANCE_FLAG     is not null    )
           )
        AND
	DECODE (Report_Type,
		'COST', DECODE (AH.Asset_Type,
				'CAPITALIZED', CB.Asset_Cost_Acct,
				null),
		'CIP COST',
			DECODE (AH.Asset_Type,
				'CIP', CB.CIP_Cost_Acct,
				null),
		'RESERVE', CB.Deprn_Reserve_Acct,
		'REVAL RESERVE', CB.Reval_Reserve_Acct) is not null;
      end if;

ELSE

 if (h_reporting_flag = 'R') then
  INSERT INTO FA_BALANCES_REPORT_GT
       (Asset_ID,
	Distribution_CCID,
	Adjustment_CCID,
	Category_Books_Account,
	Source_Type_Code,
	Amount)
    SELECT
        GAR.GROUP_ASSET_ID	ASSET_ID,
        GAD.DEPRN_EXPENSE_ACCT_CCID  				,
	GAD.DEPRN_RESERVE_ACCT_CCID 		                ,
        null,
        /* DECODE(Report_Type,
		'RESERVE', DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		'REVAL RESERVE',
	DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		Begin_or_End),*/
        'END',
        DD.DEPRN_RESERVE
    FROM
        FA_DEPRN_SUMMARY_MRC_V  DD,
        fa_GROUP_ASSET_RULES    GAR,
        fa_GROUP_ASSET_DEFAULT  GAD
    WHERE
        DD.BOOK_TYPE_CODE               = book
     AND     DD.ASSET_ID                     = GAR.GROUP_ASSET_ID
     AND        GAR.BOOK_TYPE_CODE              = DD.BOOK_TYPE_CODE
     AND       GAD.BOOK_TYPE_CODE              = GAR.BOOK_TYPE_CODE
     AND       GAD.GROUP_ASSET_ID              = GAR.GROUP_ASSET_ID
     AND      DD.PERIOD_COUNTER               =
                  (SELECT  max (DD_SUB.PERIOD_COUNTER)
                   FROM    FA_DEPRN_DETAIL_MRC_V DD_SUB
                   WHERE   DD_SUB.BOOK_TYPE_CODE   = book
                   AND     DD_SUB.ASSET_ID         = GAR.GROUP_ASSET_ID
                   AND     DD_SUB.PERIOD_COUNTER   <= PERIOD_PC);
 else
  INSERT INTO FA_BALANCES_REPORT_GT
       (Asset_ID,
	Distribution_CCID,
	Adjustment_CCID,
	Category_Books_Account,
	Source_Type_Code,
	Amount)
    SELECT
        GAR.GROUP_ASSET_ID	ASSET_ID,
        GAD.DEPRN_EXPENSE_ACCT_CCID  				,
	GAD.DEPRN_RESERVE_ACCT_CCID 		                ,
        null,
        /* DECODE(Report_Type,
		'RESERVE', DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		'REVAL RESERVE',
	DECODE(DD.Deprn_Source_Code,
			'D', Begin_or_End, 'ADDITION'),
		Begin_or_End),*/
        'END',
        DD.DEPRN_RESERVE
    FROM
        FA_DEPRN_SUMMARY         DD,
        fa_GROUP_ASSET_RULES    GAR,
        fa_GROUP_ASSET_DEFAULT  GAD
    WHERE
        DD.BOOK_TYPE_CODE               = book
     AND     DD.ASSET_ID                     = GAR.GROUP_ASSET_ID
     AND        GAR.BOOK_TYPE_CODE              = DD.BOOK_TYPE_CODE
     AND       GAD.BOOK_TYPE_CODE              = GAR.BOOK_TYPE_CODE
     AND       GAD.GROUP_ASSET_ID              = GAR.GROUP_ASSET_ID
     AND      DD.PERIOD_COUNTER               =
                  (SELECT  max (DD_SUB.PERIOD_COUNTER)
                   FROM    FA_DEPRN_DETAIL DD_SUB
                   WHERE   DD_SUB.BOOK_TYPE_CODE   = book
                   AND     DD_SUB.ASSET_ID         = GAR.GROUP_ASSET_ID
                   AND     DD_SUB.PERIOD_COUNTER   <= PERIOD_PC);
   end if;
  END IF;

  end if;  -- end of CRL check

  --Added during DT Fix
commit;
--End of DT Fix
  end get_balance_group_end;


procedure Get_Deprn_Effects
   (Book	in	varchar2,
    Distribution_Source_Book in varchar2,
    Period1_PC	in	number,
    Period2_PC	in	number,
    Report_Type	in	varchar2)
  is

  --Added during DT Fix
PRAGMA AUTONOMOUS_TRANSACTION;
--End of DT Fix
     h_set_of_books_id  number;
     h_reporting_flag   varchar2(1);
  begin

  -- get mrc related info
  begin
    -- h_set_of_books_id := to_number(substrb(userenv('CLIENT_INFO'),45,10));
    select to_number(substrb(userenv('CLIENT_INFO'),45,10))
    into h_set_of_books_id from dual;

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

   if (h_reporting_flag = 'R') then
    INSERT INTO FA_BALANCES_REPORT_GT
       (Asset_ID,
	Distribution_CCID,
	Adjustment_CCID,
	Category_Books_Account,
	Source_Type_Code,
	Amount)
    SELECT
	DH.Asset_ID,
	DH.Code_Combination_ID,
	null,
	DECODE (RT.Lookup_Code,
		'RESERVE', CB.Deprn_Reserve_Acct,
		'REVAL RESERVE', CB.Reval_Reserve_Acct),
	DECODE(DD.Deprn_Source_Code,
		'D', 'DEPRECIATION', 'ADDITION'),
	SUM (DECODE (RT.Lookup_Code,
		'RESERVE', DD.Deprn_Amount - decode(ADJ.debit_credit_flag,'DR',1,-1)
                                              * nvl(ADJ.adjustment_amount,0),
		'REVAL RESERVE', -DD.Reval_Amortization))
    FROM
	FA_LOOKUPS_B		RT,
	FA_CATEGORY_BOOKS	CB,
	FA_DISTRIBUTION_HISTORY	DH,
	FA_ASSET_HISTORY	AH,
	FA_DEPRN_DETAIL_MRC_V	DD,
	FA_DEPRN_PERIODS_MRC_V	DP,
        FA_ADJUSTMENTS_MRC_V    ADJ
    WHERE
	DH.Book_Type_Code	= Distribution_Source_Book
    AND
	AH.Asset_ID		= DH.Asset_ID		AND
	AH.Asset_Type	 in ( 'CAPITALIZED' ,'CIP')		AND
	AH.Date_Effective <
		nvl(DH.date_ineffective, sysdate)	AND
	nvl(DH.date_ineffective, sysdate) <=
		NVL(AH.Date_Ineffective, SYSDATE)
    AND
	CB.Category_ID		= AH.Category_ID	AND
	CB.Book_Type_Code	= Book
    AND
	((DD.Deprn_Source_Code 	= 'B'
		AND (DD.Period_Counter+1) < Period2_PC)	OR
	 (DD.Deprn_Source_Code 	= 'D'))			AND
	DD.Book_Type_Code||''	= Book			AND
	DD.Asset_ID		= DH.Asset_ID		AND
	DD.Distribution_ID	= DH.Distribution_ID	AND
	DD.Period_Counter between
		Period1_PC and Period2_PC
    AND
	DP.Book_Type_Code	= DD.Book_Type_Code	AND
	DP.Period_Counter	= DD.Period_Counter
    AND
	RT.Lookup_Type 		= 'REPORT TYPE'	AND
	DECODE (RT.Lookup_Code,
		'RESERVE', CB.Deprn_Reserve_Acct,
		'REVAL RESERVE', CB.Reval_Reserve_Acct) is not null
    AND
	(DECODE (RT.Lookup_Code,
		'RESERVE', DD.Deprn_Amount,
		'REVAL RESERVE', NVL(DD.Reval_Amortization,0)) <> 0 OR
         DECODE (RT.Lookup_Code,
                'RESERVE', DD.Deprn_Amount - nvl(DD.deprn_adjustment_amount,0),
                'REVAL RESERVE', NVL(DD.Reval_Amortization,0)) <> 0)
    AND ADJ.asset_id(+) = DD.asset_id AND
        ADJ.book_type_code(+) = DD.book_type_code AND
        ADJ.period_counter_created(+) = DD.period_counter AND
        ADJ.distribution_id(+) = DD.distribution_id AND
        ADJ.source_type_code(+) = 'REVALUATION' AND
        ADJ.adjustment_type(+) = 'EXPENSE' AND
        ADJ.adjustment_amount(+) <> 0
    GROUP BY
	DH.Asset_ID,
	DH.Code_Combination_ID,
	DECODE (RT.Lookup_Code,
		'RESERVE', CB.Deprn_Reserve_Acct,
		'REVAL RESERVE', CB.Reval_Reserve_Acct),
	DD.Deprn_Source_Code;
   else
    INSERT INTO FA_BALANCES_REPORT_GT
       (Asset_ID,
	Distribution_CCID,
	Adjustment_CCID,
	Category_Books_Account,
	Source_Type_Code,
	Amount)
    SELECT
	DH.Asset_ID,
	DH.Code_Combination_ID,
	null,
	DECODE (RT.Lookup_Code,
		'RESERVE', CB.Deprn_Reserve_Acct,
		'REVAL RESERVE', CB.Reval_Reserve_Acct),
	DECODE(DD.Deprn_Source_Code,
		'D', 'DEPRECIATION', 'ADDITION'),
	SUM (DECODE (RT.Lookup_Code,
		'RESERVE', DD.Deprn_Amount - decode(ADJ.debit_credit_flag,'DR',1,-1)
                                              * nvl(ADJ.adjustment_amount,0),
		'REVAL RESERVE', -DD.Reval_Amortization))
    FROM
	FA_LOOKUPS_B		RT,
	FA_CATEGORY_BOOKS	CB,
	FA_DISTRIBUTION_HISTORY	DH,
	FA_ASSET_HISTORY	AH,
	FA_DEPRN_DETAIL		DD,
	FA_DEPRN_PERIODS	DP,
        FA_ADJUSTMENTS          ADJ
    WHERE
	DH.Book_Type_Code	= Distribution_Source_Book
    AND
	AH.Asset_ID		= DH.Asset_ID		AND
	AH.Asset_Type	 in ( 'CAPITALIZED','CIP')		AND
	AH.Date_Effective <
		nvl(DH.date_ineffective, sysdate)	AND
	nvl(DH.date_ineffective, sysdate) <=
		NVL(AH.Date_Ineffective, SYSDATE)
    AND
	CB.Category_ID		= AH.Category_ID	AND
	CB.Book_Type_Code	= Book
    AND
	((DD.Deprn_Source_Code 	= 'B'
		AND (DD.Period_Counter+1) < Period2_PC)	OR
	 (DD.Deprn_Source_Code 	= 'D'))			AND
	DD.Book_Type_Code||''	= Book			AND
	DD.Asset_ID		= DH.Asset_ID		AND
	DD.Distribution_ID	= DH.Distribution_ID	AND
	DD.Period_Counter between
		Period1_PC and Period2_PC
    AND
	DP.Book_Type_Code	= DD.Book_Type_Code	AND
	DP.Period_Counter	= DD.Period_Counter
    AND
	RT.Lookup_Type 		= 'REPORT TYPE'	AND
	DECODE (RT.Lookup_Code,
		'RESERVE', CB.Deprn_Reserve_Acct,
		'REVAL RESERVE', CB.Reval_Reserve_Acct) is not null
    AND
	(DECODE (RT.Lookup_Code,
		'RESERVE', DD.Deprn_Amount,
		'REVAL RESERVE', NVL(DD.Reval_Amortization,0)) <> 0 OR
        DECODE (RT.Lookup_Code,
                'RESERVE', DD.Deprn_Amount - nvl(DD.deprn_adjustment_amount,0),
                'REVAL RESERVE', NVL(DD.Reval_Amortization,0)) <> 0)
    AND ADJ.asset_id(+) = DD.asset_id AND
        ADJ.book_type_code(+) = DD.book_type_code AND
        ADJ.period_counter_created(+) = DD.period_counter AND
        ADJ.distribution_id(+) = DD.distribution_id AND
        ADJ.source_type_code(+) = 'REVALUATION' AND
        ADJ.adjustment_type(+) = 'EXPENSE' AND
        ADJ.adjustment_amount(+) <> 0
    GROUP BY
	DH.Asset_ID,
	DH.Code_Combination_ID,
	DECODE (RT.Lookup_Code,
		'RESERVE', CB.Deprn_Reserve_Acct,
		'REVAL RESERVE', CB.Reval_Reserve_Acct),
	DD.Deprn_Source_Code;
   end if;

    -- run only if CRL installed
   if ( nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y') then

       -- Get the Group Depreciation Effects

      if (h_reporting_flag = 'R') then
        INSERT INTO FA_BALANCES_REPORT_GT
           (Asset_ID,
	   Distribution_CCID,
	   Adjustment_CCID,
	   Category_Books_Account,
	   Source_Type_Code,
	   Amount)
        SELECT
	   DD.Asset_ID,
	   GAD.DEPRN_EXPENSE_ACCT_CCID ,
	   GAD.DEPRN_RESERVE_ACCT_CCID,
	   null,
	   'DEPRECIATION',
	   SUM ( DD.Deprn_Amount)
        FROM
           FA_DEPRN_SUMMARY_MRC_V  DD,
           fa_GROUP_ASSET_RULES    GAR,
           fa_GROUP_ASSET_DEFAULT  GAD
        WHERE
             DD.BOOK_TYPE_CODE               = book
        AND  DD.ASSET_ID                     = GAR.GROUP_ASSET_ID
        AND  GAR.BOOK_TYPE_CODE              = DD.BOOK_TYPE_CODE
        AND  GAD.BOOK_TYPE_CODE              = GAR.BOOK_TYPE_CODE
        AND  GAD.GROUP_ASSET_ID              = GAR.GROUP_ASSET_ID
        AND  DD.PERIOD_COUNTER             between
		Period1_PC and Period2_PC
        GROUP BY
          DD.Asset_ID,
	  GAD.DEPRN_EXPENSE_ACCT_CCID ,
	  GAD.DEPRN_RESERVE_ACCT_CCID ,
	  null,
	  'DEPRECIATION' ;
       else
        INSERT INTO FA_BALANCES_REPORT_GT
           (Asset_ID,
	   Distribution_CCID,
	   Adjustment_CCID,
	   Category_Books_Account,
	   Source_Type_Code,
	   Amount)
        SELECT
	   DD.Asset_ID,
	   GAD.DEPRN_EXPENSE_ACCT_CCID ,
	   GAD.DEPRN_RESERVE_ACCT_CCID,
	   null,
	   'DEPRECIATION',
	   SUM ( DD.Deprn_Amount)
        FROM
           FA_DEPRN_SUMMARY         DD,
           fa_GROUP_ASSET_RULES    GAR,
           fa_GROUP_ASSET_DEFAULT  GAD
        WHERE
             DD.BOOK_TYPE_CODE               = book
        AND  DD.ASSET_ID                     = GAR.GROUP_ASSET_ID
        AND  GAR.BOOK_TYPE_CODE              = DD.BOOK_TYPE_CODE
        AND  GAD.BOOK_TYPE_CODE              = GAR.BOOK_TYPE_CODE
        AND  GAD.GROUP_ASSET_ID              = GAR.GROUP_ASSET_ID
        AND  DD.PERIOD_COUNTER             between
		Period1_PC and Period2_PC
        GROUP BY
          DD.Asset_ID,
	  GAD.DEPRN_EXPENSE_ACCT_CCID ,
	  GAD.DEPRN_RESERVE_ACCT_CCID ,
	  null,
	  'DEPRECIATION' ;
       end if;
    end if;  -- end of CRL check
--Added during DT Fix
commit;
--End of DT Fix
  end Get_Deprn_Effects;


procedure Insert_Info
   (Book		in	varchar2,
    Start_Period_Name	in	varchar2,
    End_Period_Name	in	varchar2,
    Report_Type		in	varchar2,
    Adj_Mode		in	varchar2)
  is
  --Added during DT Fix
PRAGMA AUTONOMOUS_TRANSACTION;
--End of DT Fix

    Period1_PC			number;
    Period1_POD			date;
    Period1_PCD			date;
    Period2_PC			number;
    Period2_PCD			date;
    Distribution_Source_Book	varchar2(15);
    Balance_Type		varchar2(2);

    h_set_of_books_id  number;
    h_reporting_flag   varchar2(1);

 begin

  -- get mrc related info
  begin
    --h_set_of_books_id := to_number(substrb(userenv('CLIENT_INFO'),45,10));
    select to_number(substrb(userenv('CLIENT_INFO'),45,10))
    into h_set_of_books_id from dual;

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


   if (h_reporting_flag = 'R') then
    SELECT
		P1.Period_Counter,
		P1.Period_Open_Date,
		NVL(P1.Period_Close_Date, SYSDATE),
		P2.Period_Counter,
		NVL(P2.Period_Close_Date, SYSDATE),
		BC.Distribution_Source_Book
    INTO
		Period1_PC,
		Period1_POD,
		Period1_PCD,
		Period2_PC,
		Period2_PCD,
		Distribution_Source_Book
    FROM
		FA_DEPRN_PERIODS_MRC_V P1,
		FA_DEPRN_PERIODS_MRC_V P2,
		FA_BOOK_CONTROLS_MRC_V BC
    WHERE
		BC.Book_Type_Code	= Book
    AND
		P1.Book_Type_Code	= Book			AND
		P1.Period_Name		= Start_Period_Name
    AND
		P2.Book_Type_Code	= Book			AND
		P2.Period_Name		= End_Period_Name;
   else
    SELECT
		P1.Period_Counter,
		P1.Period_Open_Date,
		NVL(P1.Period_Close_Date, SYSDATE),
		P2.Period_Counter,
		NVL(P2.Period_Close_Date, SYSDATE),
		BC.Distribution_Source_Book
    INTO
		Period1_PC,
		Period1_POD,
		Period1_PCD,
		Period2_PC,
		Period2_PCD,
		Distribution_Source_Book
    FROM
		FA_DEPRN_PERIODS P1,
		FA_DEPRN_PERIODS P2,
		FA_BOOK_CONTROLS BC
    WHERE
		BC.Book_Type_Code	= Book
    AND
		P1.Book_Type_Code	= Book			AND
		P1.Period_Name		= Start_Period_Name
    AND
		P2.Book_Type_Code	= Book			AND
		P2.Period_Name		= End_Period_Name;
   end if;

    if (Report_Type = 'RESERVE' or Report_Type = 'REVAL RESERVE') then
	Balance_Type := 'CR';
    else
	Balance_Type := 'DR';
    end if;

    /* DELETE FROM FA_BALANCES_REPORT_GT; */

/*This section of code needs to be replaced due to the fact that in 11.5 the
 FA_LOOKUPS table has been split into two tables: FA_LOOKUPS_B and
 FA_LOOKUPS_TL . FA_LOOKUPS is a synonym for a view of a join of these two
 tables. So Inserts and Deletes wont work on FA_LOOKUPS, and instead must be
 performed on both tables. Changes made by cbachand, 5/25/99
    DELETE FROM FA_LOOKUPS
    WHERE LOOKUP_TYPE = 'REPORT TYPE';

    INSERT INTO FA_LOOKUPS
	(lookup_type,
	 lookup_code,
	 last_updated_by,
	 last_update_date,
	 meaning,
	 enabled_flag)
     VALUES
	('REPORT TYPE',
	 Report_Type,
	 1,
	 SYSDATE,
	 Report_Type,
	 'Y');				*/


    DELETE FROM FA_LOOKUPS_B
    WHERE LOOKUP_TYPE = 'REPORT TYPE'
    AND   LOOKUP_CODE = Report_Type;


    DELETE FROM FA_LOOKUPS_TL
    WHERE LOOKUP_TYPE = 'REPORT TYPE'
    AND   LOOKUP_CODE = Report_Type;

    INSERT INTO FA_LOOKUPS_B
	(LOOKUP_TYPE,
	 LOOKUP_CODE,
	 LAST_UPDATED_BY,
	 LAST_UPDATE_DATE,
	 ENABLED_FLAG)
     VALUES
	('REPORT TYPE',
	 Report_Type,
	 1,
	 SYSDATE,
	 'Y');

    INSERT INTO FA_LOOKUPS_TL
	(LOOKUP_TYPE,
	 LOOKUP_CODE,
	 MEANING,
 	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 LANGUAGE,
	 SOURCE_LANG)
	SELECT
	 'REPORT TYPE',
	 Report_Type,
	 Report_Type,
	 SYSDATE,
	 1,
         L.LANGUAGE_CODE,
         userenv('LANG')
  	FROM FND_LANGUAGES L
  	WHERE L.INSTALLED_FLAG in ('I', 'B')
  	AND NOT EXISTS
    	(SELECT NULL
    	 FROM FA_LOOKUPS_TL T
    	 WHERE T.LOOKUP_TYPE = 'REPORT TYPE'
    	 AND T.LOOKUP_CODE = Report_Type
    	 AND T.LANGUAGE = L.LANGUAGE_CODE);

    /* Get Beginning Balance */
    /* Use Period1_PC-1, to get balance as of end of period immediately
       preceding Period1_PC */
    Get_Balance (Book, Distribution_Source_Book,
		 Period1_PC-1, Period1_PC-1, Period1_POD, Period1_PCD,
		 Report_Type, Balance_Type,
		 'BEGIN');

     -- run only if CRL installed
     if ( nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y') then
       Get_Balance_group_begin (Book, Distribution_Source_Book,
		 Period1_PC - 1, Period1_PC-1, Period1_POD, Period1_PCD,
		 Report_Type, Balance_Type,
		 'BEGIN');
     end if;

    /* Get Ending Balance */
    Get_Balance (Book, Distribution_Source_Book,
		 Period2_PC, Period1_PC-1, Period2_PCD, Period2_PCD,
		 Report_Type, Balance_Type,
		 'END');

     -- run only if CRL installed
     if ( nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y') then
        Get_Balance_group_end (Book, Distribution_Source_Book,
		 Period2_PC, Period1_PC-1, Period2_PCD, Period2_PCD,
		 Report_Type, Balance_Type,
		 'END');
     end if;

    Get_Adjustments (Book, Distribution_Source_Book,
		     Period1_PC, Period2_PC,
		     Report_Type, Balance_Type);

     -- run only if CRL installed
     if ( nvl(fnd_profile.value('CRL-FA ENABLED'), 'N') = 'Y') then
        Get_Adjustments_for_group (Book, Distribution_Source_Book,
		     Period1_PC, Period2_PC,
		     Report_Type, Balance_Type);
     end if;

    if (Report_Type = 'RESERVE' or Report_Type = 'REVAL RESERVE') then
	Get_Deprn_Effects (Book, Distribution_Source_Book,
			   Period1_PC, Period2_PC,
			   Report_Type);
    end if;
     --Added during DT Fix
commit;
--End of DT Fix

  end Insert_Info;

END FA_FASCOSTS_XMLP_PKG ;



/
