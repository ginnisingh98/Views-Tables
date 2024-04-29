--------------------------------------------------------
--  DDL for Package Body PAY_FR_ATTESTATION_ASSEDIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FR_ATTESTATION_ASSEDIC" As
/* $Header: pyfraasd.pkb 120.0 2005/05/29 04:57:09 appldev noship $ */
--
--G_stat_cadre stores the pension category of given assignment.
G_STAT_CADRE    VARCHAR2(4) Default Null;

Procedure set_defined_balance_ids(p_actual_hours_worked_id     Out Nocopy Number ,
                                  p_days_unpaid_id             Out Nocopy Number ,
                                  p_days_partially_paid_id     Out Nocopy Number,
                                  p_subject_to_unemployment_id Out Nocopy Number,
                                  p_non_monthly_earnings_id    Out Nocopy Number,
                                  p_ee_unemployment_ta_id      Out Nocopy Number,
                                  p_ee_unemployment_tb_id      Out Nocopy Number
                                 )Is

--Changed the cursor to fetch both Transactional and Contractual Indemnity --Bug#2953140.
-- Modifeid name of 'FR_ACTUAL_HRS_WORKED' to 'FR_ACTUAL_HRS_WORKED_ASSEDIC'
-- as part of time analysis changes
Cursor csr_defined_balance_id Is
Select
max(decode(balance_name,'FR_ACTUAL_HRS_WORKED_ASSEDIC',defined_balance_id)),
max(decode(balance_name,'FR_DAYS_UNPAID',defined_balance_id)),
max(decode(balance_name,'FR_DAYS_PARTIALLY_PAID',defined_balance_id)),
max(decode(balance_name,'FR_SUBJECT_TO_UNEMPLOYMENT',defined_balance_id)),
max(decode(balance_name,'FR_NON_MONTHLY_EARNINGS',defined_balance_id)),
max(decode(balance_name,'FR_EE_UNEMPLOYMENT_TA',defined_balance_id)),
max(decode(balance_name,'FR_EE_UNEMPLOYMENT_TB',defined_balance_id)),
max(decode(balance_name,'FR_NPIL_PAYMENT',defined_balance_id)),
max(decode(balance_name,'FR_LEGAL_TERMINATION_INDEMNITY',defined_balance_id)),
max(decode(balance_name,'FR_CONVENTIONAL_INDEMNITY',defined_balance_id)),
max(decode(balance_name,'FR_TRANSACTIONAL_INDEMNITY',defined_balance_id)),
max(decode(balance_name,'FR_CONTRACTUAL_INDEMNITY',defined_balance_id))
From
pay_balance_types pbt ,
pay_defined_balances pdb,
pay_balance_dimensions pbd
Where pbt.balance_type_id = pdb.balance_type_id
  and pdb.balance_dimension_id = pbd.balance_dimension_id
  and pbt.balance_name in ('FR_ACTUAL_HRS_WORKED_ASSEDIC',
                           'FR_DAYS_UNPAID',
                           'FR_DAYS_PARTIALLY_PAID',
                           'FR_SUBJECT_TO_UNEMPLOYMENT',
                           'FR_NON_MONTHLY_EARNINGS',
                           'FR_EE_UNEMPLOYMENT_TA' ,
                           'FR_EE_UNEMPLOYMENT_TB',
                           'FR_NPIL_PAYMENT',
                           'FR_LEGAL_TERMINATION_INDEMNITY',
                           'FR_CONVENTIONAL_INDEMNITY',
                           'FR_TRANSACTIONAL_INDEMNITY',
                           'FR_CONTRACTUAL_INDEMNITY'
                           )
  and pbd.database_item_suffix = decode(pbt.balance_name,'FR_NPIL_PAYMENT','_ASG_ITD'
                                                        ,'FR_LEGAL_TERMINATION_INDEMNITY','_ASG_ITD'
                                                        ,'FR_CONVENTIONAL_INDEMNITY','_ASG_ITD'
                                                        ,'FR_CONTRACTUAL_INDEMNITY', '_ASG_ITD'
                                                        ,'FR_TRANSACTIONAL_INDEMNITY','_ASG_ITD','_ASG_PTD')
  and pdb.legislation_code = 'FR'
  and pbd.legislation_code = 'FR'; --Reduce cost by 50%
Begin
	Open csr_defined_balance_id ;
        --Fetching values for transactional and contractual indemnity ids also --bug#2953140
	Fetch csr_defined_balance_id Into p_actual_hours_worked_id ,
	                                  p_days_unpaid_id,
	                                  p_days_partially_paid_id ,
	                                  p_subject_to_unemployment_id,
	                                  p_non_monthly_earnings_id ,
	                                  p_ee_unemployment_ta_id,
	                                  p_ee_unemployment_tb_id,
	                                  g_npil_payment_id ,
	                                  g_legal_term_indemnity_id,
	                                  g_conventional_indemnity_id,
                                          g_transactional_indemnity_id,
                                          g_contractual_indemnity_id;
	Close csr_defined_balance_id;

