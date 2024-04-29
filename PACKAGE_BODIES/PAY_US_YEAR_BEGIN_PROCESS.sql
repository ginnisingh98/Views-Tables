--------------------------------------------------------
--  DDL for Package Body PAY_US_YEAR_BEGIN_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_YEAR_BEGIN_PROCESS" AS
/* $Header: payusyearbegin.pkb 120.0.12010000.4 2010/01/08 06:41:59 parusia ship $ */
--
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1996 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_us_year_begin_process


    Change List
    -----------
     Date        Name      Vers    Bug No    Description
     ----        ----      ------  -------   -----------
     09-Nov-04  schauhan   115.0   3625425   Intial Version
     19-Dec-04  meshah     115.1   4132366   added a additional
                                             condition in updates
                                             of state and city tax
                                             records.
     06-Oct-09  emunisek   115.2   8985595   Added new parameter p_clr_wis_eic
                                             to the procedure reset_overrides
                                             to enable the "Clear Wisconsin EIC"
                                             in "Year Begin Process".An overloaded
                                             function was created with new parameter
                                             to maintain integrity of any other
                                             reference to this procedure.
                                             Added procedure wis_eic_ovr to clear
                                             the Wisconsin EIC through the Year
                                             Begin Process.
                                             The wis_eic_ovr is similar to wis_ind_ovr
                                             except that this will clear "EIC Filing Status"
                                             and "EIC Qualifying Children" for Wisconsin
                                             where as only "EIC Filing Status" was cleared
                                             for Indiana.
     8-Dec-09   parusia    115.3   9157658   Updated the last_update_date of the newly created
                                             record to represent the sysdate.
     8-Jan-10   parusia    115.4   9157658   Added WHO columns for sui_wb_ovr procedure
*/

PROCEDURE sui_wb_ovr
              (p_business_group in varchar2
	      ,p_curr_year         in varchar2
	      )
IS

cursor csr_get_asg(p_start_day DATE,
                   p_business_group varchar2) is
 select *
   from pay_us_emp_state_tax_rules_f pst
  where pst.sui_wage_base_override_amount is not null
   and p_start_day  between (pst.effective_start_date+1) and pst.effective_end_date
   and pst.business_group_id = to_number(p_business_group) ;

l_state_rec              PAY_US_EMP_STATE_TAX_RULES_F%rowtype;
l_last_day               DATE;
l_start_day              DATE;
l_last_year              VARCHAR2(4);
l_curr_year              VARCHAR2(4);

BEGIN
--hr_utility.trace_on(null,'oracle');
  /* Get the assignments which have non zero SUI WAGE BASE OVERRIDE AMOUNT */
  l_curr_year := p_curr_year;
  hr_utility.trace('l_curr_year '||l_curr_year);

  l_last_year := to_number(l_curr_year) - 1;

  hr_utility.trace('l_last_year '||l_last_year);

  l_last_day := to_date('12/31/'||l_last_year,'MM/DD/YYYY');
  l_start_day := to_date('01/01/'||l_curr_year,'MM/DD/YYYY');


  hr_utility.trace('l_last_day '||to_char(l_last_day));
  hr_utility.trace('l_start_day '||to_char(l_start_day));

  open csr_get_asg(l_start_day , p_business_group);

  hr_utility.trace('Updating the state tax records ...');

  loop

      fetch csr_get_asg into l_state_rec;

      exit when csr_get_asg%NOTFOUND;

      hr_utility.trace('Updating Assignment : ' ||
                            to_char(l_state_rec.assignment_id));
      hr_utility.trace(to_char(l_state_rec.emp_state_tax_rule_id));
      hr_utility.trace(to_char(l_state_rec.effective_end_date));
      hr_utility.trace(to_char( l_state_rec.assignment_id));
      hr_utility.trace(l_state_rec.state_code);
      hr_utility.trace(l_state_rec.jurisdiction_code);
      hr_utility.trace(to_char(l_state_rec.business_group_id));
      hr_utility.trace(to_char( l_state_rec.additional_wa_amount));
      hr_utility.trace( l_state_rec.filing_status_code);
      hr_utility.trace(to_char( l_state_rec.remainder_percent));
      hr_utility.trace(to_char( l_state_rec.secondary_wa));
      hr_utility.trace(to_char( l_state_rec.sit_additional_tax));
      hr_utility.trace(to_char( l_state_rec.sit_override_amount));
      hr_utility.trace(to_char( l_state_rec.sit_override_rate));
      hr_utility.trace(to_char( l_state_rec.withholding_allowances));

      /* End date the state tax record as of /12/31/(input year-1) */


      update PAY_US_EMP_STATE_TAX_RULES_F
      set    effective_end_date = l_last_day --to_date('12/31/'||end_year,'MM/DD/YYYY')
      where emp_state_tax_rule_id = l_state_rec.emp_state_tax_rule_id
      and   assignment_id        = l_state_rec.assignment_id
      and   effective_start_date = l_state_rec.effective_start_date
      and   effective_end_date   = l_state_rec.effective_end_date
      and   sui_wage_base_override_amount is not null;

      /* Null out the SUI WAGE BASE OVERRIDE AMOUNT as of 01/01/1999 */
      hr_utility.trace('Inserting Assignment : ' ||to_char(l_state_rec.assignment_id));

      hr_utility.trace('Inserting Assignment  Start Date : ' ||to_char(l_start_day));

      hr_utility.trace('Inserting Assignment  End Date : ' ||to_char(l_state_rec.effective_end_date));

      /*We need to reset INDIANA EIC Also */
/*     IF (l_state_rec.sta_information_category <> 'IN' AND l_state_rec.state_code <> '15') THEN
          l_ind_eic := l_state_rec.sta_information1;
      END IF;  will  write a new procedure for this too*/


      insert into PAY_US_EMP_STATE_TAX_RULES_F
      (emp_state_tax_rule_id,
      effective_start_date,
      effective_end_date,
      assignment_id,
      state_code,
      jurisdiction_code,
      business_group_id,
      additional_wa_amount,
      filing_status_code,
      remainder_percent,
      secondary_wa,
      sit_additional_tax,
      sit_override_amount,
      sit_override_rate,
      withholding_allowances,
      excessive_wa_reject_date,
      sdi_exempt,
      sit_exempt,
      sit_optional_calc_ind,
      state_non_resident_cert,
      sui_exempt,
      wc_exempt,
      sui_wage_base_override_amount,
      supp_tax_override_rate,
   	  last_update_date,
	  last_updated_by,
	  last_update_login,
	  created_by,
	  creation_date,
	  object_version_number)
     values
      (l_state_rec.emp_state_tax_rule_id,
      l_start_day,
      l_state_rec.effective_end_date,
      l_state_rec.assignment_id,
      l_state_rec.state_code,
      l_state_rec.jurisdiction_code,
      l_state_rec.business_group_id,
      l_state_rec.additional_wa_amount,
      l_state_rec.filing_status_code,
      l_state_rec.remainder_percent,
      l_state_rec.secondary_wa,
      l_state_rec.sit_additional_tax,
      l_state_rec.sit_override_amount,
      l_state_rec.sit_override_rate,
      l_state_rec.withholding_allowances,
      l_state_rec.excessive_wa_reject_date,
      l_state_rec.sdi_exempt,
      l_state_rec.sit_exempt,
      l_state_rec.sit_optional_calc_ind,
      l_state_rec.state_non_resident_cert,
      l_state_rec.sui_exempt,
      l_state_rec.wc_exempt,
      null,
      l_state_rec.supp_tax_override_rate,
      null                                       , -- bug 9157658
	  l_state_rec.last_updated_by,
	  l_state_rec.last_update_login,
	  l_state_rec.created_by,
	  l_state_rec.creation_date,
	  l_state_rec.object_version_number) ;

      hr_utility.trace('Updated Assignment : ' ||
                            to_char(l_state_rec.assignment_id));
  commit;
  end loop;
  close csr_get_asg;

