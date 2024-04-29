--------------------------------------------------------
--  DDL for Package Body PAY_KR_SEP_ARCHIVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_SEP_ARCHIVE_PKG" as
/* $Header: pykrsepa.pkb 120.2.12010000.3 2010/02/04 04:57:09 pnethaga ship $ */
--
-- Constants
--
g_debug   boolean;

c_range_cursor  constant varchar2(3000) :=     -- 4660184
'select distinct paa.person_id
from   pay_payroll_actions    bppa,
       per_assignments_f      paa
where  bppa.payroll_action_id = :payroll_action_id
and    paa.business_group_id  = bppa.business_group_id
and    paa.payroll_id = to_number(pay_kr_ff_functions_pkg.get_legislative_parameter(bppa.payroll_action_id, ''PAYROLL_ID'', null))
order by 1';
-- declared for archiving details related to efile

TYPE t_arch_rec IS RECORD(item   varchar2(50)
                   ,value varchar2(1000));
TYPE t_arch_tab IS TABLE OF t_arch_rec INDEX BY BINARY_INTEGER;

l_arch_tab t_arch_tab;

p_element_entry_id pay_element_entries.element_entry_id%type;


TYPE t_ele_ent_id_tab IS TABLE OF pay_element_entries.element_entry_id%type  INDEX BY BINARY_INTEGER;

TYPE t_ele_value_tab IS TABLE OF pay_element_entry_values_f.screen_entry_value%type  INDEX BY BINARY_INTEGER;

l_ele_ent_id_tab t_ele_ent_id_tab;
l_ele_value_tab t_ele_value_tab;
l_ele_ent_id_tab1 t_ele_ent_id_tab;
l_ele_value_tab1 t_ele_value_tab;
l_ele_ent_id_tab2 t_ele_ent_id_tab;
l_ele_value_tab2 t_ele_value_tab;
l_ele_ent_id_tab3 t_ele_ent_id_tab;

-- end of declared for archiving details related to efile

--------------------------------------------------------------------------------+

procedure archive_item
    ( p_item                  in     ff_user_entities.user_entity_name%type,
      p_context1              in     pay_assignment_actions.assignment_action_id%type,
      p_context2              in     pay_element_entries_f.element_entry_id%type,
      p_value                 in out NOCOPY ff_archive_items.value%type) is
  cursor  get_user_entity_id(c_user_entity_name in varchar2)
      is
  select  fue.user_entity_id,
          dbi.data_type
    from  ff_user_entities  fue,
          ff_database_items dbi
   where  user_entity_name   =c_user_entity_name
   and    fue.user_entity_id =dbi.user_entity_id;

   v_user_entity_id          ff_user_entities.user_entity_id%type;
   v_archive_item_id         ff_archive_items.archive_item_id%type;
   v_data_type               ff_database_items.data_type%type;
   v_object_version_number   ff_archive_items.object_version_number%type;
   v_some_warning            boolean;


begin

  if g_debug then
    hr_utility.set_location('Entering : archive_item',1);
  end if;

  open get_user_entity_id (p_item);
  fetch get_user_entity_id into v_user_Entity_id,
                                v_data_type;
  if get_user_entity_id%found then
  close get_user_entity_id;
    if substr(P_ITEM,1,9)='X_KR_PREV' then
     ff_archive_api.create_archive_item
         (p_validate              => false                    -- boolean  in default
         ,p_archive_item_id       => v_archive_item_id        -- number   out
         ,p_user_entity_id        => v_user_entity_id         -- number   in
         ,p_archive_value         => p_value                  -- varchar2 in
         ,p_archive_type          => 'AAP'                    -- varchar2 in default
         ,p_action_id             => p_context1               -- number   in
         ,p_legislation_code      => 'KR'                     -- varchar2 in
         ,p_object_version_number => v_object_version_number  -- number   out
         ,p_context_name1         => 'ELEMENT_ENTRY_ID'   -- varchar2 in default
         ,p_context1              => p_context2               -- varchar2 in default
         ,p_some_warning          => v_some_warning);         -- boolean  out
    else
      ff_archive_api.create_archive_item
         (p_validate              => false                    -- boolean  in default
         ,p_archive_item_id       => v_archive_item_id        -- number   out
         ,p_user_entity_id        => v_user_entity_id         -- number   in
         ,p_archive_value         => p_value                  -- varchar2 in
         ,p_archive_type          => 'AAP'                    -- varchar2 in default
         ,p_action_id             => p_context1                -- number   in
         ,p_legislation_code      => 'KR'                     -- varchar2 in
         ,p_object_version_number => v_object_version_number  -- number   out
         ,p_some_warning          => v_some_warning);         -- boolean  out
    end if;
  else
    close get_user_entity_id;
    if g_debug then
      hr_utility.set_location('User entity not found :'||p_item,20);
    end if;
  end if;

  if g_debug then
    hr_utility.set_location('Leaving : archive_item',1);
  end if;

exception
  when others then

  if get_user_entity_id%isopen then
   close get_user_entity_id;
   hr_utility.set_location('closing..',117);
  end if;

  hr_utility.set_location('Error in archive_item',20);
  raise;
end archive_item;

