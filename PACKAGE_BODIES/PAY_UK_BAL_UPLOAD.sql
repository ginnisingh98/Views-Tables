--------------------------------------------------------
--  DDL for Package Body PAY_UK_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_UK_BAL_UPLOAD" as
/* $Header: pyukupld.pkb 120.1 2005/07/11 06:17:26 npershad noship $ */
/*
 Copyright (c) Oracle Corporation 1995 All rights reserved
 PRODUCT
  Oracle*Payroll
 NAME
  pyukupld.pkb
 DESCRIPTION
  Provides support for the upload of balances based on UK dimensions.
 EXTERNAL
  expiry_date
  include_adjustment
  is_supported
  validate_batch_lines
 INTERNAL
 MODIFIED (DD-MON-YYYY)
  40.0  J.S.Hobbs   16-May-1995         created.
  40.2  A.Snell     03-Oct-1995         added director logic
  40.3  N.Bristow   06-Oct-1995         ITD dimensions not supported
                                        for balance upload.
  40.5  N.Bristow   17-Oct-1995         Changes to support ITD balances.
  40.6  N.Bristow   19-Oct-1995         Uncomment exit.
  40.7  A.Snell     28-Feb-1996         Bug 345309 mid year starters
  40.8  J.Alloun    30-JUL-1996         Added error handling.
  40.9  C.Barbieri  13-AUG-1996         Added ASG_TD_ITD dimension.
  40.10 C.Barbieri  28-Oct-1996         Changed User Balance Name
                                        Convenction.
  40.10 C.Barbieri  28-Oct-1996         Changed User Balance naming.
  110.1 A.Mills     03-Nov-1997 568639  Corrected the way that
			 	        function expiry_date handles nulls
				        from csr_regular_payment cursor.
  115.2 A.Mills     04-Apr-2001         PQP Addition of new dimension,
                                        11i only, 2 yr expiry.
  115.3 SKutteti    10-Apr-2001         Added code to take care of two
                                        new dimensions : ASG_TD_ODD_TWO_YTD
                                        and ASG_TD_EVEN_TWO_YTD
  115.4 skutteti    11-Apr-2001         Fixed typo for the above changes
  115.5 AMills      16-Oct-2001 2048418 Forward port of 665503.
  115.6 AMills      25-Jun-2003         Added dbdrv commands.
  115.7 AMills      15-Sep-2003 3140420 Changed expiry_date function
                                        to ensure expiry in current
                                        Tax Year for ytd section.
  115.9 S.Rai       15-Nov-2003 3246437 Added code to support dimensions
                                        _PER_TD_EVEN_TWO_YTD ,
                                        _PER_TD_ODD_TWO_YTD and _PER_TD_YTD
  115.10 A.Mills    05-Feb-2004 3418267 Changed expiry_date to not use
                                        csr_regular_payment, changed
                                        csr_proc_start_year.
  115.11 A.Mills    27-May-2004 3655649 Changed return date for ASG_ITD
                                        dimension to ensure there is a
                                        valid time period.
  115.12 A.Mills    04-Jun-2004         Changed csr_asg_itd_start to be
                                        valid as long as time period start
                                        is before the upload date, not
                                        necessarily after asg start date.
  115.13 npershad   10-jul-2005 4452262 Added code to support dimension
                                        '_ELEMENT_CO_REF_ITD'.
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
   -- Returns the date on which the assignment transferred payroll prior to
   -- the upload date NB. the payroll is the one the assignment is assigned to
   -- on the upload date.
   --
   cursor csr_transfer_payroll
          (
           p_assignment_id number
          ,p_upload_date   date
          ) is
     select nvl(max(ASS.effective_start_date), START_OF_TIME)
     from   per_assignments_f ASS
	   ,per_assignments_f ASS2
     where  ASS.assignment_id         = p_assignment_id
       and  ASS.effective_start_date <= p_upload_date
       and  ASS2.assignment_id        = ASS.assignment_id
       and  ASS2.effective_end_date   = (ASS.effective_start_date - 1)
       and  ASS2.payroll_id          <> ASS.payroll_id;
   --
   -- Returns the earliest regular payment date for the payroll that lies
   -- within the current tax year NB. the payroll is the one the assignment is
   -- assigned to on the upload date.
   --
   cursor csr_proc_year_start
          (
           p_assignment_id      number
          ,p_upload_date        date
          ,p_stat_yr_start_date date
          ) is
     select nvl(min(PTP.regular_payment_date), END_OF_TIME)
     from   per_time_periods  PTP
           ,per_assignments_f ASS
     where  ASS.assignment_id         = p_assignment_id
       and  p_upload_date       between ASS.effective_start_date
                                    and ASS.effective_end_date
       and  PTP.payroll_id            = ASS.payroll_id
       and  PTP.regular_payment_date >= p_stat_yr_start_date;
   --
   -- Returns the start date of the current period on the upload date.
   --
   cursor csr_period_start
          (
           p_assignment_id      number
          ,p_upload_date        date
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
   -- Returns the Earliest date that can be used for uploading
   -- for the assignment, therefore ensures that a time period
   -- exists, and uses the greatest of the assignment start and
   -- time period start. Used for ITD date, and as a minimum
   -- for other dimensions.
   --
    cursor csr_asg_itd_start
          (
           p_assignment_id      number
          ,p_upload_date        date
          ) is
    select nvl(greatest(min(ASS.effective_start_date),
                         min(PTP.start_date)), END_OF_TIME)
       from per_assignments_f ASS
           ,per_time_periods  PTP
      where ASS.assignment_id = p_assignment_id
        and ASS.effective_start_date <= p_upload_date
        and PTP.start_date <= p_upload_date
        and PTP.payroll_id   = ASS.payroll_id;
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
   -- Returns the date the employee became a director
   -- if not a director(in the current year) then return END_OF_TIME
   -- the date returned may be in the financial year or before it
   cursor csr_appointment_as_director
          (
           p_assignment_id number
          ,p_upload_date   date
          ,p_stat_yr_start_date date
          ) is
        select nvl(min(p.effective_start_date) ,END_OF_TIME)
                   from per_people_f p,
                        per_assignments_f ASS
                   where p.per_information2 = 'Y'
                   and ASS.assignment_id = p_assignment_id
                   and p_upload_date between
                         ASS.effective_start_date and ASS.effective_end_date
                   and ASS.person_id = P.person_id
                   and P.effective_start_date <= p_upload_date
                   and p.effective_end_date >= p_stat_yr_start_date  ;
 --
   l_stat_yr_start_date    date; -- The start of the tax year.
   l_stat_prev_yr_start_date date; -- The start of the previous tax year.
   l_transfer_payroll_date date; --  The date the assignment transferred
                                 --  onto the current payroll.
   l_stat_yr_proc_date     date; -- earliest regular payment date for the
                                 -- current payroll within the tax year.
   l_period_start_date     date; -- start date of the upload date period.
   l_asg_itd_start_date    date; -- The assignment start date.
   l_ele_itd_start_date    date; -- The earliest date an element entry exists.
   l_director_start_date   date; -- The date the director was appointed
   l_date                  date; -- Temp date for Start of Tax Year.
   l_regular_date          date; -- Regular payment date after the expiry
   l_expiry_date           date; -- The expiry date of the dimension.
   l_business_group_id     number; -- The business_group of the dimension.
   --
 begin
   --
   -- Calculate the start of the tax year relative to the upload date. First
   -- calculate the 6th April of the year the upload date falls in and then
   -- see which side of this date the upload date falls. If it is on or after
   -- the date then this is the current tax year start date, if it is before
   -- the date then the current tax year start date is the 6th april of the
   -- previous year.
   -- PQP Addition, Do similar calculation for 2 year expiries, but
   -- minus off another 1 year in relation to the YTD.
   --
   hr_utility.trace('Assignment ID: '||to_char(p_assignment_id));
   hr_utility.trace('Dimension name: '||p_dimension_name);
   --
   l_date := to_date('06/04/' || to_char(p_upload_date,'YYYY'),'DD/MM/YYYY');
   --
   if    p_upload_date >= l_date then
     l_stat_yr_start_date := l_date;
   elsif p_upload_date < l_date then
     l_stat_yr_start_date := add_months(l_date,-12);
   end if;
   --
   -- Calculate the expiry date for the specified dimension relative to the
   -- upload date, taking into account any contexts where appropriate. Each of
   -- the calculations also takes into account when the assignment is on a
   -- payroll to ensure that a balance adjustment could be made at that point
   -- if it were required.
   --
   -- What is the start date of the assignment ? All loading must come
   -- after this date
   --
     open  csr_asg_itd_start(p_assignment_id, p_upload_date);
     fetch csr_asg_itd_start into l_asg_itd_start_date;
     close csr_asg_itd_start;

   if substr(p_dimension_name,31,4) = 'USER' then
     -- User Balance
     --
     -- 665503 - Ensure single bgid returned.
     -- Must select distinct rather than use effective
     -- start and end date to ascertain singular
     -- business group id.
     --
     SELECT  DISTINCT business_group_id
             INTO l_business_group_id
             FROM per_assignments_f
             WHERE assignment_id = p_assignment_id;

     l_expiry_date := hr_gbbal.dimension_reset_date(
                                p_dimension_name,
                                p_upload_date,
                                l_business_group_id);
     l_expiry_date := greatest(l_expiry_date, l_asg_itd_start_date);
     --
     -- added odd and even by skutteti
     -- added _PER_TD_YTD and _PER_TD_EVEN_TWO_YTD and _PER_TD_ODD_TWO_YTD  by saurai for bug fix 3246437
     --
   elsif p_dimension_name in ('_ASG_PROC_YTD', '_ASG_YTD',
                              '_ASG_TD_YTD',   '_ASG_TD_EVEN_TWO_YTD',
                              '_ASG_TD_ODD_TWO_YTD','_PER_TD_YTD','_PER_TD_EVEN_TWO_YTD',
                              '_PER_TD_ODD_TWO_YTD')  then

     -- When did the assignment transfer onto the current payroll ?
     --
     open  csr_transfer_payroll(p_assignment_id
                               ,p_upload_date);
     fetch csr_transfer_payroll into l_transfer_payroll_date;
     close csr_transfer_payroll;
     --
     -- added by skutteti
     -- added by saurai,dimension _PER_TD_EVEN_TWO_YTD for bug fix 3246437
     if p_dimension_name IN( '_ASG_TD_EVEN_TWO_YTD','_PER_TD_EVEN_TWO_YTD')then
        if mod(to_number(to_char(l_stat_yr_start_date,'yyyy')),2) = 1 then
           l_stat_yr_start_date := l_stat_yr_start_date;
        else
           l_stat_yr_start_date := add_months(l_stat_yr_start_date, -12);
        end if;
     -- added by saurai,dimension _PER_TD_ODD_TWO_YTD for bug fix 3246437
     elsif p_dimension_name IN ('_ASG_TD_ODD_TWO_YTD','_PER_TD_ODD_TWO_YTD') then
        if mod(to_number(to_char(l_stat_yr_start_date,'yyyy')),2) = 1 then
           l_stat_yr_start_date := add_months(l_stat_yr_start_date, -12);
        else
           l_stat_yr_start_date := l_stat_yr_start_date;
        end if;
     end if;
     --
     -- What is the earliest regular payment date for the current payroll
     -- within the current tax year ?
     --
     open  csr_proc_year_start(p_assignment_id
                              ,p_upload_date
                              ,l_stat_yr_start_date);
     fetch csr_proc_year_start into l_stat_yr_proc_date;
     close csr_proc_year_start;
     --
     hr_utility.trace('proc yr start: '||to_char(l_stat_yr_proc_date));
     --
     -- The expiry date must lie within the processing tax year for the
     -- current payroll and at a time when the assignment belongs to the
     -- current payroll.
     --
     l_expiry_date := greatest(l_transfer_payroll_date, l_stat_yr_proc_date
				,l_asg_itd_start_date, l_stat_yr_start_date);
   --
   -- Calculate expiry date for _ASG_STAT_YTD dimension.
   --
   elsif p_dimension_name = '_ASG_STAT_YTD' then
     l_expiry_date := greatest(l_stat_yr_start_date,l_asg_itd_start_date);
   --
   -- Calculate expiry date for _ASG_PROC_PTD dimension.
   --
   elsif p_dimension_name = '_ASG_PROC_PTD' then
     --
     -- What is the current period start date ?
     --
     open  csr_period_start(p_assignment_id
                           ,p_upload_date);
     fetch csr_period_start into l_period_start_date;
     close csr_period_start;
     --
     hr_utility.trace('Period start: '||to_char(l_period_start_date));
     -- Set the expiry date. This is the later of the period start date,
     -- the assignment start date or the Start of tax year, incase the period
     -- begins before the tax year end (e.g. 01-30 Apr).
     --
     l_expiry_date := greatest(l_stat_yr_start_date,l_period_start_date,
                               l_asg_itd_start_date);
   --
   -- Calculate expiry date for _ASG_ITD dimension.
   --
   elsif p_dimension_name in ('_ASG_ITD','_ASG_TD_ITD') then
     --
     -- Use the greater of the assignments start date or the tfr to
     -- payroll date, as cannot do adjustments if current payroll did
     -- not exist at start of assignment and asg transferred.
     --
     open  csr_transfer_payroll(p_assignment_id
                               ,p_upload_date);
     fetch csr_transfer_payroll into l_transfer_payroll_date;
     close csr_transfer_payroll;

     l_expiry_date := greatest(l_transfer_payroll_date,l_asg_itd_start_date);

   elsif p_dimension_name in  ('_ELEMENT_ITD', '_ELEMENT_CO_REF_ITD') then
     --
     -- What is the earliest date the element entry exists ?
     --
     open  csr_ele_itd_start(p_assignment_id
                            ,p_upload_date
			    ,p_original_entry_id);
     fetch csr_ele_itd_start into l_ele_itd_start_date;
     close csr_ele_itd_start;
     --
     -- Set the expiry date.
     --
     l_expiry_date := greatest(l_ele_itd_start_date,l_asg_itd_start_date);
     --
   elsif p_dimension_name = '_PER_TD_DIR_YTD'   then
     --
     -- When did the assignment transfer onto the current payroll ?
     --
     open  csr_transfer_payroll(p_assignment_id
                               ,p_upload_date);
     fetch csr_transfer_payroll into l_transfer_payroll_date;
     close csr_transfer_payroll;
     --
     -- What is the earliest regular payment date for the current payroll
     -- within the current tax year ?
     --
     open  csr_proc_year_start(p_assignment_id
                              ,p_upload_date
                              ,l_stat_yr_start_date);
     fetch csr_proc_year_start into l_stat_yr_proc_date;
     close csr_proc_year_start;
     --
     hr_utility.trace('proc yr start: '||to_char(l_stat_yr_proc_date));
     -- What is the edate of appointment as a director
     --
     open  csr_appointment_as_director(p_assignment_id
                              ,p_upload_date
                              ,l_stat_yr_start_date);
     fetch csr_appointment_as_director into l_director_start_date;
     close csr_appointment_as_director;
     --
     -- The expiry date must lie within the processing tax year for the
     -- current payroll and at a time when the assignment belongs to the
     -- current payroll and since the appointment as director.
     --
     l_expiry_date := greatest(l_transfer_payroll_date, l_stat_yr_proc_date,
                               l_director_start_date,l_asg_itd_start_date);
   --
   end if;
   --
   -- Return the date on which the dimension expires. If this has not been
   -- set due to a cursor above not finding the correct info, set this to
   -- End Of Time. The core process will then fail this upload.
   --
   hr_utility.trace('Returned date: '||to_char(l_expiry_date));
   --
   IF l_expiry_date is null then
      --
      l_expiry_date := END_OF_TIME;
      --
   END IF;
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
  --  Only a subset of the UK dimensions are supported and these have been
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
   hr_utility.trace('Entering pay_uk_bal_upload.is_supported');
   --
   -- See if the dimension is supported.
   --
   if p_dimension_name in
     ('_ASG_PROC_YTD'
     ,'_ASG_YTD'
     ,'_ASG_TD_YTD'
     ,'_ASG_STAT_YTD'
     ,'_PER_TD_DIR_YTD'
     ,'_ASG_PROC_PTD'
     ,'_ASG_ITD'
     ,'_ASG_TD_ITD'
     ,'_ELEMENT_ITD'
     -- added by skutteti
     ,'_ASG_TD_EVEN_TWO_YTD'
     ,'_ASG_TD_ODD_TWO_YTD'
     -- added by saurai for bug fix 3246437
     ,'_PER_TD_EVEN_TWO_YTD'
     ,'_PER_TD_ODD_TWO_YTD'
     ,'_PER_TD_YTD'
     ,'_ELEMENT_CO_REF_ITD'
    )
    OR
    (
      substr(p_dimension_name,31,4) = 'USER'
      AND
      substr(p_dimension_name,40,3) = 'ASG'
    )
   then
     return (TRUE);
   else
     return (FALSE);
   end if;
   --
   hr_utility.trace('Exiting pay_uk_bal_upload.is_supported');
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
  --  are for the same assignment and balance.
  -- ARGUMENTS
  --  p_balance_type_id    - the balance to be set.
  --  p_dimension_name     - the balance dimension to be set.
  --  p_original_entry_id  - ORIGINAL_ENTRY_ID context.
  --  p_bal_adjustment_rec - details of an existing balance adjustment.
  -- USES
  -- NOTES
  --  This is used by pay_balance_upload.get_current_value.
  -----------------------------------------------------------------------------
 --
 function include_adjustment
 (
  p_balance_type_id    number
 ,p_dimension_name     varchar2
 ,p_original_entry_id  number
 ,p_bal_adjustment_rec pay_balance_upload.csr_balance_adjustment%rowtype
 ) return boolean is
 --
 ret_val boolean;
 begin
   --
   hr_utility.trace('Entering pay_uk_bal_upload.include_adjustment');
   --
   if (p_original_entry_id = p_bal_adjustment_rec.original_entry_id) or
      (p_original_entry_id is null
       and p_bal_adjustment_rec.original_entry_id is null) then
      ret_val := TRUE;
   else
      ret_val := FALSE;
   end if;
   hr_utility.trace('Exiting pay_uk_bal_upload.include_adjustment');
   --
   return (ret_val);
   --
 end include_adjustment;
 --
  -----------------------------------------------------------------------------
  -- NAME
  --  validate_batch_lines
  -- PURPOSE
 --  Applies UK specific validation to the batch.
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
   hr_utility.trace('Entering pay_uk_bal_upload.validate_batch_lines');
   --
   hr_utility.trace('Exiting pay_uk_bal_upload.validate_batch_lines');
   --
 end validate_batch_lines;
 --
end pay_uk_bal_upload;

/
