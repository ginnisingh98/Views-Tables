--------------------------------------------------------
--  DDL for Package PAY_KR_SPAY_EFILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_SPAY_EFILE" AUTHID CURRENT_USER as
/* $Header: pykrspef.pkh 120.6.12010000.6 2010/02/26 03:35:10 pnethaga ship $ */

level_cnt number;

cursor c_sep_tax_header_count
is
SELECT  'BP_COUNT=P'
        ,count(distinct hoi.org_information2||ihoi.org_information9) bp_count
        ,'CORPORATION_ID=P'
        ,hoi.org_information10
FROM    pay_assignment_actions      xpaa
       ,pay_payroll_actions         xppa
       ,hr_organization_information hoi
       ,hr_organization_units       hou
       ,hr_organization_units       phou
       ,hr_organization_information phoi
       ,hr_organization_information ihoi
WHERE   xppa.action_type                        = 'X'
        and   xppa.action_status                = 'C'
        and   xppa.effective_date between
        pay_magtape_generic.get_parameter_value('START_DATE')
        and
        pay_magtape_generic.get_parameter_value('END_DATE')
        and   xppa.payroll_action_id            = xpaa.payroll_action_id
        and   xpaa.action_status                = 'C'
	--Bug 5069923
	and   xppa.payroll_action_id 		= nvl(pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID'),xpaa.payroll_action_id)    --Bug 5069923
	--Bug 5069923
  	and   (   (pay_magtape_generic.get_parameter_value('ASSIGNMENT_SET_ID') is null)
	       or (hr_assignment_set.assignment_in_set(pay_magtape_generic.get_parameter_value('ASSIGNMENT_SET_ID'), xpaa.assignment_id) = 'Y')
	      )
	--Bug 5069923
        and   (   (pay_magtape_generic.get_parameter_value('REPORT_FOR')='A')
               or (    (hoi.organization_id in (select posev.ORGANIZATION_ID_child
						from   PER_ORG_STRUCTURE_ELEMENTS posev
						where  posev.org_structure_version_id=(pay_magtape_generic.get_parameter_value('ORG_STRUC_VERSION_ID'))
						       and exists ( select null
								    from   hr_organization_information
								    where  organization_id = posev.ORGANIZATION_ID_child
									   and org_information_context = 'CLASS'
									   and org_information1 = 'KR_BUSINESS_PLACE'
								   )
						       start with ORGANIZATION_ID_PARENT = (decode(pay_magtape_generic.get_parameter_value('REPORT_FOR'),'S',null,'SUB',pay_magtape_generic.get_parameter_value('PRIMARY_BP_ID')))
						       connect by prior ORGANIZATION_ID_child = ORGANIZATION_ID_PARENT
						)
			)
        	     or (hoi.organization_id    = pay_magtape_generic.get_parameter_value('PRIMARY_BP_ID')
			)
		  )
	      )
        and   xppa.report_type                  = 'KR_SEP'
        and   xpaa.tax_unit_id                  = hou.organization_id
        and   hou.organization_id               = hoi.organization_id
        and   hoi.org_information_context       = 'KR_BUSINESS_PLACE_REGISTRATION'
        and   hoi.org_information10             = phoi.org_information10
        and   phou.organization_id              = pay_magtape_generic.get_parameter_value('PRIMARY_BP_ID')
        and   phou.organization_id              = phoi.organization_id
        and   phoi.org_information_context      = 'KR_BUSINESS_PLACE_REGISTRATION'
        and   ihoi.org_information_context      = 'KR_INCOME_TAX_OFFICE'
	--Bug 5069923
	and   xppa.business_group_id            = pay_magtape_generic.get_parameter_value('BUSINESS_GROUP_ID')
        and   ihoi.organization_id              = hou.organization_id
        group by hoi.org_information10;

cursor c_sep_tax_header
is
SELECT      'CORP_PHONE_NUMBER=P'
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
           ,'REPORTED_DATE=P'
           ,fnd_date.date_to_canonical(pay_magtape_generic.get_parameter_value('REPORTED_DATE'))
           ,'CHARACTER_TYPE=P'
           ,'101'  character_type
           ,'REPORTING_PERIOD_P=P'
           ,'1' reporting_period
	   ,'HOME_TAX_ID=P'
	   ,nvl(pay_magtape_generic.get_parameter_value('HOME_TAX_ID'), ' ')
  FROM      hr_organization_information hoi
           ,hr_organization_information ihoi
           ,hr_organization_information choi
           ,hr_organization_units       hou
           ,hr_locations_all            hla
 WHERE     hou.organization_id               = pay_magtape_generic.get_parameter_value('PRIMARY_BP_ID')
  and      hou.organization_id               = hoi.organization_id
  and      hoi.org_information_context       = 'KR_BUSINESS_PLACE_REGISTRATION'
  and      hou.organization_id               = ihoi.organization_id
  and      ihoi.org_information_context      = 'KR_INCOME_TAX_OFFICE'
  and      choi.organization_id              = to_number(hoi.org_information10)
  and      choi.org_information_context      = 'KR_CORPORATE_INFORMATION'
  and      hla.location_id(+)                = hou.location_id
  and      hla.style(+)                      = 'KR'
  -- Bug 4272920
  and      hou.organization_id = (select xpaa.tax_unit_id
                  from  pay_assignment_actions      xpaa
                        ,pay_payroll_actions        xppa
                 where xppa.action_type             = 'X'
                 and   xppa.action_status           = 'C'
                 and   xppa.effective_date between  pay_magtape_generic.get_parameter_value('START_DATE')
                                               and  pay_magtape_generic.get_parameter_value('END_DATE')
                 and   xppa.payroll_action_id       = xpaa.payroll_action_id
		 --Bug 5069923
	  	 and   xppa.payroll_action_id 	    = nvl(pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID'),xpaa.payroll_action_id)    --Bug 5069923
		 --Bug 5069923
  		 and   (    (pay_magtape_generic.get_parameter_value('ASSIGNMENT_SET_ID') is null)
			 or (hr_assignment_set.assignment_in_set(pay_magtape_generic.get_parameter_value('ASSIGNMENT_SET_ID'), xpaa.assignment_id) = 'Y')
		       )
                 and   xpaa.action_status           = 'C'
                 and   xppa.report_type             = 'KR_SEP'
		 and   xppa.report_category 	    = 'KR_SEP'
		 and   xppa.report_qualifier	    = 'KR'
                 and   xpaa.tax_unit_id             = hou.organization_id
		 and   rownum 			    = 1
             );
  -- End of 4272920

cursor c_sep_tax_B
is
SELECT  distinct 'BP_NUMBER=P',
        hoi.org_information2,
        'TAX_OFFICE_CODE=P',
        ihoi.org_information9
FROM    pay_assignment_actions      xpaa
        ,pay_payroll_actions         xppa
        ,hr_organization_information hoi
        ,hr_organization_information ihoi
WHERE   xppa.action_type                        = 'X'
        and   xppa.action_status                = 'C'
        and   xppa.effective_date between
              -- Bug 4253329
              pay_magtape_generic.get_parameter_value('START_DATE')
              -- End of 4253329
        and   pay_magtape_generic.get_parameter_value('END_DATE')
        and   xppa.payroll_action_id            = xpaa.payroll_action_id
	--Bug 5069923
	and   xppa.payroll_action_id 		= nvl(pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID'),xpaa.payroll_action_id)
	--Bug 5069923
	and   (     (pay_magtape_generic.get_parameter_value('ASSIGNMENT_SET_ID') is null)
		 or (hr_assignment_set.assignment_in_set(pay_magtape_generic.get_parameter_value('ASSIGNMENT_SET_ID'), xpaa.assignment_id) = 'Y')
	      )
        and   xpaa.action_status                = 'C'
        and   xppa.report_type                  = 'KR_SEP'
	--Bug 5069923
        and   (     (pay_magtape_generic.get_parameter_value('REPORT_FOR')='A')
		 or (     (hoi.organization_id in ( select posev.ORGANIZATION_ID_child
						    from   PER_ORG_STRUCTURE_ELEMENTS posev
						    where  posev.org_structure_version_id=(pay_magtape_generic.get_parameter_value('ORG_STRUC_VERSION_ID'))
						           and exists (select null
								       from   hr_organization_information
								       where  organization_id = posev.ORGANIZATION_ID_child
									      and org_information_context = 'CLASS'
									      and org_information1 = 'KR_BUSINESS_PLACE'
								       )
							    start with ORGANIZATION_ID_PARENT = (decode(pay_magtape_generic.get_parameter_value('REPORT_FOR'),'S',null,'SUB',pay_magtape_generic.get_parameter_value('PRIMARY_BP_ID')))
							    connect by prior ORGANIZATION_ID_child = ORGANIZATION_ID_PARENT
						   )
			   )
         		or (hoi.organization_id = pay_magtape_generic.get_parameter_value('PRIMARY_BP_ID')
			   )
		     )
	      )
        and   hoi.organization_id               = xpaa.tax_unit_id
        and   hoi.org_information_context       = 'KR_BUSINESS_PLACE_REGISTRATION'
        and   hoi.organization_id               = ihoi.organization_id
        and   ihoi.org_information_context      = 'KR_INCOME_TAX_OFFICE'
        and   hoi.org_information10             = pay_magtape_generic.get_parameter_value('CORPORATION_ID')
        and   xppa.business_group_id            = pay_magtape_generic.get_parameter_value('BUSINESS_GROUP_ID')
        order by hoi.org_information2;

cursor c_sep_tax_B_summary
is
SELECT  'TOTAL_ITAX=P'
        ,SUM(decode(fue.user_entity_name,'A_GROSS_ITAX_ASG_RUN',fai.value,0)) ITAX
        ,'TOTAL_STAX=P'
        ,SUM(decode(fue.user_entity_name,'A_GROSS_STAX_ASG_RUN',fai.value,0)) STAX
        ,'TOTAL_RTAX=P'
        ,SUM(decode(fue.user_entity_name,'A_GROSS_RTAX_ASG_RUN',fai.value,0)) RTAX
        ,'TOTAL_TAX=P'
        ,SUM(decode(fue.user_entity_name ,'A_TAXABLE_EARNINGS_WI_PREV_ASG_RUN',  -- 5652360
             pay_kr_spay_efile_fun_pkg.get_sep_pay_amount(xpaa.assignment_action_id,fai.value),0))  TOTALTAX
        ,'EMPLOYEE_COUNT=P'
        ,sum(decode(decode(fue.user_entity_name ,'A_TAXABLE_EARNINGS_WI_PREV_ASG_RUN',
	pay_kr_spay_efile_fun_pkg.get_sep_pay_amount(xpaa.assignment_action_id,fai.value),0),0,0,1))  EMPCOUNT --Bug 9409509
        ,'PREV_EMP_COUNT=P'
        ,SUM(decode(fue.user_entity_name ,'X_KR_PREV_BP_NUMBER',1,0))  PREVEMPCOUNT
  FROM  pay_assignment_actions      xpaa
       ,pay_payroll_actions         xppa
       ,hr_organization_information hoi
       ,hr_organization_information ihoi
       ,hr_organization_units       hou
       ,ff_user_entities            fue
       ,ff_archive_items            fai
 WHERE   xppa.action_type                       = 'X'
  and   xppa.action_status                      = 'C'
  and   xppa.effective_date between
        -- Bug 4253329
        pay_magtape_generic.get_parameter_value('START_DATE')
        -- End of 4253329
  and   pay_magtape_generic.get_parameter_value('END_DATE')
  and   xppa.payroll_action_id                  = xpaa.payroll_action_id
  --Bug 5069923
  and   xppa.payroll_action_id 		        = nvl(pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID'),xpaa.payroll_action_id)
  and   xpaa.action_status                      = 'C'
  and   xppa.report_type                        = 'KR_SEP'
  and   hoi.organization_id                     = xpaa.tax_unit_id
  and   hoi.org_information_context             = 'KR_BUSINESS_PLACE_REGISTRATION'
  and   hoi.organization_id                     = ihoi.organization_id
  and   ihoi.org_information_context            = 'KR_INCOME_TAX_OFFICE'
  and   ihoi.org_information9                   = pay_magtape_generic.get_parameter_value('TAX_OFFICE_CODE')
  and   hoi.org_information2                    = pay_magtape_generic.get_parameter_value('BP_NUMBER')
  and   hoi.org_information10                   = pay_magtape_generic.get_parameter_value('CORPORATION_ID')
  and   hoi.organization_id                     = hou.organization_id
  and   hou.business_group_id                   = pay_magtape_generic.get_parameter_value('BUSINESS_GROUP_ID')
  and   fai.user_entity_id                      = fue.user_entity_id
  and   fue.user_entity_name                    IN ('A_GROSS_ITAX_ASG_RUN',
                                                    'A_GROSS_STAX_ASG_RUN',
                                                    'A_GROSS_RTAX_ASG_RUN',
                                                    'A_TAXABLE_EARNINGS_WI_PREV_ASG_RUN',
                                                    'X_KR_EMP_NAME',
                                                    'X_KR_PREV_BP_NUMBER')
  --Bug 5069923
  and	(    (pay_magtape_generic.get_parameter_value('ASSIGNMENT_SET_ID') is null)
          or (hr_assignment_set.assignment_in_set(pay_magtape_generic.get_parameter_value('ASSIGNMENT_SET_ID'), xpaa.assignment_id) = 'Y')
        )
  and   fai.context1= xpaa.assignment_action_id
-- 3627111
  and   not exists ( select 'x'
	                 from ff_user_entities            fue1
	                     ,ff_archive_items            fai1
	                 where fue1.user_entity_name      in ('A_NON_STAT_SEP_PAY_TAXABLE_EARNINGS_ASG_RUN','A_RECEIVABLE_NON_STAT_SEP_PAY_ASG_RUN')
	                 and fue1.legislation_code         = 'KR'
	                 and fai1.user_entity_id           = fue1.user_entity_id
	                 and fai1.context1                 = xpaa.assignment_action_id
	                 and fai1.value                    > '0' );


cursor c_sep_tax_B_detail
is
SELECT  'ASSIGNMENT_ACTION_ID=C'
        ,max(xpaa.assignment_action_id)
	,'REPORTING_PERIOD=P'
	,pay_magtape_generic.get_parameter_value('REPORTING_PERIOD')
FROM    pay_assignment_actions      xpaa
       ,pay_payroll_actions         xppa
       ,hr_organization_information hoi
       ,hr_organization_information ihoi
       ,hr_organization_units       hou
WHERE   xppa.action_type                        = 'X'
  and   xppa.action_status                      = 'C'
  and   xppa.effective_date between
        -- Bug 4253329
        pay_magtape_generic.get_parameter_value('START_DATE')
        -- End of 4253329
  and   pay_magtape_generic.get_parameter_value('END_DATE')
  and   xppa.payroll_action_id                  = xpaa.payroll_action_id
  --Bug 5069923
  and   xppa.payroll_action_id 		        = nvl(pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID'),xpaa.payroll_action_id)
  and   xpaa.action_status                      = 'C'
  and   xppa.report_type                        = 'KR_SEP'
  and   hoi.organization_id                     = xpaa.tax_unit_id
  and   hoi.org_information_context             = 'KR_BUSINESS_PLACE_REGISTRATION'
  and   hoi.organization_id                     = ihoi.organization_id
  --Bug 5069923
  and	(     (pay_magtape_generic.get_parameter_value('ASSIGNMENT_SET_ID') is null)
           or (hr_assignment_set.assignment_in_set(pay_magtape_generic.get_parameter_value('ASSIGNMENT_SET_ID'), xpaa.assignment_id) = 'Y')
        )
  and   ihoi.org_information_context            = 'KR_INCOME_TAX_OFFICE'
  and   ihoi.org_information9                   = pay_magtape_generic.get_parameter_value('TAX_OFFICE_CODE')
  and   hoi.org_information2                    = pay_magtape_generic.get_parameter_value('BP_NUMBER')
  and   hoi.org_information10                   = pay_magtape_generic.get_parameter_value('CORPORATION_ID')
  and   hoi.organization_id                     = hou.organization_id
  and   hou.business_group_id                   = pay_magtape_generic.get_parameter_value('BUSINESS_GROUP_ID');


cursor c_sep_tax_C
is
SELECT  'ASSIGNMENT_ACTION_ID=C'
       ,xpaa.assignment_action_id
       -- Bug 4253329
       ,'ASSIGNMENT_ACTION_ID=P'
       ,xpaa.assignment_action_id
       -- Bug 4253329
       ,'ASG_ID=P'
       ,xpaa.assignment_id
       ,'PREVIOUS_EMP_COUNT=P'
       ,nvl(pay_kr_spay_efile_fun_pkg.get_prev_emp_count(xpaa.assignment_action_id),0)
       ,'SRS_START_DATE=P'
       ,fnd_date.date_to_canonical(pay_magtape_generic.get_parameter_value('START_DATE'))
       ,'SRS_END_DATE=P'
       ,fnd_date.date_to_canonical(pay_magtape_generic.get_parameter_value('END_DATE'))
       -- Bug 4201616
       ,'RUN_TYPE_NAME=P'
       ,prt.run_type_name
       ,'PAYROLL_EFFECTIVE_DATE=P'
       ,fnd_date.date_to_canonical(ppa.effective_date)
       ,'BP_NUMBER=P'
       ,hoi.org_information2
       ,'CORP_NAME=P'
       ,hoi.org_information1
       -- End of 4201616
       ,fai.value
       -- Bug 4201616
FROM    pay_assignment_actions	    paa
       ,pay_payroll_actions 	    ppa
       ,pay_action_interlocks	    pai
       ,pay_run_types		    prt
       -- End of 4201616
       ,pay_assignment_actions      xpaa
       ,pay_payroll_actions         xppa
       ,hr_organization_information hoi
       ,hr_organization_information ihoi
       ,hr_organization_units       hou
       ,ff_user_entities            fue
       ,ff_archive_items            fai
WHERE    xppa.action_type                       = 'X'
and     xppa.action_status                      = 'C'
and     xppa.effective_date between
        -- Bug 4253329
        pay_magtape_generic.get_parameter_value('START_DATE')
        -- End of 4253329
and     pay_magtape_generic.get_parameter_value('END_DATE')
and     xppa.payroll_action_id                  = xpaa.payroll_action_id
--Bug 5069923
and     xppa.payroll_action_id 		        = nvl(pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID'),xpaa.payroll_action_id)
and     xpaa.action_status                      = 'C'
and     xppa.report_type                        = 'KR_SEP'
-- Bug 4201616
and 	paa.action_status 			= 'C'
and 	paa.source_action_id 			IS NOT NULL
and 	ppa.payroll_action_id 			= paa.payroll_action_id
and 	pai.locked_action_id			= paa.assignment_action_id
and 	xpaa.assignment_action_id 		= pai.locking_action_id
-- End of 4201616
and     hoi.organization_id                     = xpaa.tax_unit_id
and     hoi.org_information_context             = 'KR_BUSINESS_PLACE_REGISTRATION'
and     hoi.organization_id                     = ihoi.organization_id
and     ihoi.org_information_context            = 'KR_INCOME_TAX_OFFICE'
and     ihoi.org_information9                   = pay_magtape_generic.get_parameter_value('TAX_OFFICE_CODE')
and     hoi.org_information2                    = pay_magtape_generic.get_parameter_value('BP_NUMBER')
and     hoi.org_information10                   = pay_magtape_generic.get_parameter_value('CORPORATION_ID')
and     hoi.organization_id                     = hou.organization_id
--Bug 5069923
and	(     (pay_magtape_generic.get_parameter_value('ASSIGNMENT_SET_ID') is null)
           or (hr_assignment_set.assignment_in_set(pay_magtape_generic.get_parameter_value('ASSIGNMENT_SET_ID'), xpaa.assignment_id) = 'Y')
        )
and     hou.business_group_id                   = pay_magtape_generic.get_parameter_value('BUSINESS_GROUP_ID')
and     fue.user_entity_name                    in ('A_TAXABLE_EARNINGS_WI_PREV_ASG_RUN')
and     fai.user_entity_id                      = fue.user_entity_id
and     fai.context1                            = xpaa.assignment_action_id
and 	prt.run_type_id				= paa.run_type_id  -- Bug 4201616
-- 3627111
and     exists ( select 'x'
	                 from ff_user_entities            fue2
	                     ,ff_archive_items            fai2
	                 where fue2.user_entity_name       in ('A_TAXABLE_EARNINGS_WI_PREV_ASG_RUN','A_RECEIVABLE_SEPARATION_PAY_ASG_RUN')
	                 and fue2.legislation_code         = 'KR'
	                 and fai2.user_entity_id           = fue2.user_entity_id
	                 and fai2.context1                 = xpaa.assignment_action_id
	                 and fai2.value                    > '0' )
and     not exists ( select 'x'
	                 from ff_user_entities            fue1
	                     ,ff_archive_items            fai1
	                 where fue1.user_entity_name       in ('A_NON_STAT_SEP_PAY_TAXABLE_EARNINGS_ASG_RUN','A_RECEIVABLE_NON_STAT_SEP_PAY_ASG_RUN')
	                 and fue1.legislation_code         = 'KR'
	                 and fai1.user_entity_id           = fue1.user_entity_id
	                 and fai1.context1                 = xpaa.assignment_action_id
	                 and fai1.value                    > '0' )
order by fai.value;

cursor c_sep_tax_D
is
select
        'ELEMENT_ENTRY_ID=C',
        fac.context,
        fai.value
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

end pay_kr_spay_efile;

/