--------------------------------------------------------------------------------+

  ------------------------------------------------------------------------------+
  Procedure archive_corp_details
            (p_business_group_id       in hr_organization_units.business_group_id%type,
             p_tax_unit_id             in pay_assignment_Actions.tax_unit_id%type,
             p_assignment_id           in pay_assignment_actions.assignment_id%type,
             p_payroll_action_id       in pay_payroll_actions.payroll_action_id%type,
             p_assignment_Action_id    in pay_assignment_actions.assignment_action_id%type,
             p_date_earned             in date  ) is


  ------------------------------------------------------------------------------+
  -- cursor to get corp details
  ------------------------------------------------------------------------------+

/* Start of corp  details */

  cursor c_corp_details
      is
  select ihoi.org_information10        corp_tel_number
        ,choi.org_information2         corp_number
        ,choi.org_information1         corp_name
        ,choi.org_information7         corp_rep_ni
        ,choi.org_information6         corp_rep_name
        ,bhoi.org_information1         bp_name
        ,bhoi.org_information2         bp_number
        ,bhoi.org_information11        bp_rep_name
        ,bhoi.org_information12        bp_rep_ni
        ,ihoi.org_information9         bp_tax_office_code
  from   hr_organization_information   bhoi
        ,hr_organization_information   ihoi
        ,hr_organization_information   choi
  where bhoi.organization_id         = p_tax_unit_id
    and bhoi.org_information_context = 'KR_BUSINESS_PLACE_REGISTRATION'
    and choi.organization_id         = to_number(bhoi.org_information10)
    and choi.org_information_context = 'KR_CORPORATE_INFORMATION'
    and ihoi.organization_id         = bhoi.organization_id
    and ihoi.org_information_context = 'KR_INCOME_TAX_OFFICE' ;

Begin

    -----------------------------------------
    -- note : the fetch order from the cursor
    --        should be same as the order
    --        defined in the pl/sql table below
    -----------------------------------------
    l_arch_tab.delete;
    l_arch_tab(1).item := 'X_KR_CORP_TEL_NUMBER' ;
    l_arch_tab(2).item := 'X_KR_CORP_NUMBER' ;
    l_arch_tab(3).item := 'X_KR_CORP_NAME';
    l_arch_tab(4).item := 'X_KR_CORP_REP_NI' ;
    l_arch_tab(5).item := 'X_KR_CORP_REP_NAME' ;
    l_arch_tab(6).item := 'X_KR_BP_NAME';
    l_arch_tab(7).item := 'X_KR_BP_NUMBER' ;
    l_arch_tab(8).item := 'X_KR_BP_REP_NAME' ;
    l_arch_tab(9).item := 'X_KR_BP_REP_NI' ;
    l_arch_tab(10).item := 'X_KR_BP_TAX_OFFICE_CODE' ;

    if g_debug then
      hr_utility.set_location('Entering : Archiving corp Details ',1);
      hr_utility.set_location('Assignments action id is  '||p_assignment_action_id,2);
    end if;

    open c_corp_details ;
    fetch c_corp_details
     into  l_arch_tab(1).value,
           l_arch_tab(2).value,
           l_arch_tab(3).value,
           l_arch_tab(4).value,
           l_arch_tab(5).value,
           l_arch_tab(6).value,
           l_arch_tab(7).value,
           l_arch_tab(8).value,
           l_arch_tab(9).value,
           l_arch_tab(10).value;

    close c_corp_details ;

    if g_debug then
      hr_utility.set_location('Creating Archive Item ',3);
    end if;

    for i in 1..l_arch_tab.count loop

      archive_item  (p_item     => l_arch_tab(i).item
                    ,p_context1 => p_assignment_action_id
                    ,p_context2 => null
                    ,p_value    => l_arch_tab(i).value);
    end loop;


    if g_debug then
      hr_utility.set_location('Exiting : Archiving corp Details ',4);
    end if;

exception
  when others then
    hr_utility.set_location('Error in archiving corp details ',10);
    raise;

End archive_corp_details;

/* End of corp details */

-------------------------------------------------------------------------------+

-------------------------------------------------------------------------------+
Function archive_emp_details
            (p_business_group_id       in hr_organization_units.business_group_id%type,
             p_tax_unit_id             in pay_assignment_Actions.tax_unit_id%type,
             p_assignment_id           in pay_assignment_actions.assignment_id%type,
             p_payroll_action_id       in pay_payroll_actions.payroll_action_id%type,
             p_assignment_Action_id    in pay_assignment_actions.assignment_action_id%type,
             p_date_earned             in date )
 return boolean
 is

