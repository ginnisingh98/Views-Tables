--------------------------------------------------------
--  DDL for Package PAY_KR_YEA_MAGTAPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_YEA_MAGTAPE_PKG" AUTHID CURRENT_USER as
/* $Header: pykryeam.pkh 120.5.12010000.16 2010/02/18 11:06:51 vaisriva ship $ */
--
level_cnt               number;
--
g_business_place_id     number;
g_target_year           number;
g_b_records             number;
-- Bug 3248513
g_normal_yea            varchar2(1) := 'X';
g_interim_yea           varchar2(1) := 'X';
g_re_yea                varchar2(1) := 'X';
g_payroll_action_id     number;
g_assignment_set_id     number;
--
g_taxable_id            number;
g_annual_itax_id        number;
g_annual_rtax_id        number;
g_annual_stax_id        number;
--
g_rep_period_code	varchar2(1) := '2'; -- Bug 9213683
--
------------------------------------------------------------------------
cursor csr_a is
        select
                'BUSINESS_GROUP_ID=C',          to_char(bp.business_group_id),
                'BUSINESS_GROUP_ID=P',          to_char(bp.business_group_id),
                'BP_ORGANIZATION_NAME_A=P',     bptl.name,
                'TAX_OFFICE_CODE_A=P',          hoi1.org_information9,
                'BP_NUMBER_A=P',                hoi2.org_information2,
                'CORP_ORGANIZATION_NAME=P',     corptl.name,
                'CORP_NAME=P',                  hoi3.org_information1,
                'CORP_NUMBER=P',                hoi3.org_information2,
                'CORP_REPR_NAME=P',             hoi3.org_information6,
                'CORP_PHONE_NUMBER=P',          loc.telephone_number_1,
                'B_RECORDS=P',                  to_char(g_b_records),
                'HOME_TAX_ID=P',                nvl(pay_magtape_generic.get_parameter_value('HOME_TAX_ID'), ' ')
        from    hr_organization_information     hoi3,
                hr_locations_all                loc,
                hr_all_organization_units_tl    corptl,
                hr_organization_units           corp,
                hr_organization_information     hoi2,
                hr_organization_information     hoi1,
                hr_all_organization_units_tl    bptl,
                hr_organization_units           bp
        where   bp.organization_id            = g_business_place_id
        and     bptl.organization_id          = bp.organization_id
        and     bptl.language                 = userenv('LANG')
        and     hoi1.organization_id          = bp.organization_id
        and     hoi1.org_information_context  = 'KR_INCOME_TAX_OFFICE'
        and     hoi2.organization_id          = hoi1.organization_id
        and     hoi2.org_information_context  = 'KR_BUSINESS_PLACE_REGISTRATION'
        and     corp.organization_id          = to_number(hoi2.org_information10)
        and     corptl.organization_id        = corp.organization_id
        and     corptl.language               = userenv('LANG')
        and     loc.location_id(+)            = corp.location_id
        and     loc.style(+)                  = 'KR'
        and     hoi3.organization_id          = corp.organization_id
        and     hoi3.org_information_context  = 'KR_CORPORATE_INFORMATION';

