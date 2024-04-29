--------------------------------------------------------
--  DDL for Package PAY_KR_NONSTAT_SPAY_EFILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_NONSTAT_SPAY_EFILE" AUTHID CURRENT_USER as
/*$Header: pykrnspef.pkh 120.6.12010000.4 2010/02/26 03:27:13 pnethaga ship $ */

level_cnt 	number;
g_bp_count	number;

/*************************************************************************
 * Function that count the BP's under the Business Group.
 *************************************************************************/
function get_bp_count( primary_business_place_id IN Number)	return Number;

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
			);

/*********************************************************
 * Cursor to get data for record A
 * Parameters:
 *     REPORTED_DATE
 *     PRIMARY_BP_ID
 *     START_DATE
 *     END_DATE
 *********************************************************/

cursor c_record_a is
	SELECT
		'CORP_PHONE_NUMBER=P'
		,hla.telephone_number_1      corp_phone_number
		,'REPRESENTATIVE_TAX_OFFICE_CODE=P'
		,ihoi.org_information9       corp_tax_office_code
		,'CORP_NAME=P'
		,choi.org_information1       corp_name
		,'CORP_REP_NAME=P'
		,choi.org_information6       corp_rep_name
		,'CORP_NUMBER=P'
		,choi.org_information2       corp_number
		,'BP_NUMBER=P'
		,hoi.org_information2        bp_number
		,'CORPORATION_ID=P'
		,hoi.org_information10       corp_id
        ,'BP_COUNT=P'
		, g_bp_count
		,'REPORTED_DATE=P'
		,pay_magtape_generic.get_parameter_value('REPORTED_DATE')
	FROM hr_organization_information hoi
		,hr_organization_information ihoi
		,hr_organization_information choi
		,hr_organization_units       hou
		,hr_locations_all            hla
	WHERE hou.organization_id                 = pay_magtape_generic.get_parameter_value('PRIMARY_BP_ID')
		and hou.business_group_id             = pay_magtape_generic.get_parameter_value('BUSINESS_GROUP_ID')
		and hou.organization_id               = hoi.organization_id
		and hoi.org_information_context       = 'KR_BUSINESS_PLACE_REGISTRATION'
		and hou.organization_id               = ihoi.organization_id
		and ihoi.org_information_context      = 'KR_INCOME_TAX_OFFICE'
		and choi.organization_id              = to_number(hoi.org_information10)
		and choi.org_information_context      = 'KR_CORPORATE_INFORMATION'
		and hla.location_id(+)                = hou.location_id
		and hla.style(+)                      = 'KR'
		and g_bp_count > 0;

/*********************************************************
 * Cursor to get distinct business places for record B
 * Parameters:
 *     CORPORATION_ID
 *     BUSINESS_GROUP_ID
 *     TARGET_YEAR
 *
 *********************************************************/

