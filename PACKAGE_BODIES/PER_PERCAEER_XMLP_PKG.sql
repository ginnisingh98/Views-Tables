--------------------------------------------------------
--  DDL for Package Body PER_PERCAEER_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERCAEER_XMLP_PKG" AS
/* $Header: PERCAEERB.pls 120.0 2007/12/28 06:53:38 srikrish noship $ */

function BeforeReport return boolean is
begin
P_SESSION_DATE1:=TO_CHAR(P_SESSION_DATE,'DD-MON-YYYY');
--hr_standard.event('BEFORE REPORT');
P_CONC_REQUEST_ID := fnd_global.CONC_REQUEST_ID;
declare

  ret number;
  l_gre_name	per_ca_ee_extract_pkg.tab_varchar2;

begin

 null;
 c_business_group_name :=
   hr_reports.get_business_group(p_business_group_id);



ret := per_ca_ee_extract_pkg.check_gre_without_naic(p_business_group_id,
                                                 l_gre_name) ;
if ret = -1 then
   /*srw.message(1,'The following GRE(s) has NAIC missing: ');*/null;

   for i in 1..l_gre_name.count loop
     /*srw.message(2,l_gre_name(i));*/null;

   end loop;

  return (FALSE);
else

ret := per_ca_ee_extract_pkg.form1(p_business_group_id,
			 p_conc_request_id,
			 p_year,
                         p_naic_code,
                         fnd_date.canonical_to_date(p_date_all_emp),
                         fnd_date.canonical_to_date(p_date_tmp_emp));

ret := per_ca_ee_extract_pkg.form2n(p_business_group_id,
			p_conc_request_id,
			 p_year,
                         fnd_date.canonical_to_date(p_date_tmp_emp));

ret := per_ca_ee_extract_pkg.form2(p_business_group_id,
			 p_conc_request_id,
			 p_year,
                         fnd_date.canonical_to_date(p_date_tmp_emp));



ret := per_ca_ee_extract_pkg.form3(p_business_group_id,
			 p_conc_request_id,
			 p_year,
                         fnd_date.canonical_to_date(p_date_tmp_emp));

ret := per_ca_ee_extract_pkg.form4(p_business_group_id,
			 p_conc_request_id,
			 p_year,
                         fnd_date.canonical_to_date(p_date_tmp_emp));
ret := per_ca_ee_extract_pkg.form5(p_business_group_id,
			 p_conc_request_id,
			 p_year,
                         fnd_date.canonical_to_date(p_date_tmp_emp));
ret := per_ca_ee_extract_pkg.form6(p_business_group_id,
			 p_conc_request_id,
			 p_year,
                         fnd_date.canonical_to_date(p_date_tmp_emp));
ret := per_ca_ee_extract_pkg.update_rec(p_conc_request_id);
return (TRUE);
end if;
end;  end;

function CF_f5_n_promptFormula return Char is
begin
declare
  cursor cur_data is select
   'TOTAL NO OF PROMOTIONS' from dual;

  l_string		varchar2(30);
begin
  open cur_data;
  fetch cur_data into l_string;
  close cur_data;

   return l_string;

end;
end;

function cf_f5_n_totalformula(f4_n_type in varchar2) return number is
begin
declare
  cursor cur_f5_n_total is
  select
    to_number(segment3) from
   per_ca_ee_report_lines where
   request_id = p_conc_request_id and
   context = 'FORM5P' and
   substr(f4_n_type,1,5) = 'FORM5' and
   segment1 = 'NATIONAL' and
   segment2 =decode(substr(f4_n_type,6,1),'A','FR','B','PR','C','PT');

   v_temp number;

begin

  open cur_f5_n_total;
  fetch cur_f5_n_total into v_temp;
  close cur_f5_n_total;

   return v_temp;
end;
end;

function cf_f5_n_totmaformula(f4_n_type in varchar2) return number is
begin
declare
  cursor cur_f5_n_total is
  select
    to_number(segment4) from
   per_ca_ee_report_lines where
   request_id = p_conc_request_id and
   context = 'FORM5P' and
   substr(f4_n_type,1,5) = 'FORM5' and
   segment1 = 'NATIONAL' and
   segment2 =decode(substr(f4_n_type,6,1),'A','FR','B','PR','C','PT');

   v_temp number;