cursor csr_b is
 select          DISTINCT 'BP_NUMBER=P',         hoi2.org_information2,
                 'TAX_OFFICE_CODE=P',            hoi3.org_information9,
                 'C_RECORDS=P',                  pay_kr_yea_magtape_fun_pkg.b_data(hoi2.org_information2, hoi3.org_information9, 'C_RECORDS'),
                 'TAXABLE=P',                    pay_kr_yea_magtape_fun_pkg.b_data(hoi2.org_information2, hoi3.org_information9, 'TAXABLE'),
                 'ANNUAL_ITAX=P',                pay_kr_yea_magtape_fun_pkg.b_data(hoi2.org_information2, hoi3.org_information9, 'ANNUAL_ITAX'),
                 'ANNUAL_RTAX=P',                pay_kr_yea_magtape_fun_pkg.b_data(hoi2.org_information2, hoi3.org_information9, 'ANNUAL_RTAX'),
                 'ANNUAL_STAX=P',                pay_kr_yea_magtape_fun_pkg.b_data(hoi2.org_information2, hoi3.org_information9, 'ANNUAL_STAX'),
                 'D_RECORDS=P',                  pay_kr_yea_magtape_fun_pkg.b_data(hoi2.org_information2, hoi3.org_information9, 'D_RECORDS'),
                 'REP_PERIOD_CODE=P',            g_rep_period_code
         from    hr_organization_information     hoi3,
                 hr_organization_information     hoi2,
                 hr_all_organization_units_tl    bptl2,
                 hr_organization_units           bp2,
                 hr_organization_information     hoi1,
                 hr_organization_units           bp1
         where   bp1.organization_id         = pay_magtape_generic.get_parameter_value('BUSINESS_PLACE_ID')     --Bug 5069923
         and     hoi1.organization_id          = bp1.organization_id
         and     hoi1.org_information_context  = 'KR_BUSINESS_PLACE_REGISTRATION'
         and     bp2.business_group_id         = bp1.business_group_id
	 --Bug 5069923
         and     (      (pay_magtape_generic.get_parameter_value('REPORT_FOR')='A')
    		     or (        (hoi2.organization_id  in ( select posev.ORGANIZATION_ID_child
 							     from   PER_ORG_STRUCTURE_ELEMENTS posev
							     where  posev.org_structure_version_id=(pay_magtape_generic.get_parameter_value('ORG_STRUC_VERSION_ID'))
								    and exists ( select null
										 from   hr_organization_information
										 where  organization_id = posev.ORGANIZATION_ID_child
											and org_information_context = 'CLASS'
											and org_information1 = 'KR_BUSINESS_PLACE'
										)
								    start with ORGANIZATION_ID_PARENT = (decode(pay_magtape_generic.get_parameter_value('REPORT_FOR'),'S',null,'SUB',pay_magtape_generic.get_parameter_value('BUSINESS_PLACE_ID')))
								    connect by prior ORGANIZATION_ID_child = ORGANIZATION_ID_PARENT
							    )
				  )
         		       or (hoi2.organization_id = pay_magtape_generic.get_parameter_value('BUSINESS_PLACE_ID')
				  )
			 )
		 )
         and     hoi2.organization_id          = bp2.organization_id
         and     bptl2.organization_id         = bp2.organization_id
         and     bptl2.language                = userenv('LANG')
         and     hoi2.org_information_context  = 'KR_BUSINESS_PLACE_REGISTRATION'
         and     hoi2.org_information10        = hoi1.org_information10
         and     hoi3.organization_id          = hoi2.organization_id
         and     hoi3.org_information_context  = 'KR_INCOME_TAX_OFFICE'
         and     exists(
                         select  null
                         from    pay_assignment_actions  paa,
                                 pay_payroll_actions     ppa
                         where   ppa.report_type       = 'YEA'
                         and     ppa.report_qualifier  = 'KR'
                         and     ppa.business_group_id = bp1.business_group_id
                         -- Bug 3248513
	                 and     ( (ppa.report_category in (g_normal_yea, g_interim_yea, g_re_yea)) or (ppa.payroll_action_id = g_payroll_action_id) )
                         and     to_number(to_char(ppa.effective_date, 'YYYY')) = g_target_year
                         --
                         and     ppa.action_type in ('B','X')
                         and     paa.payroll_action_id = ppa.payroll_action_id
                         and     paa.tax_unit_id       = bp2.organization_id
                         and     paa.action_status     = 'C')
         order by 4;