/* Start of current employee  details */

  /*
  	Bug 4442482: 	Sparse Matrix enhancement - Use function PAY_KR_REPORT_PKG.GET_RESULT_VALUE in SELECT to make
  		  	query return row even when any one of these run result values is non-existent (null).
  */
  cursor c_cemp_details
      is
  select
         pap.last_name||first_name                      		emp_name
        ,pap.nationality                                		nationality
        ,pap.national_identifier                        		ni
        ,pay_kr_report_pkg.get_result_value(prr1.run_result_id, piv1.input_value_id)	hire_date
        ,pay_kr_report_pkg.get_result_value(prr1.run_result_id, piv2.input_value_id)	leaving_date
        ,pay_kr_report_pkg.get_result_value(prr1.run_result_id, piv3.input_value_id)	prev_hire_date
        ,pay_kr_report_pkg.get_result_value(prr1.run_result_id, piv4.input_value_id)	prev_leaving_date
        ,fnd_date.date_to_canonical(ppa.date_earned)    date_earned
        ,decode(substr(pap.national_identifier,8,1),1,NULL,2,NULL,3,NULL,4,NULL,pap.country_of_birth) country_code
 from    pay_run_results        prr1,
         pay_run_results        prr2,
         pay_payroll_actions    ppa,
         pay_assignment_actions paa,
         pay_element_types_f    pet1,
         pay_element_types_f    pet2,
         pay_input_values_f     piv1,
         pay_input_values_f     piv2,
         pay_input_values_f     piv3,
         pay_input_values_f     piv4,
         per_people_f           pap,
         per_assignments_f      paaf,
         pay_run_types_f        prt,
         fnd_territories        ft
  where  ppa.payroll_action_id      = p_payroll_action_id
  and    ppa.business_group_id      = p_business_group_id
  and    paa.assignment_id          = p_assignment_id
  and    ppa.payroll_action_id      = paa.payroll_action_id
  and    prr1.assignment_action_id  = paa.assignment_action_id
  and    prr1.element_type_id       = pet1.element_type_id
  and    pet1.element_name          = 'WKPD'
  and    pet1.legislation_code      = 'KR'
  and    pet1.element_type_id       = piv1.element_type_id
  and    pet1.element_type_id       = piv2.element_type_id
  and    pet1.element_type_id       = piv3.element_type_id
  and    pet1.element_type_id       = piv4.element_type_id
  and    piv1.name                  = 'H_DATE'
  and    piv2.name                  = 'L_DATE'
  and    piv3.name                  = 'PREV_FH_DATE'
  and    piv4.name                  = 'PREV_LL_DATE'
  and    ppa.effective_date         between pet1.effective_start_date and pet1.effective_end_date
  and    ppa.effective_date         between piv1.effective_start_date and piv1.effective_end_date
  and    ppa.effective_date         between piv2.effective_start_date and piv2.effective_end_date
  and    ppa.effective_date         between piv3.effective_start_date and piv3.effective_end_date
  and    ppa.effective_date         between piv4.effective_start_date and piv4.effective_end_date
  and    pet2.element_name          = 'TAX'
  and    pet2.legislation_code      = 'KR'
  and    prr2.element_type_id       = pet2.element_type_id
  and    prr2.source_type           = 'E'
  and    prr2.assignment_action_id  = paa.assignment_action_id
  and    ppa.effective_date         between pet2.effective_start_date and pet2.effective_end_date
  and    prt.run_type_name          in ('SEP','SEP_I')
  and    prt.run_type_id            = ppa.run_type_id
  and    paaf.assignment_id         = paa.assignment_id
  and    pap.person_id              = paaf.person_id
  and    pap.country_of_birth       = ft.territory_code (+)
  and    ppa.effective_date         between pap.effective_start_date and pap.effective_end_date
  and    ppa.effective_date         between paaf.effective_start_date and paaf.effective_end_date;

 -- 3627111
/*********************************************************
 * Cursor to get the Non-Statutroy Hire date, Leaving
 * date, Prev Employer Hire date and Prev Employer
 * Leaving date of an employee.
 *********************************************************/
	  /*
  		Bug 4442482: 	Sparse Matrix enhancement - Use function PAY_KR_REPORT_PKG.GET_RESULT_VALUE in SELECT
		                to make query return row even when any one of these run result values is non-existent
				(null).
	  */

	cursor c_emp_nonstat_details
	is
	select
		 pay_kr_report_pkg.get_result_value(prr1.run_result_id, piv1.input_value_id)	ns_hire_date
		,pay_kr_report_pkg.get_result_value(prr1.run_result_id, piv2.input_value_id)	ns_leaving_date
		,pay_kr_report_pkg.get_result_value(prr1.run_result_id, piv3.input_value_id)	ns_prev_hire_date
		,pay_kr_report_pkg.get_result_value(prr1.run_result_id, piv4.input_value_id)	ns_prev_leaving_date
	from 	 pay_run_results        prr1,
		 pay_payroll_actions    ppa,
		 pay_assignment_actions paa,
		 pay_element_types_f    pet1,
		 pay_input_values_f     piv1,
		 pay_input_values_f     piv2,
		 pay_input_values_f     piv3,
		 pay_input_values_f     piv4,
		 pay_run_types_f        prt
	where  	ppa.payroll_action_id          = p_payroll_action_id
		and ppa.business_group_id      = p_business_group_id
		and paa.assignment_id          = p_assignment_id
		and ppa.payroll_action_id      = paa.payroll_action_id
		and prt.run_type_name          in ('SEP','SEP_I')
		and prt.run_type_id            = ppa.run_type_id
		and prr1.assignment_action_id  = paa.assignment_action_id
		and prr1.element_type_id       = pet1.element_type_id
		and pet1.element_name          = 'WKPD_NON_STAT_SEP_PAY'
		and pet1.legislation_code      = 'KR'
		and pet1.element_type_id       = piv1.element_type_id
		and pet1.element_type_id       = piv2.element_type_id
		and pet1.element_type_id       = piv3.element_type_id
		and pet1.element_type_id       = piv4.element_type_id
		and piv1.name                  = 'H_DATE'
		and piv2.name                  = 'L_DATE'
		and piv3.name                  = 'PREV_FH_DATE'
		and piv4.name                  = 'PREV_LL_DATE'
		and ppa.effective_date         between pet1.effective_start_date and pet1.effective_end_date
		and ppa.effective_date         between piv1.effective_start_date and piv1.effective_end_date
		and ppa.effective_date         between piv2.effective_start_date and piv2.effective_end_date
		and ppa.effective_date         between piv3.effective_start_date and piv3.effective_end_date
		and ppa.effective_date         between piv4.effective_start_date and piv4.effective_end_date;


