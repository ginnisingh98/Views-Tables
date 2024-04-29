--------------------------------------------------------
--  DDL for Package Body PAY_JP_BAL_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_BAL_UPLOAD" as
/* $Header: pyjpupld.pkb 120.1 2006/04/24 00:54:12 ttagawa noship $ */
/*
 Copyright (c) Oracle Corporation 1995 All rights reserved
 PRODUCT
  Oracle*Payroll
 NAME
  pyjpupld.pkb
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
  40.11 R.Kamiyama  27-Jan-1997	        Modified for JP dimensions.
  40.11 R.Kamiyama  05-Jan-1997         Added select stmt to get
				        business_group_id to for JP functions.
  40.11 R.Kamiyama  07-Mar-1997         Changed to BONUS_YEAR_STARTS from
				        JP_BONUS_YEAR_STARTS
  40.12 R.Kamiyama  13-Mar-1998         Translated to JP dim name.
  40.17 Y.Negoro    11-Nov-1998         Fix 665503.
  110.01 Y.Negoro   13-Nov-1998         Create for R11
  115.1  Y.Negoro   03-JUN-1999         Create for R11i
  115.2  K.Yazawa   17-JUN-1999	        Change the package name.
                                        (hr_jpbal => hr_jprts)
  115.4  Y.Tohya    06-Oct-1999         Fix 1020589.
  115.5  K.Yazawa   08-Oct-1999         Remove Multi byte Character.
				        per_assignments_f => per_all_assignments_f
  115.6  T.Tagawa   25-Sep-2002 2597843 ASG_ITD support.
                                        Added code to avoid HR_6614_PAY_NO_TIME_PERIOD.
  115.7  T.Tagawa   18-OCT-2002 2597843 IS_SUPPORTED function simplified(UTF8 support).
  115.8  T.Tagawa   06-NOV-2002 2597843 Added code to avoid error if the payroll on actual
                                        upload date is different from that on batch upload date.
  115.9 M.Iwamoto   19-JAN-2003 2708491 Total Reward System Support.
  115.10 T.Tagawa   15-MAY-2003         Added ASG_JULTD and new ASG_FYTD to is_supported.
                                        Added new ASG_FYTD expiry date routine.
  115.11 T.Tagawa   21-MAY-2003         show err commented out.
  115.12 T.Tagawa   21-APR-2006 2656208 Re-built. All potential bugs fixed.
*/
--
-- Constants
--
c_package     constant varchar2(31) := 'pay_jp_bal_upload.';
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
--  expiry date knows this rulw and acts accordingly.
-----------------------------------------------------------------------------
--
function expiry_date(
	p_upload_date		in date,
	p_dimension_name	in varchar2,
	p_assignment_id		in number,
	p_original_entry_id	in number) return date
is
	c_proc			constant varchar2(61) := c_package || 'expiry_date';
	--
	l_business_group_id	number;
	l_payroll_id		number;
	l_ptp_start_date	date;
	l_asg_start_date	date;
	l_ee_start_date		date;
	l_legislation_code	pay_balance_dimensions.legislation_code%type;
	l_period_type		pay_balance_dimensions.period_type%type;
	l_start_date_code	pay_balance_dimensions.start_date_code%type;
	l_dim_start_date	date;
	l_expiry_date		date;
