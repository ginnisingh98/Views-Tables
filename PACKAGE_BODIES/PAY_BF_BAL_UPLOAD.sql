--------------------------------------------------------
--  DDL for Package Body PAY_BF_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BF_BAL_UPLOAD" as
/* $Header: pybfupld.pkb 120.0 2005/05/29 03:18 appldev noship $ */
/*
 Copyright (c) Oracle Corporation 1995 All rights reserved
 PRODUCT
  Oracle*Payroll
 NAME
  pybfupld.pkb
 DESCRIPTION
  Provides support for the upload of balances based on BF dimensions.
 EXTERNAL
  expiry_date
  get_tax_unit
  include_adjustment
  is_supported
  validate_batch_lines
 INTERNAL
 MODIFIED (DD-MON-YYYY)
  115.5  T.Habara    18-May-2005        Element ptd and itd support. Modified
                                        is_supported and expiry_date.
  115.4  T.Habara    10-May-2004        Added ASSIGNMENT GRE ST2 SN PERIOD TO
                                        DATE to expiry_date and is_supported.
  115.3  T.Habara    18-Sep-2003        Modified expiry_date and is_supported
                                        to support extra dimensions.
                                        Added p_source_id and p_source_text
                                        params to include_adjustment.
  115.2  A.Logue     07-Oct-1999        Change to_number(segment1) to
                                        to_char(tax_unit_id) to avoid
                                        to_number errors.
  115.1  A.Logue     14-May-1999        Canoncial Date in org_information11.
   40.8  J.Alloun    30-Jul-1996        Added error handling.
   40.7  A.Wong	     16-May-1996	uncomment exit command at the end.
   40.6  N.Bristow   08-May-1996        Bug 359005. Tax Unit Id is now passed
                                        to expiry_date and include_adjustment.
   40.5  S Desai     27-Feb-1996        Bug 333439: Date format was 'DD-MON-YY'.
   40.4  N.Bristow   13-Dec-1995        Fixed #328322. Expiry date not set
                                        correctly for assignments created
                                        in the upload year.
   40.3  N.Bristow   03-Nov-1995        The cursors retrieving the date of an
                                        itd adjustment were incorrect.
   40.2  N.Bristow   23-Oct-1995        created.
*/
 --
 -- Date constants.
 --
 START_OF_TIME constant date := to_date('01/01/0001','DD/MM/YYYY');
 END_OF_TIME   constant date := to_date('31/12/4712','DD/MM/YYYY');
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  get_tax_unit
  -- PURPOSE
  --  Returns the legal company an assignment is associated with at
  --  particular point in time.
  -- ARGUMENTS
  --  p_assignment_id  - the assignment
  --  p_effective_date - the date on which the information is required.
  -- USES
  -- NOTES
  -----------------------------------------------------------------------------
 --
 function get_tax_unit
 (
  p_assignment_id  number
 ,p_effective_date date
 ) return number is
   --
   -- Retrieves the legal company an assignment belongs to at a given date.
   --
   cursor csr_tax_unit
     (
      p_assignment_id  number
     ,p_effective_date date
     ) is
     select to_number(SCL.segment1) tax_unit_id
     from   per_assignments_f      ASG
	   ,hr_soft_coding_keyflex SCL
     where  ASG.assignment_id          = p_assignment_id
       and  SCL.soft_coding_keyflex_id = ASG.soft_coding_keyflex_id
       and  p_effective_date between ASG.effective_start_date
				 and ASG.effective_end_date;
   --
   -- Holds the tax unit an assignment belongs to.
   --
   l_tax_unit_id number;
   --
 begin
   --
   hr_utility.trace('Entering pay_bf_bal_upload.get_tax_unit');
   --
   -- Get the legal company the assignment belongs to.
   --
   open  csr_tax_unit(p_assignment_id
                     ,p_effective_date);
   fetch csr_tax_unit into l_tax_unit_id;
   close csr_tax_unit;
   --
   -- Return the tax unit.
   --
   return (l_tax_unit_id);
   --
   hr_utility.trace('Exiting pay_bf_bal_upload.get_tax_unit');
   --
 end get_tax_unit;
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
 ,p_tax_unit_id       number
 ,p_jurisdiction_code varchar2
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
     select nvl(trunc(p_upload_date -
	    to_char(fnd_date.canonical_to_date(HOI.org_information11),'DDD') +1,'Y')
            - 1 + to_char(fnd_date.canonical_to_date(HOI.org_information11),'DDD'),
	    END_OF_TIME)
     from   per_assignments_f           ASS
           ,hr_organization_information HOI
     where  ASS.assignment_id                  = p_assignment_id
       and  p_upload_date                   between ASS.effective_start_date
                                                and ASS.effective_end_date
       and  HOI.organization_id                = ASS.business_group_id
       and  upper(HOI.org_information_context) = 'BUSINESS GROUP INFORMATION';
   --
   -- Returns the start date of the fiscal quarter.
   --
   cursor csr_fiscal_quarter
          (
           p_assignment_id number
          ,p_upload_date   date
          ) is
     select nvl(add_months(trunc(add_months(p_upload_date, -
	    to_char(fnd_date.canonical_to_date(HOI.org_information11),'MM') + 1) -
	    to_char(fnd_date.canonical_to_date(HOI.org_information11),'DD') + 1, 'Q'),
            to_char(fnd_date.canonical_to_date(HOI.org_informatioN11),'MM') - 1) +
	    to_char(fnd_date.canonical_to_date(HOI.org_information11),'DD') - 1,
	    END_OF_TIME)
     from   per_assignments_f           ASS
           ,hr_organization_information HOI
     where  ASS.assignment_id                  = p_assignment_id
       and  p_upload_date                  between ASS.effective_start_date
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
       and  p_upload_date     between ASS.effective_start_date
                                  and ASS.effective_end_date
       and  PTP.payroll_id    = ASS.payroll_id
       and  p_upload_date      between PTP.start_date
				   and PTP.end_date;
   --
   -- Returns the earliest assignment start date relative to a date where the
   -- assignment belongs to a specific tax unit.
   --
   cursor csr_assignment_on_tax_unit
          (
           p_assignment_id number
          ,p_upload_date   date
	  ,p_expiry_date   date
	  ,p_tax_unit_id   number
          ) is
     select nvl(greatest(p_expiry_date, min(ASS.effective_start_date)),
		END_OF_TIME)
     from   per_assignments_f      ASS
	   ,hr_soft_coding_Keyflex SCL
     where  ASS.assignment_id          = p_assignment_id
       and  ASS.effective_start_date  <= p_upload_date
       and  ASS.effective_end_date    >= p_expiry_date
       and  SCL.soft_coding_keyflex_id = ASS.soft_coding_keyflex_id
       and  SCL.segment1    = to_char(p_tax_unit_id);
   --
   -- Returns the earliest date on which the assignment exists.
   --
   cursor csr_ele_itd_start
          (
           p_assignment_id     number
          ,p_upload_date       date
          ) is
     select nvl(min(ASG.effective_start_date), END_OF_TIME)
     from   per_assignments_f   ASG
     where  ASG.assignment_id         = p_assignment_id
       and  ASG.effective_start_date <= p_upload_date;
   --
   -- Returns the earliest date on which the assignment exists and the
   -- assignment belongs to a specific legal company ie. matches the
   -- TAX_UNIT_ID context.
   --
   cursor csr_ele_itd_tax_unit_start
          (
           p_assignment_id     number
          ,p_upload_date       date
          ,p_tax_unit_id       number
          ) is
     select nvl(min(ASS.effective_start_date),
                END_OF_TIME)
     from   per_assignments_f      ASS
           ,hr_soft_coding_keyflex SCL
     where  ASS.assignment_id          = p_assignment_id
       and  SCL.soft_coding_keyflex_id = ASS.soft_coding_keyflex_id
       and  ASS.effective_start_date  <= p_upload_date
       and  SCL.segment1    = to_char(p_tax_unit_id);
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
   cursor csr_oee_start_date
     (p_original_entry_id number
     ,p_upload_date       date
     ) is
     select min(pee.effective_start_date)
       from pay_element_entries_f pee
      where    (pee.element_entry_id = p_original_entry_id
             or pee.original_entry_id = p_original_entry_id)
        and pee.assignment_id = p_assignment_id
        and pee.entry_type = 'E'
        and pee.effective_start_date <= p_upload_date;
   --
   -- Holds the start of the tax year for the upload date.
   --
   l_tax_yr_start_date           date;
   --
   -- Holds the start of the tax quarter for the upload date.
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
   -- Holds the earliest assignment start date relative to a date where the
   -- assignment belongs to a specific tax unit.
   --
   l_closest_tax_unit_date       date;
   --
   -- Holds the earliest date on which the element entry exists.
   --
   l_ele_itd_start_date          date;
   --
   -- Holds the earliest date on which the element entry exists and the
   -- assignment belongs to a specific legal company.
   --
   l_ele_itd_tax_unit_start_date date;
   --
   -- Holds the expiry date of the dimension.
   --
   l_expiry_date                 date;
   --
   -- Holds the start date of the original entry.
   --
   l_oee_start_date              date;
   --
   --
   l_tax_unit_id                 number;
   l_bus_grp                     number;
 begin
   --
   -- Get the tax unit.
   --
   l_tax_unit_id := p_tax_unit_id;
   --
   -- Calculate the expiry date for the specified dimension relative to the
   -- upload date, taking into account any contexts where appropriate. Each of
   -- the calculations also takes into account when the assignment is on a
   -- payroll to ensure that a balance adjustment could be made at that point
   -- if it were required.
   --
   -- Inception to date dimension.
   --
   if    p_dimension_name in
      ('ASSIGNMENT INCEPTION TO DATE', 'ELEMENT INCEPTION TO DATE') then
     --
     -- What is the earliest date on which the element entry exists ?
     --
     open csr_ele_itd_start(p_assignment_id
                           ,p_upload_date);
     fetch csr_ele_itd_start into l_ele_itd_start_date;
     close csr_ele_itd_start;
     --
     l_expiry_date := l_ele_itd_start_date;
   --
   -- Inception to date within a tax unit dimension.
   --
   elsif p_dimension_name =
     'ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY INCEPTION TO DATE' then
     --
     -- What is the earliest date on which the element entry exists and the
     -- assignment belongs to a specific legal company ??
     --
     open csr_ele_itd_tax_unit_start(p_assignment_id
                                    ,p_upload_date
				    ,l_tax_unit_id);
     fetch csr_ele_itd_tax_unit_start into l_ele_itd_tax_unit_start_date;
     close csr_ele_itd_tax_unit_start;
     --
     l_expiry_date := l_ele_itd_tax_unit_start_date;
   --
   -- Period to date dimensions.
   --
   elsif p_dimension_name in
     ('ASSIGNMENT PERIOD TO DATE'
     ,'ASSIGNMENT GRE ST2 SN PERIOD TO DATE'
     ,'ASSIGNMENT SOURCE ID PERIOD TO DATE'
     ,'ASSIGNMENT SOURCE TEXT PERIOD TO DATE'
     ,'ASSIGNMENT IN JD PERIOD TO DATE'
     ,'ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY PERIOD TO DATE'
     ,'ASSIGNMENT IN JD WITHIN GRE PERIOD TO DATE'
     ,'ELEMENT PERIOD TO DATE'
     ,'SUBJECT TO TAX FOR ASSIGNMENT WITHIN GRE PERIOD TO DATE') then
     --
     -- What is the current period start date ?
     --
     open  csr_period_start(p_assignment_id
                           ,p_upload_date);
     fetch csr_period_start into l_prd_start_date;
     close csr_period_start;
     --
     -- Ensure that the expiry date is at a date where the assignment is to the
     -- correct legal company ie. matches the TAX_UNIT_ID context specified.
     --
     if p_dimension_name in
       ('ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY PERIOD TO DATE'
       ,'ASSIGNMENT IN JD WITHIN GRE PERIOD TO DATE'
       ,'SUBJECT TO TAX FOR ASSIGNMENT WITHIN GRE PERIOD TO DATE') then
       --
       open  csr_assignment_on_tax_unit(p_assignment_id
                                       ,p_upload_date
--	                               ,l_expiry_date
	                               ,l_prd_start_date
	                               ,l_tax_unit_id);
       fetch csr_assignment_on_tax_unit into l_closest_tax_unit_date;
       close csr_assignment_on_tax_unit;
       --
       l_expiry_date := l_closest_tax_unit_date;
       --
     else
       open csr_asg_start_date(p_assignment_id
                              ,p_upload_date
                              ,l_prd_start_date);
       fetch csr_asg_start_date into l_expiry_date;
       close csr_asg_start_date;
     end if;
   --
   -- Quarter to date dimensions.
   --
   elsif p_dimension_name in
     ('ASSIGNMENT QUARTER TO DATE'
     ,'ASSIGNMENT IN JD QUARTER TO DATE'
     ,'ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY QUARTER TO DATE'
     ,'ASSIGNMENT IN JD WITHIN GRE QUARTER TO DATE'
     ,'SUBJECT TO TAX FOR ASSIGNMENT WITHIN GRE QUARTER TO DATE') then
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
     -- Ensure that the expiry date is at a date where the assignment is to the
     -- correct legal company ie. matches the TAX_UNIT_ID context specified.
     --
     if p_dimension_name in
       ('ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY QUARTER TO DATE'
       ,'ASSIGNMENT IN JD WITHIN GRE QUARTER TO DATE'
       ,'SUBJECT TO TAX FOR ASSIGNMENT WITHIN GRE QUARTER TO DATE') then
       --
       open  csr_assignment_on_tax_unit(p_assignment_id
                                       ,p_upload_date
--	                               ,l_expiry_date
	                               ,l_tax_qtr_start_date
	                               ,l_tax_unit_id);
       fetch csr_assignment_on_tax_unit into l_closest_tax_unit_date;
       close csr_assignment_on_tax_unit;
       --
       l_expiry_date := l_closest_tax_unit_date;
       --
     else
       l_expiry_date := l_tax_qtr_start_date;
     end if;
   --
   -- Year to date dimensions.
   --
   elsif p_dimension_name in
     ('ASSIGNMENT YEAR TO DATE'
     ,'ASSIGNMENT IN JD YEAR TO DATE'
     ,'ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY YEAR TO DATE'
     ,'ASSIGNMENT IN JD WITHIN GRE YEAR TO DATE'
     ,'SUBJECT TO TAX FOR ASSIGNMENT WITHIN GRE YEAR TO DATE') then
     --
     -- What is the start date of the tax year ?
     --
     l_tax_yr_start_date := trunc(p_upload_date, 'Y');
     open csr_asg_start_date(p_assignment_id
                            ,p_upload_date
                            ,l_tax_yr_start_date);
     fetch csr_asg_start_date into l_tax_yr_start_date;
     close csr_asg_start_date;
     --
     -- Ensure that the expiry date is at a date where the assignment is to the
     -- correct legal company ie. matches the TAX_UNIT_ID context specified.
     --
     if p_dimension_name in
       ('ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY YEAR TO DATE'
       ,'ASSIGNMENT IN JD WITHIN GRE YEAR TO DATE'
       ,'SUBJECT TO TAX FOR ASSIGNMENT WITHIN GRE YEAR TO DATE') then
       --
       open  csr_assignment_on_tax_unit(p_assignment_id
                                       ,p_upload_date
--	                               ,l_expiry_date
	                               ,l_tax_yr_start_date
	                               ,l_tax_unit_id);
       fetch csr_assignment_on_tax_unit into l_closest_tax_unit_date;
       close csr_assignment_on_tax_unit;
       --
       l_expiry_date := l_closest_tax_unit_date;
       --
     else
       l_expiry_date := l_tax_yr_start_date;
     end if;
   --
   -- Fiscal quarter to date dimensions.
   --
   elsif p_dimension_name in
     ('ASSIGNMENT FISCAL QUARTER TO DATE'
     ,'ASSIGNMENT IN JD FISCAL QUARTER TO DATE'
     ,'ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY FISCAL QUARTER TO DATE'
     ,'ASSIGNMENT IN JD WITHIN GRE FISCAL QUARTER TO DATE') then
     --
     -- What is the start date of the fiscal quarter ?
     --
     open  csr_fiscal_quarter(p_assignment_id
                             ,p_upload_date);
     fetch csr_fiscal_quarter into l_fiscal_qtr_start_date;
     close csr_fiscal_quarter;
     --
     -- Ensure that the expiry date is at a date where the assignment is to the
     -- correct legal company ie. matches the TAX_UNIT_ID context specified.
     --
     if p_dimension_name in
       ('ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY FISCAL QUARTER TO DATE'
       ,'ASSIGNMENT IN JD WITHIN GRE FISCAL QUARTER TO DATE') then
       --
       open  csr_assignment_on_tax_unit(p_assignment_id
                                       ,p_upload_date
	                               ,l_fiscal_qtr_start_date
	                               ,l_tax_unit_id);
       fetch csr_assignment_on_tax_unit into l_closest_tax_unit_date;
       close csr_assignment_on_tax_unit;
       --
       l_expiry_date := l_closest_tax_unit_date;
       --
     else
       open csr_asg_start_date(p_assignment_id
                              ,p_upload_date
                              ,l_fiscal_qtr_start_date);
       fetch csr_asg_start_date into l_expiry_date;
       close csr_asg_start_date;
     end if;
   --
   -- Fiscal year to date dimensions.
   --
   elsif p_dimension_name in
     ('ASSIGNMENT FISCAL YEAR TO DATE'
     ,'ASSIGNMENT IN JD FISCAL YEAR TO DATE'
     ,'ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY FISCAL YEAR TO DATE'
     ,'ASSIGNMENT IN JD WITHIN GRE FISCAL YEAR TO DATE') then
     --
     -- What is the start date of the fiscal year ?
     --
     open  csr_fiscal_year(p_assignment_id
                          ,p_upload_date);
     fetch csr_fiscal_year into l_fiscal_yr_start_date;
     close csr_fiscal_year;
     --
     -- Ensure that the expiry date is at a date where the assignment is to the
     -- correct legal company ie. matches the TAX_UNIT_ID context specified.
     --
     if p_dimension_name in
       ('ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY FISCAL YEAR TO DATE'
       ,'ASSIGNMENT IN JD WITHIN GRE FISCAL YEAR TO DATE') then
       --
       open  csr_assignment_on_tax_unit(p_assignment_id
                                       ,p_upload_date
                                       ,l_fiscal_yr_start_date
	                               ,l_tax_unit_id);
       fetch csr_assignment_on_tax_unit into l_closest_tax_unit_date;
       close csr_assignment_on_tax_unit;
       --
       l_expiry_date := l_closest_tax_unit_date;
       --
     else
       open csr_asg_start_date(p_assignment_id
                              ,p_upload_date
                              ,l_fiscal_yr_start_date);
       fetch csr_asg_start_date into l_expiry_date;
       close csr_asg_start_date;
     end if;
     --
   end if;
   --
   -- Original entry based dimension
   --
   if p_dimension_name in
        ('ELEMENT PERIOD TO DATE', 'ELEMENT INCEPTION TO DATE') then
     --
     -- Retrieve the start date of the original entry.
     --
     open csr_oee_start_date(p_original_entry_id
                            ,p_upload_date);
     fetch csr_oee_start_date into l_oee_start_date;
     close csr_oee_start_date;
     --
     l_expiry_date := greatest(l_expiry_date, nvl(l_oee_start_date, END_OF_TIME));
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
  --  Only a subset of the BF dimensions are supported and these have been
  --  picked to allow effective migration to release 10.
  --  This is used by pay_balance_upload.validate_dimension.
  -----------------------------------------------------------------------------
 --
 function is_supported
 (
  p_dimension_name varchar2
 ) return boolean is
 begin
   --
   hr_utility.trace('Entering pay_bf_bal_upload.is_supported');
   --
   -- See if the dimension is supported.
   --
   if p_dimension_name in
     ('ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY INCEPTION TO DATE'
     ,'ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY PERIOD TO DATE'
     ,'ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY QUARTER TO DATE'
     ,'ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY YEAR TO DATE'
     ,'ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY FISCAL QUARTER TO DATE'
     ,'ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY FISCAL YEAR TO DATE'
     ,'ASSIGNMENT INCEPTION TO DATE'
     ,'ASSIGNMENT PERIOD TO DATE'
     ,'ASSIGNMENT QUARTER TO DATE'
     ,'ASSIGNMENT YEAR TO DATE'
     ,'ASSIGNMENT FISCAL QUARTER TO DATE'
     ,'ASSIGNMENT FISCAL YEAR TO DATE'
     ,'ASSIGNMENT IN JD PERIOD TO DATE'
     ,'ASSIGNMENT IN JD QUARTER TO DATE'
     ,'ASSIGNMENT IN JD YEAR TO DATE'
     ,'ASSIGNMENT IN JD FISCAL QUARTER TO DATE'
     ,'ASSIGNMENT IN JD FISCAL YEAR TO DATE'
     ,'ASSIGNMENT IN JD WITHIN GRE PERIOD TO DATE'
     ,'ASSIGNMENT IN JD WITHIN GRE QUARTER TO DATE'
     ,'ASSIGNMENT IN JD WITHIN GRE YEAR TO DATE'
     ,'ASSIGNMENT IN JD WITHIN GRE FISCAL QUARTER TO DATE'
     ,'ASSIGNMENT IN JD WITHIN GRE FISCAL YEAR TO DATE'
     ,'SUBJECT TO TAX FOR ASSIGNMENT WITHIN GRE PERIOD TO DATE'
     ,'SUBJECT TO TAX FOR ASSIGNMENT WITHIN GRE QUARTER TO DATE'
     ,'ASSIGNMENT SOURCE ID PERIOD TO DATE'
     ,'ASSIGNMENT SOURCE TEXT PERIOD TO DATE'
     ,'ASSIGNMENT GRE ST2 SN PERIOD TO DATE'
     ,'ELEMENT PERIOD TO DATE'
     ,'ELEMENT INCEPTION TO DATE'
     ,'SUBJECT TO TAX FOR ASSIGNMENT WITHIN GRE YEAR TO DATE') then
     return (TRUE);
   else
     return (FALSE);
   end if;
   --
   hr_utility.trace('Exiting pay_bf_bal_upload.is_supported');
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
  --  p_tax_unit_id        - TAX_UNIT_ID context.
  --  p_jurisdiction_code  - JURISDICTION_CODE context.
  --  p_original_entry_id  - ORIGINAL_ENTRY_ID context.
  --  p_source_id          - SOURCE_ID context.
  --  p_source_text        - SOURCE_TEXT context.
  --  p_bal_adjustment_rec - details of an existing balance adjustment.
  -- USES
  -- NOTES
  --  All the BF dimensions affect each other when they share the same context
  --  values so there is no special support required for individual dimensions.
  --  This is used by pay_balance_upload.get_current_value.
  -----------------------------------------------------------------------------
 --
 function include_adjustment
 (
  p_balance_type_id    number
 ,p_dimension_name     varchar2
 ,p_jurisdiction_code  varchar2
 ,p_original_entry_id  number
 ,p_tax_unit_id        number
 ,p_assignment_id      number
 ,p_upload_date        date
 ,p_source_id          number
 ,p_source_text        varchar2
 ,p_bal_adjustment_rec pay_balance_upload.csr_balance_adjustment%rowtype
 ) return boolean is
   --
   -- Does the balance adjustment effect the new balance dimension.
   --
   cursor csr_is_included
     (
      p_balance_type_id           number
     ,p_tax_unit_id               number
     ,p_jurisdiction_code         varchar2
     ,p_original_entry_id         number
     ,p_source_id                 number
     ,p_source_text               varchar2
     ,p_bal_adj_tax_unit_id       number
     ,p_bal_adj_jurisdiction_code varchar2
     ,p_bal_adj_original_entry_id number
     ,p_bal_adj_source_id         number
     ,p_bal_adj_source_text       varchar2
     ) is
     select BT.balance_type_id
     from   pay_balance_types BT
     where  BT.balance_type_id = p_balance_type_id
	    --
	    -- JURISDICTION_CODE context NB. if the jurisdiction code is
	    -- used then only those adjustments which are for the same
	    -- jurisdiction code can be included.
	    --
       and  ((p_jurisdiction_code is null)    or
 	     (p_jurisdiction_code is not null and
 	      substr(p_bal_adj_jurisdiction_code, 1, BT.jurisdiction_level)  =
              substr(p_jurisdiction_code        , 1, BT.jurisdiction_level)))
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
	    -- SOURCE_ID and SOURCE_TEXT contexts.
       and  nvl(p_bal_adj_source_id, -1)
          = nvl(p_source_id, nvl(p_bal_adj_source_id, -1))
       and  nvl(p_bal_adj_source_text, '~nvl~')
          = nvl(p_source_text, nvl(p_bal_adj_source_text, '~nvl~'))
       and  1 = 1;
   --
   -- The balance returned by the include check.
   --
   l_bal_type_id number;
   --
   l_tax_unit_id number;
   --
 begin
   --
   hr_utility.trace('Entering pay_bf_bal_upload.include_adjustment');
   --
   -- Get the tax unit.
   --
   l_tax_unit_id := p_tax_unit_id;
   --
   -- Does the balance adjustment effect the new balance ?
   --
   open  csr_is_included(p_balance_type_id
                        ,l_tax_unit_id
                        ,p_jurisdiction_code
                        ,p_original_entry_id
                        ,p_source_id
                        ,p_source_text
                        ,p_bal_adjustment_rec.tax_unit_id
                        ,p_bal_adjustment_rec.jurisdiction_code
                        ,p_bal_adjustment_rec.original_entry_id
                        ,p_bal_adjustment_rec.source_id
                        ,p_bal_adjustment_rec.source_text);
   fetch csr_is_included into l_bal_type_id;
   close csr_is_included;
   --
   hr_utility.trace('Exiting pay_bf_bal_upload.include_adjustment');
   --
   -- Adjustment does contribute to the new balance.
   --
   if l_bal_type_id is not null then
     return (TRUE);
   --
   -- Adjustment does not contribute to the new balance.
   --
   else
     return (FALSE);
   end if;
   --
 end include_adjustment;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  validate_batch_lines
  -- PURPOSE
 --   Applies BF specific validation to the batch.
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
   hr_utility.trace('Entering pay_bf_bal_upload.validate_batch_lines');
   --
   hr_utility.trace('Exiting pay_bf_bal_upload.validate_batch_lines');
   --
 end validate_batch_lines;
 --
end pay_bf_bal_upload;

/