Begin

    -----------------------------------------
    -- note : the fetch order from the cursor
    --        should be same as the order
    --        defined in the pl/sql table below
    -----------------------------------------
    l_arch_tab.delete;

    l_arch_tab(1).item := 'X_KR_EMP_NAME' ;
    l_arch_tab(2).item := 'X_KR_EMP_NATIONALITY' ;
    l_arch_tab(3).item := 'X_KR_EMP_NI';
    l_arch_tab(4).item := 'X_KR_EMP_HIRE_DATE' ;
    l_arch_tab(5).item := 'X_KR_EMP_LEAVING_DATE' ;
    l_arch_tab(6).item := 'X_KR_EMP_PREV_HIRE_DATE' ;
    l_arch_tab(7).item := 'X_KR_EMP_PREV_LEAVING_DATE' ;
    l_arch_tab(8).item := 'X_KR_EMP_PAID_DATE' ;
    l_arch_tab(9).item := 'X_KR_EMP_COUNTRY_CODE' ;

    if g_debug then
      hr_utility.set_location('Entering : Archiving current emp Details ',1);
      hr_utility.set_location('Assignment action id is  '||p_assignment_action_id,2);
    end if;

    open c_cemp_details ;
    fetch c_cemp_details
     into  l_arch_tab(1).value,
           l_arch_tab(2).value,
           l_arch_tab(3).value,
           l_arch_tab(4).value,
           l_arch_tab(5).value,
           l_arch_tab(6).value,
           l_arch_tab(7).value,
           l_arch_tab(8).value,
           l_arch_tab(9).value;

        if c_cemp_details%NOTFOUND then
            close c_cemp_details ;
            return(FALSE);
        else
                if g_debug then
                  hr_utility.set_location('Creating Archive Item ',3);
                end if;

                for i in 1..l_arch_tab.count loop

                        archive_item (p_item     => l_arch_tab(i).item
                           ,p_context1 => p_assignment_action_id
                           ,p_context2 => null
                           ,p_value    => l_arch_tab(i).value);
                end loop;
                close c_cemp_details ;
        end if;

-- 3627111: Archive Non-statutory Details
    l_arch_tab.delete;
    l_arch_tab(1).item := 'X_WKPD_NON_STAT_SEP_PAY_H_DATE' ;
    l_arch_tab(2).item := 'X_WKPD_NON_STAT_SEP_PAY_L_DATE' ;
    l_arch_tab(3).item := 'X_WKPD_NON_STAT_SEP_PAY_PREV_H_DATE' ;
    l_arch_tab(4).item := 'X_WKPD_NON_STAT_SEP_PAY_PREV_L_DATE' ;

-- 3627111: Fetching Non-Statutory Data from cursor
	open c_emp_nonstat_details;
	fetch c_emp_nonstat_details into
		l_arch_tab(1).value,
		l_arch_tab(2).value,
		l_arch_tab(3).value,
		l_arch_tab(4).value;
        if c_emp_nonstat_details%NOTFOUND then
            close c_emp_nonstat_details;
-- 3627111: False will not be returned from here because, these Non-Statutory data
--          are optional.
        else
			for i in 1..l_arch_tab.count loop

					archive_item (p_item     => l_arch_tab(i).item
					   ,p_context1 => p_assignment_action_id
					   ,p_context2 => null
					   ,p_value    => l_arch_tab(i).value);
			end loop;
			close c_emp_nonstat_details ;

		end if;

    if g_debug then
      hr_utility.set_location('Exiting :Archiving current emp Details',200);
    end if;
    return(true);

exception
  when others then
    hr_utility.set_location('Error in archiving emp details ',10);
    raise;

End archive_emp_details;

/* End of current employee details */

-------------------------------------------------------------------------------+

-------------------------------------------------------------------------------+

Procedure archive_prev_emp_details
            (p_business_group_id       in hr_organization_units.business_group_id%type,
             p_tax_unit_id             in pay_assignment_Actions.tax_unit_id%type,
             p_assignment_id           in pay_assignment_actions.assignment_id%type,
             p_payroll_action_id       in pay_payroll_actions.payroll_action_id%type,
             p_assignment_Action_id    in pay_assignment_actions.assignment_action_id%type,
             p_date_earned             in date  ) is

