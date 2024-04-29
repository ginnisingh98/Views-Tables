--------------------------------------------------------
--  DDL for Package Body PAY_KR_YEA_MAGTAPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_YEA_MAGTAPE_PKG" as
/* $Header: pykryeam.pkb 120.2.12010000.2 2010/01/27 14:20:01 vaisriva ship $ */
--
-- Constants
--
c_package constant varchar2(31) := '  pay_kr_yea_magtape_pkg.';
--
--Bug 5069923
report_for_var varchar2(50);

procedure populate_a
------------------------------------------------------------------------
is
        l_proc  varchar2(61) := c_package || 'populate_a';
        --
        cursor csr_a is
                select  count(distinct hoi2.org_information2||hoi3.org_information9)      --Bug# 2822459 count(*)
                from    hr_organization_information     hoi2,
                        hr_organization_information     hoi3,
                        hr_organization_units           bp2,
                        hr_organization_information     hoi1,
                        hr_organization_units           bp1
                where   bp1.organization_id           = g_business_place_id               --Bug 5069923
                and     hoi1.organization_id          = bp1.organization_id
                and     hoi1.org_information_context  = 'KR_BUSINESS_PLACE_REGISTRATION'
		--Bug 5069923
	        and     (    (report_for_var='A')
			  or (    (hoi2.organization_id  in (select posev.ORGANIZATION_ID_child
							     from   PER_ORG_STRUCTURE_ELEMENTS posev
							     where  posev.org_structure_version_id=(pay_magtape_generic.get_parameter_value('ORG_STRUC_VERSION_ID'))
							     	    and exists (select null
								                from   hr_organization_information
								        	where  organization_id = posev.ORGANIZATION_ID_child
								   		       and org_information_context = 'CLASS'
								   		       and org_information1 = 'KR_BUSINESS_PLACE'
								   	 	)
							      	    start with ORGANIZATION_ID_PARENT = (decode(report_for_var,'S',null,'SUB',g_business_place_id))
								    connect by prior ORGANIZATION_ID_child = ORGANIZATION_ID_PARENT
							     )
			           )
 	                        or (hoi2.organization_id   = g_business_place_id
			           )
 			      )
			)
                and     bp2.business_group_id         = bp1.business_group_id
                and     hoi2.organization_id          = bp2.organization_id
                and     hoi2.org_information_context  = 'KR_BUSINESS_PLACE_REGISTRATION'
                and     hoi2.org_information10        = hoi1.org_information10
                and     hoi3.organization_id          = hoi2.organization_id
                and     hoi3.org_information_context  = 'KR_INCOME_TAX_OFFICE'
                and     exists(
                                select  null
                                from    pay_assignment_actions  paa,
                                        pay_payroll_actions     ppa
                                where   ppa.report_type = 'YEA'
                                and     ppa.report_qualifier = 'KR'
                                and     ppa.business_group_id = bp1.business_group_id
                                -- Bug 3248513
                                and    ( (ppa.report_category in (g_normal_yea, g_interim_yea, g_re_yea)) or (ppa.payroll_action_id = g_payroll_action_id ))
                                and     to_number(to_char(ppa.effective_date, 'YYYY')) = g_target_year
                                --
                                and     ppa.action_type in ('B','X')
                                and     paa.payroll_action_id = ppa.payroll_action_id
                                and     paa.tax_unit_id = bp2.organization_id
                                and     paa.action_status = 'C');
begin
        if g_business_place_id is null then
                g_business_place_id := to_number(pay_magtape_generic.get_parameter_value('BUSINESS_PLACE_ID'));
                g_target_year       := to_number(pay_magtape_generic.get_parameter_value('TARGET_YEAR'));
		--Bug 5069923
		report_for_var	:= pay_magtape_generic.get_parameter_value('REPORT_FOR');
                --
                open csr_a;
                fetch csr_a into g_b_records;
                close csr_a;
        end if;
end populate_a;

------------------------------------------------------------------------
-- Package initialization section
------------------------------------------------------------------------
begin
        declare
		l_report_type	varchar2(3);
                --------------------------------------------------------
                function user_entity_id(p_user_entity_name in varchar2) return number
                --------------------------------------------------------
                is
                        l_user_entity_id        number;
                begin
                        select  user_entity_id
                        into    l_user_entity_id
                        from    ff_user_entities
                        where   user_entity_name = p_user_entity_name
                        and     legislation_code = 'KR'
                        and     creator_type = 'X';
                        --
                        return l_user_entity_id;
                end user_entity_id;
        begin
        	-- Bug 3248513
                g_payroll_action_id   := pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID');
		g_assignment_set_id   := to_number(pay_magtape_generic.get_parameter_value('ASSIGNMENT_SET_ID'));

		if g_payroll_action_id is null then

                	l_report_type         := pay_magtape_generic.get_parameter_value('REPORT_TYPE');

			if l_report_type       is null then
				g_normal_yea   		:= 'N';
				g_interim_yea  		:= 'I';
				g_rep_period_code 	:= '1';	-- Bug 9213683

			elsif l_report_type    = 'N' then
				g_normal_yea   		:= 'N';
				g_rep_period_code 	:= '1';	-- Bug 9213683

			elsif l_report_type    = 'I' then
				g_interim_yea  		:= 'I';
				g_rep_period_code 	:= '3';	-- Bug 9213683

			elsif l_report_type    = 'R' then
				g_re_yea       		:= 'R';
				g_rep_period_code 	:= '3';	-- Bug 9213683

			elsif l_report_type    = 'NI' then
				g_normal_yea   		:= 'N';
				g_interim_yea  		:= 'I';
				g_rep_period_code 	:= '1';	-- Bug 9213683

			elsif l_report_type    = 'NR' then
				g_normal_yea   		:= 'N';
				g_re_yea       		:= 'R';
				g_rep_period_code 	:= '1';	-- Bug 9213683

			end if;
		end if;
		--
                populate_a;

                g_taxable_id     := user_entity_id('X_YEA_TAXABLE');
                g_annual_itax_id := user_entity_id('X_YEA_ANNUAL_ITAX');
                g_annual_rtax_id := user_entity_id('X_YEA_ANNUAL_RTAX');
                g_annual_stax_id := user_entity_id('X_YEA_ANNUAL_STAX');

        end;
end pay_kr_yea_magtape_pkg;

/
