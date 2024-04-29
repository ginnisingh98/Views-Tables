--------------------------------------------------------
--  DDL for Package Body PAY_CA_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_BAL_UPLOAD" AS
/* $Header: pycaupld.pkb 115.4 2003/03/28 01:43:42 pganguly ship $ */
/*
 Copyright (c) Oracle Corporation 1995 All rights reserved
 PRODUCT
  Oracle*Payroll
 NAME
  pycaupld.pkb
 DESCRIPTION
  Stub File.
  Provides support for the upload of balances based on CA dimensions.
 EXTERNAL
  get_tax_unit
  get_source_id
  expiry_date
  include_adjustment
  is_supported
  validate_batch_lines
 INTERNAL
 MODIFIED (DD-MON-YYYY)
  110.0  A.Logue   11-Jul-1997        created.
  115.1  JARTHURT  05-JAN-2001        Updates to add required Canadian balance
                                      dimensions and comply with new dynamic
                                      SQL calls from pay_balance_upload.
  115.2  JARTHURT  15-JAN-2001        Corrected balance dimension list and
                                      month truncation.
  115.3  JARTHURT  22-JAN-2001        Corrected type of jurisdiction_code
  115.3  PGANGULY  27-MAR-2003        Added the following dimensions in the
                                      is_supported, expiry_date functions:
                                      Assignment within Reporting Unit Year to
                                      Date/Month. Fixed Bug# 2859270. Added
                                      dbdrv, set verify off for GSCC.
*/
 --
 -- Date constants.
 --
 START_OF_TIME constant date := to_date('01/01/0001','DD/MM/YYYY');
 END_OF_TIME   constant date := to_date('31/12/4712','DD/MM/YYYY');
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
  --  expiry date knows this rule and acts accordingly.
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
   cursor csr_ele_itd_start
          (
           p_assignment_id     number
          ,p_upload_date       date
          ) is
     select nvl(min(ASG.effective_start_date), END_OF_TIME)
     from   per_all_assignments_f   ASG
     where  ASG.assignment_id         = p_assignment_id
       and  ASG.effective_start_date <= p_upload_date;
   --
   cursor csr_asg_start_date
     (p_assignment_id number
     ,p_upload_date   date
     ,p_expiry_date   date
     ) is
     select nvl(greatest(min(ASS.effective_start_date), p_expiry_date),
                END_OF_TIME)
       from per_all_assignments_f ASS
      where ASS.assignment_id = p_assignment_id
        and ASS.effective_start_date <= p_upload_date
        and ASS.effective_end_date >= p_expiry_date;
   --
   --
   -- Holds the start of the tax year for the upload date.
   --
   l_tax_yr_start_date           date;
   --
   -- Holds the start of the tax month for the upload date.
   --
   l_tax_month_start_date        date;
   --
   -- Holds the earliest date on which the element entry exists.
   --
   l_ele_itd_start_date          date;
   --
   -- Holds the expiry date of the dimension.
   --
   l_prd_start_date              date;
   l_expiry_date                 date;
   --
 begin
   --
   --
   -- Calculate the expiry date for the specified dimension relative to the
   -- upload date, taking into account any contexts where appropriate. Each of
   -- the calculations also takes into account when the assignment is on a
   -- payroll to ensure that a balance adjustment could be made at that point
   -- if it were required.
   --
   -- Inception to date dimension.
   --
   if p_dimension_name in
      ('ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY INCEPTION TO DATE') then
     --
     -- What is the earliest date on which the element entry exists ?
     --
     open csr_ele_itd_start(p_assignment_id
                           ,p_upload_date);
     fetch csr_ele_itd_start into l_expiry_date;
     close csr_ele_itd_start;
   --
   -- Period to date dimensions.
   --
   elsif p_dimension_name in
     ('ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY PERIOD TO DATE'
     ,'ASSIGNMENT IN JD WITHIN GRE PERIOD TO DATE') then
     --
     -- What is the current period start date ?
     --
     open  csr_period_start(p_assignment_id
                           ,p_upload_date);
     fetch csr_period_start into l_prd_start_date;
     close csr_period_start;

     open csr_asg_start_date(p_assignment_id
                            ,p_upload_date
                            ,l_prd_start_date);
     fetch csr_asg_start_date into l_expiry_date;
     close csr_asg_start_date;
   --
   -- Quarter to date dimensions.
   --
   elsif p_dimension_name in
     ('ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY MONTH'
     ,'ASSIGNMENT IN JD WITHIN GRE MONTH'
     ,'ASSIGNMENT WITHIN REPORTING UNIT MONTH' ) then
     --
     -- What is the start date of the tax month ?
     --
     l_tax_month_start_date := trunc(p_upload_date, 'MON');
     open csr_asg_start_date(p_assignment_id
                            ,p_upload_date
                            ,l_tax_month_start_date);
     fetch csr_asg_start_date into l_expiry_date;
     close csr_asg_start_date;

   --
   -- Year to date dimensions.
   --
   elsif p_dimension_name in
     ('ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY YEAR TO DATE'
     ,'ASSIGNMENT IN JD WITHIN GRE YEAR TO DATE'
     ,'ASSIGNMENT WITHIN REPORTING UNIT YEAR TO DATE' ) then
     --
     -- What is the start date of the tax year ?
     --
     l_tax_yr_start_date := trunc(p_upload_date, 'Y');
     open csr_asg_start_date(p_assignment_id
                            ,p_upload_date
                            ,l_tax_yr_start_date);
     fetch csr_asg_start_date into l_expiry_date;
     close csr_asg_start_date;
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
  --  Only a subset of the CA dimensions are supported.
  --  This is used by pay_balance_upload.validate_dimension.
  -----------------------------------------------------------------------------
 --
 function is_supported
 (
  p_dimension_name varchar2
 ) return number is
 begin
   --
   hr_utility.trace('Entering pay_ca_bal_upload.is_supported stub');
   --
   -- See if the dimension is supported.
   --
   if p_dimension_name in
      ('ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY INCEPTION TO DATE'
      ,'ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY PERIOD TO DATE'
      ,'ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY YEAR TO DATE'
      ,'ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY MONTH'
      ,'ASSIGNMENT IN JD WITHIN GRE MONTH'
      ,'ASSIGNMENT IN JD WITHIN GRE YEAR TO DATE'
      ,'ASSIGNMENT IN JD WITHIN GRE PERIOD TO DATE'
      ,'ASSIGNMENT WITHIN REPORTING UNIT YEAR TO DATE'
      ,'ASSIGNMENT WITHIN REPORTING UNIT MONTH' ) then
     return (1); --(TRUE);
   else
     return (0); --(FALSE);
   end if;
   --
   hr_utility.trace('Exiting pay_ca_bal_upload.is_supported stub');
   --
 end is_supported;
 --
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
  --  All the CA dimensions affect each other when they share the same context
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
     ,p_jurisdiction_code         varchar
     ,p_original_entry_id         number
     ,p_bal_adj_tax_unit_id       number
     ,p_bal_adj_jurisdiction_code varchar
     ,p_bal_adj_original_entry_id number
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
   -- Get the jurisdiction code from the original balance batch line
   --
   cursor csr_get_jurisdiction_code
     (
      p_batch_line_id            number
     ) is
     select prov.province_abbrev
     from   pay_balance_batch_lines pbbl
           ,pay_ca_provinces_v      prov
     where  pbbl.batch_line_id = p_batch_line_id
     and    pbbl.jurisdiction_code = prov.province_abbrev
     and    pbbl.jurisdiction_code is not null;
   --
   -- Get tax_unit_id, jurisdiction_code and original_entry_id for
   --  previously tested adjustments
   --
   cursor csr_get_tested_adjustments
     (
      p_test_batch_line_id      number
     ) is
     select tax_unit_id
           ,jurisdiction_code
           ,original_entry_id
     from   pay_temp_balance_adjustments
     where  batch_line_id = p_test_batch_line_id;
   --
   -- The balance returned by the include check.
   --
   l_bal_type_id            number;
   --
   l_tax_unit_id            number;
   l_jurisdiction_code      varchar2(2);
   --
   l_adj_tax_unit_id        number;
   l_adj_jurisdiction_code  varchar2(2);
   l_adj_orig_entry_id      number;
   --
 begin
   --
   --
   open csr_get_tax_unit(p_batch_line_id);
   fetch csr_get_tax_unit into l_tax_unit_id;
   close csr_get_tax_unit;
   --
   open csr_get_jurisdiction_code(p_batch_line_id);
   fetch csr_get_jurisdiction_code into l_jurisdiction_code;
   close csr_get_jurisdiction_code;
   --
   open csr_get_tested_adjustments(p_test_batch_line_id);
   fetch csr_get_tested_adjustments into l_adj_tax_unit_id,
                                         l_adj_jurisdiction_code,
                                         l_adj_orig_entry_id;
   close csr_get_tested_adjustments;
   --
   -- Does the balance adjustment effect the new balance ?
   --
   hr_utility.trace('balance_type_id      = '||to_char(p_balance_type_id));
   hr_utility.trace('tax_unit_id          = '||to_char(l_tax_unit_id));
   hr_utility.trace('jurisdiction_code    = '||l_jurisdiction_code);
   hr_utility.trace('original_entry_id    = '||to_char(p_original_entry_id));
   hr_utility.trace('BA tax_unit_id       = '||to_char(l_adj_tax_unit_id));
   hr_utility.trace('BA jurisdiction_code = '||l_adj_jurisdiction_code);
   hr_utility.trace('BA original_entry_id = '||to_char(l_adj_orig_entry_id));
   --
   open  csr_is_included(p_balance_type_id
                        ,l_tax_unit_id
                        ,l_jurisdiction_code
                        ,p_original_entry_id
                        ,l_adj_tax_unit_id
                        ,l_adj_jurisdiction_code
                        ,l_adj_orig_entry_id);
   fetch csr_is_included into l_bal_type_id;
   close csr_is_included;
   --
   hr_utility.trace('Exiting pay_ca_bal_upload.include_adjustment_test');
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
 --  Applies CA specific validation to the batch.
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
   hr_utility.trace('Entering pay_ca_bal_upload.validate_batch_lines stub');
   --
   hr_utility.trace('Exiting pay_ca_bal_upload.validate_batch_lines stub');
   --
 end validate_batch_lines;
 --
end pay_ca_bal_upload;

/
