--------------------------------------------------------
--  DDL for Package Body PQH_PQIPED3_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PQIPED3_XMLP_PKG" AS
/* $Header: PQIPED3B.pls 120.2 2007/12/21 17:23:03 vjaganat noship $ */

function lineFormula return Number is
temp_num number;
begin
  temp_num := line_num;
  line_num:= line_num + 1;
   if line_num = 7 then
     line_num := 8;
   end if;
  return temp_num;
end;

function CF_GroupTotTitleFormula(genCode in varchar2) return char is
l_total_title	VARCHAR2(200)	:= '';
 l_gen_code	VARCHAR2(9)	:= genCode;
begin
  IF 	l_gen_code =  'M' THEN
	l_total_title	:= '7  Total Men';
  ELSIF l_gen_code 	= 'F' THEN
	l_total_title	:= '14 Total Women';
  END IF;

  return l_total_title;


end;

function BeforeReport return boolean is
l_query_text	varchar2(2000);

l_fr	varchar2(2000);
l_ft	varchar2(2000);
l_pr	varchar2(2000);
l_pt	varchar2(2000);


begin
   --hr_standard.event('BEFORE REPORT');
   CP_REPORT_DATE := to_char(P_REPORT_DATE,'DD-MON-YYYY');
line_num :=1;
   pqh_employment_category.fetch_empl_categories(p_business_group_id,l_fr,l_ft,l_pr,l_pt);

   	cp_fr  := l_fr;
	cp_ft	:= l_ft;
	cp_pr	:= l_pr;
	cp_pt	:= l_pt;

  return TRUE;

end;

function AfterReport return boolean is
begin
  --hr_standard.event('AFTER REPORT');

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function line_num_p return number is
	Begin
	 return line_num;
	 END;
 Function CP_TotTitlePerReport_p return varchar2 is
	Begin
	 return CP_TotTitlePerReport;
	 END;
 Function CP_PT_p return varchar2 is
	Begin
	 return CP_PT;
	 END;
 Function CP_PR_p return varchar2 is
	Begin
	 return CP_PR;
	 END;
 Function CP_FT_p return varchar2 is
	Begin
	 return CP_FT;
	 END;
 Function CP_FR_p return varchar2 is
	Begin
	 return CP_FR;
	 END;
 Function ReportTotLineNo_p return number is
	Begin
	 return ReportTotLineNo;
	 END;
END PQH_PQIPED3_XMLP_PKG ;

/
