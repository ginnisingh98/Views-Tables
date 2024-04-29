--------------------------------------------------------
--  DDL for Package Body PER_DIF_STMT_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_DIF_STMT_REPORT" AS
/* $Header: perfrdif.pkb 120.3 2006/09/19 21:30:05 aparkes noship $ */
--
g_xml_ctr NUMBER;
---------------------------------------------------
-- Main procedure for building XML string
------------------------------------------------------
PROCEDURE dif_main_fill_table(p_business_group_id NUMBER,
                              p_estab_id          NUMBER DEFAULT NULL,
			      p_accrual_plan_id   NUMBER ,
			      p_start_year        VARCHAR2, -- added to match parameters with CP
			      p_start_month       NUMBER, -- added to match parameters with CP
			      p_date_from         VARCHAR2,
			      p_end_year          VARCHAR2, -- added to match parameters with CP
			      p_end_month         NUMBER, -- added to match parameters with CP
			      p_date_to           VARCHAR2,
			      p_emp_id            NUMBER DEFAULT NULL,
			      p_sort_order        VARCHAR2,
			      p_template_name     VARCHAR2, -- added to match parameters with CP
			      p_xml OUT NOCOPY CLOB)
IS
--
l_order_by VARCHAR2(40);
l_where VARCHAR2(1500);
l_where_emp VARCHAR2(500);
l_where_estab VARCHAR2(500);
l_select VARCHAR2(500);
l_estab_id NUMBER;
l_emp_id NUMBER;
l_full_name per_all_people_f.full_name%TYPE;
l_emp_num per_all_people_f.employee_number%TYPE;
l_xml clob;
l_date_from date;
l_date_to date;
--
TYPE ref_cursor_type IS REF CURSOR;
ref_csr_emp_list ref_cursor_type;
--
-- Cursor for fetching field names
cursor csr_get_lookup is
  select lookup_code,meaning
  from hr_lookups
  where lookup_type='FR_DIF_STMT_LOOKUP_CODE'
  and lookup_code <> 'TOTAL'; -- added for 5111065
--
-- Cursor to specifically fetch the code and meaning
-- of 'TOTAL' from name_translations
-- added for 5111065
cursor csr_get_lookup_total is
  select lookup_code,meaning
  from hr_lookups
  where lookup_type='NAME_TRANSLATIONS'
  and lookup_code = 'TOTAL';
--
BEGIN
hr_utility.set_location('Entering dif_main_fill_table', 10);
-- Initialize the xml table counter
g_xml_ctr :=0;
-- Delete values in the table
xml_table.delete;
hr_utility.set_location('Deleted rows in xml table', 20);
--
-- Set the date values
l_date_from := fnd_date.canonical_to_date(p_date_from);
l_date_to := fnd_date.canonical_to_date(p_date_to);
--
-- Get a list of employees for this establishment
-- and accrual plan, if any
-- Build the query dynamically
l_select := 'select distinct per.person_id emp_id, estab.organization_id estab_id, per.full_name name, per.employee_number empnum from per_all_people_f per, per_all_assignments_f ass, pay_element_entries_f ent, '||
            'pay_accrual_plans  acc, hr_all_organization_units estab';
l_where := '  where per.person_id = ass.person_id and per.business_group_id = '||p_business_group_id||'  and '|| '''' ||l_date_to|| ''''||' between per.effective_start_date  '
           ||'and per.effective_end_date and estab.business_group_id = per.business_group_id  and ass.establishment_id = estab.organization_id  '
           ||'and ass.effective_end_date >= '|| '''' ||l_date_from|| ''''||'  and ass.effective_start_date <= '|| '''' ||l_date_to|| ''''||'  and ass.assignment_id = ent.assignment_id  '
           ||'and ent.element_type_id = acc.accrual_plan_element_type_id and acc.accrual_plan_id = '||p_accrual_plan_id||'  and ent.effective_end_date >= '|| '''' ||l_date_from|| ''''||' and ent.effective_start_date <= '|| '''' ||l_date_to|| ''''||'';
--
IF p_emp_id IS NULL THEN
   l_where_emp := ' ';
ELSE
   l_where_emp := 'and per.person_id = '||p_emp_id||'';
END IF;
--
hr_utility.set_location('Where emp clause is: '||l_where_emp, 30);
--
IF p_estab_id IS NULL THEN
   l_where_estab := ' ';
ELSE
   l_where_estab := 'and estab.organization_id = '||p_estab_id||'';
END IF;
--
hr_utility.set_location('Where estab clause: '||l_where_estab, 30);
--
IF p_sort_order = 'NAME' THEN
  l_order_by := '  order by per.full_name';
ELSIF p_sort_order = 'NUMBER' THEN
  l_order_by := '  order by fnd_number.canonical_to_number(per.employee_number)';
END IF;
--
hr_utility.set_location('Order by clause is: '||l_order_by, 30);
--
OPEN ref_csr_emp_list FOR l_select||l_where||l_where_emp||l_where_estab||l_order_by;
LOOP
   FETCH ref_csr_emp_list INTO l_emp_id, l_estab_id, l_full_name, l_emp_num;
   EXIT WHEN ref_csr_emp_list%NOTFOUND;
   -- Set the start label
   g_xml_ctr := g_xml_ctr +1;
   xml_table( g_xml_ctr).tag_name := 'L_MAIN';
   xml_table( g_xml_ctr).tag_value := '1';
   --
   hr_utility.set_location('g_xml_ctr after main start is: '||to_char(g_xml_ctr), 40);
   -- populate field names for each employee
   FOR get_lookup_rec IN csr_get_lookup LOOP
       --
       g_xml_ctr := g_xml_ctr +1;
       xml_table(g_xml_ctr).tag_name := get_lookup_rec.lookup_code;
       xml_table(g_xml_ctr).tag_value := get_lookup_rec.meaning;
       --
   END LOOP;
   --
   -- added for 5111065
   FOR get_lookup_total_rec IN csr_get_lookup_total LOOP
       --
       g_xml_ctr := g_xml_ctr +1;
       xml_table(g_xml_ctr).tag_name := get_lookup_total_rec.lookup_code;
       xml_table(g_xml_ctr).tag_value := get_lookup_total_rec.meaning;
       --
   END LOOP;
   --
   hr_utility.set_location('g_xml_ctr after dif lookup is: '||to_char(g_xml_ctr), 40);
   --
   -- Call the procedure to fetch all report values
   dif_emp_acc_details(p_business_group_id => p_business_group_id,
                       p_estab_id          => l_estab_id,
		       p_accrual_plan_id   => p_accrual_plan_id,
	               p_emp_id            => l_emp_id,
		       p_date_from         => l_date_from,
		       p_date_to           => l_date_to);
   --
   hr_utility.set_location('g_xml_ctr before main end is: '||to_char(g_xml_ctr), 40);
   -- Set the end label
   g_xml_ctr := g_xml_ctr +1;
   xml_table( g_xml_ctr).tag_name := 'L_MAIN';
   xml_table( g_xml_ctr).tag_value := '0';
   --