begin

  open cur_f5_n_total;
  fetch cur_f5_n_total into v_temp;
  close cur_f5_n_total;

   return v_temp;
end;
end;

function cf_f5_n_totfeformula(f4_n_type in varchar2) return number is
begin
declare
  cursor cur_f5_n_total is
  select
    to_number(segment5) from
   per_ca_ee_report_lines where
   request_id = p_conc_request_id and
   context = 'FORM5P' and
   substr(f4_n_type,1,5) = 'FORM5' and
   segment1 = 'NATIONAL' and
   segment2 =decode(substr(f4_n_type,6,1),'A','FR','B','PR','C','PT');

   v_temp number;

begin

  open cur_f5_n_total;
  fetch cur_f5_n_total into v_temp;
  close cur_f5_n_total;

   return v_temp;
end;
end;

function cf_f5_n_totabformula(f4_n_type in varchar2) return number is
begin
declare
  cursor cur_f5_n_total is
  select
    to_number(segment6) from
   per_ca_ee_report_lines where
   request_id = p_conc_request_id and
   context = 'FORM5P' and
   substr(f4_n_type,1,5) = 'FORM5' and
   segment1 = 'NATIONAL' and
   segment2 =decode(substr(f4_n_type,6,1),'A','FR','B','PR','C','PT');

   v_temp number;

begin

  open cur_f5_n_total;
  fetch cur_f5_n_total into v_temp;
  close cur_f5_n_total;

   return v_temp;
end;
end;

function cf_f5_n_maabformula(f4_n_type in varchar2) return number is
begin
declare
  cursor cur_f5_n_total is
  select
    to_number(segment7) from
   per_ca_ee_report_lines where
   request_id = p_conc_request_id and
   context = 'FORM5P' and
   substr(f4_n_type,1,5) = 'FORM5' and
   segment1 = 'NATIONAL' and
   segment2 =decode(substr(f4_n_type,6,1),'A','FR','B','PR','C','PT');

   v_temp number;

begin

  open cur_f5_n_total;
  fetch cur_f5_n_total into v_temp;
  close cur_f5_n_total;

   return v_temp;
end;
end;

function cf_f5_n_feabformula(f4_n_type in varchar2) return number is
begin
declare
  cursor cur_f5_n_total is
  select
    to_number(segment8) from
   per_ca_ee_report_lines where
   request_id = p_conc_request_id and
   context = 'FORM5P' and
   substr(f4_n_type,1,5) = 'FORM5' and
   segment1 = 'NATIONAL' and
   segment2 =decode(substr(f4_n_type,6,1),'A','FR','B','PR','C','PT');

   v_temp number;

begin

  open cur_f5_n_total;
  fetch cur_f5_n_total into v_temp;
  close cur_f5_n_total;

   return v_temp;
end;
end;

function cf_f5_n_totviformula(f4_n_type in varchar2) return number is
begin
declare
  cursor cur_f5_n_total is
  select
    to_number(segment9) from
   per_ca_ee_report_lines where
   request_id = p_conc_request_id and
   context = 'FORM5P' and
   substr(f4_n_type,1,5) = 'FORM5' and
   segment1 = 'NATIONAL' and
   segment2 =decode(substr(f4_n_type,6,1),'A','FR','B','PR','C','PT');

   v_temp number;

begin

  open cur_f5_n_total;
  fetch cur_f5_n_total into v_temp;
  close cur_f5_n_total;

   return v_temp;
end;
end;

function cf_f5_n_maviformula(f4_n_type in varchar2) return number is
begin
declare
  cursor cur_f5_n_total is
  select
    to_number(segment10) from
   per_ca_ee_report_lines where
   request_id = p_conc_request_id and
   context = 'FORM5P' and
   substr(f4_n_type,1,5) = 'FORM5' and
   segment1 = 'NATIONAL' and
   segment2 =decode(substr(f4_n_type,6,1),'A','FR','B','PR','C','PT');

   v_temp number;

