--------------------------------------------------------
--  DDL for Package Body PAY_KW_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KW_BAL_UPLOAD" as
 --  $Header: pykwbaup.pkb 120.0 2006/04/09 23:44:25 adevanat noship $

  --  Copyright (c) 1999 Oracle Corporation
  --  All rights reserved

  --  Date        Author   Bug/CR Num Notes
  --  -----------+--------+----------+-----------------------------------------
  --  15-Feb-06	  Anand MD            Initial Version


  g_package                       constant varchar2(240) := 'pay_kw_bal_upload.';

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
      where legislation_code='KW'
      and rule_type = 'L';


  -- Holds the legislative start date
      l_leg_start          pay_legislation_rules.rule_mode%TYPE;

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


  -- Returns the start date of the assignment on the upload date.
  CURSOR csr_asg_start_date
   (
      p_assignment_id NUMBER,
      p_upload_date   DATE
   ) IS
   SELECT NVL(MIN(ass.effective_start_date), END_OF_TIME)
   FROM per_assignments_f ass
   WHERE ass.assignment_id = p_assignment_id
   AND ass.payroll_id IS NOT NULL
   AND ass.effective_start_date <= p_upload_date;


  -- Returns the start date of the payroll
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



  l_start_date                  DATE;

  -- Holds assignment start date
  l_asg_start_date              DATE;

  -- Holds the start of the calendar year for the upload date.
  l_cal_yr_start_date           DATE;

  -- Holds the start of the statutory year for the upload date.
  l_tax_yr_start_date           DATE;


  --Holds the tax year start date for the upload process
  l_tax_year			DATE;

  -- Holds the expiry date of the dimension.
  l_expiry_date                 DATE;

  BEGIN



  -- Calculate the expiry date for the specified dimension relative to the
  -- upload date, taking into account any contexts where appropriate. Each of
  -- the calculations also takes into account when the assignment is on a
  -- payroll to ensure that a balance adjustment could be made at that point
  -- if it were required.
      open csr_asg_start_date(p_assignment_id, p_upload_date);
	fetch csr_asg_start_date into l_asg_start_date;
      close csr_asg_start_date;

      IF p_dimension_name in ('_ASG_PTO_YTD','_ASG_PTO_SM_YTD','_ASG_PTO_DE_YTD','_ASG_PTO_HD_YTD','_ASG_PTO_DE_SM_YTD','_ASG_PTO_DE_HD_YTD') THEN

      -- What is the current tax year start date?
      OPEN csr_tax_start_date;
  	     FETCH csr_tax_start_date INTO l_leg_start;
      CLOSE csr_tax_start_date;

        -- calculate the the payroll start date
         OPEN csr_payroll_start_date(p_assignment_id, p_upload_date);
		FETCH csr_payroll_start_date INTO l_start_date;
         CLOSE csr_payroll_start_date;

         -- calculate the tax year start date for the upload process
         l_tax_year :=  to_date(l_leg_start || to_char(p_upload_date,'YYYY'),'DD/MM/YYYY');

        -- calculate the expiry date
         l_expiry_date := greatest(l_start_date, l_asg_start_date,
                                   l_tax_year );


      END IF;


      RETURN nvl(l_expiry_date,END_OF_TIME);

      EXCEPTION
        WHEN no_data_found THEN
           l_expiry_date := END_OF_TIME;
        RETURN l_expiry_date;

    END expiry_date;
-----------------------------------------------------------------------------
  -- NAME
  --  is_supported
  -- PURPOSE
  --  Checks if the dimension is supported by the upload process.
  -- ARGUMENTS
  --  p_dimension_name - the balance dimension to be checked.
  -- USES
  -- NOTES
  --  This is used by pay_balance_upload.validate_dimension.
  -----------------------------------------------------------------------------
 --
 function is_supported
 (
  p_dimension_name varchar2
 ) return number is
 begin
   --
   hr_utility.trace('Entering pay_kw_bal_upload.is_supported');
   --
   -- See if the dimension is supported.
   --
   if p_dimension_name in
     ('_ASG_PTO_YTD'
     ,'_ASG_PTO_SM_YTD'
     ,'_ASG_PTO_DE_YTD'
     ,'_ASG_PTO_HD_YTD'
     ,'_ASG_PTO_DE_SM_YTD'
     ,'_ASG_PTO_DE_HD_YTD'
     ) then
     return (1);  -- denotes TRUE
   else
     return (0);  -- denotes FALSE
   end if;
   --
   hr_utility.trace('Exiting pay_kw_bal_upload.is_supported');
   --
 end is_supported;
 --

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
       hr_utility.trace('Entering pay_kw_bal_upload.include_adjustment stub');

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





      hr_utility.trace('Exiting pay_kw_bal_upload.include_adjustment stub');

      return l_return;


   end include_adjustment;
   --
  -----------------------------------------------------------------------------
  -- name
  --  validate_batch_lines
  -- purpose
  --   applies bf specific validation to the batch.
  -- arguments
  --  p_batch_id - the batch to be validate_batch_lines.
  -- uses
  -- notes
  --  this is used by pay_balance_upload.validate_batch_lines.
  -----------------------------------------------------------------------------

  procedure validate_batch_lines( p_batch_id number ) is
  begin

    hr_utility.trace('Entering '||g_package||'validate_batch_lines');

    hr_utility.trace('Exiting '||g_package||'validate_batch_lines');

  end validate_batch_lines;

end pay_kw_bal_upload;

/