END LOOP;
--
hr_utility.set_location('g_xml_ctr at end is: '||to_char(g_xml_ctr), 40);
-- Call the procedure to write to clob
write_to_clob(l_xml);
p_xml:= l_xml;
hr_utility.set_location('Exiting dif_main_fill_table', 10);
--
END dif_main_fill_table;
--
--------------------------------------------------------------
-- procedure for fetching employee, estab and accrual details
-- for each employee
---------------------------------------------------------------
PROCEDURE dif_emp_acc_details(p_business_group_id NUMBER,
                              p_estab_id          NUMBER ,
		              p_accrual_plan_id   NUMBER,
	                      p_emp_id            NUMBER,
		              p_date_from         DATE,
		              p_date_to           DATE)
IS
--
l_rowcount number;
l_total_absence_duration number;
l_prev_asg_catg varchar2(3);
l_assignment_id number;
l_payroll_id number;
l_total_carryover number;
l_co_start_date date;
l_period_entitlement number;
l_total_dif_accrual number;
l_total_accrual number;
l_period_adjustments number;
l_period_absence number;
l_total_adjustments number;
l_start_date date;
l_end_date date;
l_dummy_date date;
l_dif_balance number;
--
-- Declare table for storing accrual periods
TYPE acc_dates_rec is RECORD
(accrual_start_date date,
 accrual_end_date date,
 payroll_id number,
 wkg_hrs number);

TYPE acc_dates_tab is TABLE of acc_dates_rec INDEX by BINARY_INTEGER;

acc_period_dates acc_dates_tab;
--
-- Cursor for accrual and adjustment field label
cursor csr_get_repeat_lookup(c_lookup_code varchar2) is
  select lookup_code,meaning
  from hr_lookups
  where lookup_type='FR_DIF_STMT_LOOKUP_CODE'
  and lookup_code = c_lookup_code;
--
-- Cursor for establishment details in header
Cursor csr_hdr_estab_details is
Select 'er_hdr_estab_name',
       estab_tl.name ,
       'er_hdr_estab_addr_compl',
       estab_loc.address_line_2 ,
       'er_hdr_estab_addr_nstreet',
       estab_loc.address_line_1,
       'er_hdr_estab_addr_town',
       estab_loc.region_3,
       'er_hdr_estab_addr_zip',
       estab_loc.postal_code,
       'er_hdr_estab_addr_towncity',
       estab_loc.town_or_city,
       'er_hdr_estab_country',
       estab_ft.nls_territory,
       'er_hdr_comp_name',
       comp_tl.name,
       'er_hdr_comp_addr_compl',
       comp_loc.address_line_2,
       'er_hdr_comp_addr_nstreet',
       comp_loc.address_line_1,
       'er_hdr_comp_addr_town',
       comp_loc.region_3,
       'er_hdr_comp_addr_zip',
       comp_loc.postal_code,
       'er_hdr_comp_addr_towncity',
       comp_loc.town_or_city,
       'er_hdr_comp_country',
       comp_ft.nls_territory,
       'er_hdr_estab_siret',
       estab_info.org_information2
from hr_all_organization_units    estab,
     hr_all_organization_units_tl estab_tl,
     hr_all_organization_units    comp,
     hr_all_organization_units_tl comp_tl,
     hr_organization_information  estab_info,
     hr_locations_all             estab_loc,
     hr_locations_all             comp_loc,
     fnd_territories              estab_ft,
     fnd_territories              comp_ft
where estab.organization_id = p_estab_id
  and estab.business_group_id = p_business_group_id
  and estab_tl.organization_id = estab.organization_id
  and estab_tl.language = userenv('LANG')
  and estab_info.organization_id(+) = estab.organization_id
  and estab_info.org_information_context(+) = 'FR_ESTAB_INFO'
  and comp.organization_id(+) = estab_info.org_information1
  and comp.business_group_id(+) = p_business_group_id
  and comp_tl.organization_id(+) = comp.organization_id
  and comp_tl.language(+) = userenv('LANG')
  and estab_loc.location_id(+) = estab.location_id
  and estab_loc.style(+) ='FR'
  and comp_loc.location_id(+) = comp.location_id
  and comp_loc.style(+) ='FR'
  and estab_ft.territory_code(+) = estab_loc.country
  and comp_ft.territory_code(+) = comp_loc.country;
--
-- Cursor for employee details in header
Cursor csr_emp_hdr_details is
Select 'emp_hdr_full_name' ,
       per.full_name ,
       'emp_hdr_empnum',
       per.employee_number,
       'emp_hdr_addr_compl',
       per_addr.address_line2,
       'emp_hdr_addr_nstreet',
       per_addr.address_line1,
       'emp_hdr_addr_town',
       per_addr.region_3,
       'emp_hdr_addr_zip',
       per_addr.postal_code,
       'emp_hdr_addr_towncity',
       per_addr.town_or_city,
       'emp_hdr_country',
       per_ft.nls_territory ,
       'emp_hdr_hiredate',
       to_char(per.original_date_of_hire, 'dd-Mon-yy'),
       'emp_hdr_adj_svc_date',
       null, -- adjusted service date
       'emp_hdr_term_date',
       decode(serv.actual_termination_date, hr_general.end_of_time, null, to_char(serv.actual_termination_date, 'dd-Mon-yy')),
       'emp_hdr_coll_aggr',
       col_agr.name,
       'emp_hdr_asg_catg',
       hr_general.decode_lookup('EMP_CAT', asg.employment_category),
       asg.assignment_id,
       asg.payroll_id
from per_all_people_f          per,
     per_addresses             per_addr,
     fnd_territories           per_ft,
     per_periods_of_service    serv,
     per_all_assignments_f     asg,
     per_collective_agreements col_agr