cursor c_prev_emp_details(v_element_name varchar2,v_piv_name varchar2)
      is
        select  pee.element_entry_id,
                peev1.screen_entry_value
        from    pay_element_entries_f pee,
                pay_element_links_f   pel,
                pay_element_types_f   pet,
                pay_payroll_actions   ppa,
                pay_assignment_actions paa,
                pay_run_types_f            prt,
                pay_input_values_f         piv1,
                pay_element_entry_values_f peev1
        where   pet.element_name = v_element_name
                and pel.element_link_id = pee.element_link_id
                and pet.element_type_id = pel.element_type_id
                and pel.business_group_id = ppa.business_group_id --new
                and ppa.date_earned between pet.effective_start_date and pet.effective_end_date
                and paa.action_status = 'C'
                and ppa.payroll_action_id = paa.payroll_action_id
                and prt.run_type_id = paa.run_type_id
                and prt.run_type_name in ('SEP','SEP_I')
                and ppa.effective_date          between prt.effective_start_date and prt.effective_end_date
                and pet.legislation_code = 'KR'
                and pee.assignment_id  = paa.assignment_id
                and ppa.date_earned     between nvl(pee.effective_start_date,ppa.date_earned)
                and nvl(pee.effective_end_date,ppa.date_earned)
                and pee.entry_type  = 'E'
                and pee.element_link_id  = pel.element_link_id
                and piv1.name = v_piv_name                          --- cursor parameter
                and piv1.element_type_id = pet.element_type_id
                and peev1.element_entry_id  = pee.element_entry_id
                and peev1.input_value_id = piv1.input_value_id
                and ppa.effective_date between piv1.effective_start_date and piv1.effective_end_date
                and paa.assignment_id = p_assignment_id
                and ppa.payroll_action_id = p_payroll_action_id
                and ppa.business_group_id = p_business_group_id
                and peev1.screen_entry_value is not null; -- Bug# 2826658 Added not to archive null values

 l_iv_name       pay_input_values_f.name%TYPE;
 l_item          VARCHAR2(25);
 l_prepaid_value NUMBER;

procedure populate_archive_item(p_item varchar2,p_element_name varchar2, p_piv_name varchar2) is


begin

    if g_debug then
      hr_utility.set_location('Entering : Populate archive item ',1);
      hr_utility.set_location('Assignments action id is  '||p_assignment_action_id,2);
    end if;

    l_ele_ent_id_tab.delete;
    l_ele_value_tab.delete;

      open c_prev_emp_details(p_element_name,p_piv_name);
      fetch c_prev_emp_details bulk collect
      into
           l_ele_ent_id_tab,
           l_ele_value_tab;

      if g_debug then
        hr_utility.set_location('Creating Archive Item ',3);
      end if;

      for i in 1..l_ele_ent_id_tab.count loop
              archive_item(p_item     => p_item
                          ,p_context1 => p_assignment_action_id
                          ,p_value    => l_ele_value_tab (i)
                          ,p_context2 => l_ele_ent_id_tab(i));
      end loop;

    close c_prev_emp_details;

    if g_debug then
      hr_utility.set_location('Exiting : Populate archive item ',200);
    end if;
exception

  when others then
    hr_utility.set_location('Error in populate archive item ',10);
    raise;

end;

procedure populate_prev_archive_item(p_item varchar2,p_element_name varchar2, p_piv_name varchar2) is


begin

    if g_debug then
      hr_utility.set_location('Entering : Populate archive item ',1);
      hr_utility.set_location('Assignments action id is  '||p_assignment_action_id,2);
    end if;

    l_ele_ent_id_tab.delete;
    l_ele_value_tab.delete;
    l_ele_ent_id_tab1.delete;
    l_ele_value_tab1.delete;
    l_ele_ent_id_tab2.delete;
    l_ele_value_tab2.delete;
    l_ele_ent_id_tab3.delete;

      open c_prev_emp_details('PREV_ER_INFO','BP_NUMBER');
      fetch c_prev_emp_details bulk collect
      into
           l_ele_ent_id_tab1,
           l_ele_value_tab1;
      close c_prev_emp_details;
      open c_prev_emp_details('PREV_SEP_PENS_DTLS','BP_NUMBER');
      fetch c_prev_emp_details bulk collect
      into
           l_ele_ent_id_tab2,
           l_ele_value_tab2;
      close c_prev_emp_details;

      for i in 1..l_ele_ent_id_tab2.count loop
            for j in 1..l_ele_ent_id_tab1.count loop
	      if (l_ele_value_tab2(i) = l_ele_value_tab1(j)) then
		 l_ele_ent_id_tab3(i) := l_ele_ent_id_tab1(j);
	      end if;
            end loop;
      end loop;

      open c_prev_emp_details(p_element_name,p_piv_name);
      fetch c_prev_emp_details bulk collect
      into
           l_ele_ent_id_tab,
           l_ele_value_tab;

      if g_debug then
        hr_utility.set_location('Creating Archive Item ',3);
      end if;

      for i in 1..l_ele_ent_id_tab.count loop
        for j in 1..l_ele_ent_id_tab2.count loop
           if (l_ele_ent_id_tab(i) = l_ele_ent_id_tab2(j)) then

              archive_item(p_item     => p_item
                          ,p_context1 => p_assignment_action_id
                          ,p_value    => l_ele_value_tab (i)
                          ,p_context2 => l_ele_ent_id_tab3(j));
            end if;
	 end loop;
      end loop;

    close c_prev_emp_details;

    if g_debug then
      hr_utility.set_location('Exiting : Populate archive item ',200);
    end if;
exception

  when others then
    hr_utility.set_location('Error in populate archive item ',10);
    raise;

end;

procedure archive_preapid_item_value(p_item                  varchar2
				    ,p_element_name	     varchar2
                                    ,p_piv_name              varchar2
                                    ,p_assignment_action_id  number) is

  l_prepaid_value  NUMBER;