End set_defined_balance_ids;
--
Function get_last_fulltime_day_worked(p_person_id In Number ,
                                      p_last_day_worked In Date) Return Date Is
Cursor csr_last_fulltime_day_worked Is
select nvl(min(paa.date_start)-1,p_last_day_worked)
from
per_absence_attendances paa
where exists (select paat.absence_attendance_type_id
                from per_absence_attendance_types paat
               Where paat.absence_category in ('S','UL')
                 and paa.absence_attendance_type_id = paat.absence_attendance_type_id
             ) --Not possible to Join as 'connect by ' with 'join' fails in 8i.
  and level=rownum
start with p_last_day_worked between paa.date_start and paa.date_end and paa.person_id = p_person_id
connect by prior paa.date_start = paa.date_end+1 and prior person_id = person_id;


l_last_fulltime_day_worked Date;
Begin
Open csr_last_fulltime_day_worked ;
Fetch csr_last_fulltime_day_worked Into l_last_fulltime_day_worked;
Close csr_last_fulltime_day_worked;

return l_last_fulltime_day_worked;

End get_last_fulltime_day_worked;

--
Function get_estab_head_count(p_establishment_id Number ,
                              p_actual_termination_date Date) Return Number Is

Cursor csr_head_count Is
Select action_information24
From pay_action_information paa,
     pay_payroll_actions ppa
Where paa.action_context_id = ppa.payroll_action_id
  and action_information_category ='FR_DUCS_PAGE_INFO'
  and action_information1 = p_establishment_id
  and action_information2 = 'ASSEDIC'
  and ppa.report_category = 'DUCS_ARCHIVE'
  and ppa.report_qualifier = 'FR'
  and ppa.effective_date  = to_date(('31-12-'||to_number(to_char(p_actual_termination_date,'YYYY')-1)),'DD-MM-YYYY') ;

l_head_count Number;

Begin
Open csr_head_count;
Fetch csr_head_count Into l_head_count;
Close csr_head_count;

Return l_head_count ;

End;

--
Function get_pension_provider_info(p_assignment_id Number ,
                                   p_establishment_id Number ,
                                   p_termination_date Date,
                                   p_type Varchar2) Return Varchar2 Is
Cursor csr_pension_provider_id(c_assignment_id Number ,c_establishment_id Number, c_type Varchar2) Is
Select
'A' flag ,decode(c_type,'ARRCO',entry_information2 ,'AGIRC' ,entry_information4) "Pension_Provider_Id"
From
pay_element_entries_f peef ,
pay_element_links_f   pel ,
pay_element_types_f   pet
Where peef.assignment_id = c_assignment_id
  and peef.element_link_id = pel.element_link_id
  and pel.element_type_id = pet.element_type_id
  and p_termination_date between peef.effective_start_date and peef.effective_end_date
  and p_termination_date between pet.effective_start_date and pet.effective_end_date
  and p_termination_date between pel.effective_start_date and pel.effective_end_date
  and pet.element_name = 'FR_PENSION'
  and decode(c_type,'ARRCO',entry_information2 ,'AGIRC' ,entry_information4) Is Not Null
union
Select
decode(hoi.org_information3,'N','Z',hoi.org_information3) flag ,hoi.org_information1
From
hr_all_organization_units haou,
hr_organization_information hoi
Where haou.organization_id  = c_establishment_id
  and haou.organization_id = hoi.organization_id
  and hoi.org_information_context = 'FR_ESTAB_PE_PRVS'
  and exists
      (Select 1
       From
       hr_organization_information hoi1
       Where hoi1.organization_id         = hoi.org_information1
         and hoi1.org_information_context = 'FR_PE_PRV_INFO'
         and hoi1.org_information2        = c_type
       ) ;


Cursor csr_name_location(c_organization_id Number ) Is
Select
haou.name                                                     --Establishment_Name
||decode(hla.address_line_1,Null,'',','||hla.address_line_1)  --Number_Road
||decode(hla.address_line_2,Null,'',','||hla.address_line_2)  --Complement
||decode(hla.region_3,Null,'',','||hla.region_3)              --Small Town
||decode(hla.town_or_city,Null,'',','||hla.town_or_city)   --City
From
hr_all_organization_units haou ,
hr_locations_all hla
where haou.organization_id = c_organization_id
  and haou.location_id     = hla.location_id (+);

