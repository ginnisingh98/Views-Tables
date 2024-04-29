--------------------------------------------------------
--  DDL for Package Body PER_PERRPPSM_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERRPPSM_XMLP_PKG" AS
/* $Header: PERRPPSMB.pls 120.1 2007/12/06 11:29:43 amakrish noship $ */

function BeforeReport return boolean is
l_date_format varchar2(20):='DD-MON-YYYY';
begin

--c_end_of_time := hr_general.end_of_time;
c_end_of_time :=to_char(to_date(hr_general.end_of_time,l_date_format),'YYYY-MM-DD');

declare
	v_name varchar2(382);
begin


--hr_standard.event('BEFORE REPORT');

/*srw.message('001','start');*/null;


 c_business_group_name :=
   hr_reports.get_business_group(p_business_group_id);
/*srw.message('002','bg');*/null;

P_SESSION_DATE1:=TO_CHAR(P_SESSION_DATE,'DD-MON-YYYY');
  select  peo.first_name ||
	  decode(peo.first_name,null,null,' ') ||
          peo.last_name
  into    v_name
  from    per_all_people_f peo
  where  peo.person_id = p_person_id
  and  p_session_date between peo.effective_start_date
                       and     peo.effective_end_date;
  c_header_name := v_name;
   /*srw.message('003','name');*/null;

  end;


  select org_information10
  into c_currency_code
  from hr_organization_information
  where organization_id = p_business_group_id
  and org_information_context = 'Business Group Information';


 null;


 return (TRUE);
end;

function c_get_flexformula(style in varchar2) return number is
begin

declare
        v_title 		varchar2(240);
        v_label_expr 		varchar2(2000);
        v_column_expr 		varchar2(2000);

	v_aol_seperator_flag	boolean := false;

begin

hr_reports.get_dvlpr_desc_flex(
	 'PER'
	,'Address Structure'
	,style
	,'ADD1'
	,v_aol_seperator_flag
	,v_title
	,v_label_expr
	,v_column_expr
	);

c_details := v_column_expr;

return(0);

end;

RETURN NULL; end;

function c_address_copyformula(conc_address in varchar2) return varchar2 is
begin

return conc_address;
end;

function c_split_flexformula(c_address_copy in varchar2) return number is
begin

declare

v_segments_used NUMBER(10);
v_value1  VARCHAR2(240);
v_value2  VARCHAR2(240);
v_value3 VARCHAR2(240);
v_value4 VARCHAR2(240);
v_value5 VARCHAR2(240);
v_value6 VARCHAR2(240);
v_value7 VARCHAR2(240);
v_value8 VARCHAR2(240);
v_value9 VARCHAR2(240);
v_value10 VARCHAR2(240);
v_value11 VARCHAR2(240);
v_value12 VARCHAR2(240);
v_value13 VARCHAR2(240);
v_value14 VARCHAR2(240);
v_value15 VARCHAR2(240);
v_value16 VARCHAR2(240);
v_value17 VARCHAR2(240);
v_value18 VARCHAR2(240);
v_value19 VARCHAR2(240);
v_value20 VARCHAR2(240);
v_value21 VARCHAR2(240);
v_value22 VARCHAR2(240);
v_value23 VARCHAR2(240);
v_value24 VARCHAR2(240);
v_value25 VARCHAR2(240);
v_value26 VARCHAR2(240);
v_value27 VARCHAR2(240);
v_value28 VARCHAR2(240);
v_value29 VARCHAR2(240);
v_value30 VARCHAR2(240);

v_aol_seperator_flag	boolean := false;

begin
/*srw.message('001','addr='||c_address_copy);*/null;

hr_reports.get_attributes(
c_address_copy,
'Address Structure',
v_aol_seperator_flag,
v_segments_used,
v_value1,
v_value2,
v_value3,
v_value4,
v_value5,
v_value6,
v_value7,
v_value8,
v_value9,
v_value10,
v_value11,
v_value12,
v_value13,
v_value14,
v_value15,
v_value16,
v_value17,
v_value18,
v_value19,
v_value20,
v_value21,
v_value22,
v_value23,
v_value24,
v_value25,
v_value26,
v_value27,
v_value28,
v_value29,
v_value30);

c_address1 := v_value1;
c_address2 := v_value2;
c_address3 := v_value3;
c_address4 := v_value4;
c_address5 := v_value5;
c_address6 := v_value6;
c_address7 := v_value7;
c_address8 := v_value8;
c_address9 := v_value9;
c_address10 := v_value10;
c_address11 := v_value11;
c_address12 := v_value12;
c_address13 := v_value13;
c_address14 := v_value14;
c_address15 := v_value15;
c_address16 := v_value16;
c_address17 := v_value17;
c_address18 := v_value18;
c_address19 := v_value19;
c_address20 := v_value20;