END;


PROCEDURE ind_eic_ovr
              (p_business_group in varchar2
	      ,p_curr_year         in varchar2
	      )
IS

cursor csr_get_asg(p_start_day DATE,
                   p_business_group varchar2) is
 select *
   from pay_us_emp_state_tax_rules_f pst
  where pst.sta_information1 is not null
   and p_start_day  between (pst.effective_start_date+1) and pst.effective_end_date
   and sta_information_category = 'IN'
   and state_code = '15'
   and pst.business_group_id = to_number(p_business_group);

l_state_rec              PAY_US_EMP_STATE_TAX_RULES_F%rowtype;
l_last_day               DATE;
l_start_day              DATE;
l_last_year              VARCHAR2(4);
l_curr_year              VARCHAR2(4);

BEGIN
--hr_utility.trace_on(null,'oracle');
  /* Get the assignments which have non zero SUI WAGE BASE OVERRIDE AMOUNT */
  l_curr_year := p_curr_year;
  hr_utility.trace('l_curr_year '||l_curr_year);

  l_last_year := to_number(l_curr_year) - 1;

  hr_utility.trace('l_last_year '||l_last_year);

  l_last_day := to_date('12/31/'||l_last_year,'MM/DD/YYYY');
  l_start_day := to_date('01/01/'||l_curr_year,'MM/DD/YYYY');


  hr_utility.trace('l_last_day '||to_char(l_last_day));
  hr_utility.trace('l_start_day '||to_char(l_start_day));

  open csr_get_asg(l_start_day , p_business_group);

  hr_utility.trace('Updating the state tax records ...');

  loop

      fetch csr_get_asg into l_state_rec;

      exit when csr_get_asg%NOTFOUND;

      hr_utility.trace('Updating Assignment : ' ||
                            to_char(l_state_rec.assignment_id));
      hr_utility.trace(to_char(l_state_rec.emp_state_tax_rule_id));
      hr_utility.trace(to_char(l_state_rec.effective_end_date));
      hr_utility.trace(to_char( l_state_rec.assignment_id));
      hr_utility.trace(l_state_rec.state_code);
      hr_utility.trace(l_state_rec.jurisdiction_code);
      hr_utility.trace(to_char(l_state_rec.business_group_id));
      hr_utility.trace(to_char( l_state_rec.additional_wa_amount));
      hr_utility.trace( l_state_rec.filing_status_code);
      hr_utility.trace(to_char( l_state_rec.remainder_percent));
      hr_utility.trace(to_char( l_state_rec.secondary_wa));
      hr_utility.trace(to_char( l_state_rec.sit_additional_tax));
      hr_utility.trace(to_char( l_state_rec.sit_override_amount));
      hr_utility.trace(to_char( l_state_rec.sit_override_rate));
      hr_utility.trace(to_char( l_state_rec.withholding_allowances));

      /* End date the state tax record as of /12/31/(input year-1) */


      update PAY_US_EMP_STATE_TAX_RULES_F
      set    effective_end_date = l_last_day --to_date('12/31/'||end_year,'MM/DD/YYYY')
      where emp_state_tax_rule_id = l_state_rec.emp_state_tax_rule_id
      and   assignment_id        = l_state_rec.assignment_id
      and   effective_start_date = l_state_rec.effective_start_date
      and   effective_end_date   = l_state_rec.effective_end_date
      and   sta_information1 is not null;

      /* Null out the Indiana EIC as of 01/01/1999 */
      hr_utility.trace('Inserting Assignment : ' ||to_char(l_state_rec.assignment_id));

      hr_utility.trace('Inserting Assignment  Start Date : ' ||to_char(l_start_day));

      hr_utility.trace('Inserting Assignment  End Date : ' ||to_char(l_state_rec.effective_end_date));

      insert into PAY_US_EMP_STATE_TAX_RULES_F
	(
	EMP_STATE_TAX_RULE_ID,
	EFFECTIVE_START_DATE  ,
	EFFECTIVE_END_DATE     ,
	ASSIGNMENT_ID           ,
	STATE_CODE               ,
	JURISDICTION_CODE         ,
	BUSINESS_GROUP_ID          ,
	ADDITIONAL_WA_AMOUNT        ,
	FILING_STATUS_CODE           ,
	REMAINDER_PERCENT             ,
	SECONDARY_WA                   ,
	SIT_ADDITIONAL_TAX             ,
	SIT_OVERRIDE_AMOUNT            ,
	SIT_OVERRIDE_RATE              ,
	WITHHOLDING_ALLOWANCES         ,
	EXCESSIVE_WA_REJECT_DATE       ,
	SDI_EXEMPT                     ,
	SIT_EXEMPT                     ,
	SIT_OPTIONAL_CALC_IND          ,
	STATE_NON_RESIDENT_CERT        ,
	SUI_EXEMPT                     ,
	WC_EXEMPT                      ,
	SUI_WAGE_BASE_OVERRIDE_AMOUNT  ,
	SUPP_TAX_OVERRIDE_RATE         ,
	LAST_UPDATE_DATE               ,
	LAST_UPDATED_BY                ,
	LAST_UPDATE_LOGIN              ,
	CREATED_BY                     ,
	CREATION_DATE                  ,
	OBJECT_VERSION_NUMBER          ,
	ATTRIBUTE_CATEGORY             ,
	ATTRIBUTE1                     ,
	ATTRIBUTE2                     ,
	ATTRIBUTE3                     ,
	ATTRIBUTE4                     ,
	ATTRIBUTE5                     ,
	ATTRIBUTE6                     ,
	ATTRIBUTE7                     ,
	ATTRIBUTE8                     ,
	ATTRIBUTE9                     ,
	ATTRIBUTE10                    ,
	ATTRIBUTE11                    ,
	ATTRIBUTE12                    ,
	ATTRIBUTE13                    ,
	ATTRIBUTE14                    ,
	ATTRIBUTE15                    ,
	ATTRIBUTE16                    ,
	ATTRIBUTE17                    ,
	ATTRIBUTE18                    ,
	ATTRIBUTE19                    ,
	ATTRIBUTE20                    ,
	ATTRIBUTE21                    ,
	ATTRIBUTE22                    ,
	ATTRIBUTE23                    ,
	ATTRIBUTE24                    ,
	ATTRIBUTE25                    ,
	ATTRIBUTE26                    ,
	ATTRIBUTE27                    ,
	ATTRIBUTE28                    ,
	ATTRIBUTE29                    ,
	ATTRIBUTE30                    ,
	STA_INFORMATION_CATEGORY       ,
	STA_INFORMATION1               ,
	STA_INFORMATION2               ,
	STA_INFORMATION3               ,
	STA_INFORMATION4               ,
	STA_INFORMATION5               ,
	STA_INFORMATION6               ,
	STA_INFORMATION7               ,
	STA_INFORMATION8               ,
	STA_INFORMATION9               ,
	STA_INFORMATION10              ,
	STA_INFORMATION11              ,
	STA_INFORMATION12              ,
	STA_INFORMATION13              ,
	STA_INFORMATION14              ,
	STA_INFORMATION15              ,
	STA_INFORMATION16              ,
	STA_INFORMATION17              ,
	STA_INFORMATION18              ,
	STA_INFORMATION19              ,
	STA_INFORMATION20              ,
	STA_INFORMATION21              ,
	STA_INFORMATION22              ,
	STA_INFORMATION23              ,
	STA_INFORMATION24              ,
	STA_INFORMATION25              ,
	STA_INFORMATION26              ,
	STA_INFORMATION27              ,
	STA_INFORMATION28              ,
	STA_INFORMATION29              ,
	STA_INFORMATION30              )
     values
      (  l_state_rec.EMP_STATE_TAX_RULE_ID,
         l_start_day,
         l_state_rec.EFFECTIVE_END_DATE,
         l_state_rec.ASSIGNMENT_ID,
         l_state_rec.STATE_CODE               ,
	 l_state_rec.JURISDICTION_CODE         ,
	 l_state_rec.BUSINESS_GROUP_ID          ,
	 l_state_rec.ADDITIONAL_WA_AMOUNT        ,
	 l_state_rec.FILING_STATUS_CODE           ,
	 l_state_rec.REMAINDER_PERCENT             ,
	 l_state_rec.SECONDARY_WA                   ,
	 l_state_rec.SIT_ADDITIONAL_TAX             ,
	 l_state_rec.SIT_OVERRIDE_AMOUNT            ,
	 l_state_rec.SIT_OVERRIDE_RATE              ,
	 l_state_rec.WITHHOLDING_ALLOWANCES         ,
	 l_state_rec.EXCESSIVE_WA_REJECT_DATE       ,
	 l_state_rec.SDI_EXEMPT                     ,
	 l_state_rec.SIT_EXEMPT                     ,
	 l_state_rec.SIT_OPTIONAL_CALC_IND          ,
	 l_state_rec.STATE_NON_RESIDENT_CERT        ,
	 l_state_rec.SUI_EXEMPT                     ,
	 l_state_rec.WC_EXEMPT                      ,
	 l_state_rec.SUI_WAGE_BASE_OVERRIDE_AMOUNT  ,
	 l_state_rec.SUPP_TAX_OVERRIDE_RATE         ,
	 NULL                                       , -- Bug 9157658
	 l_state_rec.LAST_UPDATED_BY                ,
	 l_state_rec.LAST_UPDATE_LOGIN              ,
	 l_state_rec.CREATED_BY                     ,
	 l_state_rec.CREATION_DATE                  ,
	 l_state_rec.OBJECT_VERSION_NUMBER          ,
	 l_state_rec.ATTRIBUTE_CATEGORY             ,
	 l_state_rec.ATTRIBUTE1                     ,
	 l_state_rec.ATTRIBUTE2                     ,
	 l_state_rec.ATTRIBUTE3                     ,
	 l_state_rec.ATTRIBUTE4                     ,
	 l_state_rec.ATTRIBUTE5                     ,
	 l_state_rec.ATTRIBUTE6                     ,
	 l_state_rec.ATTRIBUTE7                     ,
	 l_state_rec.ATTRIBUTE8                     ,
	 l_state_rec.ATTRIBUTE9                     ,
	 l_state_rec.ATTRIBUTE10                    ,
	 l_state_rec.ATTRIBUTE11                    ,
	 l_state_rec.ATTRIBUTE12                    ,
	 l_state_rec.ATTRIBUTE13                    ,
	 l_state_rec.ATTRIBUTE14                    ,
	 l_state_rec.ATTRIBUTE15                    ,
	 l_state_rec.ATTRIBUTE16                    ,
	 l_state_rec.ATTRIBUTE17                    ,
	 l_state_rec.ATTRIBUTE18                    ,
	 l_state_rec.ATTRIBUTE19                    ,
	 l_state_rec.ATTRIBUTE20                    ,
	 l_state_rec.ATTRIBUTE21                    ,
	 l_state_rec.ATTRIBUTE22                    ,
	 l_state_rec.ATTRIBUTE23                    ,
	 l_state_rec.ATTRIBUTE24                    ,
	 l_state_rec.ATTRIBUTE25                    ,
	 l_state_rec.ATTRIBUTE26                    ,
	 l_state_rec.ATTRIBUTE27                    ,
	 l_state_rec.ATTRIBUTE28                    ,
	 l_state_rec.ATTRIBUTE29                    ,
	 l_state_rec.ATTRIBUTE30                    ,
	 l_state_rec.STA_INFORMATION_CATEGORY       ,
	 NULL                           ,
	 l_state_rec.STA_INFORMATION2               ,
	 l_state_rec.STA_INFORMATION3               ,
	 l_state_rec.STA_INFORMATION4               ,
	 l_state_rec.STA_INFORMATION5               ,
	 l_state_rec.STA_INFORMATION6               ,
	 l_state_rec.STA_INFORMATION7               ,
	 l_state_rec.STA_INFORMATION8               ,
	 l_state_rec.STA_INFORMATION9               ,
	 l_state_rec.STA_INFORMATION10              ,
	 l_state_rec.STA_INFORMATION11              ,
	 l_state_rec.STA_INFORMATION12              ,
	 l_state_rec.STA_INFORMATION13              ,
	 l_state_rec.STA_INFORMATION14              ,
	 l_state_rec.STA_INFORMATION15              ,
	 l_state_rec.STA_INFORMATION16              ,
	 l_state_rec.STA_INFORMATION17              ,
	 l_state_rec.STA_INFORMATION18              ,
	 l_state_rec.STA_INFORMATION19              ,
	 l_state_rec.STA_INFORMATION20              ,
	 l_state_rec.STA_INFORMATION21              ,
	 l_state_rec.STA_INFORMATION22              ,
	 l_state_rec.STA_INFORMATION23              ,
	 l_state_rec.STA_INFORMATION24              ,
	 l_state_rec.STA_INFORMATION25              ,
	 l_state_rec.STA_INFORMATION26              ,
	 l_state_rec.STA_INFORMATION27              ,
	 l_state_rec.STA_INFORMATION28              ,
	 l_state_rec.STA_INFORMATION29              ,
	 l_state_rec.STA_INFORMATION30              ) ;

      hr_utility.trace('Updated Assignment : ' ||
                            to_char(l_state_rec.assignment_id));
  commit;
  end loop;
  close csr_get_asg;

