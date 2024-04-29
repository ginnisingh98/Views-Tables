--------------------------------------------------------
--  DDL for Package Body PAY_IE_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_BAL_UPLOAD" as
/* $Header: pyieupld.pkb 120.1 2006/06/09 09:31:45 vikgupta noship $ */
/*
 Copyright (c) Oracle Corporation 1995 All rights reserved
 PRODUCT
  Oracle*Payroll
 NAME
  pyieupld.pkb
 DESCRIPTION
  Provides support for the upload of balances based on IE dimensions.
 EXTERNAL
  expiry_date
  include_adjustment
  is_supported
  validate_batch_lines
 INTERNAL
 MODIFIED (DD-MON-YYYY)
  115.0  vnatari    31-Jan-2002         created.
  115.1  vmkhande   11-mar-2003         fixed bug 2836853.
  115.2  vmkhande   16-apr-2003         Added support for
                                        ASG_QTD
  115.3  viviswan   02-may-2003 2933807 Added support for
                                        _ELEMENT_ITD
  115.4  vmkhande   01-sep-2003         Added logic to
                                        include_adjustment
  115.5  vmkhande   27-JAN-2004         Added support for
                                        _ELEMENT_YTD
  115.6  vikgupta   31-MAY-2006         fixed bug 5258159
 */
   --
   -- Date constants.
   --
   START_OF_TIME constant date := to_date('01/01/0001','DD/MM/YYYY');
   END_OF_TIME   constant date := to_date('31/12/4712','DD/MM/YYYY');
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
   --  expiry date knows this rule and acts accordingly.
   -----------------------------------------------------------------------------
   function expiry_date
   (
      p_upload_date       date,
      p_dimension_name    varchar2,
      p_assignment_id     number,
      p_original_entry_id number
   ) return date is
    -- Returns the legislative start date
    cursor csr_tax_start_date   is
     select rule_mode
      from pay_legislation_rules
      where legislation_code='IE'
      and rule_type = 'L';
  -- Holds the legislative start date
      l_leg_start          pay_legislation_rules.rule_mode%TYPE;
  -- Returns the start date of the first period of the tax year in which
  -- the upload date falls.
--  2836853.
--  csr_tax_year_start is incorrect .
-- 1)  to_char(to_date(p_upload_date,'DD/MM/YYYY'),'YYYY')
--     retuned incorrect output depening on the date setting
--     of the env. to_date(p_upload_date,'DD/MM/YYYY') is not needed as
--      p_upload_date is a date!
-- 2)   if the upload it being done on say 01-jan-2003, it would return null
--      record as below condition will not be
--      fulfilled
--  ptp2.start_date between
--    to_date(l_leg_start||to_char(to_date(
--            p_upload_date,'DD/MM/YYYY'),'YYYY'),'DD/MM/YYYY')
--      and ptp.end_date;
--      But due to 1, condition 2 did not happen and it returned the
--      first period of the payroll which is incorrect.
--      if 1 is fixed ,  then condtion 2 would occur.
-- the above errors resulted in payroll_action_id's being
-- created with incorrect effective date This is now changed such that the
-- expiry date is the greatest of the tax year start date 01/01/YYYY
-- the payroll_start_date, and the assignment start date.
/*
   cursor csr_tax_year_start
   (
      p_assignment_id number,
      p_upload_date   date
   ) is
   select
      nvl(min(ptp2.start_date), END_OF_TIME)
   from
      per_time_periods ptp,per_time_periods ptp2,per_assignments_f ass
   where
      ass.assignment_id = p_assignment_id
   and
      p_upload_date between ass.effective_start_date and ass.effective_end_date
   and
      ptp.payroll_id = ass.payroll_id
   and
      ptp2.payroll_id = ptp.payroll_id
   and
      p_upload_date between ptp.start_date and ptp.end_date
   and
      ptp2.start_date between to_date(l_leg_start||to_char(to_date(p_upload_date,'DD/MM/YYYY'),'YYYY'),'DD/MM/YYYY')
      and ptp.end_date;
*/
   -- Returns the start date of the current period on the upload date.
   cursor csr_period_start
   (
      p_assignment_id number,
      p_upload_date   date
   ) is
   select
      nvl(ptp.start_date, END_OF_TIME)
   from
      per_time_periods ptp, per_assignments_f ass
   where
      ass.assignment_id = p_assignment_id
   and
      ptp.payroll_id = ass.payroll_id
   and
      p_upload_date between ass.effective_start_date and ass.effective_end_date
   and
      p_upload_date between ptp.start_date and ptp.end_date;
   -- Returns the start date of the assignment.
   cursor csr_asg_itd_start
   (
      p_assignment_id number,
      p_upload_date   date
   ) is
   select
      nvl(min(ass.effective_start_date), END_OF_TIME)
   from
      per_assignments_f ass
   where
      ass.assignment_id = p_assignment_id
   and
      ass.payroll_id is not null
   and
      ass.effective_start_date <= p_upload_date;
   -- This cursor takes the assignment, the expiry_date and the upload_date
   -- and returns the next regular_payment_date after the expiry_date for
   -- that particular payroll.