cursor c_record_b_distinct_bp
is
	SELECT distinct
		'BP_NUMBER=P',
		hoi.org_information2,
		'TAX_OFFICE_CODE=P',
		ihoi.org_information9,
		'CORP_NAME=P',
		choi.org_information1,
		'CORP_REP_NAME=P',
		choi.org_information6,
		'CORP_REG_NUMBER=P',
		choi.org_information2
	FROM hr_organization_information hoi
		,hr_organization_information ihoi
		,hr_organization_information choi
	WHERE hoi.org_information_context         = 'KR_BUSINESS_PLACE_REGISTRATION'
		and hoi.organization_id               = ihoi.organization_id
		and ihoi.org_information_context      = 'KR_INCOME_TAX_OFFICE'
		and hoi.org_information10             = pay_magtape_generic.get_parameter_value('CORPORATION_ID')
		--Bug 5069923
        	and  (
        	         (pay_magtape_generic.get_parameter_value('REPORT_FOR')='A')
        	      or (
        	              	(hoi.organization_id in (select
        	           			 		posev.ORGANIZATION_ID_child
        	           			    	from    PER_ORG_STRUCTURE_ELEMENTS posev
        	           			    	where   posev.org_structure_version_id = (pay_magtape_generic.get_parameter_value('ORG_STRUC_VERSION_ID'))
        	           			   	        and exists (
        	           			                           select null
        	           			                           from   hr_organization_information
        	           			                           where  organization_id = posev.ORGANIZATION_ID_child
        	           			                          	  and org_information_context = 'CLASS'
        	           			                           	  and org_information1 = 'KR_BUSINESS_PLACE'
        	           			                   	   )
        	           			    	start with ORGANIZATION_ID_PARENT = ( decode ( pay_magtape_generic.get_parameter_value('REPORT_FOR'),'S',null,'SUB',pay_magtape_generic.get_parameter_value('PRIMARY_BP_ID')))
        	           			    	connect by prior ORGANIZATION_ID_child = ORGANIZATION_ID_PARENT
        	           			    	)
        	           	)
       		             or (hoi.organization_id = pay_magtape_generic.get_parameter_value('PRIMARY_BP_ID')
       		            	)
       		          )
       		     )
		and choi.organization_id              = to_number(hoi.org_information10)
		and choi.org_information_context      = 'KR_CORPORATE_INFORMATION'
		and exists (select 'x'
					from pay_assignment_actions      xpaa,
						 pay_payroll_actions         xppa,
						 ff_Archive_items            fai,
						 ff_user_entities            fue
					where xppa.action_type                = 'X'
					and xppa.action_status                = 'C'
					--Bug 5069923
					and xppa.payroll_action_id 	      = nvl(pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID'),xpaa.payroll_action_id)
					and xppa.effective_date between
						to_date(pay_magtape_generic.get_parameter_value('TARGET_YEAR')||'0101','YYYYMMDD')
						and to_date(pay_magtape_generic.get_parameter_value('TARGET_YEAR')||'1231','YYYYMMDD')
					and xppa.payroll_action_id            = xpaa.payroll_action_id
					and xpaa.action_status                = 'C'
					--Bug 5069923
					and (    (pay_magtape_generic.get_parameter_value('ASSIGNMENT_SET_ID') is null)
					      or (hr_assignment_set.assignment_in_set(pay_magtape_generic.get_parameter_value('ASSIGNMENT_SET_ID'), xpaa.assignment_id) = 'Y')
					    )
					and xppa.report_type                  = 'KR_SEP'
					and xppa.business_group_id            = pay_magtape_generic.get_parameter_value('BUSINESS_GROUP_ID')
					and hoi.organization_id               = xpaa.tax_unit_id
					and fue.user_entity_id                = fai.user_entity_id
					and fue.user_entity_name               in ('A_NON_STAT_SEP_PAY_TAXABLE_EARNINGS_ASG_RUN','A_RECEIVABLE_NON_STAT_SEP_PAY_ASG_RUN')
					and fue.legislation_code              = 'KR'
					and fai.context1                      = xpaa.assignment_action_id
					and fai.value > '0'
					)
		order by hoi.org_information2;

/*********************************************************
 * Cursor to get summary values for record B
 * Parameters:
 *     CORPORATION_ID
 *     BUSINESS_GROUP_ID
 *     TARGET_YEAR
 *     TAX_OFFICE_CODE
 *     BP_NUMBER
 *
 *********************************************************/

cursor c_record_b_summary
is
SELECT  'TOTAL_ITAX=P'
        ,SUM(decode(fue.user_entity_name,'A_GROSS_ITAX_ASG_RUN',fai.value,0)) ITAX
        ,'TOTAL_STAX=P'
        ,SUM(decode(fue.user_entity_name,'A_GROSS_STAX_ASG_RUN',fai.value,0)) STAX
        ,'TOTAL_RTAX=P'
        ,SUM(decode(fue.user_entity_name,'A_GROSS_RTAX_ASG_RUN',fai.value,0)) RTAX
        ,'TOTAL_TAXABLE_EARNG=P'
        --Bug 5659556
        ,SUM(decode(fue.user_entity_name,
        	'A_TAXABLE_EARNINGS_WI_PREV_ASG_RUN', pay_kr_spay_efile_fun_pkg.get_sep_pay_amount(xpaa.assignment_action_id,fai.value),
        	'A_NON_STAT_SEP_PAY_TAXABLE_EARNINGS_ASG_RUN',pay_kr_spay_efile_fun_pkg.get_nsep_pay_amount(xpaa.assignment_action_id,fai.value), 0))  TAXABLE_EARNG
        --
        ,'EMPLOYEE_COUNT=P'
        ,sum(decode(decode(fue.user_entity_name ,'A_NON_STAT_SEP_PAY_TAXABLE_EARNINGS_ASG_RUN',
	pay_kr_spay_efile_fun_pkg.get_nsep_pay_amount(xpaa.assignment_action_id,fai.value),0),0,0,1))  EMPCOUNT -- Bug 9409509
        ,'PREV_EMP_COUNT=P'
        ,SUM(decode(fue.user_entity_name ,'X_KR_PREV_BP_NUMBER',1,0))  PREVEMPCOUNT
	,'REPORTING_PERIOD=P'
	,pay_magtape_generic.get_parameter_value('REPORTING_PERIOD')
  FROM  pay_assignment_actions      xpaa
       ,pay_payroll_actions         xppa
       ,hr_organization_information hoi
       ,hr_organization_information ihoi
       ,hr_organization_units       hou
       ,ff_user_entities            fue
       ,ff_archive_items            fai
       ,ff_user_entities            fue1
       ,ff_archive_items            fai1
 WHERE xppa.action_type                       = 'X'
  and xppa.action_status                      = 'C'
  --Bug 5069923
  and xppa.payroll_action_id 	    = nvl(pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID'),xpaa.payroll_action_id)
  and xppa.effective_date between
      to_date(pay_magtape_generic.get_parameter_value('TARGET_YEAR')||'0101','YYYYMMDD')
	  and to_date(pay_magtape_generic.get_parameter_value('TARGET_YEAR')||'1231','YYYYMMDD')
  and xppa.payroll_action_id        = xpaa.payroll_action_id
  and xpaa.action_status            = 'C'
  and xppa.report_type              = 'KR_SEP'
  and hoi.organization_id           = xpaa.tax_unit_id
  and hoi.org_information_context   = 'KR_BUSINESS_PLACE_REGISTRATION'
  and hoi.organization_id           = ihoi.organization_id
  and ihoi.org_information_context  = 'KR_INCOME_TAX_OFFICE'
  and ihoi.org_information9         = pay_magtape_generic.get_parameter_value('TAX_OFFICE_CODE')
  and hoi.org_information2          = pay_magtape_generic.get_parameter_value('BP_NUMBER')
  and hoi.org_information10         = pay_magtape_generic.get_parameter_value('CORPORATION_ID')
  and hoi.organization_id           = hou.organization_id
  and hou.business_group_id         = pay_magtape_generic.get_parameter_value('BUSINESS_GROUP_ID')
  and fai.user_entity_id            = fue.user_entity_id
  and fue.user_entity_name          IN ('A_GROSS_ITAX_ASG_RUN',
                                        'A_GROSS_STAX_ASG_RUN',
                                        'A_GROSS_RTAX_ASG_RUN',
                                        'A_TAXABLE_EARNINGS_WI_PREV_ASG_RUN',
                                        'X_KR_PREV_BP_NUMBER',
                                        'A_NON_STAT_SEP_PAY_TAXABLE_EARNINGS_ASG_RUN')
  and fai.context1                  = xpaa.assignment_Action_id
  --Bug 5069923
  and (     (pay_magtape_generic.get_parameter_value('ASSIGNMENT_SET_ID') is null)
	 or (hr_assignment_set.assignment_in_set(pay_magtape_generic.get_parameter_value('ASSIGNMENT_SET_ID'), xpaa.assignment_id) = 'Y')
      )
  and fue1.user_entity_name         =  pay_kr_spay_efile_fun_pkg.get_archive_item(xpaa.assignment_Action_id) -- Bug 9409509
  and fue1.legislation_code         = 'KR'
  and fai1.user_entity_id           = fue1.user_entity_id
  and fai1.context1                 = xpaa.assignment_Action_id
  and fai1.value          > '0';

 /*********************************************************
 * Cursor to get the start_date and end_date of multiple
 * years. Required Parameters:
 *        TARGET_YEAR
 *
 *********************************************************/
cursor c_multiple_year              -- 4095229
is
select 	'START_DATE=P',
	 fnd_date.date_to_canonical( to_date(pay_magtape_generic.get_parameter_value('TARGET_YEAR') || '0101',
	                                    'YYYYMMDD') ) start_date,
	'END_DATE=P',
	 fnd_date.date_to_canonical( to_date(pay_magtape_generic.get_parameter_value('TARGET_YEAR') || '1231',
	                                    'YYYYMMDD')  ) end_date

from dual;

/*********************************************************
 * Cursor to get assignemnts for record C
 * Parameters:
 *     CORPORATION_ID
 *     BUSINESS_GROUP_ID
 *     START_DATE
 *     END_DATE
 *     TAX_OFFICE_CODE
 *     BP_NUMBER
 *********************************************************/

cursor c_record_c
is
SELECT  'ASSIGNMENT_ACTION_ID=C'
       ,xpaa.assignment_action_id
       -- Bug 4251252
       ,'ASSIGNMENT_ACTION_ID=P'
       ,xpaa.assignment_action_id
       -- Bug 4251252
       ,'ASG_ID=P'
       ,xpaa.assignment_id
       ,'PREVIOUS_EMP_COUNT=P'
       ,pay_kr_nonstat_spay_efile_fun.get_prev_emp_count(xpaa.assignment_action_id)
       -- Bug 7712932
       ,'STAT_SEP_PAY_OVR_TAX_BRK=P'
       ,pay_kr_nonstat_spay_efile_fun.get_sep_pay_ovr_tax_brk(xpaa.assignment_action_id,xpaa.assignment_id,'SEP')
       ,'NSTAT_SEP_PAY_OVR_TAX_BRK=P'
       ,pay_kr_nonstat_spay_efile_fun.get_sep_pay_ovr_tax_brk(xpaa.assignment_action_id,xpaa.assignment_id,'NSEP')
       -- End of Bug 7712932
       ,'BP_NUMBER=P'
       ,hoi.org_information2
       ,'CORP_NAME=P'
       ,hoi.org_information1
FROM    pay_assignment_actions      xpaa
       ,pay_payroll_actions         xppa
       ,hr_organization_information hoi
       ,hr_organization_units       hou
       ,ff_user_entities            fue
       ,ff_archive_items            fai
       ,ff_user_entities            fue1
       ,ff_archive_items            fai1
WHERE    xppa.action_type                       = 'X'
and     xppa.action_status                      = 'C'
and     xppa.effective_date
	between fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value('START_DATE'))
	and fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value('END_DATE'))