where per.person_id = p_emp_id
  and asg.person_id = per.person_id
  and per.effective_end_date = (select max(effective_end_date)
                                  from per_all_people_f
				 where person_id = per.person_id
				  and effective_end_date >= p_date_from)
  and asg.effective_end_date =(select max(effective_end_date)
                                 from per_all_assignments_f
				 where person_id = per.person_id
				   and effective_end_date >= p_date_from)
  and serv.person_id = per.person_id
  and (serv.actual_termination_date is null
  or serv.actual_termination_date= (select greatest(actual_termination_date)
                                      from per_periods_of_service
				     where person_id = per.person_id
				       and actual_termination_date > per.effective_start_date))
  and per_addr.person_id(+) = per.person_id
  and per_addr.primary_flag(+) = 'Y'
  and per_ft.territory_code(+) = per_addr.country
  and col_agr.collective_agreement_id(+) = asg.collective_agreement_id;
--
-- Cursor for contract details in header
Cursor csr_ctr_hdr_details is
select to_char(ctr.effective_start_date, 'dd-Mon-yy')    ctr_hdr_start,
       decode(ctr.effective_end_date, hr_general.end_of_time, null,to_char(ctr.effective_end_date, 'dd-Mon-yy'))      ctr_hdr_end,
       hr_general.decode_lookup('CONTRACT_TYPE',ctr.type)                ctr_hdr_type,
       hr_general.decode_lookup('FR_CONTRACT_CATEGORY',ctr_information2) ctr_hdr_category,
       decode(ctr.ctr_information12, 'HOUR', ctr.ctr_information11, to_char(asg.normal_hours)) ctr_hdr_hours
from per_contracts_f       ctr,
     per_all_assignments_f asg
where asg.person_id = p_emp_id
and asg.effective_start_date <= p_date_to
and asg.effective_end_date >= p_date_from
and asg.contract_id(+) = ctr.contract_id
and ctr.effective_end_date =(select greatest(effective_end_date)
                                 from per_contracts_f
				 where contract_id= ctr.contract_id
				   and effective_end_date >= p_date_from)
and ctr_information_category(+) = 'FR';
--
-- Cursor for accrual details in header
Cursor csr_acc_hdr_details is
select 'acc_hdr_plan_name',
       acc.accrual_plan_name    ,
       'acc_hdr_enrol_start',
       to_char(ent.effective_start_date, 'dd-Mon-yy') ,
       'acc_hdr_enrol_end',
       decode(ent.effective_end_date, hr_general.end_of_time,null, to_char(ent.effective_end_date, 'dd-Mon-yy'))
from pay_accrual_plans  acc,
     pay_element_entries_f ent,
     per_all_assignments_f asg
where acc.accrual_plan_id = p_accrual_plan_id
and asg.person_id = p_emp_id
and ent.assignment_id = asg.assignment_id
and ent.element_type_id = acc.accrual_plan_element_type_id
and ent.effective_start_date = (select max(effective_start_date)
                                from pay_element_entries_f
				where assignment_id = ent.assignment_id
				and element_type_id = acc.accrual_plan_element_type_id
				and effective_start_date <= p_date_to
				and effective_end_date >= p_date_from);
--
---------------------------------------
-- Cursors for report body
------------------------------------------
-- Cursor for selecting the greater of enrollment date and hiredate
Cursor csr_get_co_start is
select greatest(ent.effective_start_date, per.original_date_of_hire) co_start_date
from pay_element_entries_f ent,
     per_all_assignments_f asg,
     per_all_people_f      per,
     pay_accrual_plans     acc
where acc.accrual_plan_id = p_accrual_plan_id
  and per.person_id = p_emp_id
  and asg.person_id = per.person_id
  and per.effective_end_date = (select max(effective_end_date)
                                  from per_all_people_f
				 where person_id = per.person_id
				  and effective_end_date >= p_date_from)
  and asg.effective_end_date =(select max(effective_end_date)
                                 from per_all_assignments_f
				 where person_id = per.person_id
				   and effective_end_date >= p_date_from)
 and ent.assignment_id = asg.assignment_id
 and ent.element_type_id = acc.accrual_plan_element_type_id
 and ent.effective_start_date = (select max(effective_start_date)
                                from pay_element_entries_f
				where assignment_id = ent.assignment_id
				and element_type_id = acc.accrual_plan_element_type_id
				and effective_start_date <= p_date_to
				and effective_end_date >= p_date_from);
-- Cursor for selecting accrual periods based on
-- statement period
-- and change in employment category
Cursor csr_dif_acc_periods is
select asg.effective_start_date start_date,
       substr(hruserdt.get_table_value(p_business_group_id, 'FR_CIPDZ', 'CIPDZ',nvl(asg.employment_category,'FR'),p_date_from),1,1) asg_catg,
       asg.payroll_id payroll_id,
       decode(ctr.ctr_information12, 'HOUR', fnd_number.canonical_to_number(ctr.ctr_information11), asg.normal_hours) wkg_hours
from per_all_assignments_f asg,
     per_contracts_f       ctr
where asg.person_id= p_emp_id
and asg.effective_end_date >= p_date_from
and asg.effective_start_date <= p_date_to
and asg.contract_id = ctr.contract_id
and asg.effective_start_date between ctr.effective_start_date and ctr.effective_end_date
order by asg.effective_start_date asc;
--
-- Cursor for fetching different absences
-- corresponding to the accrual plan and period
Cursor csr_dif_abs_details is
select  to_char(abs.date_start, 'dd-Mon-yy')  abs_start,
        to_char(abs.date_end, 'dd-Mon-yy')    abs_end,
	abs.absence_hours      abs_duration,
	hr_general.decode_lookup('FR_TRAINING_LEAVE_CATEGORY',abs.abs_information1)   abs_trg_catg,
	abs.abs_information2   abs_course,
	po.vendor_name         abs_trg_prov,
	hr_general.decode_lookup('FR_TRAINING_TYPE',abs.abs_information4)   abs_trg_type,
	abs.abs_information17  abs_reference,
	hr_general.decode_lookup('FR_LEGAL_TRG_CATG',abs.abs_information19)  abs_leg_catg,
	abs.abs_information20  abs_out_wkg_hrs,
	decode(abs.date_projected_start, null, 'N', 'Y') abs_proj_yn
   from   per_absence_attendances abs,
          per_absence_attendance_types abt,
          pay_accrual_plans pap,
	  po_vendors po
   where  abs.absence_attendance_type_id = abt.absence_attendance_type_id
   and    abt.input_value_id = pap.pto_input_value_id
   and    abs.person_id = p_emp_id
   and    abs.abs_information_category = 'FR_TRAINING_ABSENCE'
   and    abs.date_start between p_date_from and p_date_to
   and    pap.accrual_plan_id = p_accrual_plan_id
   and    po.vendor_id = fnd_number.canonical_to_number(abs.abs_information3);
