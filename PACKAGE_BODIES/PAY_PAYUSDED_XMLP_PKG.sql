--------------------------------------------------------
--  DDL for Package Body PAY_PAYUSDED_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYUSDED_XMLP_PKG" AS
/* $Header: PAYUSDEDB.pls 120.0 2007/12/28 06:44:11 srikrish noship $ */

function BeforeReport return boolean is

  l_trace    varchar2(1);
  l_message  varchar2(240);
  l_org_name varchar2(240);

  cursor c_trace is
   select 'x'
     from pay_action_parameters
    where parameter_name = 'TRACE'
      and parameter_value = 'Y';

  cursor c_org_name (cp_org_id in number) is
   select name
     from hr_organization_units
     where organization_id = cp_org_id;

begin

P_SORT_OPTION1:=nvl(P_SORT_OPTION1,'GRE');
  --hr_standard.event('BEFORE REPORT');


   open c_trace;
   fetch c_trace into l_trace;
   if c_trace%found then
            /*srw.do_sql('alter session set SQL_TRACE TRUE');null;*/
            execute immediate 'alter session set SQL_TRACE TRUE';

   end if;
   close c_trace;



  open c_org_name (p_business_group_id);
  fetch c_org_name into l_org_name;
  if c_org_name%found then
     c_business_group_name := l_org_name;
  else
     c_business_group_name := '';
  end if;
  close c_org_name;


  if(p_tax_unit_id is not null) then
     l_message := 'Error: While Selecting Government Reporting Entity ....';
     open c_org_name (p_tax_unit_id);
     fetch c_org_name into l_org_name;
     if c_org_name%found then
        c_gre := l_org_name;
     else
        c_gre := '';
     end if;
     close c_org_name;
   end if;


  if(p_organization_id is not null )
  then
     l_message := 'Error: While Selecting Organization name ....';
     open c_org_name (p_organization_id);
     fetch c_org_name into l_org_name;
     if c_org_name%found then
        c_organization := l_org_name;
     else
        c_organization := '';
     end if;
     close c_org_name;
  end if;


 BEGIN


  if(p_consolidation_set_id is not null)
  then
      l_message := 'Error: While Selecting Consolidation_set_name ....';
      select  consolidation_set_name
      into   c_consolidation_set
      from  pay_consolidation_sets
      where consolidation_set_id = p_consolidation_set_id
      and business_group_id = p_business_group_id;
  else
      c_consolidation_set :='';
  end if;



  if (p_payroll_id is not null)
  then
      l_message := 'Error: While Selecting Payroll name ....';
      select payroll_name
      into c_payroll
      from pay_all_payrolls_f
      where payroll_id = p_payroll_id
      and p_end_date between effective_start_date and effective_end_date
      and business_group_id = p_business_group_id;
  else
      c_payroll := '';
  end if;



  if(p_element_set_id is not null)
  then
     l_message := 'Error: While Selecting Element Set name ....';
     select element_set_name
     into c_element_set
     from pay_element_sets
     where element_set_id = p_element_set_id;
  else
     c_element_set := '';
  end if;





  if(p_classification_id is not null)
  then
     l_message := 'Error: While Selecting Classification name ....';
     select classification_name
     into c_classification
     from pay_element_classifications
     where classification_id = p_classification_id;
  else
     c_classification := '';
  end if;



  if(p_element_type_id is not null)
  then
     l_message := 'Error: While Selecting Element name ....';
     select element_name
     into c_element_name
     from pay_element_types_f
     where element_type_id = p_element_type_id
     and p_end_date between effective_start_date and effective_end_date;
  else
    c_element_name := '';
  end if;



  if (p_location_id is not null)
  then
     l_message := 'Error: While Selecting Location name ....';
     select location_code
     into c_location
     from hr_locations
     where location_id = p_location_id;
  else
     c_location := '';
  end if;


  if(p_person_id is not null)
  then
     l_message := 'Error: While Selecting Employee name ....';
     select full_name
     into c_person
     from per_people_f
     where person_id = p_person_id
     and p_end_date between effective_start_date and effective_end_date;
  else
     c_person := '';
  end if;
 EXCEPTION
    when NO_DATA_FOUND then
       /*srw.message(11,l_message);*/null;

       /*srw.message(11,'No Data Found');*/null;

       return (FALSE);
    when OTHERS then
       /*srw.message(11,l_message);*/null;

       return (FALSE);
 END;
  return (TRUE);
