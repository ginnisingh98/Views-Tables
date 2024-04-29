--------------------------------------------------------
--  DDL for Package Body PAY_KR_NONSTAT_SPAY_EFILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_NONSTAT_SPAY_EFILE" as
/*$Header: pykrnspef.pkb 120.3.12010000.3 2010/02/26 03:29:25 pnethaga ship $ */

/*************************************************************************
 * Procedure to submit e-file request indirectly
 *************************************************************************/

	procedure submit_efile (errbuf              out nocopy  varchar2,
				retcode                 out nocopy  varchar2,
				p_effective_date              in varchar2,
				p_business_place              in varchar2,
				p_report_for		      in varchar2,	--5069923
				p_magnetic_file_name          in varchar2,
				p_report_file_name            in varchar2,
				p_target_year                 in varchar2,
				p_payroll_action_id	      in varchar2,	--5069923
				p_assignment_set_id	      in varchar2,	--5069923
				p_reported_date               in varchar2,
				p_reporting_period 	      in varchar2,
				p_characterset		      in varchar2,	--5069923
				p_business_group_id_hd        in varchar2,
				p_tax_reporting_org           in varchar2,	--4095229
				p_tax_reporter                in varchar2,
				p_cont_phone_no               in varchar2,
				p_home_tax_id                 in varchar2,
				p_org_struc_version_id	      in varchar2	--5069923

				)
	is

    l_req_id          		number;
	l_message				varchar2(2000);
	l_phase					varchar2(100);
	l_status				varchar2(100);
	l_action_completed		boolean;

	begin

    	l_req_id	:= fnd_request.submit_request (
				 APPLICATION          =>   'PAY'
				,PROGRAM              =>   'PAYKRSEF_NS_B'
				,DESCRIPTION          =>   'KR Non-Statutory Separation Pay E-File (MAGTAPE)'
				,ARGUMENT1            =>   'pay_magtape_generic.new_formula'
				,ARGUMENT2            =>   p_magnetic_file_name
				,ARGUMENT3            =>   p_report_file_name
				,ARGUMENT4            =>   p_effective_date
				,ARGUMENT5            =>   'MAGTAPE_REPORT_ID=KR_NS_SPAY_EFILE'
				,ARGUMENT6            =>   'PRIMARY_BP_ID='      || p_business_place
				,ARGUMENT7            =>   'TARGET_YEAR='        || p_target_year
				,ARGUMENT8            =>   'REPORTED_DATE='      || p_reported_date
				,ARGUMENT9            =>   'BUSINESS_GROUP_ID='  || p_business_group_id_hd
				,ARGUMENT10           =>   'HOME_TAX_ID='        || nvl(p_home_tax_id, ' ')
				,ARGUMENT11           =>   'TAX_REPORTING_ORG='  || p_tax_reporting_org
				,ARGUMENT12           =>   'TAX_REPORTER='       || p_tax_reporter
				,ARGUMENT13           =>   'CONT_PHONE_NO='      || p_cont_phone_no
				,ARGUMENT14           =>   'REPORT_FOR='	 || p_report_for
				,ARGUMENT15           =>   'PAYROLL_ACTION_ID='	 || p_payroll_action_id
				,ARGUMENT16           =>   'ASSIGNMENT_SET_ID='	 || p_assignment_set_id
				,ARGUMENT17	      =>   'CHARACTERSET='	 || p_characterset
				,ARGUMENT18	      =>   'ORG_STRUC_VERSION_ID='	|| p_org_struc_version_id
				,ARGUMENT19	      =>   'REPORTING_PERIOD='	|| p_reporting_period
				);

		if (l_req_id = 0) then
			retcode := 2;
			fnd_message.retrieve(errbuf);
		else
			commit;
		end if;
	end submit_efile;