--
-- Cursor getting adjustment element entries
Cursor csr_dif_adj_entries(c_assignment_id number,
                           c_start_date date,
			   c_end_date date) is
select ele.element_name         adj_element,
       to_char(pee.effective_start_date, 'dd-Mon-yy') adj_start,
       to_char(pee.effective_end_date, 'dd-Mon-yy')   adj_end,
       round(fnd_number.canonical_to_number(pev.screen_entry_value)*fnd_number.canonical_to_number(ncr.add_or_subtract), 2)   adj_hours,
       hr_general.decode_lookup('ADD_SUBTRACT',ncr.add_or_subtract)       add_or_subtract
from     pay_accrual_plans          pap,
         pay_net_calculation_rules  ncr,
         pay_element_entries_f      pee,
         pay_element_entry_values_f pev,
         pay_input_values_f         iv,
	 pay_element_types_f        ele
   where pap.accrual_plan_id  = p_accrual_plan_id
     and pee.assignment_id    = c_assignment_id
     and pee.element_entry_id = pev.element_entry_id
     and pev.input_value_id   = ncr.input_value_id
     and pap.accrual_plan_id  = ncr.accrual_plan_id
     and ncr.input_value_id not in (pap.co_input_value_id,pap.pto_input_value_id)
     and pev.screen_entry_value is not null
     and pev.effective_start_date = pee.effective_start_date
     and pev.effective_end_date = pee.effective_end_date
     and iv.input_value_id = ncr.input_value_id
     and c_end_date between iv.effective_start_date and iv.effective_end_date
     and ele.element_type_id = iv.element_type_id
     and c_end_date between ele.effective_start_date and ele.effective_end_date
     and pee.element_type_id = iv.element_type_id
     and exists
        (select null
          from pay_element_entry_values_f pev1,
               pay_input_values_f piv2
         where pev1.element_entry_id     = pev.element_entry_id
           and pev1.input_value_id       = ncr.date_input_value_id
           and pev1.effective_start_date = pev.effective_start_date
           and pev1.effective_end_date   = pev.effective_end_date
           and ncr.date_input_value_id   = piv2.input_value_id
           and pee.element_type_id       = piv2.element_type_id
           and c_end_date between piv2.effective_start_date
           and piv2.effective_end_date
           and fnd_date.canonical_to_date(decode(substr(piv2.uom, 1, 1),'D',
               pev1.screen_entry_value, Null))
               between c_start_date and c_end_date);
--
BEGIN
--
hr_utility.set_location('Entering dif_emp_acc_details', 40);
hr_utility.set_location('Table count before header is: '||to_char(xml_table.count), 40);
hr_utility.set_location('g_xml_ctr before header is: '||to_char(g_xml_ctr), 40);
--
---------------------------------
-- HEADER SECTION
-----------------------------------
-- Get establishment data
OPEN csr_hdr_estab_details;
FETCH csr_hdr_estab_details INTO
   -- Write into form fields
   xml_table( g_xml_ctr +1).tag_name ,
   xml_table( g_xml_ctr +1).tag_value ,
   --
   xml_table(g_xml_ctr +2).tag_name,
   xml_table(g_xml_ctr +2).tag_value,
   --
   xml_table(g_xml_ctr +3).tag_name,
   xml_table(g_xml_ctr +3).tag_value,
   --
   xml_table(g_xml_ctr +4).tag_name,
   xml_table(g_xml_ctr +4).tag_value,
   --
   xml_table(g_xml_ctr +5).tag_name,
   xml_table(g_xml_ctr +5).tag_value,
   --
   xml_table(g_xml_ctr +6).tag_name,
   xml_table(g_xml_ctr +6).tag_value,
   --
   xml_table(g_xml_ctr +7).tag_name,
   xml_table(g_xml_ctr +7).tag_value,
   --
   xml_table(g_xml_ctr +8).tag_name,
   xml_table(g_xml_ctr +8).tag_value,
   --
   xml_table(g_xml_ctr +9).tag_name,
   xml_table(g_xml_ctr +9).tag_value,
   --
   xml_table(g_xml_ctr +10).tag_name,
   xml_table(g_xml_ctr +10).tag_value,
   --
   xml_table(g_xml_ctr +11).tag_name,
   xml_table(g_xml_ctr +11).tag_value,
   --
   xml_table(g_xml_ctr +12).tag_name,
   xml_table(g_xml_ctr +12).tag_value,
   --
   xml_table(g_xml_ctr +13).tag_name,
   xml_table(g_xml_ctr +13).tag_value,
   --
   xml_table(g_xml_ctr +14).tag_name,
   xml_table(g_xml_ctr +14).tag_value,
   --
   xml_table(g_xml_ctr +15).tag_name,
   xml_table(g_xml_ctr +15).tag_value;
   --
   -- increment the counter to table rowcount
   g_xml_ctr := xml_table.count;
