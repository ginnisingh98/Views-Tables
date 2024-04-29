--------------------------------------------------------
--  DDL for Package PAY_KR_YEA_DON_EFILE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_YEA_DON_EFILE_PKG" AUTHID CURRENT_USER as
/* $Header: pykrydef.pkh 120.2.12010000.8 2010/03/10 07:08:52 vaisriva ship $ */
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
g_donation_exem_archive number;
--
g_rep_period_code	varchar2(1) := '2'; -- Bug 9251570
--
------------------------------------------------------------------------
cursor csr_header is
	select
		'TAX_OFFICE_CODE=P',		ihoi.org_information9,
		'PRIMARY_BP_NUMBER=P',		bhoi_primary.org_information2,
		'BR_NUMBER=P',			bhoi.org_information2,
		'NATIONAL_IDENTIFIER=P',	pp.national_identifier,
		'FULL_NAME=P',			pp.last_name || pp.first_name,   -- Bug 8281755
		'CORP_NAME=P',			choi.org_information1,
		'ASSIGN_ID=P',			paa.assignment_id,
                'NATIONALITY=P',                decode(pay_kr_ff_functions_pkg.ni_nationality(pp.national_identifier),
                                                'K', '1',
                                                '9'
                                                ),
		'ASSIGNMENT_ACTION_ID=C',       paa.assignment_action_id   /* Bug 6764369 */
	from
		per_people_f			pp,
		per_assignments_f		pa,
		pay_assignment_actions		paa,
		pay_payroll_actions		ppa,
		hr_organization_units		hou1,
		hr_organization_information	bhoi_primary,
		hr_organization_information	bhoi,
		hr_organization_information	choi,
		hr_organization_information	ihoi,
		ff_archive_items		ar
	where
		bhoi_primary.organization_id 		  = pay_magtape_generic.get_parameter_value('PRIMARY_BP_ID')
		and  bhoi_primary.org_information_context = 'KR_BUSINESS_PLACE_REGISTRATION'
		and  choi.organization_id         	  = to_number(bhoi_primary.org_information10)
		and  choi.org_information_context 	  = 'KR_CORPORATE_INFORMATION'
		and  ihoi.organization_id         	  = bhoi_primary.organization_id
		and  ihoi.org_information_context 	  = 'KR_INCOME_TAX_OFFICE'
		and  hou1.business_group_id       	  = pay_magtape_generic.get_parameter_value('BG_ID')
		and  bhoi.organization_id         	  = hou1.organization_id
		--Bug 5069923
        	and  (     (pay_magtape_generic.get_parameter_value('REPORT_FOR')='A')
			or (     (bhoi.organization_id in (select posev.ORGANIZATION_ID_child
							   from   PER_ORG_STRUCTURE_ELEMENTS posev
							   where  posev.org_structure_version_id=(pay_magtape_generic.get_parameter_value('ORG_STRUC_VERSION_ID'))
								  and exists ( select null
							   		       from   hr_organization_information
									       where  organization_id = posev.ORGANIZATION_ID_child
										      and org_information_context = 'CLASS'
										      and org_information1 = 'KR_BUSINESS_PLACE'
									     )
								  start with posev.ORGANIZATION_ID_PARENT = (decode(pay_magtape_generic.get_parameter_value('REPORT_FOR'),'S',null,'SUB',pay_magtape_generic.get_parameter_value('PRIMARY_BP_ID')))
								  connect by prior ORGANIZATION_ID_child = ORGANIZATION_ID_PARENT
							   )
				  )
        		       or (bhoi.organization_id          = pay_magtape_generic.get_parameter_value('PRIMARY_BP_ID')
				  )
			    )
		     )
		and  bhoi.org_information_context 	  = 'KR_BUSINESS_PLACE_REGISTRATION'
		and  choi.organization_id         	  =  to_number(bhoi.org_information10)
		and  ppa.business_group_id        	  =  pay_magtape_generic.get_parameter_value('BG_ID')
		and  ppa.report_type              	  = 'YEA'
		and  ppa.report_qualifier         	  = 'KR'
		and  (
			(ppa.report_category 		  in (g_normal_yea, g_interim_yea, g_re_yea))
			or (ppa.payroll_action_id 	  = g_payroll_action_id)
		)
		and  to_number(to_char(ppa.effective_date, 'YYYY'))
						   	  = g_target_year
		--
		and  ppa.action_type              	  = 'X'
		and  paa.payroll_action_id        	  =  ppa.payroll_action_id
		and  (
			(to_number(pay_magtape_generic.get_parameter_value('ASSIGNMENT_SET_ID')) is null)
			or
			(hr_assignment_set.assignment_in_set(
				to_number(pay_magtape_generic.get_parameter_value('ASSIGNMENT_SET_ID')), paa.assignment_id)
							  = 'Y')
		)
                and  (
                        (g_re_yea <> 'R')
                        or
                        (pay_kr_yea_magtape_fun_pkg.latest_yea_action(paa.assignment_action_id, g_payroll_action_id, g_target_year) = 'Y')
                )
		and  paa.tax_unit_id              	  =  bhoi.organization_id
		and  paa.action_status            	  =  'C'
		and  pa.assignment_id             	  =  paa.assignment_id
		and  ppa.effective_date 		  between pa.effective_start_date and pa.effective_end_date
		and  pp.person_id                 	  =  pa.person_id
		and  ppa.effective_date 		  between pp.effective_start_date and pp.effective_end_date
		and  ar.context1               	          =   paa.assignment_action_id
		and  ar.user_entity_id           	  =   g_donation_exem_archive
		and  ar.value                     	  >=  500000      /* Bug 9251570 */
	order by
		bhoi.org_information2 ;