/*************************************************************************
 * Function that count the BP's under the Business Group.
 * This function needs TARGET_YEAR coming from SRS
 *************************************************************************/
	function get_bp_count( primary_business_place_id IN Number)	Return Number
	is
		l_bp_count			Number;

		cursor c_business_place_count
		is
		select count(distinct hoi.org_information2||ihoi.org_information9) bp_count
				from hr_organization_information hoi
					,hr_organization_units       hou
					,hr_organization_units       phou
					,hr_organization_information phoi
					,hr_organization_information ihoi
				where hou.organization_id                 = hoi.organization_id
					and hoi.org_information_context       = 'KR_BUSINESS_PLACE_REGISTRATION'
					and hoi.org_information10             = phoi.org_information10
					and phou.organization_id              = primary_business_place_id
					and phou.organization_id              = phoi.organization_id
					--Bug 5069923
       					and (      (pay_magtape_generic.get_parameter_value('REPORT_FOR')='A')
						or (      (hoi.organization_id in (select posev.ORGANIZATION_ID_child
										    from   PER_ORG_STRUCTURE_ELEMENTS posev
										    where  posev.org_structure_version_id=(pay_magtape_generic.get_parameter_value('ORG_STRUC_VERSION_ID'))
											   and exists ( select null
													from   hr_organization_information
													where  organization_id = posev.ORGANIZATION_ID_child
													       and org_information_context = 'CLASS'
													       and org_information1 = 'KR_BUSINESS_PLACE'
												       )
											    start with ORGANIZATION_ID_PARENT = (decode(pay_magtape_generic.get_parameter_value('REPORT_FOR'),'S',null,'SUB',primary_business_place_id))
											    connect by prior ORGANIZATION_ID_child = ORGANIZATION_ID_PARENT
										     )
							   )
        				   		or (hoi.organization_id = primary_business_place_id
							   )
						    )
					    )
					and phoi.org_information_context      = 'KR_BUSINESS_PLACE_REGISTRATION'
					and ihoi.org_information_context      = 'KR_INCOME_TAX_OFFICE'
					and ihoi.organization_id              = hou.organization_id
					and exists( select 'x'
								from ff_user_entities            fue
									,ff_archive_items            fai
									,pay_assignment_actions      xpaa
									,pay_payroll_actions         xppa
								where xppa.action_type                        = 'X'
									and xppa.action_status                = 'C'
									--Bug 5069923
									and   xppa.payroll_action_id 	      = nvl(pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID'),xpaa.payroll_action_id)
									and xppa.effective_date between
										to_date(pay_magtape_generic.get_parameter_value('TARGET_YEAR')||'0101','YYYYMMDD')
										and to_date(pay_magtape_generic.get_parameter_value('TARGET_YEAR')||'1231','YYYYMMDD')
									and xppa.payroll_action_id            = xpaa.payroll_action_id
									and xpaa.action_status                = 'C'
									--Bug 5069923
								  	and (      (pay_magtape_generic.get_parameter_value('ASSIGNMENT_SET_ID') is null)
										or (hr_assignment_set.assignment_in_set(pay_magtape_generic.get_parameter_value('ASSIGNMENT_SET_ID'), xpaa.assignment_id) = 'Y')
									    )
									and xppa.report_type                  = 'KR_SEP'
									--Bug 5069923
									and   xppa.business_group_id            = pay_magtape_generic.get_parameter_value('BUSINESS_GROUP_ID')
									and xpaa.tax_unit_id                  = hou.organization_id
									and fue.user_entity_name              in ('A_NON_STAT_SEP_PAY_TAXABLE_EARNINGS_ASG_RUN','A_RECEIVABLE_NON_STAT_SEP_PAY_ASG_RUN') --Bug 9409509
									and fue.legislation_code              = 'KR'
									and fai.user_entity_id                = fue.user_entity_id
									and fai.context1                      = xpaa.assignment_action_id
									and fai.value   > '0'
								)
		group by hoi.org_information10;
	begin
		open c_business_place_count;
		fetch c_business_place_count into l_bp_count;
		close c_business_place_count;

		return nvl(l_bp_count, 0);
	end get_bp_count;

begin

	g_bp_count	:= get_bp_count(pay_magtape_generic.get_parameter_value('PRIMARY_BP_ID'));

end pay_kr_nonstat_spay_efile;

/