cursor csr_c(p_bp_number varchar2 default pay_magtape_generic.get_parameter_value('BP_NUMBER'),p_tax_office_code varchar2 default pay_magtape_generic.get_parameter_value('TAX_OFFICE_CODE')) is
        select
                'PAYROLL_ID=C',                 to_char(ppa.payroll_id),
                'PAYROLL_ACTION_ID=C',          to_char(ppa.payroll_action_id),
                'ASSIGNMENT_ID=C',              to_char(paa.assignment_id),
                'ASSIGNMENT_ID=P',              to_char(paa.assignment_id),
                'ASSIGNMENT_ACTION_ID=C',       to_char(paa.assignment_action_id),
                'DATE_EARNED=C',                fnd_date.date_to_canonical(ppa.effective_date),
                'EFFECTIVE_DATE=P',             fnd_date.date_to_canonical(ppa.effective_date),
                'NATIONAL_IDENTIFIER=P',        pp.national_identifier,
                'FULL_NAME=P',                  pp.last_name || pp.first_name,
                'HIRE_DATE=P',                  fnd_date.date_to_canonical(pds.date_start),
                'TERMINATION_DATE=P',           fnd_date.date_to_canonical(pds.actual_termination_date),
                'D_RECORDS_PER_C=P',            pay_kr_yea_magtape_fun_pkg.c_data(paa.assignment_id, 'D_RECORDS_PER_C'),
                'COUNTRY_CODE=P',               pp.country_of_birth,
                'DEPENDENT_COUNT=P',            pay_kr_yea_magtape_fun_pkg.e_record_count(paa.assignment_id,ppa.effective_date)   -- 4738717
        from    per_people_f                    pp,
                per_periods_of_service          pds,
                per_assignments_f               pa,
                pay_assignment_actions          paa,
                pay_payroll_actions             ppa,
                hr_organization_units           bp,
                fnd_territories                 ft,
	        hr_organization_information     hoi1,
	        hr_organization_information     hoi2
        where   hoi1.org_information2         = p_bp_number           --Bug2822459
        and     hoi2.org_information9         = p_tax_office_code     --Bug2822459
	and     hoi1.organization_id          = bp.organization_id
	and     hoi1.organization_id          = hoi2.organization_id
	and     hoi1.org_information_context  = 'KR_BUSINESS_PLACE_REGISTRATION'
	and     hoi2.org_information_context  = 'KR_INCOME_TAX_OFFICE'
        and     ppa.business_group_id         = bp.business_group_id
        and     ppa.report_type               = 'YEA'
        and     ppa.report_qualifier          = 'KR'
        -- Bug 3248513
        and     ( (ppa.report_category in (g_normal_yea, g_interim_yea, g_re_yea)) or (ppa.payroll_action_id = g_payroll_action_id) )
        and     to_number(to_char(ppa.effective_date, 'YYYY')) = g_target_year
        --
        and     ppa.action_type in ('B','X')
        and     paa.payroll_action_id         = ppa.payroll_action_id
	and     ppa.payroll_action_id         = ppa.payroll_action_id
	-- Bug 3248513
	and	((g_assignment_set_id is null) or (hr_assignment_set.assignment_in_set(g_assignment_set_id, paa.assignment_id) = 'Y'))
	and     ((g_re_yea <> 'R') or (pay_kr_yea_magtape_fun_pkg.latest_yea_action(paa.assignment_action_id, g_payroll_action_id, g_target_year) = 'Y')) -- Bug 4726974
	--
        and     paa.tax_unit_id               = bp.organization_id
        and     paa.action_status             = 'C'
        and     pa.assignment_id              = paa.assignment_id
        and     ppa.effective_date
                between pa.effective_start_date and pa.effective_end_date
        and     pds.period_of_service_id      = pa.period_of_service_id
        and     pp.person_id                  = pds.person_id
        and     pp.country_of_birth           = ft.territory_code (+)
        and     ppa.effective_date
                between pp.effective_start_date and pp.effective_end_date
        order by 16;