if c_address7 = 'GB' and c_address5 is not null then      select meaning
     into c_address5
     from fnd_common_lookups
     where lookup_type = 'GB_COUNTY'
     and lookup_code = c_address5;
end if;

return(0);

end;

RETURN NULL; end;

function c_get_cont_flexformula(style1 in varchar2) return number is
begin

declare
        v_title varchar2(240);
        v_label_expr varchar2(20000);
        v_column_expr varchar2(20000);
begin
hr_reports.get_dvlpr_desc_flex('PER','Address Structure',style1,
'ADD1',v_title,v_label_expr,v_column_expr);
c_cont_details := v_column_expr;
end;

RETURN NULL; end;

function c_cont_copyformula(conc_cont_address in varchar2) return varchar2 is
begin

return conc_cont_address;
end;

function c_cont_split_flexformula(c_cont_copy in varchar2) return number is
begin

declare

v_segments_used NUMBER;
v_value1  VARCHAR2(240);
v_value2  VARCHAR2(240);
v_value3 VARCHAR2(240);
v_value4 VARCHAR2(240);
v_value5 VARCHAR2(240);
v_value6 VARCHAR2(240);
v_value7 VARCHAR2(240);
v_value8 VARCHAR2(240);
v_value9 VARCHAR2(240);
v_value10 VARCHAR2(240);
v_value11 VARCHAR2(240);
v_value12 VARCHAR2(240);
v_value13 VARCHAR2(240);
v_value14 VARCHAR2(240);
v_value15 VARCHAR2(240);
v_value16 VARCHAR2(240);
v_value17 VARCHAR2(240);
v_value18 VARCHAR2(240);
v_value19 VARCHAR2(240);
v_value20 VARCHAR2(240);
v_value21 VARCHAR2(240);
v_value22 VARCHAR2(240);
v_value23 VARCHAR2(240);
v_value24 VARCHAR2(240);
v_value25 VARCHAR2(240);
v_value26 VARCHAR2(240);
v_value27 VARCHAR2(240);
v_value28 VARCHAR2(240);
v_value29 VARCHAR2(240);
v_value30 VARCHAR2(240);

begin
hr_reports.get_attributes(
c_cont_copy,
'Address Structure',
v_segments_used,
v_value1,
v_value2,
v_value3,
v_value4,
v_value5,
v_value6,
v_value7,
v_value8,
v_value9,
v_value10,
v_value11,
v_value12,
v_value13,
v_value14,
v_value15,
v_value16,
v_value17,
v_value18,
v_value19,
v_value20,
v_value21,
v_value22,
v_value23,
v_value24,
v_value25,
v_value26,
v_value27,
v_value28,
v_value29,
v_value30);

c_cont_address1 := v_value1;
c_cont_address2 := v_value2;
c_cont_address3 := v_value3;
c_cont_address4 := v_value4;
c_cont_address5 := v_value5;
c_cont_address6 := v_value6;
c_cont_address6 := v_value6;
c_cont_address7 := v_value7;
c_cont_address8 := v_value8;
c_cont_address9 := v_value9;
c_cont_address10 := v_value10;
c_cont_address11 := v_value11;
c_cont_address12 := v_value12;
c_cont_address13 := v_value13;
c_cont_address14 := v_value14;
c_cont_address15 := v_value15;
c_cont_address16 := v_value16;
c_cont_address17 := v_value17;
c_cont_address18 := v_value18;
c_cont_address19 := v_value19;
c_cont_address20 := v_value20;

return(0);

end;

RETURN NULL; end;

function C_SPECIAL_INFO_SEGSFormula return Number is
begin



return(0);

end;

function add_line(p_add_line varchar2)
return BOOLEAN is
begin
if p_add_line is null then
   return(FALSE);
else
   return(TRUE);
end if;
RETURN NULL; end;

function set_pay_meth_count(p_assignment_id in number) return number is
v_count number;
begin
select count(*)
into v_count
from   pay_personal_payment_methods_f ppm
,      pay_org_payment_methods_f opm
,      pay_payment_types pt
where  ppm.business_group_id = p_business_group_id
and    ppm.assignment_id = p_assignment_id
and    p_session_date between ppm.effective_start_date
		       and     ppm.effective_end_date
and    p_session_date between opm.effective_start_date
                       and     opm.effective_end_date
and    ppm.org_payment_method_id = opm.org_payment_method_id
and    opm.payment_type_id = pt.payment_type_id;
return( v_count);
end;

function C_PAY_METH2Formula (assignment_id in number)return Number is
begin

return(set_pay_meth_count(assignment_id) );
end;

function AfterReport return boolean is
begin