-- unnecessary code!
/*
   cursor csr_regular_payment
   (
      l_assignment_id number,
      l_upload_date date,
      l_expiry_date date
   ) is
   select
      min(ptp.regular_payment_date)
   from
      per_time_periods ptp, per_assignments_f ass
   where
      ass.assignment_id = l_assignment_id
   and
      ptp.payroll_id = ass.payroll_id
   and
      l_upload_date between ass.effective_start_date and ass.effective_end_date
   and
   ptp.regular_payment_date between l_expiry_date and l_upload_date;
   -- This cursor takes the assignment, the expiry_date and the upload_date
   -- and returns the next regular_payment_date after the expiry_date for
   -- that particular payroll.
   cursor csr_regular_payment2
   (
      l_assignment_id number,
      l_upload_date date,
      l_expiry_date date
   ) is
   select
      ptp.regular_payment_date
   from
      per_time_periods ptp, per_assignments_f ass
   where
      ass.assignment_id = l_assignment_id
   and
      ptp.payroll_id = ass.payroll_id
   and
      l_upload_date between ass.effective_start_date and ass.effective_end_date
   and
      l_expiry_date between start_date and end_date;
*/
   -- Generic start date variable.
   l_start_date            date;
   -- Holds the assignment start date.
   l_asg_itd_start_date    date;
   -- Holds the first regular payment date after the expiry date of the dimension.
   l_regular_date          date;
   -- Holds the expiry date of the dimension.
   l_expiry_date           date;
   -- Holds the business group of the dimension.
   l_business_group_id     number;
   -- Holds the start date of the quarter.
   l_qtr_start_date     date;
   -- Holds theearliest date an element entry
   l_ele_itd_start_date    date;
   cursor csr_payroll_start_date    (
      p_assignment_id number,
      p_upload_date   date
   ) is
   select
      nvl(ppf.effective_start_date, END_OF_TIME)
   from
      per_all_assignments_f ass,
      pay_all_payrolls_f ppf
   where
      ass.assignment_id = p_assignment_id
   and p_upload_date between
        nvl(ass.effective_start_date,p_upload_date) and
        nvl(ass.effective_end_date,p_upload_date)
   and ppf.payroll_id = ass.payroll_id
   and p_upload_date between
                    nvl(ppf.effective_start_date,p_upload_date) and
                    nvl(ppf.effective_end_date,p_upload_date);
   --
   -- Bug 2933807 - Added _ELEMENT_ITD Dimension Support
   -- Returns the earliest date on which the element entry exists.
   --
   cursor csr_ele_itd_start
          (
           p_assignment_id     number
          ,p_upload_date       date
          ,p_original_entry_id number
          ) is
     select nvl(min(EE.effective_start_date), END_OF_TIME)
     from   pay_element_entries_f EE
     where  EE.assignment_id         = p_assignment_id
       and  (EE.element_entry_id      = p_original_entry_id or
	     EE.original_entry_id     = p_original_entry_id)
       and  EE.effective_start_date  <= p_upload_date;
   --
    l_tax_year date;
   --------------------------------------------------------------------------------------
   begin --                        Expiry_Date - Main                                  --
   --------------------------------------------------------------------------------------
      -- What is the start date of the assignment? All loading must come after this date.
--       HR_UTILITY.trace_on(null,'BIK');
      open csr_asg_itd_start(p_assignment_id, p_upload_date);
      fetch csr_asg_itd_start into l_asg_itd_start_date;
      close csr_asg_itd_start;
      hr_utility.trace('l_asg_itd_start_date' || to_char(l_asg_itd_start_date,'DD-MON-YYYY'));
      -- Return the date on which the dimension expires.
      if substr(p_dimension_name, 31, 4) = 'USER' then
         -- User balance
         select
            distinct business_group_id -- for bug 5258159 added distinct clause.
         into
            l_business_group_id
         from
            per_assignments_f
         where
            assignment_id = p_assignment_id;
         l_expiry_date := hr_gbbal.dimension_reset_date
                          (
                             p_dimension_name,
                             p_upload_date,
                             l_business_group_id
                          );
         l_expiry_date := greatest(l_expiry_date, l_asg_itd_start_date);
      elsif p_dimension_name in ('_ASG_PTD', '_ASG_PRSI_PTD') then
         -- Calculate expiry date for _ASG_PTD, _ASG_PRSI_PTD dimension.
         -- What is the current period start date?
         open csr_period_start(p_assignment_id, p_upload_date);
         fetch csr_period_start into l_start_date;
         close csr_period_start;
         l_expiry_date := greatest(l_start_date, l_asg_itd_start_date);
      elsif p_dimension_name  in ('_ASG_YTD', '_ASG_PRSI_YTD') then
         open csr_tax_start_date;
  	     fetch csr_tax_start_date into l_leg_start;
         close csr_tax_start_date;
         -- Calculate expiry date for _ASG_YTD and _ASG_PRSI_YTD dimension.
         -- What is the current tax year start date?