END;

PROCEDURE wis_eic_ovr
              (p_business_group in varchar2
	      ,p_curr_year         in varchar2
	      )
IS

cursor csr_get_asg(p_start_day DATE,
                   p_business_group varchar2) is
 select *
   from pay_us_emp_state_tax_rules_f pst
  where (pst.sta_information1 is not null
   or pst.sta_information6 is not null)
   and p_start_day  between (pst.effective_start_date+1) and pst.effective_end_date
   and sta_information_category = 'WI'
   and state_code = '50'
   and pst.business_group_id = to_number(p_business_group);

l_state_rec              PAY_US_EMP_STATE_TAX_RULES_F%rowtype;
l_last_day               DATE;
l_start_day              DATE;
l_last_year              VARCHAR2(4);
l_curr_year              VARCHAR2(4);

BEGIN
--hr_utility.trace_on(null,'oracle');
  /* Get the assignments which have State EIC as not null */
  l_curr_year := p_curr_year;
  hr_utility.trace('l_curr_year '||l_curr_year);

  l_last_year := to_number(l_curr_year) - 1;

  hr_utility.trace('l_last_year '||l_last_year);

  l_last_day := to_date('12/31/'||l_last_year,'MM/DD/YYYY');
  l_start_day := to_date('01/01/'||l_curr_year,'MM/DD/YYYY');


  hr_utility.trace('l_last_day '||to_char(l_last_day));
  hr_utility.trace('l_start_day '||to_char(l_start_day));

  open csr_get_asg(l_start_day , p_business_group);

  hr_utility.trace('Updating the state tax records ...');

  loop

      fetch csr_get_asg into l_state_rec;

      exit when csr_get_asg%NOTFOUND;

      hr_utility.trace('Updating Assignment : ' ||
                            to_char(l_state_rec.assignment_id));
      hr_utility.trace(to_char(l_state_rec.emp_state_tax_rule_id));
      hr_utility.trace(to_char(l_state_rec.effective_end_date));
      hr_utility.trace(to_char( l_state_rec.assignment_id));
      hr_utility.trace(l_state_rec.state_code);
      hr_utility.trace(l_state_rec.jurisdiction_code);
      hr_utility.trace(to_char(l_state_rec.business_group_id));
      hr_utility.trace(to_char( l_state_rec.additional_wa_amount));
      hr_utility.trace( l_state_rec.filing_status_code);
      hr_utility.trace(to_char( l_state_rec.remainder_percent));
      hr_utility.trace(to_char( l_state_rec.secondary_wa));
      hr_utility.trace(to_char( l_state_rec.sit_additional_tax));
      hr_utility.trace(to_char( l_state_rec.sit_override_amount));
      hr_utility.trace(to_char( l_state_rec.sit_override_rate));
      hr_utility.trace(to_char( l_state_rec.withholding_allowances));

      /* End date the state tax record as of /12/31/(input year-1) */


      update PAY_US_EMP_STATE_TAX_RULES_F
      set    effective_end_date = l_last_day --to_date('12/31/'||end_year,'MM/DD/YYYY')
      where emp_state_tax_rule_id = l_state_rec.emp_state_tax_rule_id
      and   assignment_id        = l_state_rec.assignment_id
      and   effective_start_date = l_state_rec.effective_start_date
      and   effective_end_date   = l_state_rec.effective_end_date
      and   sta_information1 is not null;

      /* Null out the Wisconsin EIC as of 01/01/1999 */
      hr_utility.trace('Inserting Assignment : ' ||to_char(l_state_rec.assignment_id));

      hr_utility.trace('Inserting Assignment  Start Date : ' ||to_char(l_start_day));

      hr_utility.trace('Inserting Assignment  End Date : ' ||to_char(l_state_rec.effective_end_date));

      insert into PAY_US_EMP_STATE_TAX_RULES_F
	(
	EMP_STATE_TAX_RULE_ID,
	EFFECTIVE_START_DATE  ,
	EFFECTIVE_END_DATE     ,
	ASSIGNMENT_ID           ,
	STATE_CODE               ,
	JURISDICTION_CODE         ,
	BUSINESS_GROUP_ID          ,
	ADDITIONAL_WA_AMOUNT        ,
	FILING_STATUS_CODE           ,
	REMAINDER_PERCENT             ,
	SECONDARY_WA                   ,
	SIT_ADDITIONAL_TAX             ,
	SIT_OVERRIDE_AMOUNT            ,
	SIT_OVERRIDE_RATE              ,
	WITHHOLDING_ALLOWANCES         ,
	EXCESSIVE_WA_REJECT_DATE       ,
	SDI_EXEMPT                     ,
	SIT_EXEMPT                     ,
	SIT_OPTIONAL_CALC_IND          ,
	STATE_NON_RESIDENT_CERT        ,
	SUI_EXEMPT                     ,
	WC_EXEMPT                      ,
	SUI_WAGE_BASE_OVERRIDE_AMOUNT  ,
	SUPP_TAX_OVERRIDE_RATE         ,
	LAST_UPDATE_DATE               ,
	LAST_UPDATED_BY                ,
	LAST_UPDATE_LOGIN              ,
	CREATED_BY                     ,
	CREATION_DATE                  ,
	OBJECT_VERSION_NUMBER          ,
	ATTRIBUTE_CATEGORY             ,
	ATTRIBUTE1                     ,
	ATTRIBUTE2                     ,
	ATTRIBUTE3                     ,
	ATTRIBUTE4                     ,
	ATTRIBUTE5                     ,
	ATTRIBUTE6                     ,
	ATTRIBUTE7                     ,
	ATTRIBUTE8                     ,
	ATTRIBUTE9                     ,
	ATTRIBUTE10                    ,
	ATTRIBUTE11                    ,
	ATTRIBUTE12                    ,
	ATTRIBUTE13                    ,
	ATTRIBUTE14                    ,
	ATTRIBUTE15                    ,
	ATTRIBUTE16                    ,
	ATTRIBUTE17                    ,
	ATTRIBUTE18                    ,
	ATTRIBUTE19                    ,
	ATTRIBUTE20                    ,
	ATTRIBUTE21                    ,
	ATTRIBUTE22                    ,
	ATTRIBUTE23                    ,
	ATTRIBUTE24                    ,
	ATTRIBUTE25                    ,
	ATTRIBUTE26                    ,
	ATTRIBUTE27                    ,
	ATTRIBUTE28                    ,
	ATTRIBUTE29                    ,
	ATTRIBUTE30                    ,
	STA_INFORMATION_CATEGORY       ,
	STA_INFORMATION1               ,
	STA_INFORMATION2               ,
	STA_INFORMATION3               ,
	STA_INFORMATION4               ,
	STA_INFORMATION5               ,
	STA_INFORMATION6               ,
	STA_INFORMATION7               ,
	STA_INFORMATION8               ,
	STA_INFORMATION9               ,
	STA_INFORMATION10              ,
	STA_INFORMATION11              ,
	STA_INFORMATION12              ,
	STA_INFORMATION13              ,
	STA_INFORMATION14              ,
	STA_INFORMATION15              ,
	STA_INFORMATION16              ,
	STA_INFORMATION17              ,
	STA_INFORMATION18              ,
	STA_INFORMATION19              ,
	STA_INFORMATION20              ,
	STA_INFORMATION21              ,
	STA_INFORMATION22              ,
	STA_INFORMATION23              ,
	STA_INFORMATION24              ,
	STA_INFORMATION25              ,
	STA_INFORMATION26              ,
	STA_INFORMATION27              ,
	STA_INFORMATION28              ,
	STA_INFORMATION29              ,
	STA_INFORMATION30              )
     values
      (  l_state_rec.EMP_STATE_TAX_RULE_ID,
         l_start_day,
         l_state_rec.EFFECTIVE_END_DATE,
         l_state_rec.ASSIGNMENT_ID,
         l_state_rec.STATE_CODE               ,
	 l_state_rec.JURISDICTION_CODE         ,
	 l_state_rec.BUSINESS_GROUP_ID          ,
	 l_state_rec.ADDITIONAL_WA_AMOUNT        ,
	 l_state_rec.FILING_STATUS_CODE           ,
	 l_state_rec.REMAINDER_PERCENT             ,
	 l_state_rec.SECONDARY_WA                   ,
	 l_state_rec.SIT_ADDITIONAL_TAX             ,
	 l_state_rec.SIT_OVERRIDE_AMOUNT            ,
	 l_state_rec.SIT_OVERRIDE_RATE              ,
	 l_state_rec.WITHHOLDING_ALLOWANCES         ,
	 l_state_rec.EXCESSIVE_WA_REJECT_DATE       ,
	 l_state_rec.SDI_EXEMPT                     ,
	 l_state_rec.SIT_EXEMPT                     ,
	 l_state_rec.SIT_OPTIONAL_CALC_IND          ,
	 l_state_rec.STATE_NON_RESIDENT_CERT        ,
	 l_state_rec.SUI_EXEMPT                     ,
	 l_state_rec.WC_EXEMPT                      ,
	 l_state_rec.SUI_WAGE_BASE_OVERRIDE_AMOUNT  ,
	 l_state_rec.SUPP_TAX_OVERRIDE_RATE         ,
	 NULL                                       , -- Bug 9157658
	 l_state_rec.LAST_UPDATED_BY                ,
	 l_state_rec.LAST_UPDATE_LOGIN              ,
	 l_state_rec.CREATED_BY                     ,
	 l_state_rec.CREATION_DATE                  ,
	 l_state_rec.OBJECT_VERSION_NUMBER          ,
	 l_state_rec.ATTRIBUTE_CATEGORY             ,
	 l_state_rec.ATTRIBUTE1                     ,
	 l_state_rec.ATTRIBUTE2                     ,
	 l_state_rec.ATTRIBUTE3                     ,
	 l_state_rec.ATTRIBUTE4                     ,
	 l_state_rec.ATTRIBUTE5                     ,
	 l_state_rec.ATTRIBUTE6                     ,
	 l_state_rec.ATTRIBUTE7                     ,
	 l_state_rec.ATTRIBUTE8                     ,
	 l_state_rec.ATTRIBUTE9                     ,
	 l_state_rec.ATTRIBUTE10                    ,
	 l_state_rec.ATTRIBUTE11                    ,
	 l_state_rec.ATTRIBUTE12                    ,
	 l_state_rec.ATTRIBUTE13                    ,
	 l_state_rec.ATTRIBUTE14                    ,
	 l_state_rec.ATTRIBUTE15                    ,
	 l_state_rec.ATTRIBUTE16                    ,
	 l_state_rec.ATTRIBUTE17                    ,
	 l_state_rec.ATTRIBUTE18                    ,
	 l_state_rec.ATTRIBUTE19                    ,
	 l_state_rec.ATTRIBUTE20                    ,
	 l_state_rec.ATTRIBUTE21                    ,
	 l_state_rec.ATTRIBUTE22                    ,
	 l_state_rec.ATTRIBUTE23                    ,
	 l_state_rec.ATTRIBUTE24                    ,
	 l_state_rec.ATTRIBUTE25                    ,
	 l_state_rec.ATTRIBUTE26                    ,
	 l_state_rec.ATTRIBUTE27                    ,
	 l_state_rec.ATTRIBUTE28                    ,
	 l_state_rec.ATTRIBUTE29                    ,
	 l_state_rec.ATTRIBUTE30                    ,
	 l_state_rec.STA_INFORMATION_CATEGORY       ,
	 NULL                           ,
	 l_state_rec.STA_INFORMATION2               ,
	 l_state_rec.STA_INFORMATION3               ,
	 l_state_rec.STA_INFORMATION4               ,
	 l_state_rec.STA_INFORMATION5               ,
	 NULL                                       ,
	 l_state_rec.STA_INFORMATION7               ,
	 l_state_rec.STA_INFORMATION8               ,
	 l_state_rec.STA_INFORMATION9               ,
	 l_state_rec.STA_INFORMATION10              ,
	 l_state_rec.STA_INFORMATION11              ,
	 l_state_rec.STA_INFORMATION12              ,
	 l_state_rec.STA_INFORMATION13              ,
	 l_state_rec.STA_INFORMATION14              ,
	 l_state_rec.STA_INFORMATION15              ,
	 l_state_rec.STA_INFORMATION16              ,
	 l_state_rec.STA_INFORMATION17              ,
	 l_state_rec.STA_INFORMATION18              ,
	 l_state_rec.STA_INFORMATION19              ,
	 l_state_rec.STA_INFORMATION20              ,
	 l_state_rec.STA_INFORMATION21              ,
	 l_state_rec.STA_INFORMATION22              ,
	 l_state_rec.STA_INFORMATION23              ,
	 l_state_rec.STA_INFORMATION24              ,
	 l_state_rec.STA_INFORMATION25              ,
	 l_state_rec.STA_INFORMATION26              ,
	 l_state_rec.STA_INFORMATION27              ,
	 l_state_rec.STA_INFORMATION28              ,
	 l_state_rec.STA_INFORMATION29              ,
	 l_state_rec.STA_INFORMATION30              ) ;

      hr_utility.trace('Updated Assignment : ' ||
                            to_char(l_state_rec.assignment_id));
  commit;
  end loop;
  close csr_get_asg;

