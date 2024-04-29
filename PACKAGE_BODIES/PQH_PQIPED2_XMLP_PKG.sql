--------------------------------------------------------
--  DDL for Package Body PQH_PQIPED2_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PQIPED2_XMLP_PKG" AS
/* $Header: PQIPED2B.pls 120.1 2007/12/21 17:23:18 vjaganat noship $ */

function lineFormula return Number is
temp_num number;

begin
  if (line_num < 29) then
  temp_num := line_num;
  line_num:= line_num + 1;
  elsif (line_num between 29 and 40) then
    temp_num := tmp_var;
    tmp_var := tmp_var + 1;
    line_num := line_num + 1;
  else
    temp_num := tmp_var1;
    tmp_var1 := tmp_var1 + 1;
  end if;
   if (tmp_var = 36) then
     tmp_var := 38;
   end if;
  return temp_num;

end;

function CF_totTitleFormula(orgCode in varchar2) return Char is
 l_total_title	VARCHAR2(200)	:= '';
 l_org_code	VARCHAR2(9)	:= orgCode;
begin
  IF 	l_org_code =  'MED' THEN
	l_total_title	:= '48 Total Medical Only';
  ELSIF l_org_code 	= 'NON-MED' THEN
	l_total_title	:= '36 Total Non-Medical';
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
    P_REPORT_DATE_T := to_char(P_REPORT_DATE,'DD-MON-YYYY');
   --hr_standard.event('BEFORE REPORT');

   pqh_employment_category.fetch_empl_categories(p_business_group_id,l_fr,l_ft,l_pr,l_pt);

   	cp_fr  := l_fr;
	cp_ft	:= l_ft;
	cp_pr	:= l_pr;
	cp_pt	:= l_pt;

  return true;
end;

function CF_dispNameFormula(orgCode in varchar2) return Char is
 l_disp_title	VARCHAR2(200)	:= '';
 l_org_code	VARCHAR2(9)	:= orgCode;
begin
  IF 	l_org_code =  'MED' THEN
	l_disp_title	:= '37 Instruction Combined with Research and/or Public Service';
  ELSIF l_org_code 	= 'NON-MED' THEN
	l_disp_title	:= '25 Instruction Combined with Research and/or Public Service';
  END IF;

  return l_disp_title;
end;

function cf_faculty_totformula(SumFacultyTenured in number, SumFacultyOnTen in number, SumFacultyNotOnTen in number) return number is
begin
  return (SumFacultyTenured + SumFacultyOnTen + SumFacultyNotOnTen);
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
 Function CP_FR_p return varchar2 is
	Begin
	 return CP_FR;
	 END;
 Function CP_FT_p return varchar2 is
	Begin
	 return CP_FT;
	 END;
 Function CP_PR_p return varchar2 is
	Begin
	 return CP_PR;
	 END;
 Function CP_PT_p return varchar2 is
	Begin
	 return CP_PT;
	 END;
 Function tmp_var_p return number is
	Begin
	 return tmp_var;
	 END;
 Function tmp_var1_p return number is
	Begin
	 return tmp_var1;
	 END;
 Function CP_NonFacInstr_p return number is
	Begin
	 return CP_NonFacInstr;
	 END;
END PQH_PQIPED2_XMLP_PKG ;

/