/*
         open csr_tax_year_start(p_assignment_id, p_upload_date);
         fetch csr_tax_year_start into l_start_date;
         close csr_tax_year_start;
*/
        -- calculate the the payroll start date
         open csr_payroll_start_date(p_assignment_id, p_upload_date);
         fetch csr_payroll_start_date into l_start_date;
         close csr_payroll_start_date;
         hr_utility.trace('l_start_date' || to_char(l_start_date,'DD-MON-YYYY'));
        -- calculate the tac year start date for the upload process
         l_tax_year :=  to_date(l_leg_start || to_char(p_upload_date,'YYYY'),'DD/MM/YYYY');
         hr_utility.trace('l_tax_year' || to_char(l_tax_year,'DD-MON-YYYY'));
        -- calculate the expiry date
         l_expiry_date := greatest(l_start_date, l_asg_itd_start_date,
                                   l_tax_year );
         hr_utility.trace('l_expiry_date ' || to_char(l_expiry_date,'DD-MON-YYYY'));
      elsif p_dimension_name  in ('_ASG_QTD') then
         -- calculate the qtr start date
         l_qtr_start_date :=  trunc(p_upload_date,'Q');
        -- calculate the the payroll start date
         open csr_payroll_start_date(p_assignment_id, p_upload_date);
         fetch csr_payroll_start_date into l_start_date;
         close csr_payroll_start_date;
         hr_utility.trace('l_start_date' || to_char(l_start_date,'DD-MON-YYYY'));
        -- calculate the expiry date
         l_expiry_date := greatest(l_start_date,  l_asg_itd_start_date,
                                   l_qtr_start_date );
         hr_utility.trace('l_expiry_date ' || to_char(l_expiry_date,'DD-MON-YYYY'));
       elsif p_dimension_name in  ('_PAYMENTS','_ASG_ITD') then
    --    Calculate expiry date for _PAYMENTS and '_ASG_ITD' dimensions.
        l_expiry_date := l_asg_itd_start_date;
       elsif p_dimension_name in  ('_ELEMENT_ITD','_ELEMENT_YTD') then
       --
       -- Bug 2933807 - Added _ELEMENT_ITD Dimension Support
       -- Calculate expiry date for _ELEMENT_ITD dimensions.
       --
       open  csr_ele_itd_start(p_assignment_id
                              ,p_upload_date
                    			    ,p_original_entry_id);
         fetch csr_ele_itd_start into l_ele_itd_start_date;
       close csr_ele_itd_start;
       -- Set the expiry date.
         open csr_period_start(p_assignment_id, p_upload_date);
         fetch csr_period_start into l_start_date;
         close csr_period_start;

       l_expiry_date := greatest(l_ele_itd_start_date,l_asg_itd_start_date,l_start_date);
       HR_UTILITY.trace('l_expiry_date ' || to_char(l_expiry_date,'dd-mon-yyyy'));
       --
       end if;
--     HR_UTILITY.TRACE_OFF;
      return nvl(l_expiry_date,END_OF_TIME);
   exception
      when no_data_found then
         l_expiry_date := END_OF_TIME;
         return l_expiry_date;
   end expiry_date;
   -----------------------------------------------------------------------------
   -- NAME
   --  is_supported
   -- PURPOSE
   --  Checks if the dimension is supported by the upload process.
   -- ARGUMENTS
   --  p_dimension_name - the balance dimension to be checked.
   -- USES
   -- NOTES
   --  Only a subset of the IE dimensions are supported.
   --  This is used by pay_balance_upload.validate_dimension.
   -----------------------------------------------------------------------------
   function is_supported
   (
      p_dimension_name varchar2
   ) return number is
   begin
