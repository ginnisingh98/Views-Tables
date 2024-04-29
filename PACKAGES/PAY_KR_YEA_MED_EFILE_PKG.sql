--------------------------------------------------------
--  DDL for Package PAY_KR_YEA_MED_EFILE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_YEA_MED_EFILE_PKG" AUTHID CURRENT_USER as
/* $Header: pykrymef.pkh 120.6.12010000.3 2010/01/27 14:27:46 vaisriva ship $ */
--
level_cnt               number;
g_business_place_id     number;
g_target_year           number;
g_b_records             number;
g_normal_yea            varchar2(1) := 'X';
g_interim_yea           varchar2(1) := 'X';
g_re_yea                varchar2(1) := 'X';
g_payroll_action_id     number;
g_assignment_set_id     number;
g_medical_exp_archive   number;
--
g_rep_period_code	varchar2(1) := '2'; -- Bug 9251566
--
------------------------------------------------------------------------
cursor csr_a is
  select
       'TAX_OFFICE_CODE=P',            ihoi.org_information9,
       'PRIMARY_BP_NUMBER=P',          bhoi_primary.org_information2,
       'BR_NUMBER=P',                  bhoi.org_information2,
       'NATIONAL_IDENTIFIER=P',        pp.national_identifier,
       'FULL_NAME=P',                  pp.last_name || pp.first_name,   -- Bug 7800013
       'CORP_NAME=P',                  choi.org_information1,
       'ASSIGN_ID=P', 	               paa.assignment_id,
       'VALIDATION=P',                 pay_kr_yea_med_efile_conc_pkg.validate_det_medical_rec(
                                            paa.assignment_id,
                                            to_date(to_char(g_target_year),'yyyy') ),
       'EMP_NATIONALITY=P',           decode(pay_kr_ff_functions_pkg.ni_nationality(pp.national_identifier),'F','9'
				       ,'1')
  from
        per_people_f                    pp,
        per_periods_of_service          pds,
        per_assignments_f               pa,
        pay_assignment_actions          paa,
        pay_payroll_actions             ppa,
        hr_organization_units           hou1,
        hr_organization_information     bhoi_primary,
        hr_organization_information     bhoi,
        hr_organization_information     choi,
        hr_organization_information     ihoi,
        ff_archive_items                ar
  where
        bhoi_primary.organization_id = pay_magtape_generic.get_parameter_value('PRIMARY_BP_ID')
        and  bhoi_primary.org_information_context = 'KR_BUSINESS_PLACE_REGISTRATION'
        and  choi.organization_id         = to_number(bhoi_primary.org_information10)
        and  choi.org_information_context = 'KR_CORPORATE_INFORMATION'
        and  ihoi.organization_id         = bhoi_primary.organization_id
        and  ihoi.org_information_context = 'KR_INCOME_TAX_OFFICE'
        and  hou1.business_group_id       = pay_magtape_generic.get_parameter_value('BG_ID')
        and  bhoi.organization_id         = hou1.organization_id
	--Bug 5069923
        and  (	     (pay_magtape_generic.get_parameter_value('REPORT_FOR')='A')
   		  or (	     (bhoi.organization_id  in ( select posev.ORGANIZATION_ID_child
							 from   PER_ORG_STRUCTURE_ELEMENTS posev
							 where  posev.org_structure_version_id=(pay_magtape_generic.get_parameter_value('ORG_STRUC_VERSION_ID'))
								and exists ( select null
									     from   hr_organization_information
									     where organization_id = posev.ORGANIZATION_ID_child
 										   and org_information_context = 'CLASS'
										   and org_information1 = 'KR_BUSINESS_PLACE'
									   )
								start with posev.ORGANIZATION_ID_PARENT = (decode(pay_magtape_generic.get_parameter_value('REPORT_FOR'),'S',null,'SUB',pay_magtape_generic.get_parameter_value('PRIMARY_BP_ID')))
								connect by prior ORGANIZATION_ID_child = ORGANIZATION_ID_PARENT
							)
			     )
		          or (bhoi.organization_id = pay_magtape_generic.get_parameter_value('PRIMARY_BP_ID')
			     )
		     )
	     )
        and  bhoi.org_information_context = 'KR_BUSINESS_PLACE_REGISTRATION'
        and  choi.organization_id         =  to_number(bhoi.org_information10)
        and  ppa.business_group_id        =  pay_magtape_generic.get_parameter_value('BG_ID')
        and  ppa.report_type              = 'YEA'
        and  ppa.report_qualifier         = 'KR'
        and  ( (ppa.report_category in (g_normal_yea, g_interim_yea, g_re_yea)) or
               (ppa.payroll_action_id = g_payroll_action_id) )
        and  to_number(to_char(ppa.effective_date, 'YYYY')) = g_target_year
        --
        and  ppa.action_type              in ('B','X')
        and  paa.payroll_action_id        =  ppa.payroll_action_id
        and  ((to_number(pay_magtape_generic.get_parameter_value('ASSIGNMENT_SET_ID')) is null) or
              (hr_assignment_set.assignment_in_set(to_number(pay_magtape_generic.get_parameter_value('ASSIGNMENT_SET_ID')),
                                           paa.assignment_id) = 'Y'))
        and  (('X' <> 'R') or
              (pay_kr_yea_magtape_fun_pkg.latest_yea_action(paa.assignment_action_id, g_payroll_action_id, g_target_year) = 'Y')) -- Bug 4726974
        and  paa.tax_unit_id              =  bhoi.organization_id
        and  paa.action_status            =  'C'
        and  pa.assignment_id             =  paa.assignment_id
        and  ppa.effective_date between pa.effective_start_date and pa.effective_end_date
        and  pds.period_of_service_id     =  pa.period_of_service_id
        and  pp.person_id                 =  pds.person_id
        and  ppa.effective_date between pp.effective_start_date and pp.effective_end_date
        and  ar.context1(+)               =   paa.assignment_action_id
        and  ar.user_entity_id(+)         =   g_medical_exp_archive
        and  ar.value                     >=  2000000
   order by bhoi.org_information2;