cursor csr_d(p_assignment_id number default to_number(pay_magtape_generic.get_parameter_value('ASSIGNMENT_ID'))) is
        select
                'PREV_BP_NUMBER=P',             aei.aei_information3,
                'PREV_BP_NAME=P',               aei.aei_information2,
                'PREV_TAXABLE_MTH=P',           nvl(aei.aei_information4, 0),
                'PREV_TAXABLE_BON=P',           nvl(aei.aei_information5, 0),
                'PREV_SP_IRREG_BONUS=P',        nvl(aei.aei_information6, 0),
		'PREV_STCK_PUR_OPT_EXEC_EARN=P', nvl(aei.aei_information17, 0),  -- Bug 6622876
		-- Start of Bug 9213683: Added new columns for the 2009 YEA Efile Updates
		'PREV_HIRE_DATE=P', aei.aei_information23,
		'PREV_TERM_DATE=P', aei.aei_information1,
		-- Start of Bug 9386289
		'PREV_TAX_BRK_FDATE=P', nvl(aei.aei_information24,fnd_date.date_to_canonical(to_date('1900/01/01','YYYY/MM/DD'))),
		'PREV_TAX_BRK_TDATE=P', nvl(aei.aei_information25,fnd_date.date_to_canonical(to_date('1900/01/01','YYYY/MM/DD'))),
		-- End of Bug 9386289
		'PREV_ESOP_EARN=P', nvl(aei.aei_information26, 0),
		'PREV_NTAX_G01=P', pay_kr_yea_magtape_fun_pkg.prev_non_tax_values(p_assignment_id,aei.aei_information3,'G01',fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value('EFFECTIVE_DATE'))),
		'PREV_NTAX_H01=P', pay_kr_yea_magtape_fun_pkg.prev_non_tax_values(p_assignment_id,aei.aei_information3,'H01',fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value('EFFECTIVE_DATE'))),
		'PREV_NTAX_H05=P', pay_kr_yea_magtape_fun_pkg.prev_non_tax_values(p_assignment_id,aei.aei_information3,'H05',fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value('EFFECTIVE_DATE'))),
		'PREV_NTAX_H06=P', pay_kr_yea_magtape_fun_pkg.prev_non_tax_values(p_assignment_id,aei.aei_information3,'H06',fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value('EFFECTIVE_DATE'))),
		'PREV_NTAX_H07=P', pay_kr_yea_magtape_fun_pkg.prev_non_tax_values(p_assignment_id,aei.aei_information3,'H07',fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value('EFFECTIVE_DATE'))),
		'PREV_NTAX_H08=P', pay_kr_yea_magtape_fun_pkg.prev_non_tax_values(p_assignment_id,aei.aei_information3,'H08',fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value('EFFECTIVE_DATE'))),
		'PREV_NTAX_H09=P', pay_kr_yea_magtape_fun_pkg.prev_non_tax_values(p_assignment_id,aei.aei_information3,'H09',fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value('EFFECTIVE_DATE'))),
		'PREV_NTAX_H10=P', pay_kr_yea_magtape_fun_pkg.prev_non_tax_values(p_assignment_id,aei.aei_information3,'H10',fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value('EFFECTIVE_DATE'))),
		'PREV_NTAX_H11=P', pay_kr_yea_magtape_fun_pkg.prev_non_tax_values(p_assignment_id,aei.aei_information3,'H11',fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value('EFFECTIVE_DATE'))),
		'PREV_NTAX_H12=P', pay_kr_yea_magtape_fun_pkg.prev_non_tax_values(p_assignment_id,aei.aei_information3,'H12',fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value('EFFECTIVE_DATE'))),
		'PREV_NTAX_H13=P', pay_kr_yea_magtape_fun_pkg.prev_non_tax_values(p_assignment_id,aei.aei_information3,'H13',fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value('EFFECTIVE_DATE'))),
		'PREV_NTAX_I01=P', pay_kr_yea_magtape_fun_pkg.prev_non_tax_values(p_assignment_id,aei.aei_information3,'I01',fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value('EFFECTIVE_DATE'))),
		'PREV_NTAX_K01=P', pay_kr_yea_magtape_fun_pkg.prev_non_tax_values(p_assignment_id,aei.aei_information3,'K01',fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value('EFFECTIVE_DATE'))),
		'PREV_NTAX_M01=P', pay_kr_yea_magtape_fun_pkg.prev_non_tax_values(p_assignment_id,aei.aei_information3,'M01',fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value('EFFECTIVE_DATE'))),
		'PREV_NTAX_M02=P', pay_kr_yea_magtape_fun_pkg.prev_non_tax_values(p_assignment_id,aei.aei_information3,'M02',fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value('EFFECTIVE_DATE'))),
		'PREV_NTAX_M03=P', pay_kr_yea_magtape_fun_pkg.prev_non_tax_values(p_assignment_id,aei.aei_information3,'M03',fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value('EFFECTIVE_DATE'))),
		'PREV_NTAX_O01=P', nvl(aei.aei_information8, 0),
		'PREV_NTAX_Q01=P', nvl(aei.aei_information21, 0),
		'PREV_NTAX_S01=P', pay_kr_yea_magtape_fun_pkg.prev_non_tax_values(p_assignment_id,aei.aei_information3,'S01',fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value('EFFECTIVE_DATE'))),
		'PREV_NTAX_T01=P', pay_kr_yea_magtape_fun_pkg.prev_non_tax_values(p_assignment_id,aei.aei_information3,'T01',fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value('EFFECTIVE_DATE'))),
		'PREV_NTAX_X01=P', nvl(aei.aei_information22, 0),
		'PREV_NTAX_Y01=P', pay_kr_yea_magtape_fun_pkg.prev_non_tax_values(p_assignment_id,aei.aei_information3,'Y01',fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value('EFFECTIVE_DATE'))),
		'PREV_NTAX_Y02=P', pay_kr_yea_magtape_fun_pkg.prev_non_tax_values(p_assignment_id,aei.aei_information3,'Y02',fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value('EFFECTIVE_DATE'))),
		'PREV_NTAX_Y03=P', pay_kr_yea_magtape_fun_pkg.prev_non_tax_values(p_assignment_id,aei.aei_information3,'Y03',fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value('EFFECTIVE_DATE'))),
		'PREV_NTAX_Y20=P', pay_kr_yea_magtape_fun_pkg.prev_non_tax_values(p_assignment_id,aei.aei_information3,'Y20',fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value('EFFECTIVE_DATE'))),
		'PREV_NTAX_Z01=P', pay_kr_yea_magtape_fun_pkg.prev_non_tax_values(p_assignment_id,aei.aei_information3,'Z01',fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value('EFFECTIVE_DATE'))),
		'PREV_ITAX=P', nvl(aei.aei_information13, 0),
		'PREV_RTAX=P', nvl(aei.aei_information14, 0),
		'PREV_STAX=P', nvl(aei.aei_information15, 0),
		'PREV_EFF_DATE=P', pay_magtape_generic.get_parameter_value('EFFECTIVE_DATE') -- Bug 9386289
		-- End of Bug 9213683
        from    per_assignment_extra_info       aei
        where   aei.assignment_id             = p_assignment_id
        and     aei.information_type          = 'KR_YEA_PREV_ER_INFO'
        and     to_number(to_char(fnd_date.canonical_to_date(aei.aei_information1), 'YYYY')) = g_target_year
        order by aei_information1, 2;
