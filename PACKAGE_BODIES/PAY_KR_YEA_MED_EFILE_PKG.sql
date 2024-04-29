--------------------------------------------------------
--  DDL for Package Body PAY_KR_YEA_MED_EFILE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_YEA_MED_EFILE_PKG" as
/* $Header: pykrymef.pkb 120.1.12010000.2 2010/01/27 14:26:26 vaisriva ship $ */
--
-- Constants
--
c_package constant varchar2(31) := '  pay_kr_yea_med_efile_pkg.';
--

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
       	     --
             g_payroll_action_id := pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID');
	     g_assignment_set_id := to_number(pay_magtape_generic.get_parameter_value('ASSIGNMENT_SET_ID'));
     --        g_business_place_id := to_number(pay_magtape_generic.get_parameter_value('BUSINESS_PLACE_ID'));
             g_target_year       := to_number(pay_magtape_generic.get_parameter_value('TARGET_YEAR'));
             --
             g_medical_exp_archive := user_entity_id('X_YEA_MED_EXP_TAX_EXEM');
             --
             if g_payroll_action_id is null then

                	l_report_type         := pay_magtape_generic.get_parameter_value('REPORT_TYPE');

			if l_report_type       is null then
				g_normal_yea   := 'N';
				g_interim_yea  := 'I';
				g_rep_period_code := '1'; -- Bug 9251566

			elsif l_report_type    = 'N' then
				g_normal_yea   := 'N';
				g_rep_period_code := '1'; -- Bug 9251566

			elsif l_report_type    = 'I' then
				g_interim_yea  := 'I';
				g_rep_period_code := '3'; -- Bug 9251566

			elsif l_report_type    = 'R' then
				g_re_yea       := 'R';
				g_rep_period_code := '3'; -- Bug 9251566

			elsif l_report_type    = 'NI' then
				g_normal_yea   := 'N';
				g_interim_yea  := 'I';
				g_rep_period_code := '1'; -- Bug 9251566

			elsif l_report_type    = 'NR' then
				g_normal_yea   := 'N';
				g_re_yea       := 'R';
				g_rep_period_code := '1'; -- Bug 9251566

			end if;
	     end if;
		--
        end;
end pay_kr_yea_med_efile_pkg;

/
