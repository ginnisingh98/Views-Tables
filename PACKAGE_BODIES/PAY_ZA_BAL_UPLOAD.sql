--------------------------------------------------------
--  DDL for Package Body PAY_ZA_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ZA_BAL_UPLOAD" as
/* $Header: pyzaupld.pkb 120.5 2006/10/11 11:14:37 rpahune noship $ */
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

   -- Returns the start date of the first period of the tax year in which
   -- the upload date falls.
   cursor csr_tax_year_start
   (
      p_assignment_id number,
      p_upload_date   date
   ) is
   select
      nvl(min(ptp2.start_date), END_OF_TIME)
   from
      per_time_periods ptp, per_time_periods ptp2, per_assignments_f ass
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
      ptp2.prd_information1 = ptp.prd_information1;

   -- Returns the start date of the first period of the tax quarter in which
   -- the upload date falls.
   cursor csr_tax_quarter_start
   (
      p_assignment_id number,
      p_upload_date   date
   ) is
   select
      nvl(min(ptp2.start_date), END_OF_TIME)
   from
      per_time_periods ptp, per_time_periods ptp2, per_assignments_f ass
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
      ptp2.prd_information1 = ptp.prd_information1
   and
      ptp2.prd_information2 = ptp.prd_information2;

   -- Returns the start date of the first period of the Payroll Month in which
   -- the upload date falls.
   cursor csr_month_start
   (
      p_assignment_id number,
      p_upload_date   date
   ) is
   select
      nvl(min(ptp2.start_date), END_OF_TIME)
   from
      per_time_periods ptp, per_time_periods ptp2, per_assignments_f ass
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
      ptp2.pay_advice_date = ptp.pay_advice_date;

   -- Returns the start date of the first period of the calendar year in which
   -- the upload date falls.
   cursor csr_calendar_year_start
   (
      p_assignment_id number,
      p_upload_date   date
   ) is
   select
      nvl(min(ptp2.start_date), END_OF_TIME)
   from
      per_time_periods ptp, per_time_periods ptp2, per_assignments_f ass
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
      ptp2.prd_information3 = ptp.prd_information3;

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

   --------------------------------------------------------------------------------------
   begin --                        Expiry_Date - Main                                  --
   --------------------------------------------------------------------------------------

      -- What is the start date of the assignment? All loading must come after this date.
      open csr_asg_itd_start(p_assignment_id, p_upload_date);
      fetch csr_asg_itd_start into l_asg_itd_start_date;
      close csr_asg_itd_start;


      -- Return the date on which the dimension expires.
      if substr(p_dimension_name, 31, 4) = 'USER' then

         -- User balance
         select
            business_group_id
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

      elsif p_dimension_name in ('_ASG_CAL_PTD', '_ASG_TAX_PTD') then

         -- Calculate expiry date for _ASG_CAL_PTD, _ASG_TAX_PTD dimension.
         -- What is the current period start date?
         open csr_period_start(p_assignment_id, p_upload_date);
         fetch csr_period_start into l_start_date;
         close csr_period_start;

         l_expiry_date := greatest(l_start_date, l_asg_itd_start_date);

      elsif p_dimension_name in ('_ASG_CAL_MTD', '_ASG_TAX_MTD') then

         -- Calculate expiry date for _ASG_CAL_MTD, _ASG_TAX_MTD dimension.
         -- What is the current payroll month start date?
         open csr_month_start(p_assignment_id, p_upload_date);
         fetch csr_month_start into l_start_date;
         close csr_month_start;

         l_expiry_date := greatest(l_start_date, l_asg_itd_start_date);

      elsif p_dimension_name = '_ASG_TAX_QTD' then

         -- Calculate expiry date for _ASG_TAX_QTD dimension.
         -- What is the current tax quarter start date?
         open csr_tax_quarter_start(p_assignment_id, p_upload_date);
         fetch csr_tax_quarter_start into l_start_date;
         close csr_tax_quarter_start;

         l_expiry_date := greatest(l_start_date, l_asg_itd_start_date);

      elsif p_dimension_name in ('_ASG_TAX_YTD'
                                ,'_ASG_CLRNO_TAX_YTD'
                                ,'_ASG_LMPSM_TAX_YTD') then

         -- Calculate expiry date for _ASG_TAX_YTD dimension.
         -- What is the current tax year start date?
         open csr_tax_year_start(p_assignment_id, p_upload_date);
         fetch csr_tax_year_start into l_start_date;
         close csr_tax_year_start;

         l_expiry_date := greatest(l_start_date, l_asg_itd_start_date);

      elsif p_dimension_name = '_ASG_CAL_YTD' then

         -- Calculate expiry date for _ASG_CAL_YTD dimension.
         -- What is the current calendar year start date?
         open csr_calendar_year_start(p_assignment_id, p_upload_date);
         fetch csr_calendar_year_start into l_start_date;
         close csr_calendar_year_start;

         l_expiry_date := greatest(l_start_date, l_asg_itd_start_date);

      elsif p_dimension_name = '_ASG_ITD' then

         -- Calculate expiry date for _ASG_ITD dimension.
         l_expiry_date := l_asg_itd_start_date;

      end if;

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
   --  Only a subset of the ZA dimensions are supported.
   --  This is used by pay_balance_upload.validate_dimension.
   -----------------------------------------------------------------------------
   function is_supported
   (
      p_dimension_name varchar2
   ) return number is
   begin

      hr_utility.trace('Entering pay_za_bal_upload.is_supported stub');
-- Commneted bug no 5594502
--      hr_utility.trace_on(null,'ZABal');
      -- See if the dimension is supported.
      if p_dimension_name in
      (
         '_ASG_TAX_YTD',
         '_ASG_TAX_QTD',
         '_ASG_TAX_PTD',
         '_ASG_TAX_MTD',
         '_ASG_CAL_YTD',
         '_ASG_CAL_MTD',
         '_ASG_ITD',
	 '_ASG_CLRNO_TAX_YTD',
	 '_ASG_LMPSM_TAX_YTD'
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

      hr_utility.trace('Exiting pay_za_bal_upload.is_supported stub');

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
   begin

      hr_utility.trace('Entering pay_za_bal_upload.include_adjustment stub');

      hr_utility.trace('Exiting pay_za_bal_upload.include_adjustment stub');

      return 1;

   end include_adjustment;

   -----------------------------------------------------------------------------
   -- NAME
   --  validate_batch_lines
   -- PURPOSE
   --  Applies ZA specific validation to the batch.
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

      hr_utility.trace('Entering pay_za_bal_upload.validate_batch_lines stub');

      hr_utility.trace('Exiting pay_za_bal_upload.validate_batch_lines stub');

   end validate_batch_lines;

end pay_za_bal_upload;

/
