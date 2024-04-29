--------------------------------------------------------
--  DDL for Package Body PAY_US_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_BAL_UPLOAD" as
/* $Header: pyusupld.pkb 120.5 2006/09/25 13:44:56 alikhar noship $ */
/*
 Copyright (c) Oracle Corporation 1995 All rights reserved
 PRODUCT
  Oracle*Payroll
 NAME
  pyusxpry.pkb
 DESCRIPTION
  Provides support for the upload of balances based on US dimensions.
 EXTERNAL
  expiry_date
  get_tax_unit
  include_adjustment
  is_supported
  validate_batch_lines
 INTERNAL
 MODIFIED (DD-MON-YYYY)
 115.12  alikhar    25-Sep-2006        Bug 5181998: Modified function expiry
				       date to return dimension period start
				       date for dimensions with GRE context
				       during Purge Process.
 115.11  rdhingra   22-Mar-2006        Bug 5042715: Modified cursor
				       c_td_start_date to remove FTS on
				       per_time_periods.
 115.10  kvsankar   11-Aug-2005        Enabled the dimension '_ASG_GRE_TD_TDPTD'
                                       for Balance Initialization.
                                       Modified the procedure 'EXPIRY_DATE'
                                       to return the start date of the Time
                                       Definition period on which the Upload
                                       is done.
 115.8,9 SSattini   21-Jul-2004        Bug 4505420 - Modified the cursors
                                       csr_asg_start_date,
                                       csr_assignment_on_tax_unit,
                                       csr_ele_itd_start and
                                       csr_ele_itd_tax_unit_start in
                                       expiry_date function, so that it
                                       returns correct expiry_date value.
 115.7  SSattini    16-Jul-2004        Added 'WHENEVER OSERROR' for GSCC
                                       compliance.
 115.6  SSattini    16-Jul-2004        Bug 3751001 - Modified the cursors
                                       csr_asg_start_date,
                                       csr_assignment_on_tax_unit,
                                       csr_ele_itd_start and
                                       csr_ele_itd_tax_unit_start in
                                       expiry_date function, so that it
                                       returns correct expiry_date value
                                       when Assignment hire_date and balance
                                       upload_date falls in the same pay period.
 115.4  D.Saxby     10-Jan-2002        Bug 2144736 - further alterations to
                                       expiry_date procedure to deal correctly
                                       with a further case with assigment
                                       assigned to payroll earlier than time
                                       periods exist.
 115.4  D.Saxby     17-Dec-2001        Bug 2153245, first release of purge.
                                       Support appropriate LTD dimensions
                                       and ensure can rollup assignments that
                                       do not have payroll across their entire
                                       lifetime.
                                       Added dbdrv line.
 115.3  A.Logue     07-Oct-1999        Change to_number(segment1) to
                                       to_char(tax_unit_id) to avoid
                                       to_number errors.
  40.10 J.Alloun    30-Jul-1996        Added error handling.
  40.9  N.Bristow   08-May-1996        Bug 359005. Now tax_unit_id is now
                                       passed to expiry_date and
                                       include_adjustment.
  40.8  S Desai     27-Feb-1996	       Bug 333439: Date format was 'DD-MON-YY'.
  40.7  N.Bristow   14-Dec-1995        Expiry_date was not checking the
                                       creation date of the assignment
                                       for certain balances.
  40.6  N.Bristow   03-Nov-1995        The cursors retrieving the date of an
                                       itd adjustment were incorrect.
  40.5  N.Bristow   02-Nov-1995        Statements that reference the
                                       hr_tax_units_v view run very slow.
                                       Changed to access base tables.
  40.3  N.Bristow   25-Aug-1995        Now uses the element type for ITD
                                       balances.
  40.2  N.Bristow   06-Jul-1995        General bugs discovered when testing.
  40.1  J.S.Hobbs   16-May-1995        created.
*/
 --
 -- Date constants.
 --
 START_OF_TIME constant date := to_date('01/01/0001','DD/MM/YYYY');
 END_OF_TIME   constant date := to_date('31/12/4712','DD/MM/YYYY');
 --
 --
 -- Global for current batch info
 --
 g_batch_info	pay_balance_upload.t_batch_info_rec;
 --
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
     select fnd_number.canonical_to_number(SCL.segment1) tax_unit_id
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
   hr_utility.trace('Entering pay_us_bal_upload.get_tax_unit');
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
   hr_utility.trace('Exiting pay_us_bal_upload.get_tax_unit');
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
       and  p_upload_date                between ASS.effective_start_date
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
     select nvl(greatest(p_expiry_date, min(ASS.effective_start_date),
                   min(PTP.start_date)),
                END_OF_TIME)
     from   per_assignments_f      ASS
           ,hr_soft_coding_Keyflex SCL
           ,per_time_periods       PTP
     where  ASS.assignment_id          = p_assignment_id
       and  ASS.effective_start_date  <= p_upload_date
       and  ASS.effective_end_date    >= p_expiry_date
       and  SCL.soft_coding_keyflex_id = ASS.soft_coding_keyflex_id
       and  SCL.segment1               = to_char(p_tax_unit_id)
       and  PTP.payroll_id             = ASS.payroll_id
       and  PTP.start_date           <= p_upload_date
       and  ASS.effective_end_date >= ptp.start_date;

       /*commented out to fix bug#4505420, added above last condition
        and  ASS.effective_start_date between PTP.start_date and
            p_upload_date; */

       /*and  PTP.start_date between
            ASS.effective_start_date and p_upload_date; Bug#3751001 */
   --
   -- Returns the earliest date on which the assignment exists.
   -- Must also have an active payroll and an existing time
   -- period at this date.
   -- If the time period doesn't exist, the initialization will
   --
   cursor csr_ele_itd_start
          (
           p_assignment_id     number
          ,p_upload_date       date
          ) is
     select nvl(greatest (min(ASG.effective_start_date), min(PTP.start_date)),
                END_OF_TIME)
     from   per_assignments_f   ASG
           ,per_time_periods    PTP
     where  ASG.assignment_id         = p_assignment_id
       and  ASG.effective_start_date <= p_upload_date
       and  PTP.payroll_id            = ASG.payroll_id
       and  PTP.start_date           <= p_upload_date
       and  ASG.effective_end_date >= ptp.start_date;

       /*commented out to fix bug#4505420, added above last condition
       and  ASG.effective_start_date between PTP.start_date and
            p_upload_date; */

       /*and  PTP.start_date between
            ASG.effective_start_date and p_upload_date; Bug#3751001 */
   --
   -- Returns the earliest date on which the assignment exists and the
   -- assignment belongs to a specific legal company ie. matches the
   -- TAX_UNIT_ID context.
   -- fail when it calls the balance adjustment code.
   --
   cursor csr_ele_itd_tax_unit_start
          (
           p_assignment_id     number
          ,p_upload_date       date
          ,p_tax_unit_id       number
          ) is
     select nvl(greatest(min(ASS.effective_start_date), min(PTP.start_date)),
                END_OF_TIME)
     from   per_assignments_f      ASS
           ,hr_soft_coding_keyflex SCL
           ,per_time_periods       PTP
     where  ASS.assignment_id          = p_assignment_id
       and  SCL.soft_coding_keyflex_id = ASS.soft_coding_keyflex_id
       and  ASS.effective_start_date  <= p_upload_date
       and  SCL.segment1               = to_char(p_tax_unit_id)
       and  PTP.payroll_id             = ASS.payroll_id
       and  PTP.start_date           <= p_upload_date
        and  ASS.effective_end_date  >= ptp.start_date;

       /*commented out to fix bug#4505420, added above last condition
        and  ASS.effective_start_date between PTP.start_date
          and p_upload_date; */

       /* and  PTP.start_date between
            ASS.effective_start_date and p_upload_date; Bug#3751001 */
   --
   cursor csr_asg_start_date
     (p_assignment_id number
     ,p_upload_date   date
     ,p_expiry_date   date
     ) is
     select nvl(greatest(min(ASS.effective_start_date),
                         min(PTP.start_date), p_expiry_date),
                END_OF_TIME)
       from per_assignments_f ASS
           ,per_time_periods  PTP
      where ASS.assignment_id = p_assignment_id
        and ASS.effective_start_date <= p_upload_date
        and ASS.effective_end_date >= p_expiry_date
        and PTP.payroll_id   = ASS.payroll_id
        and PTP.start_date           <= p_upload_date
         and ASS.effective_end_date >= ptp.start_date;

       /*commented out to fix bug#4505420, added above last condition
        and ASS.effective_start_date between PTP.start_date and
            p_upload_date; */

        /* and PTP.start_date between
            ASS.effective_start_date and p_upload_date; Bug#3751001 */

   -- Cursor to get the Business Group ID
   cursor csr_business_grp_id
     (p_assignment_id number) is
   select distinct
          paf.business_group_id
     from per_assignments_f paf
    where paf.assignment_id = p_assignment_id;

   -- Cursor to get the Time Definition Start Date
   cursor c_td_start_date(p_time_definition_id number
                         ,p_upload_date        date) is
    select ptp.start_date
      from per_time_periods ptp
     where ptp.time_definition_id = p_time_definition_id
       and p_upload_date between ptp.start_date
                             and ptp.end_date
       and ptp.time_definition_id is not null
       and ptp.payroll_id is null;


   --
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
   l_tax_unit_id                 number;

   -- Holds the Business Group ID
   l_business_group_id           number;
   l_time_definition_id          number;

   -- Holds the TIme Definition Start Date
   l_td_start_date               date;

 begin
   --
   -- Get the tax unit.
   --
   l_tax_unit_id := p_tax_unit_id;
   --
   --
   -- Get the current batch info
   --
   g_batch_info := pay_balance_upload.get_batch_info;
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
      ('ASSIGNMENT INCEPTION TO DATE', 'ASSIGNMENT LIFETIME TO DATE',
       'ASSIGNMENT IN JD LIFETIME TO DATE') then
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
   elsif p_dimension_name in
     ('ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY INCEPTION TO DATE',
      'ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY LIFETIME TO DATE',
      'ASSIGNMENT IN JD WITHIN GRE LIFETIME TO DATE',
      'SUBJECT TO TAX FOR ASSIGNMENT WITHIN GRE LIFETIME TO DATE') then
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
     -- For Purge process if expiry date is EOT then set the expiry date to start of assignment
     --
     if g_batch_info.purge_mode and l_ele_itd_tax_unit_start_date = END_OF_TIME then
	     open csr_ele_itd_start(p_assignment_id
		                   ,p_upload_date);
	     fetch csr_ele_itd_start into l_ele_itd_tax_unit_start_date;
	     close csr_ele_itd_start;
     end if;
     --
     --
     l_expiry_date := l_ele_itd_tax_unit_start_date;
   --
   -- Period to date dimensions.
   --
   elsif p_dimension_name in
     ('ASSIGNMENT PERIOD TO DATE'
     ,'ASSIGNMENT IN JD PERIOD TO DATE'
     ,'ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY PERIOD TO DATE'
     ,'ASSIGNMENT IN JD WITHIN GRE PERIOD TO DATE'
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
       --
       -- For Purge process if expiry date is EOT then set the expiry date to start of dimension period
       --
       if g_batch_info.purge_mode and l_expiry_date = END_OF_TIME then
       --
	       l_expiry_date := l_prd_start_date;
       --
       end if;

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
       --
       -- For Purge process if expiry date is EOT then set the expiry date to start of dimension period
       --
       if g_batch_info.purge_mode and l_expiry_date = END_OF_TIME then
       --
	       l_expiry_date := l_tax_qtr_start_date;
       --
       end if;
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
       --
       -- For Purge process if expiry date is EOT then set the expiry date to start of dimension period
       --
       if g_batch_info.purge_mode and l_expiry_date = END_OF_TIME then
       --
	       l_expiry_date := l_tax_yr_start_date;
       --
       end if;
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
       --
       -- For Purge process if expiry date is EOT then set the expiry date to start of dimension period
       --
       if g_batch_info.purge_mode and l_expiry_date = END_OF_TIME then
       --
	       l_expiry_date := l_fiscal_qtr_start_date;
       --
       end if;
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
       --
       -- For Purge process if expiry date is EOT then set the expiry date to start of dimension period
       --
       if g_batch_info.purge_mode and l_expiry_date = END_OF_TIME then
       --
	       l_expiry_date := l_fiscal_yr_start_date;
       --
       end if;
       --
     else
       open csr_asg_start_date(p_assignment_id
                              ,p_upload_date
                              ,l_fiscal_yr_start_date);
       fetch csr_asg_start_date into l_expiry_date;
       close csr_asg_start_date;
     end if;
   --
   -- Time Definition Period To Date Dimension
   elsif p_dimension_name in
     ('ASSIGNMENT WITHIN GRE TIME DEFINITION PERIOD TO DATE') then

     open csr_business_grp_id(p_assignment_id);
     fetch csr_business_grp_id into l_business_group_id;
     close csr_business_grp_id;

    l_time_definition_id :=
            pay_us_rules.get_time_def_for_entry_func(
                         p_element_entry_id     => null
                        ,p_assignment_id        => p_assignment_id
                        ,p_assignment_action_id => null
                        ,p_business_group_id    => l_business_group_id
                        ,p_time_def_date        => p_upload_date);

     open c_td_start_date(l_time_definition_id
                         ,p_upload_date);
     fetch c_td_start_date into l_td_start_date;
     close c_td_start_date;

     l_expiry_date := l_td_start_date;
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
 ) return boolean is
 begin
   --
   hr_utility.trace('Entering pay_us_bal_upload.is_supported');
   --
   -- See if the dimension is supported.
   --
   if p_dimension_name in
     ('ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY INCEPTION TO DATE'
     ,'ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY LIFETIME TO DATE'
     ,'ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY PERIOD TO DATE'
     ,'ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY QUARTER TO DATE'
     ,'ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY YEAR TO DATE'
     ,'ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY FISCAL QUARTER TO DATE'
     ,'ASSIGNMENT WITHIN GOVERNMENT REPORTING ENTITY FISCAL YEAR TO DATE'
     ,'ASSIGNMENT INCEPTION TO DATE'
     ,'ASSIGNMENT LIFETIME TO DATE'
     ,'ASSIGNMENT PERIOD TO DATE'
     ,'ASSIGNMENT QUARTER TO DATE'
     ,'ASSIGNMENT YEAR TO DATE'
     ,'ASSIGNMENT IN JD LIFETIME TO DATE'
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
     ,'ASSIGNMENT IN JD WITHIN GRE LIFETIME TO DATE'
     ,'SUBJECT TO TAX FOR ASSIGNMENT WITHIN GRE PERIOD TO DATE'
     ,'SUBJECT TO TAX FOR ASSIGNMENT WITHIN GRE QUARTER TO DATE'
     ,'SUBJECT TO TAX FOR ASSIGNMENT WITHIN GRE YEAR TO DATE'
     ,'SUBJECT TO TAX FOR ASSIGNMENT WITHIN GRE LIFETIME TO DATE'
     ,'ASSIGNMENT WITHIN GRE TIME DEFINITION PERIOD TO DATE') then
     return (TRUE);
   else
     return (FALSE);
   end if;
   --
   hr_utility.trace('Exiting pay_us_bal_upload.is_supported');
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
  --  p_bal_adjustment_rec - details of an existing balance adjustment.
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
 ,p_jurisdiction_code  varchar2
 ,p_original_entry_id  number
 ,p_tax_unit_id        number
 ,p_assignment_id      number
 ,p_upload_date        date
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
     ,p_bal_adj_tax_unit_id       number
     ,p_bal_adj_jurisdiction_code varchar2
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
   -- The balance returned by the include check.
   --
   l_bal_type_id number;
   --
   l_tax_unit_id number;
   --
 begin
   --
   hr_utility.trace('Entering pay_us_bal_upload.include_adjustment');
   --
   l_tax_unit_id := p_tax_unit_id;
   --
   -- Does the balance adjustment effect the new balance ?
   --
   open  csr_is_included(p_balance_type_id
                        ,l_tax_unit_id
                        ,p_jurisdiction_code
                        ,p_original_entry_id
                        ,p_bal_adjustment_rec.tax_unit_id
                        ,p_bal_adjustment_rec.jurisdiction_code
                        ,p_bal_adjustment_rec.original_entry_id);
   fetch csr_is_included into l_bal_type_id;
   close csr_is_included;
   --
   hr_utility.trace('Exiting pay_us_bal_upload.include_adjustment');
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
 --   Applies US specific validation to the batch.
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
   hr_utility.trace('Entering pay_us_bal_upload.validate_batch_lines');
   --
   hr_utility.trace('Exiting pay_us_bal_upload.validate_batch_lines');
   --
 end validate_batch_lines;
 --
end pay_us_bal_upload;

/