begin
	hr_utility.set_location('Entering: ' || c_proc, 10);
	hr_utility.trace('dimension_name: ' || p_dimension_name);
	hr_utility.trace('upload_date   : ' || p_upload_date);
	--
	select	business_group_id,
		payroll_id
	into	l_business_group_id,
		l_payroll_id
	from	per_all_assignments_f
	where	assignment_id = p_assignment_id
	and	p_upload_date
		between effective_start_date and effective_end_date;
	--
	-- Calculate the expiry date for the specified dimension relative to the
	-- upload date, taking into account any contexts where appropriate. Each of
	-- the calculations also takes into account when the assignment is on a
	-- payroll to ensure that a balance adjustment could be made at that point
	-- if it were required.
	--
	-- Returns 1st Period Start Date.
	-- Also check whether payroll period exists as of p_upload_date.
	--
	hr_utility.set_location(c_proc, 20);
	--
	select	nvl(min(ptp2.start_date), END_OF_TIME)
	into	l_ptp_start_date
	from	per_time_periods	ptp,
		per_time_periods	ptp2
	where	ptp.payroll_id = l_payroll_id
	and	p_upload_date
		between ptp.start_date and ptp.end_date
	and	ptp2.payroll_id = ptp.payroll_id
	and	ptp2.start_date <= p_upload_date;
	--
	-- Returns the date on which the assignment transferred payroll prior to
	-- the upload date NB. the payroll is the one the assignment is assigned to
	-- on the upload date.
	--
	hr_utility.set_location(c_proc, 30);
	--
	select	max(asg.effective_end_date) + 1
	into	l_asg_start_date
	from	per_all_assignments_f	asg
	where	asg.assignment_id = p_assignment_id
	and	asg.effective_end_date < p_upload_date
	and	nvl(asg.payroll_id, -1) <> l_payroll_id;
	--
	if l_asg_start_date is null then
		hr_utility.set_location(c_proc, 35);
		--
		select	min(asg.effective_start_date)
		into	l_asg_start_date
		from	per_all_assignments_f	asg
		where	asg.assignment_id = p_assignment_id;
	end if;
	--
	-- In case of element level dimension
	--
	if p_original_entry_id is not null then
		hr_utility.set_location(c_proc, 41);
		--
		select	nvl(min(ee.effective_start_date), END_OF_TIME)
		into	l_ee_start_date
		from	pay_element_entries_f	ee
		where	(	ee.element_entry_id = p_original_entry_id
			or	ee.original_entry_id = p_original_entry_id)
		and	ee.assignment_id = p_assignment_id
		and	ee.entry_type = 'E'
		and	ee.effective_start_date <= p_upload_date;
	else
		hr_utility.set_location(c_proc, 42);
		--
		l_ee_start_date := START_OF_TIME;
	end if;
	--
	-- Returns the start date of balance dimension.
	--
	l_legislation_code := hr_api.return_legislation_code(l_business_group_id);
	--
	hr_utility.set_location(c_proc, 50);
	--
	select	period_type,
		start_date_code
	into	l_period_type,
		l_start_date_code
	from	pay_balance_dimensions
	where	dimension_name = p_dimension_name
	and	nvl(business_group_id, l_business_group_id) = l_business_group_id
	and	nvl(legislation_code, l_legislation_code) = l_legislation_code;
	--
	hr_utility.set_location(c_proc, 51);
	--
	pay_balance_pkg.get_period_type_start(
		P_PERIOD_TYPE		=> l_period_type,
		P_EFFECTIVE_DATE	=> p_upload_date,
		P_START_DATE		=> l_dim_start_date,
		P_START_DATE_CODE	=> l_start_date_code,
		P_PAYROLL_ID		=> l_payroll_id,
		P_BUS_GRP		=> l_business_group_id);
	--
	hr_utility.set_location(c_proc, 60);
	--
	l_expiry_date := greatest(l_ptp_start_date, l_asg_start_date, l_ee_start_date, l_dim_start_date);
	--
	hr_utility.trace('PTP_START_DATE: ' || l_ptp_start_date);
	hr_utility.trace('ASG_START_DATE: ' || l_asg_start_date);
	hr_utility.trace('EE_START_DATE : ' || l_ee_start_date);
	hr_utility.trace('DIM_START_DATE: ' || l_dim_start_date);
	hr_utility.trace('EXPIRY_DATE   : ' || l_expiry_date);
	--
	hr_utility.set_location('Leaving: ' || c_proc, 100);
	return (l_expiry_date);
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
  p_dimension_name  in varchar2
) return boolean
is
  c_proc             constant varchar2(61) := c_package || 'is_supported';
  l_is_supported     boolean;
  l_description      pay_balance_dimensions.description%type;
  l_dimension_level  pay_balance_dimensions.dimension_level%type;
  l_period_type      pay_balance_dimensions.period_type%type;
begin
  hr_utility.set_location('Entering: ' || c_proc, 10);
  --
  -- This SQL can possiblly raise TOO_MANY_ROWS exception
  -- when the same dimension name exists over multiple business groups.
  -- Current temporary workaround is to use distinct.
  -- If user defines the same dimension_name for dimensions with different parameters
  -- over multiple business groups, following SQL still raises TOO_MANY_ROWS error.
  -- In this case, this function will return "FALSE", which means this dimension is
  -- not supported for Balance Initialization.
  --
  select  distinct
          description,
          dimension_level,
          period_type
  into    l_description,
          l_dimension_level,
          l_period_type
  from    pay_balance_dimensions    dim,
          per_business_groups_perf  bg
  where   dim.dimension_name = p_dimension_name
  and     bg.business_group_id(+) = dim.business_group_id
  and     nvl(dim.legislation_code, bg.legislation_code) = 'JP';
  --
  -- See if the dimension is supported.
  -- DATE_EARNED based dimensions cannot be supported because of PURGE process.
  --
  if  l_dimension_level = 'ASG'
  and nvl(l_period_type, 'RUN') not in ('RUN', 'PAYMENT')
  and nvl(pay_core_utils.get_parameter('DATE_TYPE', l_description), 'DP') <> 'DE' then
    l_is_supported := true;
  else
    l_is_supported := false;
  end if;
  --
  hr_utility.set_location('Leaving: ' || c_proc, 100);
  return (l_is_supported);
exception
  when no_data_found then
    return false;
  when too_many_rows then
    return false;
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
  p_balance_type_id     in number
 ,p_dimension_name      in varchar2
 ,p_original_entry_id   in number
 ,p_bal_adjustment_rec  in pay_balance_upload.csr_balance_adjustment%rowtype -- pay_temp_balance_adjustments
) return boolean
is
  c_proc  constant varchar2(61) := c_package || 'include_adjustment';
  ret_val boolean;
begin
  hr_utility.set_location('Entering: ' || c_proc, 10);
  --
  if (p_original_entry_id = p_bal_adjustment_rec.original_entry_id)
  or (p_original_entry_id is null) then
--  or (p_original_entry_id is null
--      and p_bal_adjustment_rec.original_entry_id is null) then
    ret_val := TRUE;
  else
    ret_val := FALSE;
  end if;
  --
  hr_utility.set_location('Leaving: ' || c_proc, 100);
  return (ret_val);
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
  p_batch_id  in number
)
is
  c_proc  constant varchar2(61) := c_package || 'validate_batch_lines';
begin
  hr_utility.set_location('Entering: ' || c_proc, 10);
  --
  hr_utility.set_location('Leaving: ' || c_proc, 100);
end validate_batch_lines;
--
end pay_jp_bal_upload;

/