and     xppa.payroll_action_id                  = xpaa.payroll_action_id
--Bug 5069923
and   xppa.payroll_action_id 		        = nvl(pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID'),xpaa.payroll_action_id)
and     xpaa.action_status                      = 'C'
and     xppa.report_type                        = 'KR_SEP'
and     hoi.organization_id                     = xpaa.tax_unit_id
and     hoi.org_information_context             = 'KR_BUSINESS_PLACE_REGISTRATION'
and     hoi.org_information2                    = pay_magtape_generic.get_parameter_value('BP_NUMBER')
and     hoi.org_information10                   = pay_magtape_generic.get_parameter_value('CORPORATION_ID')
and     hoi.organization_id                     = hou.organization_id
and     hou.business_group_id                   = pay_magtape_generic.get_parameter_value('BUSINESS_GROUP_ID')
and     fue.user_entity_name                    = pay_kr_spay_efile_fun_pkg.get_archive_item(xpaa.assignment_Action_id) -- Bug 9409509
and     fue.legislation_code                    = 'KR'
and     fai.user_entity_id                      = fue.user_entity_id
and     fai.context1                            = xpaa.assignment_action_id
--Bug 5069923
and	(     (pay_magtape_generic.get_parameter_value('ASSIGNMENT_SET_ID') is null)
	   or (hr_assignment_set.assignment_in_set(pay_magtape_generic.get_parameter_value('ASSIGNMENT_SET_ID'), xpaa.assignment_id) = 'Y')
	)
and     fai.value   > '0'
and     fue1.user_entity_name                   = 'X_KR_EMP_NI'
and     fai1.user_entity_id                     = fue1.user_entity_id
and     fai1.context1                           = xpaa.assignment_action_id
order by fai1.value;

/*********************************************************
 * Cursor to get ELEMENT_ENTRY_ID for record D
 * Parameters:
 *     ASG_ID
 *     ASSIGNMENT_ACTION_ID
 *********************************************************/

cursor c_record_d
is
select
        'ELEMENT_ENTRY_ID=C',
        fac.context
from
        ff_contexts fc,
        ff_user_entities fue,
        ff_route_context_usages frc,
        ff_archive_item_contexts fac,
        ff_archive_items fai
where
        fue.user_entity_name = 'X_KR_PREV_BP_NUMBER'
        and fue.legislation_code = 'KR'
        and fue.route_id = frc.route_id
        and frc.context_id = fc.context_id
        and fc.context_name = 'ELEMENT_ENTRY_ID'
        and fai.context1 = pay_magtape_generic.get_parameter_value('ASSIGNMENT_ACTION_ID')
        and fai.user_entity_id = fue.user_entity_id
        and fac.archive_item_id = fai.archive_item_id
        and fac.context_id = fc.context_id
order by
       fai.value, fac.context ;

end pay_kr_nonstat_spay_efile;

/