begin

  open cur_f5_n_total;
  fetch cur_f5_n_total into v_temp;
  close cur_f5_n_total;

   return v_temp;
end;
end;

function cf_f5_n_feviformula(f4_n_type in varchar2) return number is
begin
declare
  cursor cur_f5_n_total is
  select
    to_number(segment11) from
   per_ca_ee_report_lines where
   request_id = p_conc_request_id and
   context = 'FORM5P' and
   substr(f4_n_type,1,5) = 'FORM5' and
   segment1 = 'NATIONAL' and
   segment2 =decode(substr(f4_n_type,6,1),'A','FR','B','PR','C','PT');

   v_temp number;

begin

  open cur_f5_n_total;
  fetch cur_f5_n_total into v_temp;
  close cur_f5_n_total;

   return v_temp;
end;
end;

function cf_f5_n_totdiformula(f4_n_type in varchar2) return number is
begin
declare
  cursor cur_f5_n_total is
  select
    to_number(segment12) from
   per_ca_ee_report_lines where
   request_id = p_conc_request_id and
   context = 'FORM5P' and
   substr(f4_n_type,1,5) = 'FORM5' and
   segment1 = 'NATIONAL' and
   segment2 =decode(substr(f4_n_type,6,1),'A','FR','B','PR','C','PT');

   v_temp number;

begin

  open cur_f5_n_total;
  fetch cur_f5_n_total into v_temp;
  close cur_f5_n_total;

   return v_temp;
end;
end;

function cf_f5_n_madiformula(f4_n_type in varchar2) return number is
begin
declare
  cursor cur_f5_n_total is
  select
    to_number(segment13) from
   per_ca_ee_report_lines where
   request_id = p_conc_request_id and
   context = 'FORM5P' and
   substr(f4_n_type,1,5) = 'FORM5' and
   segment1 = 'NATIONAL' and
   segment2 =decode(substr(f4_n_type,6,1),'A','FR','B','PR','C','PT');

   v_temp number;

begin

  open cur_f5_n_total;
  fetch cur_f5_n_total into v_temp;
  close cur_f5_n_total;

   return v_temp;
end;
end;

function cf_f5_n_fediformula(f4_n_type in varchar2) return number is
begin
declare
  cursor cur_f5_n_total is
  select
    to_number(segment14) from
   per_ca_ee_report_lines where
   request_id = p_conc_request_id and
   context = 'FORM5P' and
   substr(f4_n_type,1,5) = 'FORM5' and
   segment1 = 'NATIONAL' and
   segment2 =decode(substr(f4_n_type,6,1),'A','FR','B','PR','C','PT');

   v_temp number;

begin

  open cur_f5_n_total;
  fetch cur_f5_n_total into v_temp;
  close cur_f5_n_total;

   return v_temp;
end;
end;

function cf_f5_p_totalformula(f4_p_type in varchar2, f4_p_name1 in varchar2) return number is
begin
declare
  cursor cur_f5_n_total is
  select
    to_number(segment4) from
   per_ca_ee_report_lines where
   request_id = p_conc_request_id and
   context = 'FORM5P' and
   substr(f4_p_type,1,5) = 'FORM5' and
   segment1 = 'PROVINCE' and
   segment2 = f4_p_name1 and
   segment3 =decode(substr(f4_p_type,6,1),'A','FR','B','PR','C','PT');

   v_temp number;

begin

  open cur_f5_n_total;
  fetch cur_f5_n_total into v_temp;
  close cur_f5_n_total;

   return v_temp;
end;
end;

function cf_f5_p_totmaformula(f4_p_type in varchar2, f4_p_name1 in varchar2) return number is
begin
declare
  cursor cur_f5_n_total is
  select
    to_number(segment5) from
   per_ca_ee_report_lines where
   request_id = p_conc_request_id and
   context = 'FORM5P' and
   substr(f4_p_type,1,5) = 'FORM5' and
   segment1 = 'PROVINCE' and
   segment2 = f4_p_name1 and
   segment3 =decode(substr(f4_p_type,6,1),'A','FR','B','PR','C','PT');

   v_temp number;

begin

  open cur_f5_n_total;
  fetch cur_f5_n_total into v_temp;
  close cur_f5_n_total;

   return v_temp;