end;

function C_REPORT_SUBTITLEFormula return VARCHAR2 is
begin
   return null;

end;

function scheduled_dednformula(primary_balance in number, not_taken_balance in number, arrears_taken in number) return number is
begin

  return (nvl(primary_balance,0) + nvl(not_taken_balance,0)- nvl(arrears_taken,0));
end;

function current_arrearsformula(arrears_balance in number) return number is
   l_current_arrears  number := 0;
begin

  if nvl(arrears_balance,0) >= 0 then
     l_current_arrears := nvl(arrears_balance,0);
  end if;

  return l_current_arrears;

end;

function arrears_takenformula(arrears_balance in number) return number is
  l_arrears_taken  number := 0;
begin
  if nvl(arrears_balance,0) < 0 then
     l_arrears_taken := -1 * (nvl(arrears_balance,0));
  end if;

  return l_arrears_taken;

end;

function remainingformula(total_owed in number, CF_Accrued in number) return number is
diff_value number;
begin
    diff_value := to_number(nvl(total_owed,0)) - to_number(nvl(CF_Accrued,0)) ;
    return  diff_value;

end;

function element_total_textformula(element_name in varchar2) return varchar2 is
begin
  return  substr(element_name,1,87) || '  Total';
end;

function classification_total_textformu(classification_name in varchar2) return varchar2 is
begin
  return substr(classification_name,1,87) || '  Total';
end;

function s3_total_textformula(sort_option1_value in varchar2, sort_option2_value in varchar2, sort_option3_value in varchar2) return varchar2 is
begin
  return  sort_option1_value  ||' / '|| sort_option2_value  || ' / '|| sort_option3_value || '  Total';
end;

function s2_total_textformula(sort_option1_value in varchar2, sort_option2_value in varchar2) return varchar2 is
begin
  return  sort_option1_value  ||' / '||sort_option2_value || ' Total';
end;

function s1_total_textformula(sort_option1_value in varchar2) return varchar2 is
begin
    return  sort_option1_value  || ' Total';
end;

function person_total_textformula(full_name in varchar2) return varchar2 is
begin
   return substr(full_name,1,247) || '  Total';
end;

function cf_sort1formula(Sort_option1 in varchar2) return varchar2 is
begin
  return (Substr(Sort_option1,1,30));
end;

function cf_sort2formula(Sort_option2 in varchar2) return varchar2 is
begin
  return (Substr(Sort_option2,1,30));
end;

function cf_sort3formula(Sort_option3 in varchar2) return varchar2 is
begin
  return (Substr(Sort_option3,1,30));
end;

function cf_sort1_valueformula(Sort_option1_value in varchar2) return varchar2 is
begin
  return (Substr(Sort_option1_value,1,30));
end;

function cf_sort2_valueformula(Sort_option2_value in varchar2) return varchar2 is
begin
  return (Substr(Sort_option2_value,1,30));
end;

function cf_sort3_valueformula(Sort_option3_value in varchar2) return varchar2 is
begin
  return (Substr(Sort_option3_value,1,30));
end;

function cf_accruedformula(accrued_balance in varchar2, Primary_balance in number, Total_owed in number) return number is
begin
  if( (nvl(accrued_balance,0) = 0) and (nvl(Primary_balance,0) <> 0) )
   then
       return Total_owed;
   else
       return Accrued_balance;
   end if;
RETURN NULL; end;

function s3_textformula(sort_option1_value in varchar2, Sort_option1 in varchar2, sort_option2_value in varchar2, Sort_option2 in varchar2, sort_option3_value in varchar2, Sort_option3 in varchar2) return varchar2 is
   retval  varchar2(240);