l_pension_provider_id Number;
l_flag Varchar2(2);
l_name_location       Varchar2(2000);
Begin
--Get the pension provider from 'FR_PENSION' Element Entry.
--G_STAT_CADRE is set in pension_category Function.
IF ((G_STAT_CADRE = 'Yes') OR (G_STAT_CADRE  IS NULL))  THEN
--   hr_utility.set_location('Inside IF: Y', 30);
   Open csr_pension_provider_id(p_assignment_id,p_establishment_id,p_type);
   Fetch csr_pension_provider_id Into l_flag,l_pension_provider_id;
   Close csr_pension_provider_id;
ELSIF ((G_STAT_CADRE = 'No') AND (p_type='ARRCO')) THEN
  -- hr_utility.set_location('Inside IF: N', 40);
   Open csr_pension_provider_id(p_assignment_id,p_establishment_id,p_type);
   Fetch csr_pension_provider_id Into l_flag,l_pension_provider_id;
   Close csr_pension_provider_id;
  -- hr_utility.set_location('Inside Leaving IF: N', 40);
END IF;


--Get the Location
If l_pension_provider_id Is Not Null Then
  Open csr_name_location(l_pension_provider_id);
  Fetch csr_name_location Into l_name_location;
  Close csr_name_location;
End If;
--
Return l_name_location;

End get_pension_provider_info;

--
Function pension_category(p_business_group_id Number ,
                          p_assignment_id Number,
                          p_actual_termination_date Date ,
                          p_period_of_service_id Number) Return Varchar2 Is
Cursor stat_cadre Is
   Select  hr_reports.get_lookup_meaning('YES_NO',(hruserdt.get_table_value(p_business_group_id ,'FR_APEC_AGIRC','AGIRC',entry_information1,p_actual_termination_date)))
   From
      pay_element_entries_f peef ,
      pay_element_links_f   pel ,
      pay_element_types_f   pet
   Where peef.assignment_id   = p_assignment_id
    and peef.element_link_id = pel.element_link_id
    and pel.element_type_id = pet.element_type_id
    and pet.element_name    = 'FR_PENSION'
    and p_actual_termination_date between peef.effective_start_date and peef.effective_end_date
    and p_actual_termination_date between pet.effective_start_date and pet.effective_end_date
    and p_actual_termination_date between pel.effective_start_date and pel.effective_end_date ;

  l_temp Varchar2(4);
Begin
g_service_id(g_service_id.count+1) := p_period_of_service_id;

--Global variable to store return value of stat_cadre cursor.

G_STAT_CADRE := NULL;
Open stat_cadre ;
Fetch stat_cadre Into l_temp;
Close stat_cadre;
G_STAT_CADRE := l_temp;
Return l_temp;

End pension_category;

--
Procedure insert_date_run(p_effective_date varchar2 ) Is
l_ovn Number;
Begin
  For i in g_service_id.First..g_service_id.Last Loop
     --
    Select object_version_number
     Into l_ovn
     From per_periods_of_service pps
     where period_of_service_id = g_service_id(i) ;
     --
     --hr_utility.trace_on(Null,'ASSEDIC');
	  hr_utility.set_location('p_effective_date='||p_effective_date,10);
     hr_utility.set_location('period_of_service_id='||g_service_id(i),20);
     hr_utility.set_location('ovn='||l_ovn,30);

     hr_periods_of_service_api.update_pds_details(P_EFFECTIVE_DATE         =>fnd_date.canonical_to_date(p_effective_date)
                                                 ,P_PERIOD_OF_SERVICE_ID   =>g_service_id(i)
                                                 ,P_OBJECT_VERSION_NUMBER  =>l_ovn
                                                 ,P_PDS_INFORMATION14      =>p_effective_date
                                                  );
     --
   End Loop;

End;

--
--Changed the signature to return both Transactional and Contractual Indemnities. --Bug#2953140

Procedure get_termination_indemnities(p_assignment_id           In  Number ,
                                      p_last_day_worked         In  Date ,
                                      p_actual_termination_date In  Date ,
                                      p_npil                    Out Nocopy Number ,
                                      p_holiday_pay_amount      Out Nocopy Number,
                                      p_hoilday_pay_rate        Out Nocopy Number ,
                                      p_ft_contract_indemnity   Out Nocopy Number,
                                      p_legal_indemnity         Out Nocopy Number,
                                      p_conventional_indemnity  Out Nocopy Number,
                                      p_transactional_indemnity Out Nocopy Number,
                                      p_contractual_indemnity   Out Nocopy Number) Is

Cursor csr_get_hpil Is
Select /*+ORDERED*/
  pap.information6  accounting_method,
  sum(decode(piv.name,'Pay Value',prrv.result_value)) ,
  sum(decode(piv.name,'Rate',prrv.result_value))
From
  pay_assignment_actions paa,
  pay_payroll_actions ppa,
  pay_accrual_plans pap ,
  pay_input_values_f piv_base,
  pay_element_types_f pet ,
  pay_element_classifications pec ,
  pay_run_results prr,
  pay_input_values_f piv,
  pay_run_result_values prrv