------------------------------------------------------------------------

-- Note: Any change in this cursor must be included in
-- pay_kr_yea_magtape_fun_pkg.e_record_count also.

cursor csr_e( p_assignment_id varchar2 default pay_magtape_generic.get_parameter_value('ASSIGNMENT_ID'),
              p_effective_date date default fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value('EFFECTIVE_DATE'))
            ) is
-- Bug 5654127
-- Bug 7661820
select 'CONTACT_TYPE=P',       '0' contact_type,
       'NATIONALITY=P',        decode(pay_kr_ff_functions_pkg.ni_nationality(asg.assignment_id,p_effective_date),'K','1','9') nationality,
       'BASIC_FLAG=P',         '1' basic_exem_flag,
       'DISABLE_FLAG=P',       decode(pay_kr_ff_functions_pkg.disabled_flag(per.person_id,p_effective_date),'Y','1',' ') disabled_exem_flag,
       'RAISING_CHILD=P',      ' ' child_raising_exem,
       'INS_PREM_NTS=P',       '0' ins_prem_nts,
       'INS_PREM_OTH=P',       '0' ins_prem_oth,
       'MED_EXP_NTS=P',        '0' med_exp_nts,
       'MED_EXP_OTH=P',        '0' med_exp_oth,
       'EDUC_EXP_NTS=P',       '0' educ_exp_nts,
       'EDUC_EXP_OTH=P',       '0' educ_exp_oth,
       'CARD_EXP_NTS=P',       '0' card_exp_nts,
       'CARD_EXP_OTH=P',       '0' card_exp_oth,
       'CASH_EXP_NTS=P',       '0' cash_exp_nts,
       'DON_EXP_NTS=P',        '0' don_exp_nts,  -- Bug 9213683
       'DON_EXP_OTH=P',        '0' don_exp_oth,  -- Bug 7799077
       'CONT_NAME=P',          'Y' full_name,
       'CONT_NI=P',            per.national_identifier national_identifier,
       'NEW_BORN_ADOPTED=P',   ' ' new_born_adopted, -- Bug 7799077
       /* Bug 6622876 */
       'SNR_FLAG=P',            pay_kr_ff_functions_pkg.aged_flag(per.national_identifier,to_date('31-12-'||to_char(p_effective_date,'rrrr'),'dd-mm-rrrr')) snr_flag,
       'SUPER_AGED_FLAG=P',      pay_kr_ff_functions_pkg.super_aged_flag(per.national_identifier,to_date('31-12-'||to_char(p_effective_date,'rrrr'),'dd-mm-rrrr')) super_aged_flag,
       /* End of Bug 6622876 */
       '1'                     l_dummy
       from	        per_people_f		per,
			per_assignments_f	asg
		where	asg.assignment_id	=	p_assignment_id
		and	per.person_id		=	asg.person_id
		and	p_effective_date between per.effective_start_date and per.effective_end_date
		and	p_effective_date between asg.effective_start_date and asg.effective_end_date