END;

PROCEDURE pa_head_tx_ovr
              (p_business_group in varchar2
	      ,p_curr_year         in varchar2
	      )
IS

cursor csr_get_asg(p_start_day DATE,
		   p_business_group varchar2) is
 select pct.*
   from pay_us_emp_city_tax_rules_f pct,
        pay_state_rules psr,
        pay_us_states pus
  where psr.head_tax_period = 'A'
    and psr.state_code = pus.state_abbrev
    and pus.state_code = pct.state_code
    and pct.ht_exempt is not null
    and p_start_day between (pct.effective_start_date+1) and pct.effective_end_date
    and pct.business_group_id = to_number(p_business_group) ;


l_city_rec              PAY_US_EMP_CITY_TAX_RULES_F%rowtype;
l_last_day               DATE;
l_start_day              DATE;
l_last_year              VARCHAR2(4);
l_curr_year              VARCHAR2(4);

BEGIN
--hr_utility.trace_on(null,'oracle');
  /* Get the assignments which have PA head Tax Exemption */
  l_curr_year := p_curr_year;
  hr_utility.trace('l_curr_year '||l_curr_year);

  l_last_year := to_number(l_curr_year) - 1;

  hr_utility.trace('l_last_year '||l_last_year);

  l_last_day := to_date('12/31/'||l_last_year,'MM/DD/YYYY');
  l_start_day := to_date('01/01/'||l_curr_year,'MM/DD/YYYY');


  hr_utility.trace('l_last_day '||to_char(l_last_day));
  hr_utility.trace('l_start_day '||to_char(l_start_day));

  open csr_get_asg(l_start_day , p_business_group);

  hr_utility.trace('Updating the city tax records ...');

  loop

      fetch csr_get_asg into l_city_rec;

      exit when csr_get_asg%NOTFOUND;

     /* End date the city tax record as of /12/31/(input year-1) */


      update PAY_US_EMP_CITY_TAX_RULES_F
      set    effective_end_date = l_last_day --to_date('12/31/'||end_year,'MM/DD/YYYY')
      where emp_city_tax_rule_id = l_city_rec.emp_city_tax_rule_id
      and   assignment_id        = l_city_rec.assignment_id
      and   effective_start_date = l_city_rec.effective_start_date
      and   effective_end_date   = l_city_rec.effective_end_date
      and   ht_exempt is not null;

      /* Null out the PA Head Tax exemption as of 01/01/1999 */
      hr_utility.trace('Inserting Assignment : ' ||to_char(l_city_rec.assignment_id));

      hr_utility.trace('Inserting Assignment  Start Date : ' ||to_char(l_start_day));

      hr_utility.trace('Inserting Assignment  End Date : ' ||to_char(l_city_rec.effective_end_date));



		 insert into PAY_US_EMP_CITY_TAX_RULES_F
		 (
		 EMP_CITY_TAX_RULE_ID,
		 EFFECTIVE_START_DATE,
		 EFFECTIVE_END_DATE   ,
		 ASSIGNMENT_ID         ,
		 STATE_CODE             ,
		 COUNTY_CODE             ,
		 CITY_CODE                ,
		 BUSINESS_GROUP_ID        ,
		 ADDITIONAL_WA_RATE       ,
		 FILING_STATUS_CODE       ,
		 JURISDICTION_CODE        ,
		 LIT_ADDITIONAL_TAX       ,
		 LIT_OVERRIDE_AMOUNT      ,
		 LIT_OVERRIDE_RATE        ,
		 WITHHOLDING_ALLOWANCES   ,
		 LIT_EXEMPT               ,
		 SD_EXEMPT                ,
		 HT_EXEMPT                ,
		 SCHOOL_DISTRICT_CODE     ,
		 LAST_UPDATE_DATE         ,
		 LAST_UPDATED_BY          ,
		 LAST_UPDATE_LOGIN        ,
		 CREATED_BY               ,
		 CREATION_DATE            ,
		 OBJECT_VERSION_NUMBER    ,
		 ATTRIBUTE_CATEGORY       ,
		 ATTRIBUTE1               ,
		 ATTRIBUTE2               ,
		 ATTRIBUTE3               ,
		 ATTRIBUTE4               ,
		 ATTRIBUTE5               ,
		 ATTRIBUTE6               ,
		 ATTRIBUTE7               ,
		 ATTRIBUTE8               ,
		 ATTRIBUTE9               ,
		 ATTRIBUTE10              ,
		 ATTRIBUTE11              ,
		 ATTRIBUTE12              ,
		 ATTRIBUTE13              ,
		 ATTRIBUTE14              ,
		 ATTRIBUTE15              ,
		 ATTRIBUTE16              ,
		 ATTRIBUTE17              ,
		 ATTRIBUTE18              ,
		 ATTRIBUTE19              ,
		 ATTRIBUTE20              ,
		 ATTRIBUTE21              ,
		 ATTRIBUTE22              ,
		 ATTRIBUTE23              ,
		 ATTRIBUTE24              ,
		 ATTRIBUTE25              ,
		 ATTRIBUTE26              ,
		 ATTRIBUTE27              ,
		 ATTRIBUTE28              ,
		 ATTRIBUTE29              ,
		 ATTRIBUTE30              ,
		 CTY_INFORMATION_CATEGORY ,
		 CTY_INFORMATION1         ,
		 CTY_INFORMATION2         ,
		 CTY_INFORMATION3         ,
		 CTY_INFORMATION4         ,
		 CTY_INFORMATION5         ,
		 CTY_INFORMATION6         ,
		 CTY_INFORMATION7         ,
		 CTY_INFORMATION8         ,
		 CTY_INFORMATION9         ,
		 CTY_INFORMATION10        ,
		 CTY_INFORMATION11        ,
		 CTY_INFORMATION12        ,
		 CTY_INFORMATION13        ,
		 CTY_INFORMATION14        ,
		 CTY_INFORMATION15        ,
		 CTY_INFORMATION16        ,
		 CTY_INFORMATION17        ,
		 CTY_INFORMATION18        ,
		 CTY_INFORMATION19        ,
		 CTY_INFORMATION20        ,
		 CTY_INFORMATION21        ,
		 CTY_INFORMATION22        ,
		 CTY_INFORMATION23        ,
		 CTY_INFORMATION24        ,
		 CTY_INFORMATION25        ,
		 CTY_INFORMATION26        ,
		 CTY_INFORMATION27        ,
		 CTY_INFORMATION28        ,
		 CTY_INFORMATION29        ,
		 CTY_INFORMATION30
		 )
		 values
		 (
		 l_city_rec.emp_city_tax_rule_id,
		 l_start_day,
		 l_city_rec.effective_end_date,
		 l_city_rec.ASSIGNMENT_ID         ,
		 l_city_rec.STATE_CODE             ,
		 l_city_rec.COUNTY_CODE             ,
		 l_city_rec.CITY_CODE                ,
		 l_city_rec.BUSINESS_GROUP_ID        ,
		 l_city_rec.ADDITIONAL_WA_RATE       ,
		 l_city_rec.FILING_STATUS_CODE       ,
		 l_city_rec.JURISDICTION_CODE        ,
		 l_city_rec.LIT_ADDITIONAL_TAX       ,
		 l_city_rec.LIT_OVERRIDE_AMOUNT      ,
		 l_city_rec.LIT_OVERRIDE_RATE        ,
		 l_city_rec.WITHHOLDING_ALLOWANCES   ,
		 l_city_rec.LIT_EXEMPT               ,
		 l_city_rec.SD_EXEMPT                ,
		 NULL                                ,
		 l_city_rec.SCHOOL_DISTRICT_CODE     ,
        	 NULL                                , -- Bug 9157658
		 l_city_rec.LAST_UPDATED_BY          ,
		 l_city_rec.LAST_UPDATE_LOGIN        ,
		 l_city_rec.CREATED_BY               ,
		 l_city_rec.CREATION_DATE            ,
		 l_city_rec.OBJECT_VERSION_NUMBER    ,
		 l_city_rec.ATTRIBUTE_CATEGORY       ,
		 l_city_rec.ATTRIBUTE1               ,
		 l_city_rec.ATTRIBUTE2               ,
		 l_city_rec.ATTRIBUTE3               ,
		 l_city_rec.ATTRIBUTE4               ,
		 l_city_rec.ATTRIBUTE5               ,
		 l_city_rec.ATTRIBUTE6               ,
		 l_city_rec.ATTRIBUTE7               ,
		 l_city_rec.ATTRIBUTE8               ,
		 l_city_rec.ATTRIBUTE9               ,
		 l_city_rec.ATTRIBUTE10              ,
		 l_city_rec.ATTRIBUTE11              ,
		 l_city_rec.ATTRIBUTE12              ,
		 l_city_rec.ATTRIBUTE13              ,
		 l_city_rec.ATTRIBUTE14              ,
		 l_city_rec.ATTRIBUTE15              ,
		 l_city_rec.ATTRIBUTE16              ,
		 l_city_rec.ATTRIBUTE17              ,
		 l_city_rec.ATTRIBUTE18              ,
		 l_city_rec.ATTRIBUTE19              ,
		 l_city_rec.ATTRIBUTE20              ,
		 l_city_rec.ATTRIBUTE21              ,
		 l_city_rec.ATTRIBUTE22              ,
		 l_city_rec.ATTRIBUTE23              ,
		 l_city_rec.ATTRIBUTE24              ,
		 l_city_rec.ATTRIBUTE25              ,
		 l_city_rec.ATTRIBUTE26              ,
		 l_city_rec.ATTRIBUTE27              ,
		 l_city_rec.ATTRIBUTE28              ,
		 l_city_rec.ATTRIBUTE29              ,
		 l_city_rec.ATTRIBUTE30              ,
		 l_city_rec.CTY_INFORMATION_CATEGORY ,
		 l_city_rec.CTY_INFORMATION1         ,
		 l_city_rec.CTY_INFORMATION2         ,
		 l_city_rec.CTY_INFORMATION3         ,
		 l_city_rec.CTY_INFORMATION4         ,
		 l_city_rec.CTY_INFORMATION5         ,
		 l_city_rec.CTY_INFORMATION6         ,
		 l_city_rec.CTY_INFORMATION7         ,
		 l_city_rec.CTY_INFORMATION8         ,
		 l_city_rec.CTY_INFORMATION9         ,
		 l_city_rec.CTY_INFORMATION10        ,
		 l_city_rec.CTY_INFORMATION11        ,
		 l_city_rec.CTY_INFORMATION12        ,
		 l_city_rec.CTY_INFORMATION13        ,
		 l_city_rec.CTY_INFORMATION14        ,
		 l_city_rec.CTY_INFORMATION15        ,
		 l_city_rec.CTY_INFORMATION16        ,
		 l_city_rec.CTY_INFORMATION17        ,
		 l_city_rec.CTY_INFORMATION18        ,
		 l_city_rec.CTY_INFORMATION19        ,
		 l_city_rec.CTY_INFORMATION20        ,
		 l_city_rec.CTY_INFORMATION21        ,
		 l_city_rec.CTY_INFORMATION22        ,
		 l_city_rec.CTY_INFORMATION23        ,
		 l_city_rec.CTY_INFORMATION24        ,
		 l_city_rec.CTY_INFORMATION25        ,
		 l_city_rec.CTY_INFORMATION26        ,
		 l_city_rec.CTY_INFORMATION27        ,
		 l_city_rec.CTY_INFORMATION28        ,
		 l_city_rec.CTY_INFORMATION29        ,
		 l_city_rec.CTY_INFORMATION30
		 );


      hr_utility.trace('Updated Assignment : ' ||
                            to_char(l_city_rec.assignment_id));
  commit;
  end loop;
  close csr_get_asg;