CLOSE  csr_hdr_estab_details;
--
hr_utility.set_location('Table count after estab hdr is: '||to_char(xml_table.count), 40);
hr_utility.set_location('g_xml_ctr after estab hdr is: '||to_char(g_xml_ctr), 40);
-- Get employee data
OPEN csr_emp_hdr_details;
-- fetch data into form fields
-- and corresponding variables
FETCH csr_emp_hdr_details INTO
   --
   xml_table( g_xml_ctr +1).tag_name ,
   xml_table( g_xml_ctr +1).tag_value ,
   --
   xml_table(g_xml_ctr +2).tag_name,
   xml_table(g_xml_ctr +2).tag_value,
   --
   xml_table(g_xml_ctr +3).tag_name,
   xml_table(g_xml_ctr +3).tag_value,
   --
   xml_table(g_xml_ctr +4).tag_name,
   xml_table(g_xml_ctr +4).tag_value,
   --
   xml_table(g_xml_ctr +5).tag_name,
   xml_table(g_xml_ctr +5).tag_value,
   --
   xml_table(g_xml_ctr +6).tag_name,
   xml_table(g_xml_ctr +6).tag_value,
   --
   xml_table(g_xml_ctr +7).tag_name,
   xml_table(g_xml_ctr +7).tag_value,
   --
   xml_table(g_xml_ctr +8).tag_name,
   xml_table(g_xml_ctr +8).tag_value,
   --
   xml_table(g_xml_ctr +9).tag_name,
   xml_table(g_xml_ctr +9).tag_value,
   --
   xml_table(g_xml_ctr +10).tag_name,
   xml_table(g_xml_ctr +10).tag_value,
   --
   xml_table(g_xml_ctr +11).tag_name,
   xml_table(g_xml_ctr +11).tag_value,
   --
   xml_table(g_xml_ctr +12).tag_name,
   xml_table(g_xml_ctr +12).tag_value,
   --
   xml_table(g_xml_ctr +13).tag_name,
   xml_table(g_xml_ctr +13).tag_value,
   --
   l_assignment_id,
   l_payroll_id;
   --
   -- increment the counter to table rowcount
   g_xml_ctr := xml_table.count;
   --
CLOSE csr_emp_hdr_details;
--
hr_utility.set_location('Table count after emp hdr is: '||to_char(xml_table.count), 40);
hr_utility.set_location('g_xml_ctr after emp hdr is: '||to_char(g_xml_ctr), 40);
-- Get contract details
FOR ctr_hdr_rec IN csr_ctr_hdr_details LOOP
   -- Set the start label
   g_xml_ctr := g_xml_ctr +1;
   xml_table( g_xml_ctr).tag_name := 'L_CTR_HDR';
   xml_table( g_xml_ctr).tag_value := '1';
   --
   -- Write into form fields
   g_xml_ctr := g_xml_ctr +1;
   xml_table( g_xml_ctr).tag_name := 'ctr_hdr_start';
   xml_table( g_xml_ctr).tag_value := ctr_hdr_rec.ctr_hdr_start;
   --
   g_xml_ctr := g_xml_ctr +1;
   xml_table( g_xml_ctr).tag_name := 'ctr_hdr_end';
   xml_table( g_xml_ctr).tag_value := ctr_hdr_rec.ctr_hdr_end;
   --
   g_xml_ctr := g_xml_ctr +1;
   xml_table( g_xml_ctr).tag_name := 'ctr_hdr_type';
   xml_table( g_xml_ctr).tag_value := ctr_hdr_rec.ctr_hdr_type;
   --
   g_xml_ctr := g_xml_ctr +1;
   xml_table( g_xml_ctr).tag_name := 'ctr_hdr_category';
   xml_table( g_xml_ctr).tag_value := ctr_hdr_rec.ctr_hdr_category;
   --
   g_xml_ctr := g_xml_ctr +1;
   xml_table( g_xml_ctr).tag_name := 'ctr_hdr_hours';
   xml_table( g_xml_ctr).tag_value := ctr_hdr_rec.ctr_hdr_hours;
   --
   -- Set the end label
   g_xml_ctr := g_xml_ctr +1;
   xml_table( g_xml_ctr).tag_name := 'L_CTR_HDR';
   xml_table( g_xml_ctr).tag_value := '0';
   --
END LOOP;
--
hr_utility.set_location('Table count after ctr hdr is: '||to_char(xml_table.count), 40);
hr_utility.set_location('g_xml_ctr after ctr header is: '||to_char(g_xml_ctr), 40);
-- Get accrual details
OPEN csr_acc_hdr_details;
FETCH csr_acc_hdr_details INTO
   -- Write into form fields
   xml_table( g_xml_ctr +1).tag_name ,
   xml_table( g_xml_ctr +1).tag_value ,
   --
   xml_table(g_xml_ctr +2).tag_name,
   xml_table(g_xml_ctr +2).tag_value,
   --
   xml_table(g_xml_ctr +3).tag_name,
   xml_table(g_xml_ctr +3).tag_value;
   --
   -- Increment the counter
   g_xml_ctr := xml_table.count;
   --
CLOSE csr_acc_hdr_details;
--
hr_utility.set_location('Table count after accrual hdr is: '||to_char(xml_table.count), 40);
hr_utility.set_location('g_xml_ctr after accrual header is: '||to_char(g_xml_ctr), 40);
-- Write form fields for statement dates
--
g_xml_ctr := g_xml_ctr +1;
xml_table( g_xml_ctr).tag_name := 'report_date';
xml_table( g_xml_ctr).tag_value := to_char(sysdate, 'dd-Mon-yy');
--
g_xml_ctr := g_xml_ctr +1;
xml_table( g_xml_ctr).tag_name := 'statement_start_date';
xml_table( g_xml_ctr).tag_value := to_char(p_date_from, 'dd-Mon-yy');
--
g_xml_ctr := g_xml_ctr +1;
xml_table( g_xml_ctr).tag_name :='statement_end_date';
xml_table( g_xml_ctr).tag_value := to_char(p_date_to, 'dd-Mon-yy');
--
hr_utility.set_location('Table count after header is: '||to_char(xml_table.count), 40);
hr_utility.set_location('g_xml_ctr after header is: '||to_char(g_xml_ctr), 40);
-------- END OF HEADER --------------
-------------------------------------
-- Body of the report
--------------------------------------
------------------------------
-- DIF accrual section
------------------------------
-- Get the carry over values till the start of statement
l_total_carryover := 0;
OPEN csr_get_co_start;
FETCH csr_get_co_start INTO l_co_start_date;
CLOSE csr_get_co_start;
-- Get accrual values till statement start date
   per_accrual_calc_functions.get_net_accrual(
       p_assignment_id      => l_assignment_id,
       p_plan_id            => p_accrual_plan_id,
       p_payroll_id         => l_payroll_id,
       p_business_group_id  => p_business_group_id,
       p_calculation_date   => p_date_from-1,
       p_accrual_start_date => l_co_start_date,
       p_start_date         => l_dummy_date,
       p_End_Date           => l_dummy_date,
       p_Accrual_End_Date   => l_dummy_date,
       p_accrual            => l_total_accrual,
       p_net_entitlement    => l_total_carryover
       );