end;
end;

function cf_f5_p_totfeformula(f4_p_type in varchar2, f4_p_name1 in varchar2) return number is
begin
declare
  cursor cur_f5_n_total is
  select
    to_number(segment6) from
   per_ca_ee_report_lines where
   request_id = p_conc_request_id and
   context = 'FORM5P' and
   substr(f4_p_type,1,5) = 'FORM5' and
   segment1 = 'PROVINCE' and
   segment2 = f4_p_name1 and
   segment3 =decode(substr(f4_p_type,6,1),'A','FR','B','PR','C','PT');

   v_temp number;

begin

  open cur_f5_n_total;
  fetch cur_f5_n_total into v_temp;
  close cur_f5_n_total;

   return v_temp;
end;
end;

function cf_f5_p_totabformula(f4_p_type in varchar2, f4_p_name1 in varchar2) return number is
begin
declare
  cursor cur_f5_n_total is
  select
    to_number(segment7) from
   per_ca_ee_report_lines where
   request_id = p_conc_request_id and
   context = 'FORM5P' and
   substr(f4_p_type,1,5) = 'FORM5' and
   segment1 = 'PROVINCE' and
   segment2 = f4_p_name1 and
   segment3 =decode(substr(f4_p_type,6,1),'A','FR','B','PR','C','PT');

   v_temp number;

begin

  open cur_f5_n_total;
  fetch cur_f5_n_total into v_temp;
  close cur_f5_n_total;

   return v_temp;
end;
end;

function cf_f5_p_maabformula(f4_p_type in varchar2, f4_p_name1 in varchar2) return number is
begin
declare
  cursor cur_f5_n_total is
  select
    to_number(segment8) from
   per_ca_ee_report_lines where
   request_id = p_conc_request_id and
   context = 'FORM5P' and
   substr(f4_p_type,1,5) = 'FORM5' and
   segment1 = 'PROVINCE' and
   segment2 = f4_p_name1 and
   segment3 =decode(substr(f4_p_type,6,1),'A','FR','B','PR','C','PT');

   v_temp number;

begin

  open cur_f5_n_total;
  fetch cur_f5_n_total into v_temp;
  close cur_f5_n_total;

   return v_temp;
end;
end;

function cf_f5_p_feabformula(f4_p_type in varchar2, f4_p_name1 in varchar2) return number is
begin
declare
  cursor cur_f5_n_total is
  select
    to_number(segment9) from
   per_ca_ee_report_lines where
   request_id = p_conc_request_id and
   context = 'FORM5P' and
   substr(f4_p_type,1,5) = 'FORM5' and
   segment1 = 'PROVINCE' and
   segment2 = f4_p_name1 and
   segment3 =decode(substr(f4_p_type,6,1),'A','FR','B','PR','C','PT');

   v_temp number;

begin

  open cur_f5_n_total;
  fetch cur_f5_n_total into v_temp;
  close cur_f5_n_total;

   return v_temp;
end;
end;

function cf_f5_p_totdiformula(f4_p_type in varchar2, f4_p_name1 in varchar2) return number is
begin
declare
  cursor cur_f5_n_total is
  select
    to_number(segment13) from
   per_ca_ee_report_lines where
   request_id = p_conc_request_id and
   context = 'FORM5P' and
   substr(f4_p_type,1,5) = 'FORM5' and
   segment1 = 'PROVINCE' and
   segment2 = f4_p_name1 and
   segment3 =decode(substr(f4_p_type,6,1),'A','FR','B','PR','C','PT');

   v_temp number;

begin

  open cur_f5_n_total;
  fetch cur_f5_n_total into v_temp;
  close cur_f5_n_total;

   return v_temp;
end;
end;

function cf_f5_p_madiformula(f4_p_type in varchar2, f4_p_name1 in varchar2) return number is
begin
declare
  cursor cur_f5_n_total is
  select
    to_number(segment14) from
   per_ca_ee_report_lines where
   request_id = p_conc_request_id and
   context = 'FORM5P' and
   substr(f4_p_type,1,5) = 'FORM5' and
   segment1 = 'PROVINCE' and
   segment2 = f4_p_name1 and
   segment3 =decode(substr(f4_p_type,6,1),'A','FR','B','PR','C','PT');

   v_temp number;