END;



PROCEDURE fed_eic_filing_status_ovr
              (p_business_group in varchar2
	      ,p_curr_year         in varchar2
	      )
IS

cursor csr_get_asg(p_start_day DATE,
		   p_business_group varchar2) is
 select *
  from pay_us_emp_fed_tax_rules_f pft
 where pft.eic_filing_status_code <> 0
  and  p_start_day between (pft.effective_start_date+1) and pft.effective_end_date
  and  pft.business_group_id = to_number(p_business_group);


l_fed_rec              PAY_US_EMP_FED_TAX_RULES_F%rowtype;
l_last_day               DATE;
l_start_day              DATE;
l_last_year              VARCHAR2(4);
l_curr_year              VARCHAR2(4);

BEGIN
--hr_utility.trace_on(null,'oracle');
  /* Get the assignments which have Fed EIC  */
  l_curr_year := p_curr_year;
  hr_utility.trace('l_curr_year '||l_curr_year);

  l_last_year := to_number(l_curr_year) - 1;

  hr_utility.trace('l_last_year '||l_last_year);

  l_last_day := to_date('12/31/'||l_last_year,'MM/DD/YYYY');
  l_start_day := to_date('01/01/'||l_curr_year,'MM/DD/YYYY');


  hr_utility.trace('l_last_day '||to_char(l_last_day));
  hr_utility.trace('l_start_day '||to_char(l_start_day));

  open csr_get_asg(l_start_day , p_business_group);

  hr_utility.trace('Updating the fed tax records ...');

  loop

      fetch csr_get_asg into l_fed_rec;

      exit when csr_get_asg%NOTFOUND;

     /* End date the fed tax record as of /12/31/(input year-1) */


      update PAY_US_EMP_FED_TAX_RULES_F
      set    effective_end_date = l_last_day --to_date('12/31/'||end_year,'MM/DD/YYYY')
      where assignment_id        = l_fed_rec.assignment_id
      and   effective_start_date = l_fed_rec.effective_start_date
      and   effective_end_date   = l_fed_rec.effective_end_date
      and   eic_filing_status_code <> 0;

      /* Null out the FED EIC of 01/01/1999 */
      hr_utility.trace('Inserting Assignment : ' ||to_char(l_fed_rec.assignment_id));

      hr_utility.trace('Inserting Assignment  Start Date : ' ||to_char(l_start_day));

      hr_utility.trace('Inserting Assignment  End Date : ' ||to_char(l_fed_rec.effective_end_date));



