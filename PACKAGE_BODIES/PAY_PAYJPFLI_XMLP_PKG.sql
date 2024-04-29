--------------------------------------------------------
--  DDL for Package Body PAY_PAYJPFLI_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYJPFLI_XMLP_PKG" AS
/* $Header: PAYJPFLIB.pls 120.1 2007/12/18 18:38:40 amakrish noship $ */

function cf_li_dummyformula(SALARY_CATEGORY in varchar2, TARGET_MONTH in varchar2, WAI_EE_COUNT in number, WAI_EX_COUNT in number, WAI_TW_COUNT in number, WAI_EE_SAL_AMT in number,
WAI_EX_SAL_AMT in number, WAI_TW_SAL_AMT in number, UI_EE_COUNT in number, UI_EX_COUNT in number, UI_EE_SAL_AMT in number, UI_EX_SAL_AMT in number, UI_AGED_COUNT in number) return number is
	l_date_era_code	NUMBER;
	l_date_year	NUMBER;
	l_date_month	NUMBER;
	l_date_day	NUMBER;
begin
	CP_SALARY_CATEGORY := pay_jp_report_pkg.substrb2(hr_general.decode_lookup('JP_SALARY_CATEGORY',SALARY_CATEGORY),1,8);

	pay_jp_report_pkg.to_era(	to_date(TARGET_MONTH || '01','YYYYMMDD'),
					l_date_era_code,
					l_date_year,
					l_date_month,
					l_date_day);
	l_date_year	:= l_date_year - trunc(l_date_year,-2);
	CP_TARGET_YEAR	:= l_date_year;
	CP_TARGET_MONTH:= l_date_month;

	CP_WAI_COUNT 	:= WAI_EE_COUNT + WAI_EX_COUNT + WAI_TW_COUNT;
	CP_WAI_SAL_AMT	:= WAI_EE_SAL_AMT + WAI_EX_SAL_AMT + WAI_TW_SAL_AMT;

	CP_UI_COUNT 	:= UI_EE_COUNT + UI_EX_COUNT;
	CP_UI_SAL_AMT	:= UI_EE_SAL_AMT + UI_EX_SAL_AMT;

	if SALARY_CATEGORY = 'SALARY' then
		CP_WAI_COUNT_SALARY_SUM	:= CP_WAI_COUNT_SALARY_SUM + CP_WAI_COUNT;
		CP_UI_COUNT_SALARY_SUM		:= CP_UI_COUNT_SALARY_SUM + CP_UI_COUNT;
		CP_UI_AGED_COUNT_SALARY_SUM	:= CP_UI_AGED_COUNT_SALARY_SUM + UI_AGED_COUNT;
		CP_NUM_OF_SALARY_MONTHS	:= CP_NUM_OF_SALARY_MONTHS + 1;
	end if;
	return('');
end;

function BeforeReport return boolean is
	l_date_era_code	NUMBER;
	l_date_year	NUMBER;
	l_date_month	NUMBER;
	l_date_day	NUMBER;
  l_year_suffix varchar2(100);
  l_title       varchar2(100);
begin
 -- hr_standard.event('BEFORE REPORT');
	pay_jp_report_pkg.to_era(	to_date(lpad(to_char(P_FISCAL_YEAR),4,'0') || '-04-01','YYYY-MM-DD'),
					l_date_era_code,
					l_date_year,
					l_date_month,
					l_date_day);
	l_date_year := l_date_year - trunc(l_date_year,-2);
  hr_utility.set_message(801,'PAY_JP_PAYJPFLI_REPORT_TITLE');
	l_title := hr_utility.get_message;
  hr_utility.set_message(801,'PAY_JP_FISCAL_YEAR');
	l_year_suffix := hr_utility.get_message;
	CP_REPORT_TITLE := pay_jp_report_pkg.substrb2(
				hr_general.decode_lookup('JP_ERA',to_char(l_date_era_code)) ||
				lpad(nvl(to_char(l_date_year),' '),2,' ') ||l_year_suffix||' '||l_title,1,255);
	return (TRUE);
end;