begin

  if g_debug then
    hr_utility.set_location('Entering : archive_preapid_item_value',1);
  end if;

  l_ele_ent_id_tab.delete;
  l_ele_value_tab.delete;

  open c_prev_emp_details(p_element_name,p_piv_name);
  fetch c_prev_emp_details bulk collect
   into
     l_ele_ent_id_tab,
     l_ele_value_tab;

    l_prepaid_value := 0;

    for i in 1..l_ele_value_tab.count loop
      l_prepaid_value := l_prepaid_value + l_ele_value_tab (i);
    end loop ;

    close c_prev_emp_details;

    archive_item(p_item     => p_item
                ,p_context1 => p_assignment_action_id
                ,p_context2 => null
                ,p_value    => l_prepaid_value);

    if g_debug then
      hr_utility.set_location('Leaving : archive_preapid_item_value',1);
    end if;

 exception
  when others then
   hr_utility.set_location('Error in archive_preapid_item_value   ',10);
   raise;

end archive_preapid_item_value;

Begin

    if g_debug then
      hr_utility.set_location('Entering : Archiving prev emp Details ',10);
    end if;

    populate_archive_item('X_KR_PREV_BP_NUMBER','PREV_ER_INFO','BP_NUMBER');
    populate_archive_item('X_KR_PREV_BP_NAME','PREV_ER_INFO','BP_NAME');
    populate_archive_item('X_KR_PREV_HIRE_DATE','PREV_ER_INFO','H_DATE');
    populate_archive_item('X_KR_PREV_LEAVING_DATE','PREV_ER_INFO','L_DATE');
    populate_archive_item('X_KR_PREV_FINAL_INT_DATE','PREV_ER_INFO','FINAL_INT_DATE');
    populate_archive_item('X_KR_PREV_SEP_PAY','PREV_ER_INFO','SEP_PAY');
    populate_archive_item('X_KR_PREV_NON_TAXABLE_EARNING','PREV_ER_INFO','NON_TAXABLE_EARNING');
    populate_archive_item('X_KR_PREV_SEP_ALLOWANCE','PREV_ER_INFO','SP_SEP_ALW');
    populate_archive_item('X_KR_PREV_SEP_INSURANCE','PREV_ER_INFO','SEP_INS');
    populate_archive_item('X_KR_PREV_SEP_POST_TAX_FLAG','PREV_ER_INFO','ELIGIBLE_POST_TAX_DEDUC_FLAG');


    populate_prev_archive_item('X_KR_PREV_SEP_TOT_RECEIVED','PREV_SEP_PENS_DTLS','TOTAL_RECEIVED');
    populate_prev_archive_item('X_KR_PREV_SEP_PRINCIPAL_INTRST','PREV_SEP_PENS_DTLS','PRINCIPAL_INTRST');
    populate_prev_archive_item('X_KR_PREV_SEP_PERS_CONTRIBUTION','PREV_SEP_PENS_DTLS','PERS_CONTRIBUTION');
    populate_prev_archive_item('X_KR_PREV_SEP_PENS_EXEM','PREV_SEP_PENS_DTLS','PENS_EXEM');

  -- Bug 2678508 Incorrect prepaid Tax Logic in Sep Tax receipt
  -- So archiving the Prev Separaion Pay ITAX ,RTAX,STAX

    archive_preapid_item_value('X_KR_EMP_PREPAID_ITAX','PREV_ER_INFO','ITAX',p_assignment_action_id);
    archive_preapid_item_value('X_KR_EMP_PREPAID_RTAX','PREV_ER_INFO','RTAX',p_assignment_action_id);
    archive_preapid_item_value('X_KR_EMP_PREPAID_STAX','PREV_ER_INFO','STAX',p_assignment_action_id);


    if g_debug then
      hr_utility.set_location('Exiting : Archiving prev emp Details ',200);
    end if;

End archive_prev_emp_details;

/* End of prev_emp details */

-------------------------------------------------------------------------------+

-------------------------------------------------------------------------------+

  Procedure archive_xdbi
    (p_business_group_id       in hr_organization_units.business_group_id%type,
     p_tax_unit_id             in pay_assignment_Actions.tax_unit_id%type,
     p_assignment_id           in pay_assignment_actions.assignment_id%type,
     p_payroll_action_id       in pay_payroll_actions.payroll_action_id%type,
     p_assignment_Action_id    in pay_assignment_actions.assignment_action_id%type,
     p_date_earned             in date  ) is
  begin

/* Corporate Dtails and Prev emp details are archived only if
   current emp details exist */

   if (archive_emp_details
                             (p_business_group_id,
                              p_tax_unit_id,
                              p_assignment_id,
                              p_payroll_action_id,
                              p_assignment_Action_id,
                              p_date_earned)) then

           archive_corp_details
                                     (p_business_group_id,
                                      p_tax_unit_id,
                                      p_assignment_id,
                                      p_payroll_action_id,
                                      p_assignment_Action_id,
                                      p_date_earned);


           archive_prev_emp_details
                                     (p_business_group_id,
                                      p_tax_unit_id,
                                      p_assignment_id,
                                      p_payroll_action_id,
                                      p_assignment_Action_id,
                                      p_date_earned);
   end if;

  end archive_xdbi;
-------------------------------------------------------------------------------+

--------------------------------------------------------------------------------
procedure range_cursor(p_payroll_action_id in number,
                       p_sqlstr            out NOCOPY varchar2)