/* Insert Stmt for FED Tax Rules will come here */
      insert into pay_us_emp_fed_tax_rules_f
      (
	   EMP_FED_TAX_RULE_ID   ,
	   EFFECTIVE_START_DATE   ,
	   EFFECTIVE_END_DATE      ,
	   ASSIGNMENT_ID            ,
	   SUI_STATE_CODE            ,
	   SUI_JURISDICTION_CODE     ,
	   BUSINESS_GROUP_ID         ,
	   ADDITIONAL_WA_AMOUNT      ,
	   FILING_STATUS_CODE        ,
	   FIT_OVERRIDE_AMOUNT       ,
	   FIT_OVERRIDE_RATE         ,
	   WITHHOLDING_ALLOWANCES    ,
	   CUMULATIVE_TAXATION       ,
	   EIC_FILING_STATUS_CODE    ,
	   FIT_ADDITIONAL_TAX        ,
	   FIT_EXEMPT                ,
	   FUTA_TAX_EXEMPT           ,
	   MEDICARE_TAX_EXEMPT       ,
	   SS_TAX_EXEMPT             ,
	   STATUTORY_EMPLOYEE        ,
	   W2_FILED_YEAR             ,
	   SUPP_TAX_OVERRIDE_RATE    ,
	   EXCESSIVE_WA_REJECT_DATE  ,
	   LAST_UPDATE_DATE          ,
	   LAST_UPDATED_BY           ,
	   LAST_UPDATE_LOGIN         ,
	   CREATED_BY                ,
	   CREATION_DATE             ,
	   OBJECT_VERSION_NUMBER     ,
	   ATTRIBUTE_CATEGORY        ,
	   ATTRIBUTE1                ,
	   ATTRIBUTE2                ,
	   ATTRIBUTE3                ,
	   ATTRIBUTE4                ,
	   ATTRIBUTE5                ,
	   ATTRIBUTE6                ,
	   ATTRIBUTE7                ,
	   ATTRIBUTE8                ,
	   ATTRIBUTE9                ,
	   ATTRIBUTE10               ,
	   ATTRIBUTE11               ,
	   ATTRIBUTE12               ,
	   ATTRIBUTE13               ,
	   ATTRIBUTE14               ,
	   ATTRIBUTE15               ,
	   ATTRIBUTE16               ,
	   ATTRIBUTE17               ,
	   ATTRIBUTE18               ,
	   ATTRIBUTE19               ,
	   ATTRIBUTE20               ,
	   ATTRIBUTE21               ,
	   ATTRIBUTE22               ,
	   ATTRIBUTE23               ,
	   ATTRIBUTE24               ,
	   ATTRIBUTE25               ,
	   ATTRIBUTE26               ,
	   ATTRIBUTE27               ,
	   ATTRIBUTE28               ,
	   ATTRIBUTE29               ,
	   ATTRIBUTE30               ,
	   FED_INFORMATION_CATEGORY  ,
	   FED_INFORMATION1          ,
	   FED_INFORMATION2          ,
	   FED_INFORMATION3          ,
	   FED_INFORMATION4          ,
	   FED_INFORMATION5          ,
	   FED_INFORMATION6          ,
	   FED_INFORMATION7          ,
	   FED_INFORMATION8          ,
	   FED_INFORMATION9          ,
	   FED_INFORMATION10         ,
	   FED_INFORMATION11         ,
	   FED_INFORMATION12         ,
	   FED_INFORMATION13         ,
	   FED_INFORMATION14         ,
	   FED_INFORMATION15         ,
	   FED_INFORMATION16         ,
	   FED_INFORMATION17         ,
	   FED_INFORMATION18         ,
	   FED_INFORMATION19         ,
	   FED_INFORMATION20         ,
	   FED_INFORMATION21         ,
	   FED_INFORMATION22         ,
	   FED_INFORMATION23         ,
	   FED_INFORMATION24         ,
	   FED_INFORMATION25         ,
	   FED_INFORMATION26         ,
	   FED_INFORMATION27         ,
	   FED_INFORMATION28         ,
	   FED_INFORMATION29         ,
	   FED_INFORMATION30
      )
      values
      (
	   l_fed_rec.EMP_FED_TAX_RULE_ID     ,
	   l_start_day,
	   l_fed_rec.effective_end_date,
	   l_fed_rec.ASSIGNMENT_ID    ,
	   l_fed_rec.SUI_STATE_CODE    ,
	   l_fed_rec.SUI_JURISDICTION_CODE     ,
	   l_fed_rec.BUSINESS_GROUP_ID         ,
	   l_fed_rec.ADDITIONAL_WA_AMOUNT      ,
	   l_fed_rec.FILING_STATUS_CODE        ,
	   l_fed_rec.FIT_OVERRIDE_AMOUNT       ,
	   l_fed_rec.FIT_OVERRIDE_RATE         ,
	   l_fed_rec.WITHHOLDING_ALLOWANCES    ,
	   l_fed_rec.CUMULATIVE_TAXATION       ,
	   0   ,
	   l_fed_rec.FIT_ADDITIONAL_TAX        ,
	   l_fed_rec.FIT_EXEMPT                ,
	   l_fed_rec.FUTA_TAX_EXEMPT           ,
	   l_fed_rec.MEDICARE_TAX_EXEMPT       ,
	   l_fed_rec.SS_TAX_EXEMPT             ,
	   l_fed_rec.STATUTORY_EMPLOYEE        ,
	   l_fed_rec.W2_FILED_YEAR             ,
	   l_fed_rec.SUPP_TAX_OVERRIDE_RATE    ,
	   l_fed_rec.EXCESSIVE_WA_REJECT_DATE  ,
           NULL                                , -- Bug 9157658
	   l_fed_rec.LAST_UPDATED_BY           ,
	   l_fed_rec.LAST_UPDATE_LOGIN         ,
	   l_fed_rec.CREATED_BY                ,
	   l_fed_rec.CREATION_DATE             ,
	   l_fed_rec.OBJECT_VERSION_NUMBER     ,
	   l_fed_rec.ATTRIBUTE_CATEGORY        ,
	   l_fed_rec.ATTRIBUTE1                ,
	   l_fed_rec.ATTRIBUTE2                ,
	   l_fed_rec.ATTRIBUTE3                ,
	   l_fed_rec.ATTRIBUTE4                ,
	   l_fed_rec.ATTRIBUTE5                ,
	   l_fed_rec.ATTRIBUTE6                ,
	   l_fed_rec.ATTRIBUTE7                ,
	   l_fed_rec.ATTRIBUTE8                ,
	   l_fed_rec.ATTRIBUTE9                ,
	   l_fed_rec.ATTRIBUTE10               ,
	   l_fed_rec.ATTRIBUTE11               ,
	   l_fed_rec.ATTRIBUTE12               ,
	   l_fed_rec.ATTRIBUTE13               ,
	   l_fed_rec.ATTRIBUTE14               ,
	   l_fed_rec.ATTRIBUTE15               ,
	   l_fed_rec.ATTRIBUTE16               ,
	   l_fed_rec.ATTRIBUTE17               ,
	   l_fed_rec.ATTRIBUTE18               ,
	   l_fed_rec.ATTRIBUTE19               ,
	   l_fed_rec.ATTRIBUTE20               ,
	   l_fed_rec.ATTRIBUTE21               ,
	   l_fed_rec.ATTRIBUTE22               ,
	   l_fed_rec.ATTRIBUTE23               ,
	   l_fed_rec.ATTRIBUTE24               ,
	   l_fed_rec.ATTRIBUTE25               ,
	   l_fed_rec.ATTRIBUTE26               ,
	   l_fed_rec.ATTRIBUTE27               ,
	   l_fed_rec.ATTRIBUTE28               ,
	   l_fed_rec.ATTRIBUTE29               ,
	   l_fed_rec.ATTRIBUTE30               ,
	   l_fed_rec.FED_INFORMATION_CATEGORY  ,
	   l_fed_rec.FED_INFORMATION1          ,
	   l_fed_rec.FED_INFORMATION2          ,
	   l_fed_rec.FED_INFORMATION3          ,
	   l_fed_rec.FED_INFORMATION4          ,
	   l_fed_rec.FED_INFORMATION5          ,
	   l_fed_rec.FED_INFORMATION6          ,
	   l_fed_rec.FED_INFORMATION7          ,
	   l_fed_rec.FED_INFORMATION8          ,
	   l_fed_rec.FED_INFORMATION9          ,
	   l_fed_rec.FED_INFORMATION10         ,
	   l_fed_rec.FED_INFORMATION11         ,
	   l_fed_rec.FED_INFORMATION12         ,
	   l_fed_rec.FED_INFORMATION13         ,
	   l_fed_rec.FED_INFORMATION14         ,
	   l_fed_rec.FED_INFORMATION15         ,
	   l_fed_rec.FED_INFORMATION16         ,
	   l_fed_rec.FED_INFORMATION17         ,
	   l_fed_rec.FED_INFORMATION18         ,
	   l_fed_rec.FED_INFORMATION19         ,
	   l_fed_rec.FED_INFORMATION20         ,
	   l_fed_rec.FED_INFORMATION21         ,
	   l_fed_rec.FED_INFORMATION22         ,
	   l_fed_rec.FED_INFORMATION23         ,
	   l_fed_rec.FED_INFORMATION24         ,
	   l_fed_rec.FED_INFORMATION25         ,
	   l_fed_rec.FED_INFORMATION26         ,
	   l_fed_rec.FED_INFORMATION27         ,
	   l_fed_rec.FED_INFORMATION28         ,
	   l_fed_rec.FED_INFORMATION29         ,
	   l_fed_rec.FED_INFORMATION30
      );


      hr_utility.trace('Updated Assignment : ' ||
                            to_char(l_fed_rec.assignment_id));
  commit;
  end loop;
  close csr_get_asg;