--
hr_utility.set_location('Calculation date for carry over is: '||to_char(p_date_from-1), 40);
hr_utility.set_location('Total carryover till date is: '||to_char(l_total_carryover), 40);
-- populate form field values
g_xml_ctr := g_xml_ctr +1;
xml_table( g_xml_ctr).tag_name := 'co_date_to';
xml_table( g_xml_ctr).tag_value := to_char(p_date_from-1, 'dd-Mon-yy');
--
g_xml_ctr := g_xml_ctr +1;
xml_table( g_xml_ctr).tag_name :=  'co_hours';
xml_table( g_xml_ctr).tag_value := round(l_total_carryover, 2);
--
-- Get the different accrual periods
-- populate the start and end dates in the PL/SQL table
l_rowcount:=0;
FOR acc_periods_rec IN csr_dif_acc_periods LOOP
   IF l_rowcount=0 THEN
     -- for the first record, set the start date
     l_rowcount := l_rowcount+1;
     acc_period_dates(l_rowcount).accrual_start_date := p_date_from;
     acc_period_dates(l_rowcount).payroll_id := acc_periods_rec.payroll_id;
     acc_period_dates(l_rowcount).wkg_hrs := acc_periods_rec.wkg_hours;
     l_prev_asg_catg := acc_periods_rec.asg_catg;
   ELSE
     IF acc_periods_rec.asg_catg <> l_prev_asg_catg THEN
       -- set the previous row end date
       acc_period_dates(l_rowcount).accrual_end_date := acc_periods_rec.start_date-1;
       l_rowcount := l_rowcount+1;
       acc_period_dates(l_rowcount).accrual_start_date := acc_periods_rec.start_date;
       acc_period_dates(l_rowcount).payroll_id := acc_periods_rec.payroll_id;
       acc_period_dates(l_rowcount).wkg_hrs := acc_periods_rec.wkg_hours;
       l_prev_asg_catg := acc_periods_rec.asg_catg;
     END IF;
   END IF;
END LOOP;
-- Check if the last end date was populated
IF acc_period_dates(l_rowcount).accrual_end_date IS NULL THEN
   -- set it to statement end date
   acc_period_dates(l_rowcount).accrual_end_date := p_date_to;
   --
END IF;
l_total_dif_accrual:= 0;
-- Call the accrual procedure for each period
FOR i in 1..l_rowcount LOOP
    per_accrual_calc_functions.get_net_accrual(
       p_assignment_id      => l_assignment_id,
       p_plan_id            => p_accrual_plan_id,
       p_payroll_id         => acc_period_dates(i).payroll_id,
       p_business_group_id  => p_business_group_id,
       p_calculation_date   => acc_period_dates(i).accrual_end_date,
       p_accrual_start_date => acc_period_dates(i).accrual_start_date,
       p_start_date         => l_start_date,
       p_End_Date           => l_end_date,
       p_Accrual_End_Date   => l_dummy_date,
       p_accrual            => l_total_accrual,
       p_net_entitlement    => l_period_entitlement);
    --
    hr_utility.set_location('Calculation date for this period is: '||to_char(acc_period_dates(i).accrual_end_date), 40);
    hr_utility.set_location('Start date for this period is: '||to_char(l_start_date),40);
    hr_utility.set_location('End date for this period is: '||to_char(l_end_date),40);
    --
    hr_utility.set_location('Period accrual before adding abs and adj is: '||to_char(l_period_entitlement), 40);
    -- Calculate the absences for this period
    l_period_absence := per_accrual_calc_functions.get_absence(
                             p_assignment_id    => l_assignment_id,
                             p_plan_id          => p_accrual_plan_id,
			     p_start_date       => l_start_date,
			     p_calculation_date => l_end_date);
    -- Calculate the adjustments for this period
    l_period_adjustments := per_accrual_calc_functions.get_other_net_contribution(
			     p_assignment_id    => l_assignment_id,
                             p_plan_id          => p_accrual_plan_id,
                             p_start_date       => l_start_date,
                             p_calculation_date => l_end_date);
    -- Add the values to get the gross accrual value
    l_period_entitlement := l_period_entitlement + l_period_absence + l_period_adjustments;
    -- Set the start label
    g_xml_ctr := g_xml_ctr +1;
    xml_table( g_xml_ctr).tag_name := 'L_DIF_ACC';
    xml_table( g_xml_ctr).tag_value := '1';
    --
    -- Get the field name
    g_xml_ctr := g_xml_ctr +1;
    OPEN csr_get_repeat_lookup('ACC_REPEAT');
    FETCH csr_get_repeat_lookup into xml_table( g_xml_ctr).tag_name, xml_table( g_xml_ctr).tag_value;
    CLOSE csr_get_repeat_lookup;
    --
    -- Write form fields
    g_xml_ctr := g_xml_ctr +1;
    xml_table( g_xml_ctr).tag_name := 'acc_date_from';
    xml_table( g_xml_ctr).tag_value := to_char(acc_period_dates(i).accrual_start_date, 'dd-Mon-yy');
    --
    g_xml_ctr := g_xml_ctr +1;
    xml_table( g_xml_ctr).tag_name := 'acc_date_to';
    xml_table( g_xml_ctr).tag_value := to_char(acc_period_dates(i).accrual_end_date, 'dd-Mon-yy');
    --
    g_xml_ctr := g_xml_ctr +1;
    xml_table( g_xml_ctr).tag_name := 'acc_wkg_hrs';
    xml_table( g_xml_ctr).tag_value := acc_period_dates(i).wkg_hrs;
    --
    g_xml_ctr := g_xml_ctr +1;
    xml_table( g_xml_ctr).tag_name := 'acc_hours';
    xml_table( g_xml_ctr).tag_value := round(l_period_entitlement, 2);
    --
    -- Set the end label
    g_xml_ctr := g_xml_ctr +1;
    xml_table( g_xml_ctr).tag_name := 'L_DIF_ACC';
    xml_table( g_xml_ctr).tag_value := '0';
    --
    -- Calculate the total accrual for using later
    l_total_dif_accrual:= l_total_dif_accrual +l_period_entitlement;
    --
    hr_utility.set_location('Period accrual is: '||to_char(l_period_entitlement), 40);
    hr_utility.set_location('Total dif accrual is: '||to_char(l_total_dif_accrual), 40);
    --
 END LOOP;
 -- write the total DIF accural field
 l_total_dif_accrual := l_total_dif_accrual + l_total_carryover;
 --
 g_xml_ctr := g_xml_ctr +1;
 xml_table( g_xml_ctr).tag_name := 'total_dif_acc';
 xml_table( g_xml_ctr).tag_value := round(l_total_dif_accrual,2);
 --
 hr_utility.set_location('Table count after DIF accruals is: '||to_char(xml_table.count), 40);
 hr_utility.set_location('g_xml_ctr after DIF accruals is: '||to_char(g_xml_ctr), 40);
 --