begin
  if(sort_option1_value is not null)
  then
     retval := Sort_option1  || ': '||sort_option1_value  ||'    ';
  end if;

  if(sort_option2_value is not null)
  then
     retval := retval || Sort_option2  || ': '||sort_option2_value  ||'    ';
  end if;

  if(sort_option3_value is not null)
  then
     retval := retval || Sort_option3  || ': '||sort_option3_value  ||'    ';
  end if;

  return  retval;
end;

function AfterPForm return boolean is

cursor c_element_set(cp_element_set_id in number) is
  select petr.element_type_id
    from pay_element_type_rules petr
   where petr.element_set_id = cp_element_set_id
     and petr.include_or_exclude = 'I'
  union all
  select pet1.element_type_id
    from pay_element_types_f pet1
   where pet1.classification_id in
              (select classification_id
                 from pay_ele_classification_rules
                where element_set_id = cp_element_set_id)
  minus
  select petr.element_type_id
    from pay_element_type_rules petr
   where petr.element_set_id = cp_element_set_id
     and petr.include_or_exclude = 'E';

lv_element_set_where varchar2(32000);
ln_element_type_id   number;

begin

  p_hint := '  ';

  if  (nvl(hr_general2.get_oracle_db_version, 0) < 10.0)  then
    p_hint := '';
  end if;


  if p_person_id is not null then
     p_where_clause := 'and to_number(person_id) = to_number(:P_PERSON_ID) ';
     p_hint := '  ';
  end if;

  if p_payroll_id is not null then
     p_where_clause := p_where_clause ||
                        ' and payroll_id = to_number(:p_payroll_id) ';
  end if;

  if p_classification_id is not null then
     p_where_clause := p_where_clause ||
                        ' and classification_id = to_number(:P_CLASSIFICATION_ID) ';
  end if;

  if p_tax_unit_id is not null then
     p_where_clause := p_where_clause ||
                        ' and tax_unit_id = to_number(:P_TAX_UNIT_ID) ';
  end if;

  if p_element_type_id is not null then
     p_where_clause := p_where_clause ||
                        ' and element_type_id = to_number(:P_ELEMENT_TYPE_ID) ';
  end if;

  if p_organization_id is not null then
     p_where_clause := p_where_clause ||
                        ' and organization_id = to_number(:P_ORGANIZATION_ID) ';
  end if;

  if p_location_id is not null then
       p_where_clause := p_where_clause ||
                          ' and location_id = to_number(:P_LOCATION_ID) ';
  end if;

  if p_element_set_id is not null then
     open c_element_set(p_element_set_id);
     loop
       fetch c_element_set into ln_element_type_id;
       if c_element_set%notfound then

          lv_element_set_where := substr(lv_element_set_where, 2);
          exit;
       end if;
       lv_element_Set_where := lv_element_set_where || ',' || ln_element_type_id;
     end loop;
     close c_element_set;

     p_where_clause := p_where_clause ||
                        ' and element_type_id in (' || lv_element_set_where || ')';
  end if;



  return (TRUE);
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
 Function C_Consolidation_set_p return varchar2 is
	Begin
	 return C_Consolidation_set;
	 END;
 Function C_Payroll_p return varchar2 is
	Begin
	 return C_Payroll;
	 END;
 Function C_Classification_p return varchar2 is
	Begin
	 return C_Classification;
	 END;
 Function C_Element_name_p return varchar2 is
	Begin
	 return C_Element_name;
	 END;
 Function C_GRE_p return varchar2 is
	Begin
	 return C_GRE;
	 END;
 Function C_Location_p return varchar2 is
	Begin
	 return C_Location;
	 END;
 Function C_Organization_p return varchar2 is
	Begin
	 return C_Organization;
	 END;
 Function C_Person_p return varchar2 is
	Begin
	 return C_Person;
	 END;
 Function C_ELEMENT_SET_p return varchar2 is
	Begin
	 return C_ELEMENT_SET;
	 END;
END PAY_PAYUSDED_XMLP_PKG ;

/