--      hr_utility.trace_on(null,'BIK');
      hr_utility.trace('Entering pay_ie_bal_upload.is_supported stub');
      -- Bug 2933807 - Added _ELEMENT_ITD Dimension
      -- See if the dimension is supported.
      if p_dimension_name in
      (
         '_ASG_YTD',
         '_ASG_PTD',
         '_ASG_PRSI_YTD',
         '_ASG_PRSI_PTD',
         '_PAYMENTS',
         '_ELEMENT_ITD',
         '_ASG_ITD',
         '_ASG_QTD',
         '_ELEMENT_YTD'
      )
      or
      (
         substr(p_dimension_name, 31, 4) = 'USER'
         and
         substr(p_dimension_name, 40, 3) = 'ASG'
      )
      then
         return 1;
      else
         return 0;
      end if;
      hr_utility.trace('Exiting pay_ie_bal_upload.is_supported stub');
   end is_supported;
   -----------------------------------------------------------------------------
   -- NAME
   --  include_adjustment
   -- PURPOSE
   --  Given a dimension, and relevant contexts and details of an existing
   --  balance adjustment, it will find out if the balance adjustment effects
   --  the dimension to be set. Both the dimension to be set and the adjustment
   --  are for the same assignment and balance.
   -- ARGUMENTS
   --  p_balance_type_id    - the balance to be set.
   --  p_dimension_name     - the balance dimension to be set.
   --  p_original_entry_id  - ORIGINAL_ENTRY_ID context.
   --  p_bal_adjustment_rec - details of an existing balance adjustment.
   --  p_test_batch_line_id -
   -- USES
   -- NOTES
   --  This is used by pay_balance_upload.get_current_value.
   -----------------------------------------------------------------------------
   function include_adjustment
   (
      p_balance_type_id    number,
      p_dimension_name     varchar2,
      p_original_entry_id  number,
      p_upload_date        date,
      p_batch_line_id      number,
      p_test_batch_line_id number
   ) return number is
   	CURSOR csr_bal_adj_source_text (p_test_batch_line_id NUMBER, p_batch_line_id NUMBER) IS
	  SELECT tba.SOURCE_TEXT
	  FROM   pay_temp_balance_adjustments tba,
    		 pay_balance_batch_lines bbl
	  WHERE  tba.batch_line_id = p_test_batch_line_id
	  AND    bbl.batch_line_id = p_batch_line_id
	  AND    tba.SOURCE_TEXT like nvl(bbl.SOURCE_TEXT,'%');
-- Note above: included the like condiditon as for PRSI balances
-- ASG_YTd dim source text will be null! as a result
-- it could mean that bal adj does not happen, which would be incorrect
-- we should let the bal adj happen for ASG_YTD and ASG_PTD

	CURSOR csr_bal_adj_orig_entry_id (p_test_batch_line_id NUMBER, p_batch_line_id NUMBER) IS
	  SELECT tba.original_entry_id
	  FROM   pay_temp_balance_adjustments tba,
		     pay_balance_batch_lines bbl
	  WHERE  tba.batch_line_id = p_test_batch_line_id
	  AND    bbl.batch_line_id = p_batch_line_id
	  AND    tba.original_entry_id = bbl.original_entry_id;

   l_source_text varchar2(10);
   l_return Number := 1;--True
   l_original_entry_id Number;
   Begin
      hr_utility.trace('Entering pay_ie_bal_upload.include_adjustment stub');
      Open csr_bal_adj_source_text(p_test_batch_line_id,p_batch_line_id);
   	  FETCH csr_bal_adj_source_text INTO l_source_text;
  	  IF csr_bal_adj_source_text%NOTFOUND THEN
          	l_return  := 0; -- false
	  END IF;
      CLOSE csr_bal_adj_source_text;
      -- the below will ensure that bal adjustment is done if the
      -- original entry_id is same.
      If p_dimension_name in ('_ELEMENT_YTD','_ELEMENT_ITD')
      Then
         Open csr_bal_adj_orig_entry_id(p_test_batch_line_id,p_batch_line_id);
         Fetch csr_bal_adj_orig_entry_id into l_original_entry_id;
         If  csr_bal_adj_orig_entry_id%NOTFOUND then
          	l_return  := 0; -- false
         End If;
         Close csr_bal_adj_orig_entry_id;
      End if;
      hr_utility.trace('Exiting pay_ie_bal_upload.include_adjustment l_return:' ||l_return );
      Return l_return;
   End include_adjustment;
   -----------------------------------------------------------------------------
   -- NAME
   --  validate_batch_lines
   -- PURPOSE
   --  Applies IE specific validation to the batch.
   -- ARGUMENTS
   --  p_batch_id - the batch to be validate_batch_linesd.
   -- USES
   -- NOTES
   --  This is used by pay_balance_upload.validate_batch_lines.
   -----------------------------------------------------------------------------
   procedure validate_batch_lines
   (
      p_batch_id number
   ) is
   begin
      hr_utility.trace('Entering pay_ie_bal_upload.validate_batch_lines stub');
      hr_utility.trace('Exiting pay_ie_bal_upload.validate_batch_lines stub');
   end validate_batch_lines;
end pay_ie_bal_upload;

/