--hr_standard.event('AFTER REPORT');

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_address1_p return varchar2 is
	Begin
	 return C_address1;
	 END;
 Function C_address2_p return varchar2 is
	Begin
	 return C_address2;
	 END;
 Function C_address3_p return varchar2 is
	Begin
	 return C_address3;
	 END;
 Function C_address4_p return varchar2 is
	Begin
	 return C_address4;
	 END;
 Function C_address5_p return varchar2 is
	Begin
	 return C_address5;
	 END;
 Function C_address6_p return varchar2 is
	Begin
	 return C_address6;
	 END;
 Function C_address7_p return varchar2 is
	Begin
	 return C_address7;
	 END;
 Function C_address8_p return varchar2 is
	Begin
	 return C_address8;
	 END;
 Function C_address9_p return varchar2 is
	Begin
	 return C_address9;
	 END;
 Function C_address10_p return varchar2 is
	Begin
	 return C_address10;
	 END;
 Function C_address11_p return varchar2 is
	Begin
	 return C_address11;
	 END;
 Function C_address12_p return varchar2 is
	Begin
	 return C_address12;
	 END;
 Function C_address13_p return varchar2 is
	Begin
	 return C_address13;
	 END;
 Function C_address14_p return varchar2 is
	Begin
	 return C_address14;
	 END;
 Function C_address15_p return varchar2 is
	Begin
	 return C_address15;
	 END;
 Function C_address16_p return varchar2 is
	Begin
	 return C_address16;
	 END;
 Function C_address17_p return varchar2 is
	Begin
	 return C_address17;
	 END;
 Function C_address18_p return varchar2 is
	Begin
	 return C_address18;
	 END;
 Function C_address19_p return varchar2 is
	Begin
	 return C_address19;
	 END;
 Function C_address20_p return varchar2 is
	Begin
	 return C_address20;
	 END;
 Function C_cont_address1_p return varchar2 is
	Begin
	 return C_cont_address1;
	 END;
 Function C_cont_address2_p return varchar2 is
	Begin
	 return C_cont_address2;
	 END;
 Function C_cont_address3_p return varchar2 is
	Begin
	 return C_cont_address3;
	 END;
 Function C_cont_address4_p return varchar2 is
	Begin
	 return C_cont_address4;
	 END;
 Function C_cont_address5_p return varchar2 is
	Begin
	 return C_cont_address5;
	 END;
 Function C_cont_address6_p return varchar2 is
	Begin
	 return C_cont_address6;
	 END;
 Function C_cont_address7_p return varchar2 is
	Begin
	 return C_cont_address7;
	 END;
 Function C_cont_address8_p return varchar2 is
	Begin
	 return C_cont_address8;
	 END;
 Function C_cont_address9_p return varchar2 is
	Begin
	 return C_cont_address9;
	 END;
 Function C_cont_address10_p return varchar2 is
	Begin
	 return C_cont_address10;
	 END;
 Function C_cont_address11_p return varchar2 is
	Begin
	 return C_cont_address11;
	 END;
 Function C_cont_address12_p return varchar2 is
	Begin
	 return C_cont_address12;
	 END;
 Function C_cont_address13_p return varchar2 is
	Begin
	 return C_cont_address13;
	 END;
 Function C_cont_address14_p return varchar2 is
	Begin
	 return C_cont_address14;
	 END;
 Function C_cont_address15_p return varchar2 is
	Begin
	 return C_cont_address15;
	 END;
 Function C_cont_address16_p return varchar2 is
	Begin
	 return C_cont_address16;
	 END;
 Function C_cont_address17_p return varchar2 is
	Begin
	 return C_cont_address17;
	 END;
 Function C_cont_address18_p return varchar2 is
	Begin
	 return C_cont_address18;
	 END;
 Function C_cont_address19_p return varchar2 is
	Begin
	 return C_cont_address19;
	 END;
 Function C_cont_address20_p return varchar2 is
	Begin
	 return C_cont_address20;
	 END;
 Function C_BUSINESS_GROUP_NAME_p return varchar2 is
	Begin
	 return C_BUSINESS_GROUP_NAME;
	 END;
 Function C_details_p return varchar2 is
	Begin
	 return C_details;
	 END;
 Function C_cont_details_p return varchar2 is
	Begin
	 return C_cont_details;
	 END;
 Function C_requirement_desc_p return varchar2 is
	Begin
	 return C_requirement_desc;
	 END;
 Function C_requirement_value_p return varchar2 is
	Begin
	 return C_requirement_value;
	 END;
 Function C_header_name_p return varchar2 is
	Begin
	 return C_header_name;
	 END;
 Function C_pay_meth_count_p return number is
	Begin
	 return C_pay_meth_count;
	 END;
 Function C_END_OF_TIME_p return varchar2 is
	Begin
	 return C_END_OF_TIME;
	 END;
 Function C_currency_code_p return varchar2 is
	Begin
	 return C_currency_code;
	 END;
END PER_PERRPPSM_XMLP_PKG ;

/