union
-- Bug 8644512 : Added code to return correct contact type depending on the year
select 'CONTACT_TYPE=P',    pay_kr_ff_functions_pkg.get_cont_lookup_code(rel_code,
				to_number(to_char(p_effective_date,'YYYY'))) contact_type,
       'NATIONALITY=P',        pkc.cont_nationality nationality,
       'BASIC_FLAG=P',         decode(pkc.cont_information2,'Y',decode(pay_kr_ff_functions_pkg.dpnt_eligible_for_basic_exem(
                                      pkc.contact_type,pkc.cont_information11,pkc.national_identifier, pkc.cont_information2,
                                      pkc.cont_information4,pkc.cont_information8, p_effective_date),'Y','1',' '),' ') basic_exem_flag,
       'DISABLE_FLAG=P',       decode(pkc.cont_information4,'Y','1',' ')  disabled_exem_flag,
       'RAISING_CHILD=P',      decode(pkc.cont_information7 ,'Y',decode(pay_kr_ff_functions_pkg.child_flag(
                                      pkc.national_identifier,p_effective_date), 'Y', '1', ' '), ' ') child_raising_exem,
       'INS_PREM_NTS=P',       to_char(nvl(cei.cei_information1, '0')+ nvl(cei.cei_information10, '0')) ins_prem_nts,
       'INS_PREM_OTH=P',       to_char(nvl(cei.cei_information2, '0')+ nvl(cei.cei_information11, '0')) ins_prem_oth,
       'MED_EXP_NTS=P',        nvl(cei.cei_information3, '0') med_exp_nts,
       'MED_EXP_OTH=P',        nvl(cei.cei_information4, '0') med_exp_oth,
       'EDUC_EXP_NTS=P',       nvl(cei.cei_information5, '0') educ_exp_nts,
       'EDUC_EXP_OTH=P',       nvl(cei.cei_information6, '0') educ_exp_oth,
       'CARD_EXP_NTS=P',       nvl(cei.cei_information7, '0') card_exp_nts,
       'CARD_EXP_OTH=P',       nvl(cei.cei_information8, '0') card_exp_oth,
       'CASH_EXP_NTS=P',       nvl(cei.cei_information9, '0') cash_exp_nts,
       'DON_EXP_NTS=P',        nvl(cei.cei_information14, '0') don_exp_nts,  -- Bug 9213683
       'DON_EXP_OTH=P',        nvl(cei.cei_information15, '0') don_exp_oth,  -- Bug 7799077
       'CONT_NAME=P',          pkc.full_name full_name,
       'CONT_NI=P',            pkc.national_identifier national_identifier,
       'NEW_BORN_ADOPTED=P',   decode(nvl(cei.cei_information13, 'N'),'Y','1',' ') new_born_adopted, -- Bug 7799077
       /* Bug 6622876 */
       'SNR_FLAG=P',           decode(pkc.cont_information3,'Y',pay_kr_ff_functions_pkg.aged_flag(pkc.national_identifier,to_date('31-12-'||to_char(p_effective_date,'rrrr'),'dd-mm-rrrr'))) snr_flag,
       'SUPER_AGED_FLAG=P',     decode(pkc.cont_information3,'Y',pay_kr_ff_functions_pkg.super_aged_flag(pkc.national_identifier,to_date('31-12-'||to_char(p_effective_date,'rrrr'),'dd-mm-rrrr'))) super_aged_flag,