function cf_report_dummyformula(CS_CP_WAI_SAL_AMT_SUM in number, CS_CP_UI_SAL_AMT_SUM in number, CS_UI_AGED_SAL_AMT_SUM in number) return number is
begin
			if CP_NUM_OF_SALARY_MONTHS > 0 then
		CP_WAI_COUNT_SALARY_AVG	:= trunc(CP_WAI_COUNT_SALARY_SUM / CP_NUM_OF_SALARY_MONTHS);
		CP_UI_COUNT_SALARY_AVG		:= trunc(CP_UI_COUNT_SALARY_SUM / CP_NUM_OF_SALARY_MONTHS);
		CP_UI_AGED_COUNT_SALARY_AVG	:= CP_UI_AGED_COUNT_SALARY_SUM / CP_NUM_OF_SALARY_MONTHS;
	end if;

	if CP_UI_AGED_COUNT_SALARY_AVG > 0 and CP_UI_AGED_COUNT_SALARY_AVG < 1 then
		CP_UI_AGED_COUNT_SALARY_AVG	:= 1;
	else
		CP_UI_AGED_COUNT_SALARY_AVG	:= trunc(CP_UI_AGED_COUNT_SALARY_AVG);
	end if;
	CP_WAI_SAL_AMT_SUM	:= trunc(CS_CP_WAI_SAL_AMT_SUM / 1000);
	CP_UI_SAL_AMT_SUM	:= trunc(CS_CP_UI_SAL_AMT_SUM / 1000);
	CP_UI_AGED_SAL_AMT_SUM	:= trunc(CS_UI_AGED_SAL_AMT_SUM / 1000);
	CP_UI_NET_SAL_AMT_SUM	:= CP_UI_SAL_AMT_SUM - CP_UI_AGED_SAL_AMT_SUM;
	return('');
end;

function AfterReport return boolean is
begin
--  hr_standard.event('AFTER REPORT');
  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function CP_SALARY_CATEGORY_p return varchar2 is
	Begin
	 return CP_SALARY_CATEGORY;
	 END;
 Function CP_TARGET_YEAR_p return number is
	Begin
	 return CP_TARGET_YEAR;
	 END;
 Function CP_TARGET_MONTH_p return number is
	Begin
	 return CP_TARGET_MONTH;
	 END;
 Function CP_WAI_COUNT_p return number is
	Begin
	 return CP_WAI_COUNT;
	 END;
 Function CP_WAI_SAL_AMT_p return number is
	Begin
	 return CP_WAI_SAL_AMT;
	 END;
 Function CP_UI_COUNT_p return number is
	Begin
	 return CP_UI_COUNT;
	 END;
 Function CP_UI_SAL_AMT_p return number is
	Begin
	 return CP_UI_SAL_AMT;
	 END;
 Function CP_REPORT_TITLE_p return varchar2 is
	Begin
	 return CP_REPORT_TITLE;
	 END;
 Function CP_WAI_SAL_AMT_SUM_p return number is
	Begin
	 return CP_WAI_SAL_AMT_SUM;
	 END;
 Function CP_UI_SAL_AMT_SUM_p return number is
	Begin
	 return CP_UI_SAL_AMT_SUM;
	 END;
 Function CP_UI_AGED_SAL_AMT_SUM_p return number is
	Begin
	 return CP_UI_AGED_SAL_AMT_SUM;
	 END;
 Function CP_UI_NET_SAL_AMT_SUM_p return number is
	Begin
	 return CP_UI_NET_SAL_AMT_SUM;
	 END;
 Function CP_WAI_COUNT_SALARY_AVG_p return number is
	Begin
	 return CP_WAI_COUNT_SALARY_AVG;
	 END;
 Function CP_UI_COUNT_SALARY_AVG_p return number is
	Begin
	 return CP_UI_COUNT_SALARY_AVG;
	 END;
 Function CP_UI_AGED_COUNT_SALARY_AVG_p return number is
	Begin
	 return CP_UI_AGED_COUNT_SALARY_AVG;
	 END;
 Function CP_WAI_COUNT_SALARY_SUM_p return number is
	Begin
	 return CP_WAI_COUNT_SALARY_SUM;
	 END;
 Function CP_UI_COUNT_SALARY_SUM_p return number is
	Begin
	 return CP_UI_COUNT_SALARY_SUM;
	 END;
 Function CP_UI_AGED_COUNT_SALARY_SUM_p return number is
	Begin
	 return CP_UI_AGED_COUNT_SALARY_SUM;
	 END;
 Function CP_NUM_OF_SALARY_MONTHS_p return number is
	Begin
	 return CP_NUM_OF_SALARY_MONTHS;
	 END;
END PAY_PAYJPFLI_XMLP_PKG ;

/
