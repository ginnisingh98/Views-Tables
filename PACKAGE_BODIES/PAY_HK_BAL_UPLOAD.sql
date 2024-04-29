--------------------------------------------------------
--  DDL for Package Body PAY_HK_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_HK_BAL_UPLOAD" as
-- /* $Header: pyhkupld.pkb 120.0 2005/05/29 05:40:32 appldev noship $ */
--
-- +======================================================================+
-- |              Copyright (c) 2001 Oracle Corporation UK Ltd            |
-- |                        Reading, Berkshire, England                   |
-- |                           All rights reserved.                       |
-- +======================================================================+
-- SQL Script File Name : pyhkupld.pkb
-- Description          : This script delivers balance upload support
--                        functions for the Hong Kong localization (HK).
--
-- DELIVERS EXTERNAL functions
--   expiry_date
--   include_adjustment
--   is_supported
--   validate_batch_lines
--
-- Change List:
-- ------------
--
-- ======================================================================
-- Version  Date         Author    Bug No.  Description of Change
-- -------  -----------  --------  -------  -----------------------------
-- 115.0    02-JAN-2001  JBailie            Initial Version - based on the
--                                          pay_sg_bal_upload
-- 115.1    25-JUN-2001  JLin               Added dimensions for source_id
--                                          context balance to the function
--                                          expiry_date and is_support
-- 115.2    28-JUN-2001  JLin               Added _ASG_MPF% dimensions
--
-- ======================================================================
--
 --
 -- Date constants.
 --
 START_OF_TIME constant date := to_date('01/01/0001','DD/MM/YYYY');
 END_OF_TIME   constant date := to_date('31/12/4712','DD/MM/YYYY');
 --
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  expiry_date
  -- PURPOSE
  --  Returns the expiry date of a given dimension relative to a date.
  -- ARGUMENTS
  --  p_upload_date       - the date on which the balance should be correct.
  --  p_dimension_name    - the dimension being set.
  --  p_assignment_id     - the assignment involved.
  --  p_original_entry_id - ORIGINAL_ENTRY_ID context.
  -- USES
  -- NOTES
  --  This is used by pay_balance_upload.dim_expiry_date.
  --  If the expiry date cannot be derived then it is set to the end of time
  --  to indicate that a failure has occured. The process that uses the
  --  expiry date knows this rulw and acts accordingly.
  -----------------------------------------------------------------------------
 --
 function expiry_date
 (
  p_upload_date       date
 ,p_dimension_name    varchar2
 ,p_assignment_id     number
 ,p_original_entry_id number
 ) return date is
   --
   -- Returns the start date of the fiscal year.
   --
   cursor csr_fiscal_year
          (
           p_assignment_id number
          ,p_upload_date   date
          ) is
     select nvl(add_months(fnd_date.canonical_to_date(HOI.ORG_INFORMATION11),
                       12*(floor(months_between(p_upload_date,
                          fnd_date.canonical_to_date(HOI.ORG_INFORMATION11))/12))),
	          END_OF_TIME)
     from   per_assignments_f           ASS
           ,hr_organization_information HOI
     where  ASS.assignment_id                  = p_assignment_id
       and  p_upload_date                between ASS.effective_start_date
			                     and ASS.effective_end_date
       and  HOI.organization_id                = ASS.business_group_id
       and  upper(HOI.org_information_context) = 'BUSINESS GROUP INFORMATION';
   --
   -- Returns the start date of the tax year.
   --
   cursor csr_tax_year
          (
           p_assignment_id number
          ,p_upload_date   date
          ) is
     SELECT to_date('01-04-'||to_char(fnd_number.canonical_to_number(
            to_char(p_upload_date,'YYYY'))+ decode(sign(p_upload_date
            - to_date('01-04-'||to_char(p_upload_date,'YYYY'),'DD-MM-YYYY'))
            ,-1,-1,0)),'DD-MM-YYYY')
     from   per_assignments_f           ASS
     where  ASS.assignment_id                  = p_assignment_id
       and  p_upload_date                between ASS.effective_start_date
			                     and ASS.effective_end_date;
   --
   -- Returns the start date of the fiscal quarter.
   --
   cursor csr_fiscal_quarter
          (
           p_assignment_id number
          ,p_upload_date   date
          ) is
     select nvl(add_months(fnd_date.canonical_to_date(HOI.ORG_INFORMATION11),
                       3*(floor(months_between(p_upload_date,
                          fnd_date.canonical_to_date(HOI.ORG_INFORMATION11))/3))),
	          END_OF_TIME)
     from   per_assignments_f           ASS
           ,hr_organization_information HOI
     where  ASS.assignment_id                  = p_assignment_id
       and  p_upload_date                between ASS.effective_start_date
			                     and ASS.effective_end_date
       and  HOI.organization_id                = ASS.business_group_id
       and  upper(HOI.org_information_context) = 'BUSINESS GROUP INFORMATION';
   --
   -- Returns the start date of the current period on the upload date.
   --
   cursor csr_period_start
          (
           p_assignment_id number
          ,p_upload_date   date
          ) is
     select nvl(PTP.start_date, END_OF_TIME)
     from   per_time_periods  PTP
           ,per_assignments_f ASS
     where  ASS.assignment_id = p_assignment_id
       and  p_upload_date       between ASS.effective_start_date
                                    and ASS.effective_end_date
       and  PTP.payroll_id    = ASS.payroll_id
       and  p_upload_date      between PTP.start_date
				   and PTP.end_date;
   --
   -- Returns the earliest date on which the assignment exists.
   --
   cursor csr_ele_ltd_start
          (
           p_assignment_id     number
          ,p_upload_date       date
          ) is
     select nvl(min(ASG.effective_start_date), END_OF_TIME)
     from   per_assignments_f   ASG
     where  ASG.assignment_id         = p_assignment_id
       and  ASG.effective_start_date <= p_upload_date;
   --
   --
   cursor csr_asg_start_date
     (p_assignment_id number
     ,p_upload_date   date
     ,p_expiry_date   date
     ) is
     select nvl(greatest(min(ASS.effective_start_date), p_expiry_date),
                END_OF_TIME)
       from per_assignments_f ASS
      where ASS.assignment_id = p_assignment_id
        and ASS.effective_start_date <= p_upload_date
        and ASS.effective_end_date >= p_expiry_date;
   --
   --
   -- Holds the start of the month for the upload date.
   --
   l_month_start_date            date;
   --
   -- Holds the start of the calendar year for the upload date.
   --
   l_cal_yr_start_date           date;
   --
   -- Holds the start of the statutory year for the upload date.
   --
   l_tax_yr_start_date           date;
   --
   -- Holds the start of the statutory quarter for the upload date.
   --
   l_tax_qtr_start_date          date;
   --
   -- Holds the start of the fiscal year for the upload date.
   --
   l_fiscal_yr_start_date        date;
   --
   -- Holds the start of the fiscal quarter for the upload date.
   --
   l_fiscal_qtr_start_date       date;
   --
   -- Holds the start of the period for the upload date.
   --
   l_prd_start_date              date;
   --
   -- Holds the earliest date on which the element entry exists.
   --
   l_ele_ltd_start_date          date;
   --
   -- Holds the expiry date of the dimension.
   --
   l_expiry_date                 date;
   --
 begin
   --
   -- Calculate the expiry date for the specified dimension relative to the
   -- upload date, taking into account any contexts where appropriate. Each of
   -- the calculations also takes into account when the assignment is on a
   -- payroll to ensure that a balance adjustment could be made at that point
   -- if it were required.
   --
   -- Lifetime to date dimension.
   --
   if p_dimension_name in
     ('_ASG_LTD'
     ,'_ASG_LE_LTD') then
     --
     -- What is the earliest date on which the element entry exists ?
     --
     open csr_ele_ltd_start(p_assignment_id
                           ,p_upload_date);
     fetch csr_ele_ltd_start into l_ele_ltd_start_date;
     close csr_ele_ltd_start;
     --
     l_expiry_date := l_ele_ltd_start_date;
   --
   -- Inception to date within a tax unit dimension.
   --
   -- Period to date dimensions.
   --
   elsif p_dimension_name in
     ('_ASG_PTD'
     ,'_ASG_LE_PTD'
     ,'_ASG_SRCE_PTD'
     ,'_ASG_SRCE_MPF_PTD'
     ,'_ASG_MPF_PTD') then
     --
     -- What is the current period start date ?
     --
     open  csr_period_start(p_assignment_id
                           ,p_upload_date);
     fetch csr_period_start into l_prd_start_date;
     close csr_period_start;
     --
     open csr_asg_start_date(p_assignment_id
                            ,p_upload_date
                            ,l_prd_start_date);
     fetch csr_asg_start_date into l_expiry_date;
     close csr_asg_start_date;
   --
   -- Month dimensions.
   --
   elsif p_dimension_name in
     ('_ASG_MONTH'
     ,'_ASG_LE_MONTH'
     ,'_ASG_SRCE_MONTH'
     ,'_ASG_SRCE_MPF_MONTH'
     ,'_ASG_MPF_MONTH') then
     --
     -- What is the current month start ?
     --
     l_month_start_date := trunc(p_upload_date, 'MON');
     open csr_asg_start_date(p_assignment_id
                            ,p_upload_date
                            ,l_month_start_date);
     fetch csr_asg_start_date into l_month_start_date;
     close csr_asg_start_date;
     --
     open csr_asg_start_date(p_assignment_id
                            ,p_upload_date
                            ,l_month_start_date);
     fetch csr_asg_start_date into l_expiry_date;
     close csr_asg_start_date;
   --
   -- Quarter to date dimensions.
   --
   elsif p_dimension_name in
     ('_ASG_QTD'
     ,'_ASG_LE_QTD'
     ,'_ASG_SRCE_QTD'
     ,'_ASG_SRCE_MPF_QTD'
     ,'_ASG_MPF_QTD') then
     --
     -- What is the start date of the tax quarter ?
     --
     l_tax_qtr_start_date := trunc(p_upload_date, 'Q');
     open csr_asg_start_date(p_assignment_id
                            ,p_upload_date
                            ,l_tax_qtr_start_date);
     fetch csr_asg_start_date into l_tax_qtr_start_date;
     close csr_asg_start_date;
     --
     l_expiry_date := l_tax_qtr_start_date;
   --
   -- Year to date dimensions.
   --
   elsif p_dimension_name in
     ('_ASG_CAL_YTD'
     ,'_ASG_LE_CAL_YTD') then
     --
     -- What is the start date of the calendar year ?
     --
     l_cal_yr_start_date := trunc(p_upload_date, 'Y');
     open csr_asg_start_date(p_assignment_id
                            ,p_upload_date
                            ,l_cal_yr_start_date);
     fetch csr_asg_start_date into l_cal_yr_start_date;
     close csr_asg_start_date;
     --
     -- Ensure that the expiry date is at a date where the assignment is to the
     -- correct legal company ie. matches the TAX_UNIT_ID context specified.
     --
     l_expiry_date := l_cal_yr_start_date;
   --
   -- Year to date dimensions.
   --
   elsif p_dimension_name in
     ('_ASG_YTD'
     ,'_ASG_LE_YTD'
     ,'_ASG_SRCE_YTD'
     ,'_ASG_SRCE_MPF_YTD'
     ,'_ASG_MPF_YTD') then
     --
     -- What is the start date of the tax year ?
     --
     open  csr_tax_year(p_assignment_id
                       ,p_upload_date);
     fetch csr_tax_year into l_tax_yr_start_date;
     close csr_tax_year;
     --
     open csr_asg_start_date(p_assignment_id
                            ,p_upload_date
                            ,l_tax_yr_start_date);
     fetch csr_asg_start_date into l_tax_yr_start_date;
     close csr_asg_start_date;
     --
     -- Ensure that the expiry date is at a date where the assignment is to the
     -- correct legal company ie. matches the TAX_UNIT_ID context specified.
     --
     l_expiry_date := l_tax_yr_start_date;
   --
   -- Fiscal quarter to date dimensions.
   --
   elsif p_dimension_name in
     ('_ASG_FQTD'
     ,'_ASG_LE_FQTD') then
     --
     -- What is the start date of the fiscal quarter ?
     --
     open  csr_fiscal_quarter(p_assignment_id
                             ,p_upload_date);
     fetch csr_fiscal_quarter into l_fiscal_qtr_start_date;
     close csr_fiscal_quarter;
     --
     open csr_asg_start_date(p_assignment_id
                            ,p_upload_date
                            ,l_fiscal_qtr_start_date);
     fetch csr_asg_start_date into l_expiry_date;
     close csr_asg_start_date;
   --
   -- Fiscal year to date dimensions.
   --
   elsif p_dimension_name in
     ('_ASG_FYTD'
     ,'_ASG_LE_FYTD') then
     --
     -- What is the start date of the fiscal year ?
     --
     open  csr_fiscal_year(p_assignment_id
                          ,p_upload_date);
     fetch csr_fiscal_year into l_fiscal_yr_start_date;
     close csr_fiscal_year;
     --
     open csr_asg_start_date(p_assignment_id
                            ,p_upload_date
                            ,l_fiscal_yr_start_date);
     fetch csr_asg_start_date into l_expiry_date;
     close csr_asg_start_date;
     --
   end if;
   --
   -- return the date on which the dimension expires.
   --
   return (l_expiry_date);
   --
 end expiry_date;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  is_supported
  -- PURPOSE
  --  Checks if the dimension is supported by the upload process.
  -- ARGUMENTS
  --  p_dimension_name - the balance dimension to be checked.
  -- USES
  -- NOTES
  --  Only a subset of the US dimensions are supported and these have been
  --  picked to allow effective migration to release 10.
  --  This is used by pay_balance_upload.validate_dimension.
  -----------------------------------------------------------------------------
 --
 function is_supported
 (
  p_dimension_name varchar2
 ) return number is
 begin
   --
   hr_utility.trace('Entering pay_hk_bal_upload.is_supported');
   --
   -- See if the dimension is supported.
   --
   if p_dimension_name in
     ('_ASG_LE_PTD'
     ,'_ASG_LE_MONTH'
     ,'_ASG_LE_QTD'
     ,'_ASG_LE_YTD'
     ,'_ASG_LE_CAL_YTD'
     ,'_ASG_LE_FQTD'
     ,'_ASG_LE_FYTD'
     ,'_ASG_LE_LTD'
     ,'_ASG_PTD'
     ,'_ASG_MONTH'
     ,'_ASG_QTD'
     ,'_ASG_YTD'
     ,'_ASG_CAL_YTD'
     ,'_ASG_FQTD'
     ,'_ASG_FYTD'
     ,'_ASG_LTD'
     ,'_ASG_SRCE_MONTH'
     ,'_ASG_SRCE_PTD'
     ,'_ASG_SRCE_QTD'
     ,'_ASG_SRCE_YTD'
     ,'_ASG_SRCE_MPF_MONTH'
     ,'_ASG_SRCE_MPF_PTD'
     ,'_ASG_SRCE_MPF_QTD'
     ,'_ASG_SRCE_MPF_YTD'
     ,'_ASG_MPF_MONTH'
     ,'_ASG_MPF_PTD'
     ,'_ASG_MPF_QTD'
     ,'_ASG_MPF_YTD') then
     return (1);  -- denotes TRUE
   else
     return (0);  -- denotes FALSE
   end if;
   --
   hr_utility.trace('Exiting pay_hk_bal_upload.is_supported');
   --
 end is_supported;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  include_adjustment
  -- PURPOSE
  --  Given a dimension, and relevant contexts and details of an existing
  --  balanmce adjustment, it will find out if the balance adjustment effects
  --  the dimension to be set. Both the dimension to be set and the adjustment
  --  are for the same assignment and balance. The adjustment also lies between
  --  the expiry date of the new balance and the date on which it is to set.
  -- ARGUMENTS
  --  p_balance_type_id    - the balance to be set.
  --  p_dimension_name     - the balance dimension to be set.
  --  p_original_entry_id  - ORIGINAL_ENTRY_ID context.
  --  p_upload_date
  --  p_batch_line_id
  --  p_test_batch_line_id
  -- USES
  -- NOTES
  --  All the US dimensions affect each other when they share the same context
  --  values so there is no special support required for individual dimensions.
  --  This is used by pay_balance_upload.get_current_value.
  -----------------------------------------------------------------------------
 --
 function include_adjustment
 (
  p_balance_type_id    number
 ,p_dimension_name     varchar2
 ,p_original_entry_id  number
 ,p_upload_date        date
 ,p_batch_line_id      number
 ,p_test_batch_line_id number
 ) return number is
   --
   -- Does the balance adjustment effect the new balance dimension.
   --
   cursor csr_is_included
     (
      p_balance_type_id           number
     ,p_tax_unit_id               number
     ,p_original_entry_id         number
     ,p_bal_adj_tax_unit_id       number
     ,p_bal_adj_original_entry_id number
     ) is
     select BT.balance_type_id
     from   pay_balance_types BT
     where  BT.balance_type_id = p_balance_type_id
	    --
	    -- TAX_UNIT_ID context NB. if the tax unit is used then only those
	    -- adjustments which are for the same tax unit can be included.
	    --
       and  nvl(p_tax_unit_id, nvl(p_bal_adj_tax_unit_id, -1)) =
 	    nvl(p_bal_adj_tax_unit_id, -1)
	    --
	    -- ORIGINAL_ENTRY_ID context NB. this context controls the expiry
	    -- date of the dimension in the same way as the QTD dimension. Any
	    -- existing balance adjustments that lie between the upload date
	    -- and the expiry date are all included. There is no special
	    -- criteria that has to be met.
	    --
       and  1 = 1;
   --
   -- Get the tax_unit_id from the original balance batch line
   --
   cursor csr_get_tax_unit
     (
      p_batch_line_id            number
     ) is
     select htuv.tax_unit_id
     from   pay_balance_batch_lines pbbl
           ,hr_tax_units_v htuv
     where  pbbl.batch_line_id = p_batch_line_id
     and    pbbl.tax_unit_id = htuv.tax_unit_id
     and    pbbl.tax_unit_id is not null
     union all
     select htuv.tax_unit_id
     from   pay_balance_batch_lines pbbl
           ,hr_tax_units_v htuv
     where  pbbl.batch_line_id = p_batch_line_id
     and    upper(pbbl.gre_name) = upper(htuv.name)
     and    pbbl.tax_unit_id is null;
   --
   -- Get tax_unit_id and original_entry_id for previously tested adjustments
   --
   cursor csr_get_tested_adjustments
     (
      p_test_batch_line_id      number
     ) is
     select tax_unit_id
           ,original_entry_id
     from   pay_temp_balance_adjustments
     where  batch_line_id = p_test_batch_line_id;
   --
   -- The balance returned by the include check.
   --
   l_bal_type_id       number;
   --
   l_tax_unit_id       number;
   --
   l_adj_tax_unit_id   number;
   l_adj_orig_entry_id number;
   --
 begin
   --
   hr_utility.trace('Entering pay_hk_bal_upload.include_adjustment_test');
   --
   open csr_get_tax_unit(p_batch_line_id);
   fetch csr_get_tax_unit into l_tax_unit_id;
   close csr_get_tax_unit;
   --
   open csr_get_tested_adjustments(p_test_batch_line_id);
   fetch csr_get_tested_adjustments into l_adj_tax_unit_id, l_adj_orig_entry_id;
   close csr_get_tested_adjustments;
   --
   -- Does the balance adjustment effect the new balance ?
   --
   hr_utility.trace('balance_type_id      = '||to_char(p_balance_type_id));
   hr_utility.trace('tax_unit_id          = '||to_char(l_tax_unit_id));
   hr_utility.trace('original_entry_id    = '||to_char(p_original_entry_id));
   hr_utility.trace('BA tax_unit_id       = '||to_char(l_adj_tax_unit_id));
   hr_utility.trace('BA original_entry_id = '||to_char(l_adj_orig_entry_id));
   --
   open  csr_is_included(p_balance_type_id
                        ,l_tax_unit_id
                        ,p_original_entry_id
                        ,l_adj_tax_unit_id
                        ,l_adj_orig_entry_id);
   fetch csr_is_included into l_bal_type_id;
   close csr_is_included;
   --
   hr_utility.trace('Exiting pay_hk_bal_upload.include_adjustment_test');
   --
   -- Adjustment does contribute to the new balance.
   --
   if l_bal_type_id is not null then
     return (1);  --TRUE
   --
   -- Adjustment does not contribute to the new balance.
   --
   else
     return (0);  --FALSE
   end if;
   --
 end include_adjustment;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  validate_batch_lines
  -- PURPOSE
 --   Applies SG specific validation to the batch.
  -- ARGUMENTS
  --  p_batch_id - the batch to be validate_batch_linesd.
  -- USES
  -- NOTES
  --  This is used by pay_balance_upload.validate_batch_lines.
  -----------------------------------------------------------------------------
 --
 procedure validate_batch_lines
 (
  p_batch_id number
 ) is
 begin
   --
   hr_utility.trace('Entering pay_hk_bal_upload.validate_batch_lines');
   --
   hr_utility.trace('Exiting pay_hk_bal_upload.validate_batch_lines');
   --
 end validate_batch_lines;
 --
end pay_hk_bal_upload;

/
