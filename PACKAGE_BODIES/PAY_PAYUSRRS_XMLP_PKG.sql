--------------------------------------------------------
--  DDL for Package Body PAY_PAYUSRRS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYUSRRS_XMLP_PKG" AS
/* $Header: PAYUSRRSB.pls 120.0 2007/12/28 06:47:31 srikrish noship $ */

function BeforeReport return boolean is
begin
declare
  trace  varchar2(30) := '';
begin

 --hr_standard.event('BEFORE REPORT');

 null;

 c_business_group_name := hr_reports.get_business_group(p_business_group_id);


  if p_asg_set_id is not null then

      select ASSIGNMENT_SET_NAME into CP_asg_set_name
        from hr_assignment_sets
        where assignment_set_id = p_asg_set_id;

  end if;


  if p_tax_unit_id IS NOT NULL then

      Select name into cp_gre_name
                  from hr_organization_units
                  where organization_id = p_tax_unit_id;
  end if;

  if p_person_id IS NOT NULL then

      Select distinct ppf.full_name into c_person_name
                                from per_people_f ppf
                                where ppf.person_id = p_person_id;
  end if;
  if p_assignment_number IS NOT NULL then

           Select ppf.full_name into c_person_name
                                from per_people_f ppf,
                                     per_all_assignments_f paa
                                where paa.person_id = ppf.person_id
                                and paa.assignment_number = p_assignment_number;
  end if;

  if p_classification_id IS NOT NULL then

           Select pec.classification_name into c_classification_name
                                from pay_element_classifications pec
                                where pec.classification_id = p_classification_id;
  end if;



Select upper(parameter_value)
    into trace
    from pay_action_parameters
   where parameter_name = 'TRACE';

  If trace <> 'N' then
      /*srw.do_sql('alter session set SQL_TRACE TRUE');null;*/
      execute immediate 'alter session set SQL_TRACE TRUE';

  end if;

Exception When Others then
  /*srw.message(1,'Some parameters are NULL ...No Data Found');*/null;


 LP_END_DATE := P_END_DATE;
 LP_START_DATE:=P_START_DATE;
end;
 return (TRUE);
end;

function element_categoryformula(element_information_category in varchar2, element_information1 in varchar2) return varchar2 is

  CURSOR ecat_cur IS
     SELECT meaning
       FROM fnd_common_lookups
      WHERE lookup_type=element_information_category
        AND lookup_code=element_information1;
  ecatc ecat_cur%ROWTYPE;

begin

   OPEN ecat_cur;
   FETCH ecat_cur INTO ecatc;
   CLOSE ecat_cur;
   RETURN ecatc.meaning;

end;

FUNCTION GET_BUSINESS_GROUP_NAME(fp_business_group_id IN NUMBER) RETURN VARCHAR2 IS

   CURSOR bg_cur IS
      SELECT name
        FROM hr_organization_units
       WHERE organization_id = fp_business_group_id;
   bgc bg_cur%ROWTYPE;

BEGIN

   OPEN bg_cur;
   FETCH bg_cur into bgc;
   CLOSE bg_cur;
   return (bgc.name);

END;

function gre_nameformula(TAX_UNIT_ID in number) return varchar2 is
begin

   --return(get_business_group_name() (TAX_UNIT_ID));
   return(get_business_group_name(TAX_UNIT_ID));

end;

function CF_con_dateFormula return VARCHAR2 is
begin
  return (to_char(p_start_date,'DD-MON-YYYY') || '  To: ' || to_char(p_end_date,'DD-MON-YYYY') );
end;

function AfterReport return boolean is
begin
  --hr_standard.event('AFTER REPORT');
  return (TRUE);
end;

function AfterPForm return boolean is
begin

  p_where_clause := null;
  p_hint_clause := null;
  --p_from_clause := null;
  p_from_clause := ' ';

  if p_asg_set_id is not null then
     p_hint_clause := '';

     p_from_clause := ' , hr_assignment_set_amendments hasa ';

     p_where_clause := p_where_clause ||
           ' AND hasa.assignment_set_id = '||p_asg_set_id ||
           ' AND paf.assignment_id = hasa.assignment_id
             AND upper(hasa.include_or_exclude) = '||''''||'I'||'''';

  end if;


  if p_tax_unit_id IS NOT NULL then

      p_where_clause := p_where_clause ||
           ' AND  paa.TAX_UNIT_ID  = '||p_tax_unit_id;

  end if;

  if p_person_id IS NOT NULL then

     p_hint_clause := '';

      p_where_clause := p_where_clause ||
                                ' AND peo.PERSON_ID = '||p_person_id;


  end if;
  if p_assignment_number IS NOT NULL then

      p_hint_clause := '';

      p_where_clause := p_where_clause ||
                                ' AND paf.ASSIGNMENT_NUMBER = '||''''||
                                     p_assignment_number||'''';

  end if;

  if p_classification_id IS NOT NULL then

      p_where_clause := p_where_clause ||
                                ' AND pec.CLASSIFICATION_ID = '||p_classification_id;


  end if;
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
 Function C_PERSON_NAME_p return varchar2 is
	Begin
	 return C_PERSON_NAME;
	 END;
 Function C_CLASSIFICATION_NAME_p return varchar2 is
	Begin
	 return C_CLASSIFICATION_NAME;
	 END;
 Function CP_GRE_NAME_p return varchar2 is
	Begin
	 return CP_GRE_NAME;
	 END;
 Function CP_asg_set_name_p return varchar2 is
	Begin
	 return CP_asg_set_name;
	 END;
/*Added as a fix*/
function RVALUEFormula(RESULT_VALUE VARCHAR2) return Number is
begin
     return to_number(RESULT_VALUE);
end;
END PAY_PAYUSRRS_XMLP_PKG ;

/