--------------------------------------------------------------------------------
is
begin
  p_sqlstr := c_range_cursor;
end range_cursor;
--------------------------------------------------------------------------------
procedure assignment_action_creation(p_payroll_action_id in number,
                                     p_start_person_id   in number,
                                     p_end_person_id     in number,
                                     p_chunk             in number)
--------------------------------------------------------------------------------
is
--
  l_locking_action_id number;
--
  cursor csr_process_assignment
  is
  select paa.assignment_id,
         paa.assignment_action_id,
         paa.source_action_id,
         paa.tax_unit_id
  from   pay_run_types_f        prt,
         pay_payroll_actions    ppa,
         pay_assignment_actions paa,
         per_assignments_f      pa,
         pay_payroll_actions    bppa
  where  bppa.payroll_action_id = p_payroll_action_id
  and    pa.business_group_id = bppa.business_group_id
  and    pa.person_id
         between p_start_person_id and p_end_person_id
  and    bppa.effective_date
         between pa.effective_start_date and pa.effective_end_date
  and    pa.payroll_id = to_number(pay_kr_ff_functions_pkg.get_legislative_parameter(bppa.payroll_action_id, 'PAYROLL_ID', null))
  and    paa.assignment_id = pa.assignment_id
  and    paa.action_status = 'C'
  and    ppa.payroll_action_id = paa.payroll_action_id
  and    ppa.effective_date
  /*       between trunc(bppa.effective_date,'YYYY') and add_months(trunc(bppa.effective_date,''YYYY''),12) -1 */
         between trunc(bppa.effective_date,'YYYY') and bppa.effective_date
  and    prt.run_type_id = paa.run_type_id
  and    ppa.effective_date
         between prt.effective_start_date and prt.effective_end_date
  and    prt.run_type_name like 'SEP%'
  and    prt.run_type_name <> 'SEP_L'
  and    not exists(
                select  'x'
                from    pay_payroll_actions    appa,
                        pay_assignment_actions apaa,
                        pay_action_interlocks  pai
                where   pai.locked_action_id = paa.assignment_action_id
                and     apaa.assignment_action_id = pai.locking_action_id
                and     appa.payroll_action_id = apaa.payroll_action_id
                and     appa.action_type = 'X'
                and     appa.report_type = bppa.report_type
                and     trunc(appa.effective_date,'YYYY') = trunc(bppa.effective_date,'YYYY')
                union all    -- 4660184
                select  'x'
                from    pay_payroll_actions    ppa2,
                        pay_run_types_f        prt2,
                        pay_assignment_actions paa2
                where   paa2.assignment_id = paa.assignment_id
                and     prt2.run_type_id = paa2.run_type_id
                and     prt2.run_type_id = ppa2.run_type_id
                and     prt2.run_type_name like 'SEP%'
                and     ppa2.payroll_action_id = paa2.payroll_action_id
                and     ppa2.effective_date
                        between trunc(bppa.effective_date,'YYYY') and bppa.effective_date
                and     ppa2.effective_date
                        between prt2.effective_start_date and prt2.effective_end_date
                and     paa2.action_sequence > paa.action_sequence
                )

  order by pa.assignment_id, paa.action_sequence;
--
  l_csr_process_assignment csr_process_assignment%rowtype;
--
begin
--
  if g_debug then
    hr_utility.trace('Start Of assignment_action_creation');
  end if;

  open csr_process_assignment;
  loop
    fetch csr_process_assignment into l_csr_process_assignment;
    exit when csr_process_assignment%notfound;
    --
    --  Insert new Assignment Action for Archive Process
    --
    select pay_assignment_actions_s.nextval
    into   l_locking_action_id
    from   dual;
    --
    if g_debug then
      hr_utility.trace(' Locking assignment_action_id ..:'||l_locking_action_id);
    end if;

    hr_nonrun_asact.insact(lockingactid => l_locking_action_id,
                           assignid     => l_csr_process_assignment.assignment_id,
                           pactid       => p_payroll_action_id,
                           chunk        => p_chunk,
                           greid        => l_csr_process_assignment.tax_unit_id,
                           prepayid     => null,
                           status       => 'U');
    --
    -- Lock archived Assignemnt Actions
    --
    if g_debug then
      hr_utility.trace('Locked assignment_action_id ..:'||l_csr_process_assignment.assignment_action_id);
    end if;

    --Bug # 2377251 : added the the code to lock the assignment_action_id (i.e child assignment action id )

    hr_nonrun_asact.insint(lockingactid => l_locking_action_id,
                           lockedactid  => l_csr_process_assignment.assignment_action_id);

    if g_debug then
      hr_utility.trace('Locked source_action_id ..:'||l_csr_process_assignment.source_action_id);
    end if;
    --
    hr_nonrun_asact.insint(lockingactid => l_locking_action_id,
                           lockedactid  => l_csr_process_assignment.source_action_id);
    --

  end loop;
  close csr_process_assignment;

  if g_debug then
    hr_utility.trace('End Of assignment_action_creation');
  end if;
--
end assignment_action_creation;
--------------------------------------------------------------------------------
procedure archinit(p_payroll_action_id in number)
--------------------------------------------------------------------------------
is
begin
--
  null;
--
end archinit;
--------------------------------------------------------------------------------
procedure archive_data(p_assignment_action_id in number,
                       p_effective_date       in date)