------------------------------------------------------------------------

cursor csr_b is
select
        'MED_REG_NO=P',           pay_kr_yea_med_efile_conc_pkg.get_medical_reg_no(
                                                       assignment_id,
                                                       to_date(to_char(g_target_year),'yyyy'),
                                                       med_reg_no),
	'MED_NAME=P',             med_name ,
	 -- Bug 7800013
	'TOTAL_MED_NO_OF_PAYMENTS=P', total_med_no_of_payments ,
	'TOTAL_EXPENSE_AMOUNT=P',   total_expense_amount ,
	'RELATIONSHIP=P',         relarionship ,
	'SOURCE_CODE=P' ,         source_code,
        'RESIDENT_REG_NO=P',      pay_kr_yea_med_efile_conc_pkg.get_resident_reg_no(
                                                       assignment_id,
                                                       to_date(to_char(g_target_year),'yyyy'),
                                                       resident_reg_no),
	'DISABLED_OR_AGED=P',     disabled_or_aged,
        'DEPNT_NATIONALITY=P',    decode(pay_kr_ff_functions_pkg.ni_nationality(resident_reg_no),'F','9','1'),
	'REP_PERIOD_CODE=P',	  g_rep_period_code 		-- Bug 9251566
from
(
   select
        pae.assignment_id                 assignment_id ,
	aei_information5                  med_reg_no ,
	nvl(aei_information6,' ')         med_name,
	-- Bug 7800013
	sum(decode(aei_information12,
	    null,decode(aei_information11,null,0,0,
	    0,1),aei_information12)) +
	sum(decode(aei_information10,
	    null,decode(aei_information3,null,0,0,
	    0,1),aei_information10))      total_med_no_of_payments,
	    sum(nvl(aei_information11,0)) +
	sum(nvl(aei_information3,0))      total_expense_amount,
	aei_information7                  relarionship,
	-- Bug 7800013
	aei_information13                 source_code,
	aei_information8                  resident_reg_no,
	aei_information9                  disabled_or_aged
    from PER_ASSIGNMENT_EXTRA_INFO       pae
    where
         pae.assignment_id =pay_magtape_generic.get_parameter_value('ASSIGN_ID')
         and pae.information_type = 'KR_YEA_DETAIL_MEDICAL_EXP_INFO'
         and to_char(fnd_date.canonical_to_date(pae.aei_information1),'yyyy') = g_target_year
    group by pae.assignment_id, aei_information8,aei_information5,aei_information6,aei_information13,
        aei_information7,aei_information8 ,aei_information9
 );


------------------------------------------------------------------------
end pay_kr_yea_med_efile_pkg;

/