begin

  open cur_f5_n_total;
  fetch cur_f5_n_total into v_temp;
  close cur_f5_n_total;

   return v_temp;
end;
end;

function cf_f5_p_fediformula(f4_p_type in varchar2, f4_p_name1 in varchar2) return number is
begin
declare
  cursor cur_f5_n_total is
  select
    to_number(segment15) from
   per_ca_ee_report_lines where
   request_id = p_conc_request_id and
   context = 'FORM5P' and
   substr(f4_p_type,1,5) = 'FORM5' and
   segment1 = 'PROVINCE' and
   segment2 = f4_p_name1 and
   segment3 =decode(substr(f4_p_type,6,1),'A','FR','B','PR','C','PT');

   v_temp number;

begin

  open cur_f5_n_total;
  fetch cur_f5_n_total into v_temp;
  close cur_f5_n_total;

   return v_temp;
end;
end;

function cf_f5_p_totviformula(f4_p_type in varchar2, f4_p_name1 in varchar2) return number is
begin
declare
  cursor cur_f5_n_total is
  select
    to_number(segment10) from
   per_ca_ee_report_lines where
   request_id = p_conc_request_id and
   context = 'FORM5P' and
   substr(f4_p_type,1,5) = 'FORM5' and
   segment1 = 'PROVINCE' and
   segment2 = f4_p_name1 and
   segment3 =decode(substr(f4_p_type,6,1),'A','FR','B','PR','C','PT');

   v_temp number;

begin

  open cur_f5_n_total;
  fetch cur_f5_n_total into v_temp;
  close cur_f5_n_total;

   return v_temp;
end;
end;

function cf_f5_p_maviformula(f4_p_type in varchar2, f4_p_name1 in varchar2) return number is
begin
declare
  cursor cur_f5_n_total is
  select
    to_number(segment11) from
   per_ca_ee_report_lines where
   request_id = p_conc_request_id and
   context = 'FORM5P' and
   substr(f4_p_type,1,5) = 'FORM5' and
   segment1 = 'PROVINCE' and
   segment2 = f4_p_name1 and
   segment3 =decode(substr(f4_p_type,6,1),'A','FR','B','PR','C','PT');

   v_temp number;

begin

  open cur_f5_n_total;
  fetch cur_f5_n_total into v_temp;
  close cur_f5_n_total;

   return v_temp;
end;
end;

function cf_f5_p_feviformula(f4_p_type in varchar2, f4_p_name1 in varchar2) return number is
begin
declare
  cursor cur_f5_n_total is
  select
    to_number(segment12) from
   per_ca_ee_report_lines where
   request_id = p_conc_request_id and
   context = 'FORM5P' and
   substr(f4_p_type,1,5) = 'FORM5' and
   segment1 = 'PROVINCE' and
   segment2 = f4_p_name1 and
   segment3 =decode(substr(f4_p_type,6,1),'A','FR','B','PR','C','PT');

   v_temp number;

begin

  open cur_f5_n_total;
  fetch cur_f5_n_total into v_temp;
  close cur_f5_n_total;

   return v_temp;
end;
end;

function CF_f5_p_promptFormula return Char is
begin
declare
  cursor cur_data is select
   'TOTAL NUMBER OF PROMOTIONS' from dual;

  l_string		varchar2(30);
begin
  open cur_data;
  fetch cur_data into l_string;
  close cur_data;

   return l_string;

end;
end;

function AfterReport return boolean is
begin

  /*SRW.DO_SQL('DELETE per_ca_ee_report_lines
	      WHERE request_id = :p_conc_request_id');*/null;


 --hr_standard.event('AFTER REPORT');
 return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_BUSINESS_GROUP_NAME_p return varchar2 is
	Begin
	 return C_BUSINESS_GROUP_NAME;
	 END;
 Function C_REPORT_SUBTITLE_p return varchar2 is
	Begin
	 return C_REPORT_SUBTITLE;
	 END;
END PER_PERCAEER_XMLP_PKG ;

/