Where paa.assignment_id        = p_assignment_id
  and ppa.payroll_action_id    = paa.payroll_action_id
  and ppa.date_earned         >= p_last_day_worked
  and ppa.action_type         in ('Q','R','B','I')
  and ppa.business_group_id    = pap.business_group_id
  and pap.accrual_category  like 'FR%HOLIDAY'
  and pap.information_category like 'FR_FR%HOLIDAY'
  and pap.information28        = piv_base.input_value_id
  and piv_base.element_type_id = pet.element_type_id
  and pec.classification_id    = pet.classification_id
  and pec.classification_name  = 'Earnings'
  and pec.business_group_id   is null
  and pec.legislation_code     = 'FR'
  and prr.assignment_action_id = paa.assignment_action_id
  and prr.element_type_id      = pet.element_type_id
  and prr.status              in ('P','PA')
  and pet.element_type_id      = piv.element_type_id
  and piv.name                in ('Pay Value','Rate')
  and prrv.run_result_id       = prr.run_result_id
  and prrv.input_value_id      = piv.input_value_id
  and p_actual_termination_date  between pet.effective_start_date
                                     and pet.effective_end_date
  and p_actual_termination_date  between piv.effective_start_date
                                     and piv.effective_end_date
  and p_actual_termination_date  between piv_base.effective_start_date
                                     and piv_base.effective_end_date
group by paa.assignment_id ,pap.information6;

Cursor csr_get_ft_indemnity Is
Select
sum(decode(pet.element_name,'FR_FIXED_TERM_CONTRACT_INDEMNITY_PAY',prrv.result_value))
From
pay_element_types_f pet ,
pay_input_values_f piv ,
pay_payroll_actions ppa,
pay_assignment_actions paa,
pay_run_results prr,
pay_run_result_values prrv
Where pet.element_type_id   = piv.element_type_id
  and ppa.payroll_action_id = paa.payroll_action_id
  and prr.assignment_action_id = paa.assignment_action_id
  and prr.element_type_id = pet.element_type_id
  and prr.status          in ('P','PA')
  and prrv.run_result_id = prr.run_result_id
  and prrv.input_value_id = piv.input_value_id
  and ppa.action_type  in ('Q','R','B','I')
  and pet.element_name ='FR_FIXED_TERM_CONTRACT_INDEMNITY_PAY'
  and piv.name         = 'Pay Value'
  and paa.assignment_id = p_assignment_id
  and ppa.date_earned >= p_last_day_worked
  and p_actual_termination_date between pet.effective_start_date and pet.effective_end_date
  and p_actual_termination_date between piv.effective_start_date and piv.effective_end_date
group by paa.assignment_id;

--Changed the cursor to fetch both Transactional and contractual balances --Bug#2953140.
Cursor csr_get_indemnities Is
Select
pay_balance_pkg.get_value(g_npil_payment_id,max(paa.assignment_action_id)) npil,
pay_balance_pkg.get_value(g_legal_term_indemnity_id,max(paa.assignment_action_id)) legal,
pay_balance_pkg.get_value(g_conventional_indemnity_id,max(paa.assignment_action_id)) conventional,
pay_balance_pkg.get_value(g_contractual_indemnity_id,max(paa.assignment_action_id)) contractual,
pay_balance_pkg.get_value(g_transactional_indemnity_id,max(paa.assignment_action_id)) transactional
From
pay_payroll_actions ppa ,
pay_assignment_actions paa
Where ppa.payroll_action_id = paa.payroll_action_id
  and paa.assignment_id     = p_assignment_id
  and ppa.action_type in ('R' ,'Q')
  and paa.action_status      = 'C'
  and paa.source_action_id Is Null
  and ppa.date_earned       >= p_last_day_worked
group by paa.assignment_id  ;
l_accounting_method Varchar2(30);
Begin

Open csr_get_ft_indemnity;
Fetch csr_get_ft_indemnity Into p_ft_contract_indemnity;
Close csr_get_ft_indemnity;
--
Open csr_get_indemnities;
Fetch csr_get_indemnities Into p_npil,
                               p_legal_indemnity ,
                               p_conventional_indemnity,
                               p_contractual_indemnity,
                               p_transactional_indemnity;
Close csr_get_indemnities;
--
Open csr_get_hpil ;
Fetch csr_get_hpil Into l_accounting_method,p_holiday_pay_amount,p_hoilday_pay_rate;
 If l_accounting_method ='FR_WORK_DAYS' Then  --Bug:2883952
   p_hoilday_pay_rate := ceil(p_hoilday_pay_rate*6/5);
 End If;
Close csr_get_hpil ;
--

End get_termination_indemnities;


End pay_fr_attestation_assedic;

/
