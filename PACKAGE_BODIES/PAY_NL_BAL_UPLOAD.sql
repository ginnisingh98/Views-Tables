--------------------------------------------------------
--  DDL for Package Body PAY_NL_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NL_BAL_UPLOAD" as
/* $Header: pynlupld.pkb 115.3 2003/09/15 23:13:56 karajago noship $ */
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
      where legislation_code='NL'
      and rule_type = 'L';

  -- Holds the legislative start date
      l_leg_start          pay_legislation_rules.rule_mode%TYPE;

  -- Returns the start date of the first period of the tax year in which
  -- the upload date falls.

-- 1)  to_char(to_date(p_upload_date,'DD/MM/YYYY'),'YYYY')
--     retuned incorrect output depening on the date setting
--     of the env. to_date(p_upload_date,'DD/MM/YYYY') is not needed as
--      p_upload_date is a date!
-- 2)   if the upload it being done on say 01-jan-2003, it would return null
--      record as below condition will not be fulfilled
--      ptp2.start_date between
--      to_date(l_leg_start||to_char(to_date(
--      p_upload_date,'DD/MM/YYYY'),'YYYY'),'DD/MM/YYYY')
--      and ptp.end_date;
--      But due to 1, condition 2 did not happen and it returned the
--      first period of the payroll which is incorrect.
--      if 1 is fixed ,  then condtion 2 would occur.


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

   -- Generic start date variable.
   l_start_date            date;

   -- Holds the assignment start date.
   l_asg_itd_start_date    date;

   --Holds the LQTD start date.
   l_lqtd_start_date date;

   --Holds month start date
   l_month_start_date date;

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

   --Used for _ASG_LQTD expiry date calculation
   begin_date date;
   end_date date;

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

   --Holds the tax year start date for the upload process
   l_tax_year date;
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

     elsif p_dimension_name in ('ASSIGNMENT PERIOD TO DATE', 'ASSIGNMENT SI TYPE PERIOD TO DATE','ASSIGNMENT RUN','ASSIGNMENT SI TYPE RUN') then

         -- Calculate expiry date for _ASG_PTD, _ASG_PRSI_PTD dimension.
         -- What is the current period start date?
         open csr_period_start(p_assignment_id, p_upload_date);
         fetch csr_period_start into l_start_date;
         close csr_period_start;
         l_expiry_date := greatest(l_start_date, l_asg_itd_start_date);

     elsif p_dimension_name  in ('ASSIGNMENT YEAR TO DATE', 'ASSIGNMENT SI TYPE YEAR TO DATE') then

         open csr_tax_start_date;
  	     fetch csr_tax_start_date into l_leg_start;
         close csr_tax_start_date;

        -- Calculate expiry date for _ASG_YTD and _ASG_PRSI_YTD dimension.
        -- What is the current tax year start date?
        -- calculate the the payroll start date
         open csr_payroll_start_date(p_assignment_id, p_upload_date);
         fetch csr_payroll_start_date into l_start_date;
         close csr_payroll_start_date;
         -- calculate the tax year start date for the upload process
         l_tax_year :=  to_date(l_leg_start || to_char(p_upload_date,'YYYY'),'DD/MM/YYYY');

        -- calculate the expiry date
         l_expiry_date := greatest(l_start_date, l_asg_itd_start_date,
                                   l_tax_year );

     elsif p_dimension_name  in ('ASSIGNMENT SI TYPE MONTH', 'ASSIGNMENT MONTH') then
         -- calculate the the payroll start date
         open csr_payroll_start_date(p_assignment_id, p_upload_date);
         fetch csr_payroll_start_date into l_start_date;
         close csr_payroll_start_date;
         l_month_start_date := trunc(p_upload_date,'MM') ;
      	 l_expiry_date := greatest(l_month_start_date,l_start_date,l_asg_itd_start_date);

     elsif p_dimension_name  in ('ASSIGNMENT QUARTER TO DATE','ASSIGNMENT SI TYPE QUARTER TO DATE') then
         -- calculate the qtr start date
         l_qtr_start_date :=  trunc(p_upload_date,'Q');

         -- calculate the the payroll start date
         open csr_payroll_start_date(p_assignment_id, p_upload_date);
         fetch csr_payroll_start_date into l_start_date;
         close csr_payroll_start_date;

         -- calculate the expiry date
         l_expiry_date := greatest(l_start_date,  l_asg_itd_start_date,
                                   l_qtr_start_date );

      elsif p_dimension_name in ('ASSIGNMENT LUNAR QUARTER TO DATE') then
         -- calculate the the payroll start date
         open csr_payroll_start_date(p_assignment_id, p_upload_date);
         fetch csr_payroll_start_date into l_start_date;
         close csr_payroll_start_date;

         -- calculate the tax year satrt date
         open csr_tax_start_date;
  	     fetch csr_tax_start_date into l_leg_start;
         close csr_tax_start_date;
                 -- calculate the tax year start date for the upload process

         l_tax_year :=  to_date(l_leg_start ||
                                to_char(p_upload_date,'YYYY'),'DD/MM/YYYY');
         -- Derive Lunar Quarter Start Date
         SELECT l_tax_year - to_char(l_tax_year,'D') + 2
                 + (84*(decode(trunc((to_number((to_char(p_upload_date,'IW')))-1)/12),4,3,trunc((to_number((to_char(p_upload_date,'IW')))-1)/12))))
         INTO   l_lqtd_start_date
         FROM dual;

 	     l_expiry_date :=greatest(l_lqtd_start_date,l_asg_itd_start_date,l_start_date);

     elsif p_dimension_name in  ('_PAYMENTS','ASSIGNMENT INCEPTION TO DATE') then
        -- Calculate expiry date for _PAYMENTS and '_ASG_ITD' dimensions.
        l_expiry_date := l_asg_itd_start_date;

     elsif p_dimension_name in  ('_ELEMENT_ITD') then
        --
        -- Calculate expiry date for _ELEMENT_ITD dimensions.
        --
        open  csr_ele_itd_start(p_assignment_id
                              ,p_upload_date
                    			    ,p_original_entry_id);
        fetch csr_ele_itd_start into l_ele_itd_start_date;
        close csr_ele_itd_start;
        -- Set the expiry date.
        l_expiry_date := greatest(l_ele_itd_start_date,l_asg_itd_start_date);
        --
     end if;