--------------------------------------------------------------------------------
is
--
  l_business_group_id    number;
  l_payroll_id           number;
  l_payroll_action_id    number;
  l_assignment_id        number;
  l_assignment_action_id number;
  l_date_earned          date;
  l_tax_unit_id          number;
--
  l_context_no number;
  cnt          number := 0;
--
  cursor csr_context
  is
  select ppa.business_group_id,
         ppa.payroll_id,
         ppa.payroll_action_id,
         paa.assignment_id,
         paa.assignment_action_id,
         ppa.date_earned,
         paa.tax_unit_id
  from   pay_payroll_actions    ppa,
         pay_assignment_actions paa,
         pay_action_interlocks  pai,
         pay_assignment_actions xpaa
  where  xpaa.assignment_action_id = p_assignment_action_id
  and    pai.locking_action_id = xpaa.assignment_action_id
  and    paa.assignment_action_id = pai.locked_action_id
  and    paa.source_action_id is not null
  and    ppa.payroll_action_id = paa.payroll_action_id;
--
begin
--
  if g_debug then
    hr_utility.trace('Start of archive_data');
  end if;

  l_context_no := pay_archive.g_context_values.sz;
  for i in 1..l_context_no loop
    pay_archive.g_context_values.name(i) := NULL;
    pay_archive.g_context_values.value(i) := NULL;
  end loop;
  pay_archive.g_context_values.sz := 0;
--
  open csr_context;
  fetch csr_context into
    l_business_group_id,
    l_payroll_id,
    l_payroll_action_id,
    l_assignment_id,
    l_assignment_action_id,
    l_date_earned,
    l_tax_unit_id;
  close csr_context;
--
  --
  -- Set Context for DB Item
  --
  if l_business_group_id is not null then
    cnt := cnt + 1;
    pay_archive.g_context_values.name(cnt) := 'BUSINESS_GROUP_ID';
    pay_archive.g_context_values.value(cnt) := l_business_group_id;
  end if;
  --
  if l_payroll_id is not null then
    cnt := cnt + 1;
    pay_archive.g_context_values.name(cnt) := 'PAYROLL_ID';
    pay_archive.g_context_values.value(cnt) := l_payroll_id;
  end if;
  --
  if l_payroll_action_id is not null then
    cnt := cnt + 1;
    pay_archive.g_context_values.name(cnt) := 'PAYROLL_ACTION_ID';
    pay_archive.g_context_values.value(cnt) := l_payroll_action_id;
  end if;
  --
  if l_assignment_id is not null then
    cnt := cnt + 1;
    pay_archive.g_context_values.name(cnt) := 'ASSIGNMENT_ID';
    pay_archive.g_context_values.value(cnt) := l_assignment_id;
  end if;
  --
  if l_assignment_action_id is not null then
    cnt := cnt + 1;
    pay_archive.g_context_values.name(cnt) := 'ASSIGNMENT_ACTION_ID';
    pay_archive.g_context_values.value(cnt) := l_assignment_action_id;
    -- Set Assignment Action id to get Balance
    pay_archive.balance_aa := l_assignment_action_id;
    pay_archive.archive_aa := l_assignment_action_id;
  end if;
  --
  if l_date_earned is not null then
    cnt := cnt + 1;
    pay_archive.g_context_values.name(cnt) := 'DATE_EARNED';
    pay_archive.g_context_values.value(cnt) := fnd_date.date_to_canonical(l_date_earned);
  end if;
  --
  if l_tax_unit_id is not null then
    cnt := cnt + 1;
    pay_archive.g_context_values.name(cnt) := 'TAX_UNIT_ID';
    pay_archive.g_context_values.value(cnt) := l_tax_unit_id;
  end if;
  --
  -- This value is used in pay_archive.archive_dbi
  pay_archive.g_context_values.sz := cnt;
  --
--
--
  if g_debug then
    hr_utility.set_location('P_BUSINESS_GROUP_ID      ->' ||l_business_group_id,100);
    hr_utility.set_location('P_TAX_UNIT_ID            ->' ||l_tax_unit_id,200);
    hr_utility.set_location('P_ASSIGNMENT_ID          ->' ||l_assignment_id,300);
    hr_utility.set_location('P_PAYROLL_ACTION_ID      ->' ||l_payroll_action_id,400);
    hr_utility.set_location('P_ASSIGNMENT_ACTION_ID   ->' ||p_assignment_action_id,500);
  end if;

--------------------------

--Archive efile related data
--------------------------
 if g_debug then
   hr_utility.set_location('Calling archive_xdbi',2);
 end if;

 archive_xdbi                      (  P_BUSINESS_GROUP_ID     =>l_business_group_id
                                     ,P_TAX_UNIT_ID           =>l_tax_unit_id
                                     ,P_ASSIGNMENT_ID         =>l_assignment_id
                                     ,P_PAYROLL_ACTION_ID     =>l_payroll_action_id
                                     ,P_ASSIGNMENT_ACTION_ID  =>p_assignment_action_id
                                     ,P_DATE_EARNED           =>l_date_earned );

  if g_debug then
    hr_utility.set_location('Exiting archive_xdbi',3);
    hr_utility.trace('End of archive_data');
  end if;
end archive_data;

begin
	g_debug  :=  hr_utility.debug_enabled;
end pay_kr_sep_archive_pkg;

/