END;

/*Created for Bug8985595 to allow the clearing of Wisconsin EIC through Year Begin
Process.This is an overloaded function created to maintain integrity of any other
reference to this procedure. */

PROCEDURE reset_overrides
              (errbuf                      out nocopy varchar2
              ,retcode                     out nocopy number
	      ,p_business_group            in  varchar2
	      ,p_curr_year                 in  varchar2
	      ,p_clr_ind_add_ovr           in  varchar2
	      ,p_clr_ind_eic               in  varchar2
	      ,p_clr_sui_wb_ovr            in  varchar2
	      ,p_clr_pa_head_tax           in  varchar2
	      ,p_clr_fed_eic_filing_status in  varchar2
	     )
  IS

l_clr_wis_eic varchar2(3);

BEGIN

l_clr_wis_eic := 'N';

/*If a call to reset_overrides happens without the p_clr_wis_eic,
then we make p_clr_wis_eic as No and pass it to the procedure*/

    reset_overrides
              (errbuf
              ,retcode
	      ,p_business_group
	      ,p_curr_year
	      ,p_clr_ind_add_ovr
	      ,p_clr_ind_eic
	      ,p_clr_sui_wb_ovr
	      ,p_clr_pa_head_tax
	      ,p_clr_fed_eic_filing_status
	      ,l_clr_wis_eic
	     );