------------------------------------------------------------------------

cursor csr_donation is
	select
		'DON_RECIPIENT_NO=P',	don_recipient_no,
		'DON_RECIPIENT_NAME=P',	don_recipient_name ,
		'NO_OF_DONATIONS=P',	no_of_donations ,
		'DONATION_AMOUNT=P',	donation_amount ,
		'DONATION_CODE=P',	donation_code ,
		'DONATOR_NAME=P',       donator_name,           /* Bug 7799419 */
		'DONATOR_REG_NO=P',     donator_reg_no,         /* Bug 7799419 */
                'DONATOR_REL_CODE=P',   donator_rel_code,       /* Bug 7799419 */
                'DONATOR_NATIONALITY=P', decode(pay_kr_ff_functions_pkg.ni_nationality(donator_reg_no),
                                         'K', '1','9'),         	-- Bug 7799419
                'EXEM_AMT_DURING_TP1=P', exem_amt_during_tax_pd1, 	-- Bug 7799419
                'CARRY_OVER_AMT1=P',     carry_over_amt1,         	-- Bug 7799419
                'CARRY_OVER_BAL1=P', 	 carry_over_bal1,	 	-- Bug 9251570
                'CARRY_OVER_AMT2=P',     carry_over_amt2,         	-- Bug 9251570
		'REP_PERIOD_CODE=P',	 g_rep_period_code        	-- Bug 9251570
	from
		(  /* Bug 7799419: Modified the query for the Donation Type Details information */
			select
				pae.assignment_id		assignment_id,
				nvl(pae.aei_information7, ' ')	don_recipient_no ,
				nvl(pae.aei_information8, ' ')	don_recipient_name,
				sum(nvl(pae.aei_information4, 1)) no_of_donations,
				sum(pae.aei_information3)	donation_amount,
				pae.aei_information5		donation_code,
                                ppf.last_name||ppf.first_name   donator_name,   -- Bug 8281755
                                pae.aei_information13           donator_reg_no,
                                pae.aei_information12           donator_rel_code,
                                nvl(var.aei_information4, 0)  exem_amt_during_tax_pd1,         	-- Bug 9251570
                                nvl(var.aei_information5, 0)  carry_over_amt1,         		-- Bug 9251570
                                nvl(var.aei_information3, 0)  carry_over_bal1,         		-- Bug 9251570
                                nvl(var1.aei_information5, 0)  carry_over_amt2         		-- Bug 9251570
			from
				per_assignment_extra_info pae,
                                per_kr_resident_reg_number_v resreg,		-- Bug 9453056
				per_assignments_f paf,				-- Bug 9453056
                                (select aei_information3,         		-- Bug 9251570
                                        aei_information4,
                                        aei_information5,
                                        aei_information7
                                 from per_assignment_extra_info
                                 where assignment_id = pay_magtape_generic.get_parameter_value('ASSIGN_ID')
                                 and   information_type = 'KR_YEA_DONATION_TYPE_DETAIL'
                                 and aei_information2 = (g_target_year - 1)
                                 and   to_char(fnd_date.canonical_to_date(aei_information1),'yyyy') = g_target_year
                                 ) var,
                                (select aei_information5,
                                        aei_information7
                                 from per_assignment_extra_info
                                 where assignment_id = pay_magtape_generic.get_parameter_value('ASSIGN_ID')
                                 and   information_type = 'KR_YEA_DONATION_TYPE_DETAIL'
                                 and aei_information2 = g_target_year
                                 and   to_char(fnd_date.canonical_to_date(aei_information1),'yyyy') = g_target_year
                                 ) var1, 		-- Bug 9251570
                                per_people_f ppf     	-- Bug 8281755
			where
				pae.assignment_id 	 = pay_magtape_generic.get_parameter_value('ASSIGN_ID')
				-- Start of Bug 9453056
				and paf.assignment_id = pae.assignment_id
  				and paf.person_id = resreg.person_id
  				and fnd_date.canonical_to_date(pae.aei_information1) BETWEEN resreg.cont_effective_start_date
                                AND resreg.cont_effective_end_date
  				and fnd_date.canonical_to_date(pae.aei_information1) BETWEEN resreg.person_effective_start_date
                                AND resreg.person_effective_end_date
  				and fnd_date.canonical_to_date(pae.aei_information1) BETWEEN paf.effective_start_date
                                AND paf.effective_end_date
  				and fnd_date.canonical_to_date(pae.aei_information1) BETWEEN nvl(resreg.relationship_start_date,   fnd_date.canonical_to_date(pae.aei_information1))
                                AND decode(resreg.relationship_end_date,NULL,fnd_date.canonical_to_date(pae.aei_information1),
                                    decode(resreg.relationship_end_reason,'D',
                                           TRUNC(add_months(resreg.relationship_end_date,12),'YYYY') -1,resreg.relationship_end_date))
  				and resreg.cont_person_id = ppf.person_id
				-- End of Bug 9453056
                                and pae.assignment_extra_info_id = var.aei_information7 (+)
                                and pae.assignment_extra_info_id = var1.aei_information7 (+)
				and pae.information_type = 'KR_YEA_DETAIL_DONATION_INFO'
				and to_char(fnd_date.canonical_to_date(pae.aei_information1),'yyyy') = g_target_year
				-- Start of Bug 8281755
                                and ppf.national_identifier = pae.aei_information13
                                and fnd_date.canonical_to_date(pae.aei_information1) between ppf.effective_start_date and ppf.effective_end_date
                                and ppf.full_name = pae.aei_information14		-- Bug 9251570
                                -- End of Bug 8281755
			group by
				pae.assignment_id,
				pae.aei_information7,
				pae.aei_information8,
				pae.aei_information5,
                                ppf.last_name||ppf.first_name,  -- Bug 8281755
                                pae.aei_information13,
                                pae.aei_information12,
                                var.aei_information4,
                                var.aei_information5,
                                var.aei_information3,		-- Bug 9251570
                                var1.aei_information5		-- Bug 9251570
 		) ;


------------------------------------------------------------------------
end pay_kr_yea_don_efile_pkg;

/
