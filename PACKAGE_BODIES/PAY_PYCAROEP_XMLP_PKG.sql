--------------------------------------------------------
--  DDL for Package Body PAY_PYCAROEP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PYCAROEP_XMLP_PKG" AS
/* $Header: PYCAROEPB.pls 120.0 2007/12/28 06:48:37 srikrish noship $ */

function BeforeReport return boolean is

CURSOR csr_get_trace_param is
select upper(parameter_value)
from pay_action_parameters
where parameter_name='TRACE';

CURSOR csr_get_person(p_person_id number) is
select full_name
from per_all_people_f
where person_id=p_person_id;

CURSOR csr_get_sel_type(p_selection_type varchar2) is
select meaning
from hr_lookups
where lookup_type = 'PAY_CA_ROE_SELECTION_TYPE'
  and lookup_code = p_selection_type;

l_person varchar2(320);
l_trace  varchar2(30);
l_asg_set varchar2(50);
l_selection_type varchar2(80);


CURSOR csr_get_asg_set(p_assignment_set number) is
select assignment_set_name
from hr_assignment_sets
where assignment_set_id = p_assignment_set;

begin
--hr_standard.event('BEFORE REPORT');
 null;
 c_business_group_name := hr_reports.get_business_group(p_business_group_id);


  If fnd_number.canonical_to_number(P_PERSON_ID) is not NULL then

     Open csr_get_person(fnd_number.canonical_to_number(P_PERSON_ID));
     Fetch csr_get_person into l_person;
     If csr_get_person%notfound then
   	close csr_get_person;
     End if;

     CP_PERSON := l_person;

  End if;

  IF fnd_number.canonical_to_number(P_ASSIGNMENT_SET) is not NULL then

     open csr_get_asg_set(fnd_number.canonical_to_number(P_ASSIGNMENT_SET));
     Fetch csr_get_asg_set into l_asg_set;
     If csr_get_asg_set%notfound then
        close csr_get_asg_set;
     Else
        close csr_get_asg_set;
     End if;

     CP_assignment_set_name := l_asg_set;

  End if;

  IF p_selection_type is not null then

     open csr_get_sel_type(p_selection_type);
     Fetch csr_get_sel_type into l_selection_type;
     If csr_get_sel_type%notfound then
        close csr_get_sel_type;
     Else
        close csr_get_sel_type;
     End if;

     CP_selection_type := l_selection_type;

  End if;

  CP_start_date := fnd_date.canonical_to_date(p_start_date);
  CP_end_date := fnd_date.canonical_to_date(p_end_date);


  Open csr_get_trace_param;
  Fetch csr_get_trace_param into l_trace;
  If l_trace = 'Y' then
	/*srw.do_sql('Alter session set SQL_TRACE true');*/null;
--Added during DT Fix
execute immediate('Alter session set SQL_TRACE true') ;
--End of DT Fix
  End if;

return (TRUE);
end;

function AfterPForm return boolean is
 l_person varchar2(30);
begin


  If ((P_START_DATE is not NULL) and (P_END_DATE is not NULL)) then
	begin
	If P_PERSON_ID IS NOT NULL then
	  LP_DATE_OR_PERSON := ' AND fnd_date.canonical_to_date(pcrv.roe_date) BETWEEN fnd_date.canonical_TO_DATE(:P_START_DATE) '||
                                ' AND fnd_date.canonical_TO_DATE(:P_END_DATE)'||
			        ' AND paf.person_id=to_number(:P_PERSON_ID)';

	Elsif P_ASSIGNMENT_SET is NOT NULL then
          LP_ASSIGNMENT_SET := ', HR_ASSIGNMENT_SET_AMENDMENTS  haa';
	  LP_DATE_OR_PERSON := ' AND fnd_date.canonical_to_date(pcrv.roe_date) BETWEEN fnd_date.canonical_to_DATE(:P_START_DATE) AND fnd_date.canonical_TO_DATE(:P_END_DATE)'||
                                ' AND haa.assignment_id = paf.assignment_id AND haa.include_or_exclude = ''I''' ||
                                ' AND haa.assignment_set_id = to_number(:P_ASSIGNMENT_SET)';

	Else
	  LP_DATE_OR_PERSON := ' AND fnd_date.canonical_to_date(pcrv.roe_date) BETWEEN fnd_date.canonical_to_DATE(:P_START_DATE) AND fnd_date.canonical_TO_DATE(:P_END_DATE)';
	End if;
	end;
  Elsif P_PERSON_ID is not NULL then
	LP_DATE_OR_PERSON := 'AND paf.person_id=to_number(:P_PERSON_ID)';
  Elsif P_ASSIGNMENT_SET is NOT NULL then
        LP_ASSIGNMENT_SET := ', HR_ASSIGNMENT_SET_AMENDMENTS  haa';
        LP_DATE_OR_PERSON := ' AND haa.assignment_id = paf.assignment_id AND haa.include_or_exclude = ''I''' ||
                              ' AND haa.assignment_set_id = to_number(:P_ASSIGNMENT_SET)';
  End if;

--Added during DT Fix
if LP_ASSIGNMENT_SET is null
then
        LP_ASSIGNMENT_SET := ' ';
end if;

if LP_DATE_OR_PERSON is null
then
        LP_DATE_OR_PERSON := ' ';
end if;
--End of DT Fix

  return (TRUE);
end;

function cf_languageformula(ROE_PER_CORRESPONDENCE_LANG1 in varchar2, ROE_FINAL_PAY_PERIOD_END_DATE in varchar2) return char is
l_language varchar2(25);

  cursor cur_lookup is select
   meaning from hr_lookups
   where lookup_type = 'PAY_CA_CORRESPONDENCE_LANGUAGE'
   and   lookup_code = ROE_PER_CORRESPONDENCE_LANG1;
begin
   open cur_lookup;
   fetch cur_lookup
     into l_language;
   close cur_lookup;

  CP_EFFECTIVE_DATE := ROE_FINAL_PAY_PERIOD_END_DATE;

return(l_language);

Exception
When no_data_found then
return(' ');

end;

function cf_roe_pay_period_typeformula(ROE_PAY_PERIOD_TYPE1 in varchar2) return char is
   l_temp  per_time_period_types_tl.display_period_type%TYPE;

    cursor cur_display_period_type is
  select
     ptpv.DISPLAY_PERIOD_TYPE
  from
     per_time_period_types_vl ptpv
  where
     ptpv.period_type = ROE_PAY_PERIOD_TYPE1;

begin

   OPEN    cur_display_period_type;
   FETCH   cur_display_period_type
   INTO      l_temp;
   CLOSE  cur_display_period_type;

   RETURN  l_temp;
end;

function AfterReport return boolean is
begin
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
 Function CP_PERSON_p return varchar2 is
	Begin
	 return CP_PERSON;
	 END;
 Function CP_Effective_date_p return date is
	Begin
	 return CP_Effective_date;
	 END;
 Function CP_Assignment_set_name_p return varchar2 is
	Begin
	 return CP_Assignment_set_name;
	 END;
 Function CP_selection_type_p return varchar2 is
	Begin
	 return CP_selection_type;
	 END;
 Function CP_start_date_p return date is
	Begin
	 return CP_start_date;
	 END;
 Function CP_end_date_p return date is
	Begin
	 return CP_end_date;
	 END;
END PAY_PYCAROEP_XMLP_PKG ;

/