END;

/*Added Parameter p_clr_wis_eic for Bug8985595 to allow the clearing of Wisconsin EIC through Year Begin Process */

PROCEDURE reset_overrides
              (errbuf                      out nocopy varchar2
              ,retcode                     out nocopy number
	      ,p_business_group            in  varchar2
	      ,p_curr_year                 in  varchar2
	      ,p_clr_ind_add_ovr           in  varchar2
	      ,p_clr_ind_eic               in  varchar2
	      ,p_clr_sui_wb_ovr            in  varchar2
	      ,p_clr_pa_head_tax           in  varchar2
	      ,p_clr_fed_eic_filing_status in  varchar2
	      ,p_clr_wis_eic               in  varchar2
	     )
  IS

BEGIN
--hr_utility.trace_on(null,'ORACLE');
hr_utility.trace(p_business_group||p_curr_year||p_clr_ind_add_ovr||p_clr_ind_eic||p_clr_sui_wb_ovr||p_clr_pa_head_tax||p_clr_fed_eic_filing_status);


  /* Clear the Indiana Override Adderess/Location  */
	IF p_clr_ind_add_ovr = 'Y' THEN
	   pay_us_indiana.update_address(errbuf,retcode,p_business_group,p_curr_year);
	END IF;
  /* End Indiana Override Address /Location */

   /* Clear Indiana EIC */
	IF p_clr_ind_eic = 'Y' THEN
	hr_utility.trace('Procedure ind_eic_ovr');
        ind_eic_ovr(p_business_group,p_curr_year);
	END IF;
  /* End Indiana EIC */

  /*Added for Bug8985595 to allow the clearing of Wisconsin EIC through Year Begin Process */

   /* Clear Wisconsin EIC */
	IF p_clr_wis_eic = 'Y' THEN
	hr_utility.trace('Procedure wis_eic_ovr');
        wis_eic_ovr(p_business_group,p_curr_year);
	END IF;
  /* End Wisconsin EIC */

  /*Bug8985595 ends*/

  /* Clear SUI Wage Base Override */
	IF p_clr_sui_wb_ovr = 'Y' THEN
	   hr_utility.trace('Procedure sui_wb_ovr');
	   sui_wb_ovr(p_business_group,p_curr_year);
	END IF;
  /* End SUI Wage Base Override */


 /*Clear PA Head tax exempt */
        IF p_clr_pa_head_tax ='Y' THEN
	    hr_utility.trace('Procedure pa_head_tx_ovr');
	    pa_head_tx_ovr(p_business_group,p_curr_year);
	END IF;
  /* End PS head tax exempt */


  /* Clear Federal EIC Filing status */
     IF p_clr_fed_eic_filing_status = 'Y' THEN
        hr_utility.trace('Procedure fed_eic_filing_status_ovr');
	fed_eic_filing_status_ovr(p_business_group,p_curr_year);
     END IF;
  /*  End EIC filing status*/

END reset_overrides;

end pay_us_year_begin_process;

/