----------------------
-- DIF taken section
----------------------
l_total_absence_duration := 0;
FOR dif_abs_rec IN csr_dif_abs_details LOOP
    -- Add the total duration
    -- to be used for balance calculation later on
    l_total_absence_duration := l_total_absence_duration + dif_abs_rec.abs_duration;
    -- Set the start label
    g_xml_ctr := g_xml_ctr +1;
    xml_table( g_xml_ctr).tag_name := 'L_DIF_TAKEN';
    xml_table( g_xml_ctr).tag_value := '1';
    --
    -- Write form fields
    g_xml_ctr := g_xml_ctr +1;
    xml_table( g_xml_ctr).tag_name := 'abs_start_date';
    xml_table( g_xml_ctr).tag_value := dif_abs_rec.abs_start;
    --
    g_xml_ctr := g_xml_ctr +1;
    xml_table( g_xml_ctr).tag_name := 'abs_end_date';
    xml_table( g_xml_ctr).tag_value := dif_abs_rec.abs_end;
    --
    g_xml_ctr := g_xml_ctr +1;
    xml_table( g_xml_ctr).tag_name := 'abs_duration';
    xml_table( g_xml_ctr).tag_value := dif_abs_rec.abs_duration;
    --
    g_xml_ctr := g_xml_ctr +1;
    xml_table( g_xml_ctr).tag_name := 'abs_trg_catg';
    xml_table( g_xml_ctr).tag_value := dif_abs_rec.abs_trg_catg;
    --
    g_xml_ctr := g_xml_ctr +1;
    xml_table( g_xml_ctr).tag_name := 'abs_course_name';
    xml_table( g_xml_ctr).tag_value := dif_abs_rec.abs_course;
    --
    g_xml_ctr := g_xml_ctr +1;
    xml_table( g_xml_ctr).tag_name := 'abs_trg_prov';
    xml_table( g_xml_ctr).tag_value := dif_abs_rec.abs_trg_prov;
    --
    g_xml_ctr := g_xml_ctr +1;
    xml_table( g_xml_ctr).tag_name := 'abs_trg_type';
    xml_table( g_xml_ctr).tag_value := dif_abs_rec.abs_trg_type;
    --
    g_xml_ctr := g_xml_ctr +1;
    xml_table( g_xml_ctr).tag_name := 'abs_trg_ref';
    xml_table( g_xml_ctr).tag_value := dif_abs_rec.abs_reference;
    --
    g_xml_ctr := g_xml_ctr +1;
    xml_table( g_xml_ctr).tag_name := 'abs_leg_catg';
    xml_table( g_xml_ctr).tag_value := dif_abs_rec.abs_leg_catg;
    --
    g_xml_ctr := g_xml_ctr +1;
    xml_table( g_xml_ctr).tag_name := 'abs_out_wkg_hrs';
    xml_table( g_xml_ctr).tag_value := dif_abs_rec.abs_out_wkg_hrs;
    --
    g_xml_ctr := g_xml_ctr +1;
    xml_table( g_xml_ctr).tag_name := 'abs_proj_yn';
    xml_table( g_xml_ctr).tag_value := dif_abs_rec.abs_proj_yn;
    --
    -- Set the end label
    g_xml_ctr := g_xml_ctr +1;
    xml_table( g_xml_ctr).tag_name := 'L_DIF_TAKEN';
    xml_table( g_xml_ctr).tag_value := '0';
    --
END LOOP;
-- Write the total absence form field
g_xml_ctr := g_xml_ctr +1;
xml_table( g_xml_ctr).tag_name := 'total_dif_abs';
xml_table( g_xml_ctr).tag_value := l_total_absence_duration;
--
hr_utility.set_location('Table count after DIF taken is: '||to_char(xml_table.count), 40);
hr_utility.set_location('g_xml_ctr after DIF taken is: '||to_char(g_xml_ctr), 40);
-----------------------------
-- DIF adjustment section
-----------------------------
-- Initialize the total adjustments
l_total_adjustments := 0;
-- Get the adjustment element entries
FOR dif_adj_rec IN csr_dif_adj_entries(l_assignment_id, p_date_from, p_date_to) LOOP
    --
    -- Add the total values
    -- for the total adjustments field
    l_total_adjustments := l_total_adjustments + dif_adj_rec.adj_hours;
    -- Set the start label
    g_xml_ctr := g_xml_ctr +1;
    xml_table( g_xml_ctr).tag_name := 'L_DIF_ADJ';
    xml_table( g_xml_ctr).tag_value := '1';
    --
    -- Get the field name
    g_xml_ctr := g_xml_ctr +1;
    OPEN csr_get_repeat_lookup('ADJUST');
    FETCH csr_get_repeat_lookup into xml_table( g_xml_ctr).tag_name, xml_table( g_xml_ctr).tag_value;
    CLOSE csr_get_repeat_lookup;
    --
    -- Write the form fields
    g_xml_ctr := g_xml_ctr +1;
    xml_table( g_xml_ctr).tag_name := 'adj_element';
    xml_table( g_xml_ctr).tag_value := dif_adj_rec.adj_element;
    --
    g_xml_ctr := g_xml_ctr +1;
    xml_table( g_xml_ctr).tag_name := 'adj_start';
    xml_table( g_xml_ctr).tag_value := dif_adj_rec.adj_start;
    --
    g_xml_ctr := g_xml_ctr +1;
    xml_table( g_xml_ctr).tag_name := 'adj_end';
    xml_table( g_xml_ctr).tag_value := dif_adj_rec.adj_end;
    --
    g_xml_ctr := g_xml_ctr +1;
    xml_table( g_xml_ctr).tag_name := 'adj_hours';
    xml_table( g_xml_ctr).tag_value := dif_adj_rec.adj_hours;
    --
    g_xml_ctr := g_xml_ctr +1;
    xml_table( g_xml_ctr).tag_name := 'adj_add_or_subtract';
    xml_table( g_xml_ctr).tag_value := dif_adj_rec.add_or_subtract;
    --
    -- Set the end label
    g_xml_ctr := g_xml_ctr +1;
    xml_table( g_xml_ctr).tag_name := 'L_DIF_ADJ';
    xml_table( g_xml_ctr).tag_value := '0';
    --