--   HR_UTILITY.TRACE_OFF;
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
   --  Only a subset of the NL dimensions are supported.
   --  This is used by pay_balance_upload.validate_dimension.
   -----------------------------------------------------------------------------
   function is_supported
   (
      p_dimension_name varchar2
   ) return number is

   p_dimension_name_temp varchar2(100);
	   begin


      hr_utility.trace('Entering pay_nl_bal_upload.is_supported stub');

      -- See if the dimension is supported.


      if p_dimension_name in
      (
         'ASSIGNMENT YEAR TO DATE','ASSIGNMENT SI TYPE YEAR TO DATE',
         'ASSIGNMENT PERIOD TO DATE','ASSIGNMENT SI TYPE PERIOD TO DATE',
         'ASSIGNMENT QUARTER TO DATE','ASSIGNMENT SI TYPE QUARTER TO DATE','ASSIGNMENT LUNAR QUARTER TO DATE',
         'ASSIGNMENT INCEPTION TO DATE','ASSIGNMENT MONTH','ASSIGNMENT SI TYPE MONTH'
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

      hr_utility.trace('Exiting pay_nl_bal_upload.is_supported stub');

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


    	  CURSOR csr_bal_adj(p_test_batch_line_id NUMBER, p_batch_line_id NUMBER) IS
	  SELECT tba.source_text,tba.balance_type_id
	  FROM   pay_temp_balance_adjustments tba,
    		 pay_balance_batch_lines bbl
	  WHERE  tba.batch_line_id = p_test_batch_line_id
	  AND    bbl.batch_line_id = p_batch_line_id;

	  l_source_text1 varchar2(10);
	  l_return Number := 0;--True
          v_cur_bal_adj csr_bal_adj%rowtype;
   begin
       hr_utility.trace('Entering pay_nl_bal_upload.include_adjustment stub');

       --Select source text of the current batch line
       select source_text into l_source_text1 from pay_balance_batch_lines where batch_line_id=p_batch_line_id;

       --For context balances
       if l_source_text1 is not null then
       open csr_bal_adj(p_test_batch_line_id,p_batch_line_id);
       FETCH csr_bal_adj INTO v_cur_bal_adj;

       --Two different dimensions of the same balance and same context, hence adjustment needs to be done
       if v_cur_bal_adj.source_text=l_source_text1 and v_cur_bal_adj.balance_type_id=p_balance_type_id then
        	l_return := 1;
       end if;

       --If no other dimension of the same balance has been processed before
       IF csr_bal_adj%NOTFOUND THEN
         	l_return  := 0; -- false
       END IF;
       CLOSE csr_bal_adj;


       --For non context balances , adjustment should be done
       else
		l_return := 1;
       end if;





      hr_utility.trace('Exiting pay_nl_bal_upload.include_adjustment stub');

      return l_return;


   end include_adjustment;

   -----------------------------------------------------------------------------
   -- NAME
   --  validate_batch_lines
   -- PURPOSE
   --  Applies NL specific validation to the batch.
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

      hr_utility.trace('Entering pay_nl_bal_upload.validate_batch_lines stub');

      hr_utility.trace('Exiting pay_nl_bal_upload.validate_batch_lines stub');

   end validate_batch_lines;

end pay_nl_bal_upload;

/