/* End of Bug 6622876 */
       '2'                     l_dummy
  from pay_kr_cont_details_v        pkc,
       per_contact_extra_info_f     cei                                   -- Bug 5872042
 where pkc.assignment_id              = p_assignment_id
   and p_effective_date between pkc.emp_start_date and pkc.emp_end_date
   and pay_kr_ff_functions_pkg.is_exempted_dependent(pkc.contact_type, pkc.cont_information11,pkc.national_identifier, pkc.cont_information2,
           pkc.cont_information3,
           pkc.cont_information4,
           pkc.cont_information7,
           pkc.cont_information8,
           p_effective_date,
           pkc.cont_information10,
           pkc.cont_information12,
           pkc.cont_information13,
           pkc.cont_information14,
	   cei.contact_extra_info_id) = 'Y'
   and to_char(cei.effective_start_date(+), 'yyyy') = to_char(p_effective_date,'yyyy')
   and cei.information_type(+) = 'KR_DPNT_EXPENSE_INFO'
   and cei.contact_relationship_id(+) = pkc.contact_relationship_id
   and p_effective_date between nvl(pkc.date_start, p_effective_date)
            and decode(pkc.cont_information9, 'D',trunc(add_months(nvl(pkc.date_end, p_effective_date),12),'YYYY')-1,
                nvl(pkc.date_end, p_effective_date) )
   and p_effective_date	between nvl(ADDRESS_START_DATE, p_effective_date) and nvl(ADDRESS_END_DATE, p_effective_date)
   and p_effective_date between pkc.CONT_START_DATE and pkc.CONT_END_DATE
 order by l_dummy, national_identifier;
-- End of Bug 5872042
-- End of Bug 5654127
------------------------------------------------------------------------

end pay_kr_yea_magtape_pkg;

/