END LOOP;
-- Write the total adjustments form field
g_xml_ctr := g_xml_ctr +1;
xml_table( g_xml_ctr).tag_name := 'total_dif_adj';
xml_table( g_xml_ctr).tag_value := l_total_adjustments;
--
hr_utility.set_location('Table count after DIF adjustments is: '||to_char(xml_table.count), 40);
hr_utility.set_location('g_xml_ctr after DIF adjustments is: '||to_char(g_xml_ctr), 40);
-------------------------------
-- DIF Balance section
------------------------------
-- get the balance value
l_dif_balance := l_total_dif_accrual - l_total_absence_duration - l_total_adjustments;
-- populate the form field
g_xml_ctr := g_xml_ctr +1;
xml_table( g_xml_ctr).tag_name := 'dif_bal_hrs';
xml_table( g_xml_ctr).tag_value := round(l_dif_balance, 2);
--
hr_utility.set_location('Table count after DIF balance is: '||to_char(xml_table.count), 40);
hr_utility.set_location('g_xml_ctr after DIF balance is: '||to_char(g_xml_ctr), 40);
hr_utility.set_location('Exiting dif_emp_acc_details' , 50);
--
END dif_emp_acc_details;
--
--------------------------------------------------
-- procedure for writing to clob
------------------------------------------------------
PROCEDURE write_to_clob(p_xfdf_clob out nocopy clob) IS

l_xfdf_string clob;
l_str1 varchar2(1000);
l_str2 varchar2(20);
l_str3 varchar2(20);
l_str4 varchar2(20);
l_str5 varchar2(20);
l_str6 varchar2(1000);
l_str7 varchar2(1000);
l_str8 varchar2(1000);
--
BEGIN
--
hr_utility.set_location('Entering write_to_clob', 60);
--
l_str1 := '<?xml version="1.0" encoding="UTF-8"?>
	       		 <FIELDS> ';

l_str2 := '<';
l_str3 := '>';
l_str4 := '</' ;
l_str5 := '</FIELDS> ';
l_str6 := '<?xml version="1.0" encoding="UTF-8"?>
          <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
	  </xfdf>';
dbms_lob.createtemporary(l_xfdf_string, FALSE, dbms_lob.call);
dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);
--
hr_utility.set_location('Table count: '||to_char(xml_table.count), 60);
--
IF xml_table.count > 0 THEN
	dbms_lob.writeappend( l_xfdf_string, length(l_str1), l_str1 );
	FOR ctr_table IN xml_table.FIRST .. xml_table.LAST LOOP
	    hr_utility.set_location('Counter table: '||to_char(ctr_table), 65);
	    l_str7 := xml_table(ctr_table).tag_name;
	    l_str8 := nvl(xml_table(ctr_table).tag_value, ' ');
	    IF l_str7 in('L_MAIN', 'L_CTR_HDR', 'L_DIF_ACC', 'L_DIF_TAKEN', 'L_DIF_ADJ')THEN
	        --
                hr_utility.set_location('Tag name is: '||l_str7, 65);
		hr_utility.set_location('Tag value is: '||l_str8, 65);
		--
		IF l_str8 = '1' THEN -- start of the label
		    dbms_lob.writeappend( l_xfdf_string, length(l_str2), l_str2 );--- <
		    dbms_lob.writeappend( l_xfdf_string, length(l_str7),l_str7);------ name
		    dbms_lob.writeappend( l_xfdf_string, length(l_str3), l_str3 );---->
		    --
		    hr_utility.set_location('xml string', 70);
		    --
		ELSE -- end of the label
		    dbms_lob.writeappend( l_xfdf_string, length(l_str4), l_str4 );---- </
		    dbms_lob.writeappend( l_xfdf_string, length(l_str7),l_str7);----- name
		    dbms_lob.writeappend( l_xfdf_string, length(l_str3), l_str3 );----- >
		    --
		    hr_utility.set_location('xml string', 80);
		    --
		END IF;
	    ELSE
	        --
		hr_utility.set_location('xml string: '||l_str7, 90);
		--
		dbms_lob.writeappend( l_xfdf_string, length(l_str2), l_str2 );--- <
		dbms_lob.writeappend( l_xfdf_string, length(l_str7),l_str7);------ name
		dbms_lob.writeappend( l_xfdf_string, length(l_str3), l_str3 );---->
		dbms_lob.writeappend( l_xfdf_string, length(l_str8), l_str8);-----value
		--
		hr_utility.set_location('Appended Value: '||l_str8, 95);
		--
		dbms_lob.writeappend( l_xfdf_string, length(l_str4), l_str4 );---- </
		dbms_lob.writeappend( l_xfdf_string, length(l_str7),l_str7);----- name
		dbms_lob.writeappend( l_xfdf_string, length(l_str3), l_str3 );----- >
	    END IF;
	END LOOP;
	--
        hr_utility.set_location('l_str5 is: '||l_str5, 100);
	--
	dbms_lob.writeappend( l_xfdf_string, length(l_str5), l_str5 );
	--
	hr_utility.set_location('xml string', 100);
	--
  ELSE
	dbms_lob.writeappend( l_xfdf_string, length(l_str6), l_str6 );
	--
	hr_utility.set_location('xml string', 110);
	--
  END IF;
  hr_utility.set_location(dbms_lob.getlength(l_xfdf_string), 120);
  --
  dbms_lob.createtemporary(p_xfdf_clob,TRUE);
  p_xfdf_clob := l_xfdf_string;
  --
  hr_utility.set_location('After assigning to out LOB'||dbms_lob.getlength(p_xfdf_clob), 130);
  --
  hr_utility.set_location('After writing to clob', 140);
  --
EXCEPTION
  WHEN OTHERS THEN
      hr_utility.set_location('Exception: '||to_char(SQLCODE)||' '||SUBSTR(SQLERRM, 1, 50), 60);
       return;
--
hr_utility.set_location('Exiting write_to_clob', 60);
--
END write_to_clob;
--
END;

/
