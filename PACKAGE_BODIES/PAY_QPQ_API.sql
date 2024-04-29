--------------------------------------------------------
--  DDL for Package Body PAY_QPQ_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_QPQ_API" as
/* $Header: pyqpqrhi.pkb 120.1.12010000.3 2010/03/29 11:42:15 phattarg ship $ */
--
-- Current record structure definition
--
g_old_rec  g_rec_type;
--
-- Global package name
--
g_package  varchar2(33) := '  pay_qpq_api.';
--
-- Global api dml status
--
g_api_dml  boolean;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< use_qpay_excl_model >------------------------|
-- ----------------------------------------------------------------------------
function use_qpay_excl_model return varchar2 is
  /*
  || Introduced via Enhancement 3368211.
  || This function is used to determine whether the new QuickPay Exclusions
  || data model is in use.
  */
  --
  l_short_name varchar2(30) := 'QPAY_EXCL_TABLE';
  l_status     varchar2(15);
  l_use_qpay_excl_model boolean;
  --
  qpay_upgrade_in_progress exception;
  pragma exception_init (qpay_upgrade_in_progress, -20001);
  --
begin
  --
  pay_core_utils.get_upgrade_status(
    p_bus_grp_id => null,
    p_short_name => l_short_name,
    p_status => l_status
    );
  --
  return l_status;
  --
exception
  --
  when qpay_upgrade_in_progress then
    hr_utility.set_message(801,'PAY_33880_QPAY_UPG_IN_PROGRESS');
    hr_utility.raise_error;
  --
end use_qpay_excl_model;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< control_separate_check_entries >---------------|
-- ----------------------------------------------------------------------------
procedure control_separate_check_entries

	/*
	|| This procedure ensures that a 'quickpay' payroll run cannot contain
	|| an earnings entry that is required to be processed separately as well as any
	|| other earnings entry. This is done by looking for a specified set of input
	|| value names. The check is only meaningful for the US legislation.
	*/

	(
	pi_payroll_action_id in pay_payroll_actions.payroll_action_id%type
	-- The "in" parameter used to identify Payroll Action
	) is

-- Trace variables used for debugging
l_procedure_name constant varchar2 (72) := g_package||'control_separate_check_entries';
l_step_reached varchar2 (4) := '0';

-- The conditions which must be met for the parameters to be valid
all_parameters_are_valid constant boolean := (pi_payroll_action_id is not null);

--
-- Enhancement 3368211
-- This is the version of csr_earnings to be used with the obsolete
-- QuickPay Inclusions model
--
cursor csr_earnings_old (

	-- Get the number of earnings entries in the quickpay run

	pi_look_for_separate_check in varchar2 default 'YES'

	-- If parameter set to YES then look only for entries that must be processed
	-- separately, otherwise look only for entries without that requirement.

	) is

        select  /*+ ORDERED INDEX(PAY_ACTION PAY_PAYROLL_ACTIONS_PK)
                            INDEX(ASGT_ACTION PAY_ASSIGNMENT_ACTIONS_N50)
                            INDEX(QP_INCL PAY_QUICKPAY_INCLUSIONS_FK2)
                            INDEX(ENTRY PAY_ELEMENT_ENTRIES_F_PK)
                            INDEX(LINK PAY_ELEMENT_LINKS_F_PK)
                            INDEX(ELEMENT PAY_ELEMENT_TYPES_F_PK)
                            INDEX(CLASS PAY_ELEMENT_CLASSIFICATION_PK)
                            INDEX(ENTVAL PAY_ELEMENT_ENTRY_VALUES_F_N50)
            USE_NL(PAY_ACTION, ASGT_ACTION) USE_NL(ASGT_ACTION, QP_INCL)
            USE_NL(QP_INCL, ENTRY) USE_NL(ENTRY, LINK)  USE_NL(LINK, ELEMENT)
            USE_NL(ELEMENT, CLASS) USE_NL(CLASS, ENTVAL) */
                count (*) TOTAL_OF_ROWS
        from    pay_payroll_actions             PAY_ACTION,
                pay_assignment_actions          ASGT_ACTION,
                pay_quickpay_inclusions         QP_INCL,
                pay_element_entries_f           ENTRY,
                pay_element_links_f             LINK,
                pay_element_types_f             ELEMENT,
                pay_element_classifications     CLASS,
                pay_element_entry_values_f      ENTVAL
	where	pay_action.payroll_action_id = PI_PAYROLL_ACTION_ID
	and	asgt_action.payroll_action_id = pay_action.payroll_action_id
	and	asgt_action.assignment_action_id = qp_incl.assignment_action_id
	and	qp_incl.element_entry_id = entry.element_entry_id
	and	entry.element_link_id = link.element_link_id
	and	link.element_type_id = element.element_type_id
	and	entry.element_entry_id = entval.element_entry_id (+)
	and	(entval.element_entry_value_id is null
		or pay_action.effective_date between entval.effective_start_date
						and entval.effective_end_date)
	and	pay_action.effective_date between entry.effective_start_date
						and entry.effective_end_date
	and	pay_action.effective_date between link.effective_start_date
						and link.effective_end_date
	and	pay_action.effective_date between element.effective_start_date
						and element.effective_end_date
	and	element.classification_id = class.classification_id
	/* and the element is an earnings element */
	and	class.classification_name in (	'Earnings',
						'Imputed Earnings',
						'Supplemental Earnings')
	/* and the element is in a US legislation */
	and	(element.legislation_code = 'US'
		or (element.legislation_code is null
		   and exists (
			select 1
			from per_business_groups_perf BIZ_GRP
			where element.business_group_id = biz_grp.business_group_id
			and biz_grp.legislation_code = 'US')))
	/* and there is or is not an input value indicating that the entry must be
	processed separately, depending upon the parameter */
	and	(nvl (PI_LOOK_FOR_SEPARATE_CHECK, 'NO') = 'YES'
		and exists (
			select 1
			from pay_input_values_f INPVAL
			where inpval.element_type_id = element.element_type_id
			and ((upper (inpval.name) in (	'SEPARATE CHECK',
							'TAX SEPARATELY')
                             and entval.screen_entry_value = 'Y')
                        or  (upper (inpval.name) = 'DEDUCTION PROCESSING'
                             and entval.screen_entry_value in ('T', 'PTT')))
			and inpval.input_value_id = entval.input_value_id
			and pay_action.effective_date
				between inpval.effective_start_date
				and inpval.effective_end_date)
		or (nvl (PI_LOOK_FOR_SEPARATE_CHECK, 'NO') <> 'YES'
		    and NOT exists (
			select 1
			from pay_input_values_f INPVAL
			where inpval.element_type_id = element.element_type_id
			and ((upper (inpval.name) in (	'SEPARATE CHECK',
							'TAX SEPARATELY')
                             and entval.screen_entry_value = 'Y')
                        or  (upper (inpval.name) = 'DEDUCTION PROCESSING'
                             and entval.screen_entry_value in ('T', 'PTT')))
			and inpval.input_value_id = entval.input_value_id
			and pay_action.effective_date
				between inpval.effective_start_date
				and inpval.effective_end_date)));

--
-- Enhancement 3368211
-- This is the updated version of csr_earnings to be used with the new
-- QuickPay Exclusions model
--
cursor csr_earnings (

	-- Get the number of earnings entries in the quickpay run

	pi_look_for_separate_check in varchar2 default 'YES'

	-- If parameter set to YES then look only for entries that must be processed
	-- separately, otherwise look only for entries without that requirement.

	) is

        select  /*+ ORDERED INDEX(PAY_ACTION PAY_PAYROLL_ACTIONS_PK)
                            INDEX(ASGT_ACTION PAY_ASSIGNMENT_ACTIONS_N50)
                            INDEX(ENTRY PAY_ELEMENT_ENTRIES_F_N50)
                            INDEX(LINK PAY_ELEMENT_LINKS_F_PK)
                            INDEX(ELEMENT PAY_ELEMENT_TYPES_F_PK)
                            INDEX(CLASS PAY_ELEMENT_CLASSIFICATION_PK)
                            INDEX(ENTVAL PAY_ELEMENT_ENTRY_VALUES_F_N50)
            USE_NL(PAY_ACTION, ASGT_ACTION) USE_NL(ENTRY, LINK)
            USE_NL(LINK, ELEMENT) USE_NL(ELEMENT, CLASS)
            USE_NL(CLASS, ENTVAL) */
                count (*) TOTAL_OF_ROWS
        from    pay_payroll_actions             PAY_ACTION,
                pay_assignment_actions          ASGT_ACTION,
                pay_element_entries_f           ENTRY,
                pay_element_links_f             LINK,
                pay_element_types_f             ELEMENT,
                pay_element_classifications     CLASS,
                pay_element_entry_values_f      ENTVAL
	where	pay_action.payroll_action_id = PI_PAYROLL_ACTION_ID
	and	asgt_action.payroll_action_id = pay_action.payroll_action_id
  and asgt_action.assignment_id = entry.assignment_id
  /* and entry doesn't exist in Pay_Quickpay_Exclusions */
  and not (
    exists (
      select 'x'
      from pay_quickpay_exclusions QP_EXCL
      where qp_excl.assignment_action_id = asgt_action.assignment_action_id
      and qp_excl.element_entry_id = entry.element_entry_id
      )
    )
	and	entry.element_link_id = link.element_link_id
	and	link.element_type_id = element.element_type_id
	and	entry.element_entry_id = entval.element_entry_id (+)
	and	(entval.element_entry_value_id is null
		or pay_action.effective_date between entval.effective_start_date
						and entval.effective_end_date)
	and	pay_action.effective_date between entry.effective_start_date
						and entry.effective_end_date
	and	pay_action.effective_date between link.effective_start_date
						and link.effective_end_date
	and	pay_action.effective_date between element.effective_start_date
						and element.effective_end_date
	and	element.classification_id = class.classification_id
	/* and the element is an earnings element */
	and	class.classification_name in (	'Earnings',
						'Imputed Earnings',
						'Supplemental Earnings')
	/* and the element is in a US legislation */
	and	(element.legislation_code = 'US'
		or (element.legislation_code is null
		   and exists (
			select 1
			from per_business_groups_perf BIZ_GRP
			where element.business_group_id = biz_grp.business_group_id
			and biz_grp.legislation_code = 'US')))
	/* and there is or is not an input value indicating that the entry must be
	processed separately, depending upon the parameter */
	and	(nvl (PI_LOOK_FOR_SEPARATE_CHECK, 'NO') = 'YES'
		and exists (
			select 1
			from pay_input_values_f INPVAL
			where inpval.element_type_id = element.element_type_id
			and ((upper (inpval.name) in (	'SEPARATE CHECK',
							'TAX SEPARATELY')
                             and entval.screen_entry_value = 'Y')
                        or  (upper (inpval.name) = 'DEDUCTION PROCESSING'
                             and entval.screen_entry_value in ('T', 'PTT')))
			and inpval.input_value_id = entval.input_value_id
			and pay_action.effective_date
				between inpval.effective_start_date
				and inpval.effective_end_date)
		or (nvl (PI_LOOK_FOR_SEPARATE_CHECK, 'NO') <> 'YES'
		    and NOT exists (
			select 1
			from pay_input_values_f INPVAL
			where inpval.element_type_id = element.element_type_id
			and ((upper (inpval.name) in (	'SEPARATE CHECK',
							'TAX SEPARATELY')
                             and entval.screen_entry_value = 'Y')
                        or  (upper (inpval.name) = 'DEDUCTION PROCESSING'
                             and entval.screen_entry_value in ('T', 'PTT')))
			and inpval.input_value_id = entval.input_value_id
			and pay_action.effective_date
				between inpval.effective_start_date
				and inpval.effective_end_date)));

l_separate_check_earnings csr_earnings%rowtype;
l_collective_check_earnings csr_earnings%rowtype;

too_many_separate_checks exception;
	-- It is not allowed to have more than one 'separate check' entry in
	-- the same payroll run
separate_check_not_separate exception;
	-- It is not allowed to have a 'separate check' entry in the payroll
	-- run together with other earnings entries.

procedure step
	-- Mark the step reached and output the debug location
       (
	pi_step in natural,
	-- The point within the code that was reached

	pi_message_prefix in varchar2 default null
	--Text to be prepended to the location text

	) is

	lpi_message_prefix varchar2 (80) := pi_message_prefix || ' ';

	begin

	l_step_reached := to_char (pi_step);

	hr_utility.set_location (lpi_message_prefix || l_procedure_name,
				l_step_reached);

end step;

BEGIN

step (1, 'Entering');
hr_general.assert_condition (all_parameters_are_valid);

step (2);

-- Get the number of earnings entries included in the run that must be
-- separately processed
--
-- Enhancement 3368211
-- First, check which version of csr_earnings we should be using
if use_qpay_excl_model = 'Y' then
  open csr_earnings (pi_look_for_separate_check => 'YES');
  fetch csr_earnings into l_separate_check_earnings;
  close csr_earnings;
else
  open csr_earnings_old (pi_look_for_separate_check => 'YES');
  fetch csr_earnings_old into l_separate_check_earnings;
  close csr_earnings_old;
end if;

step(3);

if
   -- if there is one entry which must be separately processed
   l_separate_check_earnings.total_of_rows = 1
then

  step(4);

  -- Get the number of earnings entries included in the run that do NOT require
  -- to be separately processed.
  --
  -- Enhancement 3368211
  -- First, check which version of csr_earnings we should be using
  if use_qpay_excl_model = 'Y' then
    open csr_earnings (pi_look_for_separate_check => 'NO');
    fetch csr_earnings into l_collective_check_earnings;
    close csr_earnings;
  else
    open csr_earnings_old (pi_look_for_separate_check => 'NO');
    fetch csr_earnings_old into l_collective_check_earnings;
    close csr_earnings_old;
  end if;

  if
     -- if there is any earnings entry which should NOT be separately processed
     l_collective_check_earnings.total_of_rows > 0
  then

    step (5);
    raise separate_check_not_separate;

  end if;

elsif
      -- if there is more than one entry which must be separately processed
      l_separate_check_earnings.total_of_rows > 1
then

  step (6);
  raise too_many_separate_checks;

end if;

step (7, 'Leaving');

EXCEPTION

when value_error
then

  -- Probably caused by one of the conditions specified in the variable
  -- all_parameters_are_valid being FALSE. This is a trap for invalid
  -- parameter values.

  fnd_message.set_name ('PAY','HR_6153_ALL_PROCEDURE_FAIL');
  fnd_message.set_token ('PROCEDURE',l_procedure_name);
  fnd_message.set_token ('STEP',l_step_reached);
  fnd_message.raise_error;

when separate_check_not_separate
or too_many_separate_checks
then

  fnd_message.set_name ('PAY','HR_51295_QP_MIXED_TAXSEP');
  fnd_message.raise_error;

END control_separate_check_entries;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_asg_on_payroll >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure chk_asg_on_payroll
  (p_assignment_id in pay_assignment_actions.assignment_id%TYPE
  ) is
  --
  v_exists   varchar2(1);
  v_proc     varchar2(72) := g_package||'chk_asg_on_payroll';
  v_argument varchar2(30);
  --
  cursor pay_asg is
    select 'Y'
      from fnd_sessions         ses
         , per_assignments_f    asg
     where ses.session_id           = userenv('SESSIONID')
       and ses.effective_date between asg.effective_start_date
                                  and asg.effective_end_date
       and asg.payroll_id      is not null
       and asg.assignment_id        = p_assignment_id;
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => v_proc
    ,p_argument       => 'assignment_id'
    ,p_argument_value => p_assignment_id
    );
  --
  -- Check the assignment is on the payroll as of the effective date
  --
  open pay_asg;
  fetch pay_asg into v_exists;
  if pay_asg%notfound then
    close pay_asg;
    -- Error: You have tried to define QuickPay for an assignment that has no
    -- payroll component valid at Date Paid.  For the run to process, you
    -- must create a payroll component that is valid at this date.
    hr_utility.set_message(801, 'HR_7242_QPAY_NO_PAY_D_PAID');
    hr_utility.raise_error;
  end if;
  close pay_asg;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
end chk_asg_on_payroll;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_new_eff_date >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure chk_new_eff_date
  (p_assignment_id in varchar2
  ,p_new_date      in varchar2
  ) is
  --
  v_exists    varchar2(1);
  v_proc      varchar2(72) := g_package||'chk_new_eff_date';
  v_argument  varchar2(30);
  --
  cursor cur_dat (v_assignment_id number, v_new_date date) is
    select 'Y'
      from per_assignments_f   asg
     where asg.assignment_id       = v_assignment_id
       and asg.payroll_id     is not null
       and v_new_date        between asg.effective_start_date
                                 and asg.effective_end_date;
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => v_proc
    ,p_argument       => 'assignment_id'
    ,p_argument_value => p_assignment_id
    );
  hr_api.mandatory_arg_error
    (p_api_name       => v_proc
    ,p_argument       => 'new_date'
    ,p_argument_value => p_new_date
    );
  --
  -- Check that the assignment is on a payroll as of
  -- the proposed effective date
  --
  open cur_dat(fnd_number.canonical_to_number(p_assignment_id), fnd_date.canonical_to_date(p_new_date));
  fetch cur_dat into v_exists;
  if cur_dat%notfound then
    close cur_dat;
    -- Error: You cannot change to this effective date, because the current
    -- assignment is not on a payroll as of the new date.
    hr_utility.set_message(801, 'HR_7243_QPAY_NOT_PAY_NEW_DATE');
    hr_utility.raise_error;
  end if;
  close cur_dat;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
end chk_new_eff_date;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_assignment >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that the assignment is in the same business group as the
--   QuickPay, as of a particular date.
--
-- Pre Conditions:
--   p_business_group_id is known to be an existing business group.
--   p_assignment_id is known to be a valid assignment which exists at some
--   point in time.
--
-- In Arguments:
--   p_assignment_id the assignment to check.
--   p_business_group_id the business group to check.
--   p_effective_date the date the assignment must exist.
--
-- Post Success:
--   End normally if the assignment exists as of p_effective_date and is in
--   business group p_business_group_id.
--
-- Post Failure:
--   Raises an application error if the assignment does not exist in
--   p_business_group_id at p_effective_date.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure chk_assignment
  (p_assignment_id     in pay_assignment_actions.assignment_id%TYPE
  ,p_business_group_id in pay_payroll_actions.business_group_id%TYPE
  ,p_effective_date    in pay_payroll_actions.effective_date%TYPE
  ) is
  --
  v_exists  varchar2(1);
  v_proc    varchar2(72) := g_package||'chk_assignment';
  --
  cursor sel_asg is
    select 'Y'
      from per_assignments_f
     where assignment_id           = p_assignment_id
       and business_group_id + 0   = p_business_group_id
       and p_effective_date  between effective_start_date
                                 and effective_end_date;
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  open sel_asg;
  fetch sel_asg into v_exists;
  if sel_asg%notfound then
    close sel_asg;
    -- Error: You have tried to define QuickPay for an assignment that is to a
    -- different Business Group, or does not exist at Date Paid.
    hr_utility.set_message(801, 'HR_7244_QPAY_NO_PAY_D_EFF');
    hr_utility.raise_error;
  end if;
  close sel_asg;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
end chk_assignment;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_consol_set >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that a consolidation set exists in a particular business group.
--
-- Pre Conditions:
--   p_business_group_id is known to be an existing business group.
--
-- In Arguments:
--   p_consolidation_set_id the consolidation set to check.
--   p_business_group_id the id of the business group to check the
--   consolidation set is in.
--
-- Post Success:
--   Ends normally if the consolidation set (p_consolidation_set_id) exists
--   and is in the same business group as p_business_group_id.
--
-- Post Failure:
--   An application error is raised if any of the following are true:
--     1) A consolidation_set does not exist with an id of
--        p_consolidation_set_id.
--     2) The p_consolidation_set_id does exist but it is not in the same
--        business group as p_business_group_id.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure chk_consol_set
  (p_consolidation_set_id in pay_consolidation_sets.consolidation_set_id%TYPE
  ,p_business_group_id    in pay_consolidation_sets.business_group_id%TYPE
  ) is
  --
  v_exists  varchar2(1);
  v_proc    varchar2(72) := g_package||'chk_consol_set';
  --
  cursor sel_set is
    select 'Y'
      from pay_consolidation_sets
     where consolidation_set_id  = p_consolidation_set_id
       and business_group_id + 0 = p_business_group_id;
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  open sel_set;
  fetch sel_set into v_exists;
  if sel_set%notfound then
    close sel_set;
    -- Error: You have tried to define QuickPay for a consolidation set that
    -- does not exist, or does not exist in the Business Group defined for the
    -- run.
    hr_utility.set_message(801, 'HR_7245_QPAY_INVAL_CON_SET');
    hr_utility.raise_error;
  end if;
  close sel_set;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
end chk_consol_set;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_period_exists >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that a time period exists for a payroll as of a specified
--   date. Used for validating that a period exists for the QuickPay date paid
--   and date earned.
--
-- Pre Conditions:
--   p_payroll_id is known to be a valid payroll which does exist as of p_date.
--   p_message exists in the AOL message dictionary.
--
-- In Arguments:
--   p_date is the date to check for,
--   p_payroll_id is payroll to check there is a time period for as of p_date.
--   p_message is set to message_name to be raised if a period does
--   not exist.
--
-- Post Success:
--   p_time_period_id is set to per_time_periods.time_period_id and
--   p_period_name is set to per_time_periods.period_name for the period
--   which exists as of p_date for the payroll p_payroll_id.
--
-- Post Failure:
--   The application error p_message is raised if a time period does not
--   exist for the payroll as of p_date. The values of p_time_period_id and
--   p_period_name are undefined as the end of the procedure is not reached.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure chk_period_exists
  (p_date           in     date
  ,p_payroll_id     in     per_time_periods.payroll_id%TYPE
  ,p_message        in     varchar2
  ,p_time_period_id    out nocopy per_time_periods.time_period_id%TYPE
  ,p_period_name       out nocopy per_time_periods.period_name%TYPE
  ) is
  --
  v_time_period_id  per_time_periods.time_period_id%TYPE;
  v_period_name     per_time_periods.period_name%TYPE;
  v_proc            varchar2(72) := g_package||'chk_period_exists';
  --
  cursor sel_tim is
    select time_period_id
         , period_name
      from per_time_periods
     where payroll_id       = p_payroll_id
       and p_date     between start_date
                          and end_date;
  --
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  open sel_tim;
  fetch sel_tim into v_time_period_id, v_period_name;
  if sel_tim%notfound then
    --
    -- Could not find a row in per_time_periods which matches
    -- p_date and p_payroll_id. So need to raise the error p_message.
    --
    close sel_tim;
    hr_utility.set_message(801, p_message);
    hr_utility.raise_error;
  end if;
  close sel_tim;
  --
  p_time_period_id := v_time_period_id;
  p_period_name    := v_period_name;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
end chk_period_exists;
--
-- ----------------------------------------------------------------------------
-- |--------------------< chk_period_exists_eff_for_gb >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates that a time period exists for a payroll as of a specified
--   date. Used for validating that a period exists for the QuickPay date paid
--   and date earned.
--
-- Pre Conditions:
--   p_payroll_id is known to be a valid payroll which does exist as of p_date.
--   p_message exists in the AOL message dictionary.
--
-- In Arguments:
--   p_date is the date to check for,
--   p_payroll_id is payroll to check there is a time period for as of p_date.
--   p_message is set to message_name to be raised if a period does
--   not exist.
--
-- Post Success:
--   p_time_period_id is set to per_time_periods.time_period_id and
--   p_period_name is set to per_time_periods.period_name for the period
--   which exists as of p_date for the payroll p_payroll_id.
--
-- Post Failure:
--   The application error p_message is raised if a time period does not
--   exist for the payroll as of p_date. The values of p_time_period_id and
--   p_period_name are undefined as the end of the procedure is not reached.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure chk_period_exists_eff_for_gb
  (p_date           in     date
  ,p_payroll_id     in     per_time_periods.payroll_id%TYPE
  ,p_message        in     varchar2
  ,p_time_period_id    out nocopy per_time_periods.time_period_id%TYPE
  ,p_period_name       out nocopy per_time_periods.period_name%TYPE
  ) is
  --
  v_time_period_id  per_time_periods.time_period_id%TYPE;
  v_period_name     per_time_periods.period_name%TYPE;
  v_proc            varchar2(72) := g_package||'chk_period_exists';
  --
  cursor sel_tim is
    select time_period_id
         , period_name
      from per_time_periods
     where payroll_id       = p_payroll_id
       and p_date           = regular_payment_date;
  --
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  open sel_tim;
  fetch sel_tim into v_time_period_id, v_period_name;
  if sel_tim%notfound then
    --
    -- Could not find a row in per_time_periods which matches
    -- p_date and p_payroll_id. So need to raise the error p_message.
    --
    close sel_tim;
    hr_utility.set_message(801, p_message);
    hr_utility.raise_error;
  end if;
  close sel_tim;
  --
  p_time_period_id := v_time_period_id;
  p_period_name    := v_period_name;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
end chk_period_exists_eff_for_gb;
--
-- ----------------------------------------------------------------------------
-- |------------------------< get_date_earned_for_gb >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Derives the date_earned value for the GB legislation.
--
-- Pre Conditions:
--   The current business group is known to be for GB legislation.
--   Assumes the assignment exists and is on a payroll as of p_effective_date.
--
-- In Arguments:
--   p_effective_date set to the date paid value the user has entered or
--   the GB default value.
--
-- Post Success:
--   Returns the derived value for date_earned. If the default date earned
--   cannot be derived, then p_gb_date_earned will be set to null.
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function get_date_earned_for_gb
  (p_assignment_id   in pay_assignment_actions.assignment_id%TYPE
  ,p_effective_date  in pay_payroll_actions.effective_date%TYPE
  ) return pay_payroll_actions.date_earned%TYPE is
  --
  -- Cursor definitions
  --
  -- Used to find the start and end dates of the matching period
  --
  cursor csr_per_dat is
    select p.start_date
         , p.end_date
         , a.payroll_id
      from per_time_periods  p
         , per_assignments_f a
     where a.assignment_id        = p_assignment_id
       and p_effective_date between a.effective_start_date
                                and a.effective_end_date
       and p.payroll_id           = a.payroll_id
       and p_effective_date       = p.regular_payment_date;
  --
  -- Used to find all the assignment rows which overlap the
  -- current time period.
  --
  cursor csr_per_asg (v_period_start date
                     ,v_period_end   date
                     ) is
    select a.effective_start_date
         , a.effective_end_date
         , a.payroll_id
      from per_assignments_f a
     where a.assignment_id         = p_assignment_id
       and a.effective_end_date   >= v_period_start
       and a.effective_start_date <= v_period_end
  order by a.effective_start_date;
  --
  -- Local variables
  --
  -- The start date of the period which matches the assignment's payroll and
  -- p_effective_date.
  v_period_start_date date;
  --
  -- The end date of the period which matches the assignment's payroll and
  -- p_effective_date.
  v_period_end_date   date;
  --
  -- The assignment's payroll as of p_effective_date.
  v_cur_payroll_id    per_assignments_f.payroll_id%TYPE;
  --
  -- Working value for the date earned. The best value so far given the
  -- the processed records.
  v_wrk_date          date := null;
  v_proc              varchar2(72) := g_package||'get_date_earned_for_gb';
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Get the period start, end dates and the assignment's current payroll.
  --
  open csr_per_dat;
  fetch csr_per_dat into v_period_start_date
                       , v_period_end_date
                       , v_cur_payroll_id;
  close csr_per_dat;
  --
  -- Loop for assignment records which overlap with the current period
  --
  <<csr_per_asg_loop>>
  for cur_asg IN csr_per_asg (v_period_start_date, v_period_end_date) loop
    --
    if cur_asg.effective_end_date <= v_period_end_date  and
       cur_asg.payroll_id          = v_cur_payroll_id   then
      --
      -- Use the date for the current assignment record only if the record
      -- does not last after the end of the periods and the payroll_id
      -- matches the current payroll.
      --
      v_wrk_date := cur_asg.effective_end_date;
      hr_utility.set_location(v_proc, 6);
      --
    elsif cur_asg.payroll_id = v_cur_payroll_id then
      --
      -- If the assignment is still on the same payroll at the end of
      -- the period, then use the end of period date.
      --
      v_wrk_date := v_period_end_date;
      hr_utility.set_location(v_proc, 7);
      --
    else
      --
      -- The current assignment is not on the same payroll as of the
      -- driving date.
      --
      null;
      hr_utility.set_location(v_proc, 8);
    end if;
    --
  end loop csr_per_asg_loop;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  return v_wrk_date;
end get_date_earned_for_gb;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_eff_date_for_gb >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure contains additional GB specific validation for the
--   QuickPay Run effective_date attribute. It should not called directly.
--   It is a supporting procedure for chk_eff_date only.
--
-- Pre Conditions:
--   p_time_period_id is the id of a time period which is known to exist
--   as of p_effective_date.
--
-- In Arguments:
--   p_effective_date the date paid for the QuickPay Run Payroll Process.
--   p_time_period_id set to the time period which is current as of
--   p_effective_date for the current assignment's payroll.
--
-- Post Success:
--   Ends normally if p_effective_date corresponds to the regular payment
--   date for the current time period.
--
-- Post Failure:
--   An application error message is raised if p_effective_date does not
--   equal the regular payment date for the current time period.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure chk_eff_date_for_gb
  (p_effective_date  in  pay_payroll_actions.effective_date%TYPE
  ,p_time_period_id  in  pay_payroll_actions.time_period_id%TYPE
  ) is
  --
  v_exists  varchar2(1);
  v_proc    varchar2(72) := g_package||'chk_eff_date_for_gb';
  --
  cursor sel_tim is
    select 'Y'
      from per_time_periods
     where time_period_id       = p_time_period_id
       and regular_payment_date = p_effective_date;
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  open sel_tim;
  fetch sel_tim into v_exists;
  if sel_tim%notfound then
    close sel_tim;
    -- Error: The QuickPay Date Paid must be the same as a payroll
    -- period regular payment date.
    hr_utility.set_message(801, 'HR_7286_QPAY_EFF_FOR_GB');
    hr_utility.raise_error;
  end if;
  close sel_tim;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
end chk_eff_date_for_gb;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_eff_date >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure chk_eff_date
  (p_effective_date    in     pay_payroll_actions.effective_date%TYPE
  ,p_assignment_id     in     pay_assignment_actions.assignment_id%TYPE
  ,p_legislation_code  in     per_business_groups.legislation_code%TYPE
  ,p_recal_date_earned in     boolean
  ,p_payroll_id           out nocopy pay_payroll_actions.payroll_id%TYPE
  ,p_time_period_id       out nocopy pay_payroll_actions.time_period_id%TYPE
  ,p_period_name          out nocopy per_time_periods.period_name%TYPE
  ,p_new_date_earned      out nocopy pay_payroll_actions.date_earned%TYPE
  ) is
  --
  v_payroll_id            pay_payroll_actions.payroll_id%TYPE;
  v_eff_time_period_id    per_time_periods.time_period_id%TYPE;
  v_eff_time_period_name  per_time_periods.period_name%TYPE;
  v_new_date_earned       pay_payroll_actions.date_earned%TYPE;
  v_proc                  varchar2(72) := g_package||'chk_eff_date';
  v_rule_mode             pay_legislation_rules.rule_mode%type;
  --
  -- Used to find out if the assingment is on a payroll as p_effective_date
  --
  cursor sel_pay is
    select asg.payroll_id
      from per_assignments_f asg
     where /* Payroll as of effective date */
           asg.assignment_id       = p_assignment_id
       and asg.payroll_id     is not null
       and p_effective_date  between asg.effective_start_date
                                 and asg.effective_end_date;
  --
  cursor get_leg_rule is
    select rule_mode
      from pay_legislation_rules
     where rule_type = 'ENABLE_QP_OFFSET'
       and legislation_code = p_legislation_code;
  --
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Check mandatory arguments have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => v_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_effective_date
    );
  hr_api.mandatory_arg_error
    (p_api_name       => v_proc
    ,p_argument       => 'assignment_id'
    ,p_argument_value => p_assignment_id
    );
  hr_api.mandatory_arg_error
    (p_api_name       => v_proc
    ,p_argument       => 'legislation_code'
    ,p_argument_value => p_legislation_code
    );
  --
  -- Ensure the assignment is on a payroll as of the effective_date.
  --
  open sel_pay;
  fetch sel_pay into v_payroll_id;
  if sel_pay%notfound then
    close sel_pay;
    -- Error: You have tried to define QuickPay for an assignment that has no
    -- payroll component defined at Date Paid.
    hr_utility.set_message(801, 'HR_7246_QPAY_ASG_PAY_D_PAID');
    hr_utility.raise_error;
  end if;
  close sel_pay;
  hr_utility.set_location(v_proc, 6);
  --
  -- Possible Error to check for: You have tried to define QuickPay for an
  -- assignment that has no payroll period defined at Date Paid.
  --
  --
  -- Check ENABLE_QP_OFFSET legislation_rule. If leg rule does not exist
  -- or rule_mode = 'N', use eff date to derive period, else use
  -- regular payment date
  --
  open get_leg_rule;
  fetch get_leg_rule into v_rule_mode;
  if (get_leg_rule%notfound or v_rule_mode = 'N' or p_legislation_code <> 'GB') then
    chk_period_exists
      (p_date           => p_effective_date
      ,p_payroll_id     => v_payroll_id
      ,p_message        => 'HR_7247_QPAY_NO_PERIOD_D_PAID'
      ,p_time_period_id => v_eff_time_period_id
      ,p_period_name    => v_eff_time_period_name
      );
  else
    chk_period_exists_eff_for_gb
      (p_date           => p_effective_date
      ,p_payroll_id     => v_payroll_id
      ,p_message        => 'HR_7247_QPAY_NO_PERIOD_D_PAID'
      ,p_time_period_id => v_eff_time_period_id
      ,p_period_name    => v_eff_time_period_name
    );
    --
    chk_eff_date_for_gb
      (p_effective_date => p_effective_date
      ,p_time_period_id => v_eff_time_period_id
      );
    --
  end if;
  hr_utility.set_location(v_proc, 8);
  close get_leg_rule;
  --
  -- If required re-calculate new default value for date_earned
  --
  if p_recal_date_earned then
    if p_legislation_code = 'GB' then
      --
      -- Re-calculate for GB legislation
      --
      v_new_date_earned := get_date_earned_for_gb
                             (p_assignment_id  => p_assignment_id
                             ,p_effective_date => p_effective_date
                             );
    else
      --
      -- Re-calculate for non-GB legislations
      --
      v_new_date_earned := p_effective_date;
    end if;
  else
    --
    -- The default should not be re-calculate
    --
    v_new_date_earned := null;
  end if;
  --
  p_payroll_id      := v_payroll_id;
  p_time_period_id  := v_eff_time_period_id;
  p_period_name     := v_eff_time_period_name;
  p_new_date_earned := v_new_date_earned;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
end chk_eff_date;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_date_earned_for_gb >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure contains additional GB specific validation for the
--   QuickPay Run date_earned attribute. It should not called directly.
--   It is a supporting procedure for chk_date_earned only.
--
-- Pre Conditions:
--   p_effective_date has already been validated.
--
-- In Arguments:
--   p_date_earned set user's value for date earned.
--   p_assignment_id the current assignment.
--
-- Post Success:
--   Ends normally if p_date_earned matches the value which must be used.
--
-- Post Failure:
--   An application error message is raised if p_date_earned does not
--   equal the default date_earned value.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure chk_date_earned_for_gb
  (p_date_earned     in pay_payroll_actions.date_earned%TYPE
  ,p_assignment_id   in pay_assignment_actions.assignment_id%TYPE
  ,p_effective_date  in pay_payroll_actions.effective_date%TYPE
  ) is
  --
  v_df_date_earned  pay_payroll_actions.date_earned%TYPE;
  v_proc            varchar2(72) := g_package||'chk_date_earned_for_gb';
  --
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Find out the default value for date earned
  --
  v_df_date_earned := get_date_earned_for_gb
                        (p_assignment_id  => p_assignment_id
                        ,p_effective_date => p_effective_date
                        );
  --
  -- If the value provided by the user is different to the default
  -- then raise an error.
  --
  if v_df_date_earned <> p_date_earned then
    -- Error: You must use the default value for the QuickPay Run Date Earned,
    -- when using GB legislation.
    hr_utility.set_message(801, 'HR_7288_QPAY_ERN_FOR_GB');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
end chk_date_earned_for_gb;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_date_earned >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure chk_date_earned
  (p_date_earned       in pay_payroll_actions.date_earned%TYPE
  ,p_assignment_id     in pay_assignment_actions.assignment_id%TYPE
  ,p_legislation_code  in per_business_groups.legislation_code%TYPE
  ,p_effective_date    in pay_payroll_actions.effective_date%TYPE
  ,p_payroll_id        in out nocopy pay_payroll_actions.payroll_id%TYPE
  ,p_time_period_id    in out nocopy pay_payroll_actions.time_period_id%TYPE
  ,p_period_name       in out nocopy per_time_periods.period_name%TYPE
  ) is
  --
  v_payroll_id            pay_payroll_actions.payroll_id%TYPE;
  v_time_period_id        per_time_periods.time_period_id%TYPE;
  v_time_period_name      per_time_periods.period_name%TYPE;
  v_proc                  varchar2(72) := g_package||'chk_date_earned';
  v_argument              varchar2(30);
  v_rule_mode             pay_legislation_rules.rule_mode%type;
  --
  cursor sel_pay is
    select asg.payroll_id
      from per_assignments_f asg
     where /* Payroll as of date_earned */
           asg.assignment_id      = p_assignment_id
       and asg.payroll_id    is not null
       and p_date_earned    between asg.effective_start_date
                                and asg.effective_end_date;
--
  cursor get_leg_rule is
    select rule_mode
      from pay_legislation_rules
     where rule_type = 'ENABLE_QP_OFFSET'
       and legislation_code = p_legislation_code;
--
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => v_proc
    ,p_argument       => 'date_earned'
    ,p_argument_value => p_date_earned
    );
  hr_api.mandatory_arg_error
    (p_api_name       => v_proc
    ,p_argument       => 'assignment_id'
    ,p_argument_value => p_assignment_id
    );
  hr_api.mandatory_arg_error
    (p_api_name       => v_proc
    ,p_argument       => 'legislation_code'
    ,p_argument_value => p_legislation_code
    );
  if p_legislation_code = 'GB' then
    hr_api.mandatory_arg_error
      (p_api_name       => v_proc
      ,p_argument       => 'effective_date'
      ,p_argument_value => p_effective_date
      );
  end if;
  --
  -- Ensure the assignment is on a payroll as of the date_earned.
  --
  open sel_pay;
  fetch sel_pay into v_payroll_id;
  if sel_pay%notfound then
    close sel_pay;
    -- Error: You have tried to define QuickPay for an assignment that has no
    -- payroll component defined at Date Earned.
    hr_utility.set_message(801, 'HR_7249_QPAY_ASG_PAY_D_EARNED');
    hr_utility.raise_error;
  end if;
  close sel_pay;
  hr_utility.set_location(v_proc, 6);
  --
  -- A time period must exist for the payroll
  -- as of date earned.
  --
  -- Possible error to check for: You have tried to define QuickPay for an
  -- assignment that has no payroll period defined at Date Earned.
  chk_period_exists
    (p_date           => p_date_earned
    ,p_payroll_id     => v_payroll_id
    ,p_message        => 'HR_7250_QPAY_NO_PERIOD_D_EARN'
    ,p_time_period_id => v_time_period_id
    ,p_period_name    => v_time_period_name
    );
  hr_utility.set_location(v_proc, 7);
  --
  -- For GB, carry out legislation specific checks.
  --
  if p_legislation_code = 'GB' then
    chk_date_earned_for_gb
      (p_date_earned    => p_date_earned
      ,p_assignment_id  => p_assignment_id
      ,p_effective_date => p_effective_date
      );
  end if;
  --
  p_payroll_id := v_payroll_id;
  open get_leg_rule;
  fetch get_leg_rule into v_rule_mode;
  if (v_rule_mode = 'Y') then
      p_time_period_id := v_time_period_id;
      p_period_name := v_time_period_name;
  end if;
  close get_leg_rule;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
end chk_date_earned;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_eff_earned_payroll >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Validates the assignment is on the same payroll as of the effective_date
--   and date_earned.
--
-- Pre Conditions:
--   The assignment (p_assignment_id) is known to exist on a payroll as of
--   p_effective_date and on a payroll as of p_date_earned.
--
-- In Arguments:
--   p_date_earned is the QuickPay date earned.
--   p_effective_date is the QuickPay date paid.
--   p_assignment_id is the assignment to check.
--   p_raise_error indicates if the an application error message should be
--   raised if the assignment is on different payrolls as of the two dates.
--
-- Post Success:
--   p_same_payroll is set to true if the assignment is on the same payroll
--   as of date earned and date paid. Otherwise it is set to false.
--
-- Post Failure:
--   If p_same_payroll will be set to false and p_raise_error is true an
--   application error is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure chk_eff_earned_payroll
  (p_effective_date in  pay_payroll_actions.effective_date%TYPE
  ,p_date_earned    in  pay_payroll_actions.date_earned%TYPE
  ,p_assignment_id  in  pay_assignment_actions.assignment_id%TYPE
  ,p_raise_error    in  boolean
  ,p_same_payroll   out nocopy boolean
  ) is
  --
  v_exists  varchar2(1);
  v_proc    varchar2(72) := g_package||'chk_eff_earned_payroll';
  --
  cursor sel_same is
    select 'Y'
      from per_assignments_f asg1
         , per_assignments_f asg2
     where /* Payroll as of date_earned */
           asg1.assignment_id       = p_assignment_id
       and p_date_earned      between asg1.effective_start_date
                                  and asg1.effective_end_date
       and asg1.payroll_id     is not null
           /* Payroll as of the effective date */
       and asg2.assignment_id       = p_assignment_id
       and p_effective_date   between asg2.effective_start_date
                                  and asg2.effective_end_date
       and asg2.payroll_id     is not null
           /* Payrolls are the same */
       and asg1.payroll_id          = asg2.payroll_id;
--
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Ensure the assignment is the same payroll
  -- as of the effective_date and date_earned.
  --
  open sel_same;
  fetch sel_same into v_exists;
  if sel_same%notfound then
    close sel_same;
    p_same_payroll := false;
    if p_raise_error then
      -- Error: You have tried to define QuickPay for an assignment that has
      -- different payroll components for Date Earned and Date Paid.  The
      -- assignment must be to the same payroll for both dates.
      hr_utility.set_message(801, 'HR_7251_QPAY_DIFF_PAYROLLS');
      hr_utility.raise_error;
    end if;
  else
    close sel_same;
    p_same_payroll := true;
  end if;
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
end chk_eff_earned_payroll;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_action_status >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used check the action_status has only been updated
--   from 'C' (for Complete) to 'M' (for Mark for Retry). This is the only
--   update which the user is allowed to do. All other action_status updates
--   are only allowed from the Pre-payment process code.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_payroll_action_id is the id of the QuickPay Run being updated.
--   p_old_action_status is set to the existing action_status in the database.
--   p_new_action_status is set to the user's proposed new action_status value.
--
-- Post Success:
--   Processing continues if the update is 'C' to 'M' and there are no other
--   action interlocks preventing the update. Any run result details will be
--   deleted.
--
-- Post Failure:
--   An application error is raised if the user is trying to do any other
--   update (i.e. not 'C' to 'M'). Also an error is raised if there are any
--   action interlocks preventing the update.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure chk_action_status
  (p_payroll_action_id in number
  ,p_old_action_status in varchar2
  ,p_new_action_status in varchar2
  ) is
--
  v_proc  varchar2(72) := g_package||'chk_action_status';
--
begin
  hr_utility.set_location('Entering:'||v_proc, 5);
  --
  -- Check the updated status is from 'C'omplete to 'M'ark for Retry
  --
  if (p_old_action_status not in ('C', 'S')) and (p_new_action_status <> 'M') then
    -- Error: You have tried to enter an invalid status for a completed
    -- QuickPay run. You can only update a completed assignment process
    -- status to Marked for Retry.
    hr_utility.set_message(801, 'HR_7252_QPAY_ONLY_MARK_RETRY');
    hr_utility.raise_error;
  end if;
  hr_utility.set_location(v_proc, 6);
  --
  -- Check that this QuickPay Run can have
  -- a status of Mark for Retry
  --
  py_rollback_pkg.rollback_payroll_action(
                  p_payroll_action_id    => p_payroll_action_id,
                  p_rollback_mode        => 'RETRY',
                  p_leave_base_table_row => TRUE);
  --
  hr_utility.set_location(' Leaving:'||v_proc, 10);
end chk_action_status;
--
-- KKAWOl : Ok, commenting chk_legislative_parameters out as this is no
-- longer required. We pass run type id to the run instead.
-- Will need a chk_run_type procedure.
/*
-- ----------------------------------------------------------------------------
-- |----------------------< chk_legislative_parameters >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure validates the legislative_parameters attribute has been
--   set correctly.
--
-- Pre Conditions:
--   The p_business_group_id has already been validated as a business group
--   which exists in the database.
--
-- In Arguments:
--   p_legislation_code the current business group's legislation.
--   p_action_status is set to the current Assignment Process action status.
--   During insert p_action_status should be set to 'U', the code for
--   Unprocessed.
--   p_legislative_parameters is set to the legislative_parameters for the
--   QuickPay Run.
--
-- Post Success:
--   Processing will continue if the business group is for a US legislation
--   and p_legislative_parameters has been set to 'R' (for Regular) or 'S'
--   (for Supplemental) and p_action_status is not 'C' for Complete. Or the
--   business group is for a non-US legislation and legislation_parameters
--   is null.
--
-- Post Failure:
--   An error will be raised if any of the following conditions are found:
--     1) The business group is for a US legislation and
--        p_legislative_parameters is not set to 'R' or 'S'.
--     2) The business group is for a US legislation and p_action_status
--        is set to 'C'. (This is because legislation_parameters cannot be
--        updated if the status is Complete.)
--     3) The business group is for any non-US legislation and
--        p_legislative_parameters is not null.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure chk_legislative_parameters
  (p_legislative_parameters pay_payroll_actions.legislative_parameters%TYPE
  ,p_action_status          varchar2
  ,p_legislation_code       per_business_groups.legislation_code%TYPE
  ) Is
  --
  v_proc             varchar2(72) := g_package||'chk_legislative_parameters';
  --
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  if p_legislation_code = 'US' or
     p_legislation_code = 'CA' then
    --
    -- For a US legislation legislative_parameters cannot be updated
    -- when the action_status is Complete.
    --
    if p_action_status = 'C' then
      -- Error: You have tried to alter the Regular/Supplemental flag for a
      -- completed QuickPay run.  You can only change this flag before a run
      -- commences.
      hr_utility.set_message(801, 'HR_7253_QPAY_REG_SUPP_NO_UPD');
      hr_utility.raise_error;
    end if;
    --
    -- When the legislation is US then legislative_parameters
    -- must be set to 'R' or 'S'.
    --
    if p_legislation_code = 'US' then
      if ((p_legislative_parameters is null) or
         (p_legislative_parameters <> 'R') and
         (p_legislative_parameters <> 'S')) then
        -- Error: For US Business Groups the payroll process
        -- legislative_parameters must be set to 'R' (for Regular) or 'S'
        -- (for Supplemental).
        hr_utility.set_message(801, 'HR_7254_QPAY_LEG_PAR_R_OR_S');
        hr_utility.raise_error;
      end if;

    elsif p_legislation_code = 'CA' then

      if ((p_legislative_parameters is null) or
          (p_legislative_parameters <> 'R') and
          (p_legislative_parameters <> 'N') and
          (p_legislative_parameters <> 'L')) then

        -- Error: For Canadian Business Groups the payroll process
        -- legislative_parameters must be set to 'R' (for Regular) or
        -- 'N' (for Non Periodic) or 'L' (for Lump Sum).

        hr_utility.set_message(801,'HR_7254_QPAY_LEG_PAR_R_OR_S');
        hr_utility.raise_error;
      end if;

    end if;
  else
    --
    -- When the legislation is not US,CA legislative_parameters
    -- must be null.
    --
    if p_legislative_parameters is not null then
      -- Error: For this legislation, you must set the payroll process
      -- legislative_parameters attribute to null.
      hr_utility.set_message(801, 'HR_7255_QPAY_LEG_PAR_NULL');
      hr_utility.raise_error;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
End chk_legislative_parameters;
--
*/
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_run_type  >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used in update and delete validation to check the
--   run type value.
--   a) If row exists on pay_legislative_field_info with
--            field_name = 'TAX_PROCESSING_TYPE'
--            target_location = 'PAYWSRQP'
--            rule_type = 'RUN_TYPE_FLAG'
--            rule_mode = 'Y'
--            validation_name = 'DISPLAY'
--            validation_type = 'ITEM_PROPERTY'
--      then tax_processing_type can be not null.
--   b) Foreign key to pay_run_types_f.
--
Procedure chk_run_type
  ( p_run_type_id       in pay_run_types_f.run_type_id%type
   ,p_effective_date    in pay_payroll_actions.effective_date%TYPE
   ,p_business_group_id in pay_payroll_actions.business_group_id%TYPE
   ,p_legislation_code  in per_business_groups.legislation_code%TYPE
  )
  --
IS
  v_proc             varchar2(72) := g_package||'chk_run_type';
  l_rule_mode        pay_legislative_field_info.rule_mode%type;
  l_rt_exists        pay_run_types_f.run_type_id%type;
  --
  cursor get_leg_rule is
  select lfi.rule_mode
    from pay_legislative_field_info lfi
   where lfi.field_name = 'TAX_PROCESSING_TYPE'
     and lfi.target_location = 'PAYWSRQP'
     and lfi.rule_type = 'RUN_TYPE_FLAG'
     and lfi.validation_type = 'ITEM_PROPERTY'
     and lfi.validation_name = 'DISPLAY'  ;
  --
  cursor get_rt_exists is
  select rt.run_type_id
    from pay_run_types_f rt
   where rt.run_type_id = p_run_type_id
     and (rt.legislation_code = p_legislation_code
          or (rt.legislation_code is null
              and rt.business_group_id = p_business_group_id)
          or (rt.legislation_code is null and rt.business_group_id is null))
   and not exists
         ( select null
              from pay_legislative_field_info lfi
             where lfi.validation_type = 'EXCLUDE'
               and lfi.rule_type = 'DATA_VALIDATION'
               and lfi.field_name = 'TAX_PROCESSING_TYPE'
               and lfi.target_location = 'PAYWSRQP'
               and lfi.legislation_code = p_legislation_code
               and upper(lfi.validation_name) = upper(rt.run_type_name))
   and p_effective_date between rt.effective_start_date
                     and rt.effective_end_date;
  --
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Cannot have a run type id as not null if the row on
  -- pay_legislative_field_info does not exist.
  --
  if p_run_type_id is not null then
    open get_leg_rule;
    fetch get_leg_rule into l_rule_mode;
    if ((get_leg_rule%notfound) OR
        (get_leg_rule%found and l_rule_mode <> 'Y')) then
       close get_leg_rule;
       hr_utility.set_message(801, 'PAY_52380_INVALID_RUN_TYPE');
       hr_utility.raise_error;
    end if;
    --
    close get_leg_rule;
    --
    -- Now check the run type is valid, i.e. exists on pay_run_types_f
    -- and is either global or belongs to bix grp or leg code.
    --
    open get_rt_exists;
    fetch get_rt_exists into l_rt_exists;
    if (get_rt_exists%notfound) then
       close get_rt_exists;
       hr_utility.set_message(801, 'PAY_52380_INVALID_RUN_TYPE');
       hr_utility.raise_error;
    end if;
    --
    close get_rt_exists;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
End chk_run_type;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< chk_cur_task >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used in update and delete validation to check the
--   payroll_action current_task value. The user should not be allowed to
--   update any QuickPay Run attribute or delete a QuickPay Run when the
--   current_task is not null. (A not null value means a C process is
--   still processing the action.)
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_current_task set to the pay_payroll_actions.current_task of the
--   current payroll_action.
--
-- Post Success:
--   The current_task for this QuickPay Run is null. (Update or delete can
--   be allowed to continue, subject to other validation.)
--
-- Post Failure:
--   An application error is raised if the current_task value is not null.
--
-- {End Of Comments}
--
procedure chk_cur_task
  (p_current_task in pay_payroll_actions.current_task%TYPE
  ) is
  --
  v_proc  varchar2(72) := g_package||'chk_cur_task';
  --
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  if p_current_task is not null then
    -- Error: You have tried to update a field or to delete the QuickPay run
    -- while the run is processing.
    hr_utility.set_message(801, 'HR_7241_QPAY_Q_PROCESSING');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
end chk_cur_task;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_for_con_request >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure chk_for_con_request
  (p_payroll_action_id in pay_payroll_actions.payroll_action_id%TYPE
  ) is
  --
  v_request_id  pay_payroll_actions.request_id%TYPE;
  v_bl          boolean;
  v_phase       varchar2(255);
  v_status      varchar2(255);
  v_dev_phase   varchar2(255);
  v_dev_status  varchar2(255);
  v_message     varchar2(255);
  v_proc        varchar2(72) := g_package||'chk_for_con_request';
  --
  cursor sel_reqt is
    select request_id
      from pay_payroll_actions
     where payroll_action_id = p_payroll_action_id;
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Try to obtain the AOL request_id for this payroll process.
  --
  open sel_reqt;
  fetch sel_reqt into v_request_id;
  if sel_reqt%notfound then
    close sel_reqt;
    -- A row could not be found in pay_payroll_actions
    -- with an id of p_payroll_action_id.
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  close sel_reqt;
  hr_utility.set_location(v_proc, 7);
  --
  -- Only need to find out the concurrent request status
  -- if the request_id is set and is non-zero.
  --
  if (v_request_id is not null) and (v_request_id <> 0) then
    hr_utility.set_location(v_proc, 8);
    --
    v_bl := fnd_concurrent.get_request_status
              (request_id => v_request_id
              ,phase      => v_phase
              ,status     => v_status
              ,dev_phase  => v_dev_phase
              ,dev_status => v_dev_status
              ,message    => v_message
              );
    hr_utility.set_location(v_proc, 9);
    --
    -- The process is still waiting or running if the
    -- concurrent phase value is not Completed.
    --
    if v_dev_phase <> 'COMPLETE' then
      -- Error: You cannot update or delete a QuickPay definition when a
      -- request is still running or waiting to run on the AOL concurrent
      -- manager. You may need to contact your system administrator to resolve
      -- this problem. Please quote AOL concurrent request_id *REQUEST_ID.
      hr_utility.set_message(801, 'HR_7264_QPAY_CON_REQ_STILL_RUN');
      hr_utility.set_message_token('REQUEST_ID', to_char(v_request_id));
      hr_utility.raise_error;
    end if;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 15);
end chk_for_con_request;
--
-- ----------------------------------------------------------------------------
-- |------------------------< get_legislation_code >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Returns the legislation_code for a specified business group.
--
-- Pre Conditions:
--   p_business_group_id is known to be a business group in the HR schema.
--
-- In Arguments:
--   p_business_group_id is mandatory.
--
-- Post Success:
--   Returns the legislation code for p_business_group_id.
--
-- Post Failure:
--   Raises an error if the legislation code for p_business_group_id cannot
--   be found.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function get_legislation_code
  (p_business_group_id  in pay_payroll_actions.business_group_id%TYPE
  ) return varchar2 is
--
  cursor cur_leg is
    select legislation_code
      from per_business_groups_perf
     where business_group_id  = p_business_group_id;
  --
  v_legislation_code  per_business_groups.legislation_code%TYPE;
  v_proc              varchar2(72) := g_package||'get_legislation_code';
--
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Find out the legislation code for the current business group
  --
  open cur_leg;
  fetch cur_leg into v_legislation_code;
  if cur_leg%notfound then
    close cur_leg;
    -- The legislation code could not be found for current business group.
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', v_proc);
    hr_utility.set_message_token('STEP', '6');
    hr_utility.raise_error;
  end if;
  close cur_leg;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  return v_legislation_code;
end get_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
--
function return_api_dml_status Return Boolean Is
--
  v_proc  varchar2(72) := g_package||'return_api_dml_status';
--
begin
  hr_utility.set_location('Entering:'||v_proc, 5);
  --
  Return (nvl(g_api_dml, false));
  --
  hr_utility.set_location(' Leaving:'||v_proc, 10);
end return_api_dml_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is called when a constraint has been violated (i.e.
--   The exception hr_api.check_integrity_violated,
--   hr_api.parent_integrity_violated or hr_api.child_integrity_violated has
--   been raised).
--   The exceptions can only be raised as follows:
--   1) A check constraint can only be violated during an INSERT or UPDATE
--      dml operation.
--   2) A parent integrity constraint can only be violated during an
--      INSERT or UPDATE dml operation.
--   3) A child integrity constraint can only be violated during an
--      DELETE dml operation.
--
-- Pre Conditions:
--   Either hr_api.check_integrity_violated, hr_api.parent_integrity_violated
--   or hr_api.child_integrity_violated has been raised with the subsequent
--   stripping of the constraint name from the generated error message text.
--
-- In Arguments:
--   p_constraint_name is in upper format and is just the constraint name
--   (e.g. not prefixed by brackets, schema owner etc).
--
-- Post Success:
--   Development dependant.
--
-- Post Failure:
--   Development dependant.
--
-- Developer Implementation Notes:
--   For each constraint being checked the hr system package failure message
--   has been generated as a template only. These system error messages should
--   be modified as required (i.e. change the system failure message to a user
--   friendly defined error message).
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  v_proc  varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||v_proc, 5);
  --
  If (p_constraint_name = 'PAY_PAYRACT_ACTION_POPULAT_CHK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', v_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  elsif (p_constraint_name = 'PAY_PAYRACT_ACTION_STATUS_CHK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', v_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  elsif (p_constraint_name = 'PAY_PAYRACT_ACTION_TYPE_CHK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', v_proc);
    hr_utility.set_message_token('STEP','15');
  elsif (p_constraint_name = 'PAY_PAYRACT_CURRENT_TASK_CHK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', v_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
  elsif (p_constraint_name = 'PAY_PAYROLL_ACTIONS_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', v_proc);
    hr_utility.set_message_token('STEP','25');
    hr_utility.raise_error;
  elsif (p_constraint_name = 'PAY_PAYROLL_ACTIONS_FK2') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', v_proc);
    hr_utility.set_message_token('STEP','30');
    hr_utility.raise_error;
  elsif (p_constraint_name = 'PAY_PAYROLL_ACTIONS_FK5') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', v_proc);
    hr_utility.set_message_token('STEP','35');
    hr_utility.raise_error;
  elsif (p_constraint_name = 'PAY_PAYROLL_ACTIONS_FK6') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', v_proc);
    hr_utility.set_message_token('STEP','40');
    hr_utility.raise_error;
  elsif (p_constraint_name = 'PAY_PAYROLL_ACTIONS_FK7') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', v_proc);
    hr_utility.set_message_token('STEP','45');
    hr_utility.raise_error;
  elsif (p_constraint_name = 'PAY_PAYROLL_ACTIONS_FK8') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', v_proc);
    hr_utility.set_message_token('STEP','50');
    hr_utility.raise_error;
  else
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', v_proc);
    hr_utility.set_message_token('STEP','55');
    hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(' Leaving:'||v_proc, 10);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_mandatory_args >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure checks all known mandatory arguments to ensure that they
--   are not null. This check does not include system generated attributes
--   such as primary keys or object version number because usually, these
--   arguments are system maintained.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--
-- Post Success:
--   Processing continues if p_rec.business_group_id and p_rec.effective_date
--   are not null.
--
-- Post Failure:
--   If p_rec.business_group_id or p_rec.effective_date are null then an
--   application error will be raised and processing is terminated.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure check_mandatory_args(p_rec in g_rec_type) Is
--
  v_proc      varchar2(72) := g_package||'check_mandatory_args';
  v_argument  varchar2(30);
--
Begin
  hr_utility.set_location('Entering:'||v_proc, 5);
  --
  -- This procedure does not check action_type, action_population_status,
  -- action_status because they are all set at by the pre-insert procedure.
  -- Consolidation_set_id is has been added to this procedure because it is
  -- mandatory for QuickPay Runs.
  --
  hr_api.mandatory_arg_error
    (p_api_name       => v_proc
    ,p_argument       => 'business_group_id'
    ,p_argument_value => p_rec.business_group_id
    );
  hr_api.mandatory_arg_error
    (p_api_name       => v_proc
    ,p_argument       => 'effective_date'
    ,p_argument_value => p_rec.effective_date
    );
  hr_api.mandatory_arg_error
    (p_api_name       => v_proc
    ,p_argument       => 'consolidation_set_id'
    ,p_argument_value => p_rec.consolidation_set_id
    );
  --
  hr_utility.set_location(' Leaving:'||v_proc, 10);
End check_mandatory_args;
--
-- ----------------------------------------------------------------------------
-- |----------------------< check_non_updateable_args >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updateable attributes have
--   not been updated. If an attribute has been updated an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--   record set to.
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updatable attributes
--   have been altered.
--
-- {End Of Comments}
--
Procedure check_non_updateable_args(p_rec in g_rec_type) is
--
  v_proc      varchar2(72) := g_package||'check_non_updateable_args';
  v_argument  varchar2(30);
--
Begin
  hr_utility.set_location('Entering:'||v_proc, 5);
  if nvl(p_rec.business_group_id, hr_api.g_number) <>
     nvl(g_old_rec.business_group_id, hr_api.g_number) then
    v_argument := 'business_group_id';
    raise hr_api.argument_changed;
  end if;
  hr_utility.set_location(v_proc, 6);
  --
  if nvl(p_rec.effective_date, hr_api.g_date) <>
     nvl(g_old_rec.effective_date, hr_api.g_date) then
    v_argument := 'effective_date';
    raise hr_api.argument_changed;
  end if;
  hr_utility.set_location(v_proc, 7);
  --
  if nvl(p_rec.current_task, hr_api.g_varchar2) <>
     nvl(g_old_rec.current_task, hr_api.g_varchar2) then
    v_argument := 'current_task';
    raise hr_api.argument_changed;
  end if;
  hr_utility.set_location(v_proc, 8);
  --
  if nvl(p_rec.date_earned, hr_api.g_date) <>
     nvl(g_old_rec.date_earned, hr_api.g_date) then
    v_argument := 'date_earned';
    raise hr_api.argument_changed;
  end if;
  --
  hr_utility.set_location(' Leaving:'||v_proc, 10);
Exception
  When hr_api.argument_changed Then
    --
    -- A non updatetable attribute has been changed therefore we
    -- must report this error
    --
    hr_api.argument_changed_error
      (p_api_name => v_proc
      ,p_argument => v_argument
      );
--
End check_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the insert dml. Presently, if the entity has a corresponding primary
--   key which is maintained by an associating sequence, the primary key for
--   the entity will be populated with the next sequence value in
--   preparation for the insert dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the ins procedure.
--
-- In Arguments:
--   A Pl/Sql record structure.
--
-- Post Success:
--   p_rec.payroll_action_id is set with the primary key value.
--   p_rec.action_status is set to 'U', the code for Unprocessed.
--   p_action_type is set to 'Q', the code for QuickPay Run.
--   p_action_population_status is to 'U', the code for unpopulated.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure pre_insert
  (p_rec                      in out nocopy g_rec_type
  ,p_action_type                 out nocopy pay_payroll_actions.action_type%TYPE
  ,p_action_population_status    out nocopy
     pay_payroll_actions.action_population_status%TYPE
  ) is
--
  v_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select pay_payroll_actions_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Set the following attributes to there insert values.
  -- (payroll_id and time_period_id are during the insert_validate logic.)
  --
  --
  -- Set the initial action_status to unprocessed
  --
  p_rec.action_status := 'U';
  --
  -- Set pay_payroll_action columns which are only
  -- set by non-process code at insert time.
  --
  -- Set action_type to QuickPay Run
  --
  p_action_type := 'Q';
  --
  -- Set action_population_status to unpopulated
  --
  p_action_population_status := 'U';
  --
  -- Select the next sequence number
  --
  open C_Sel1;
  fetch C_Sel1 into p_rec.payroll_action_id;
  close C_Sel1;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the update dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Arguments:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Access Status:
--   Internal Development Use Only.
--
Procedure pre_update(p_rec in g_rec_type) is
--
  v_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the delete dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the del procedure.
--
-- In Arguments:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure pre_delete(p_rec in g_rec_type) is
--
  v_proc  varchar2(72) := g_package||'pre_delete';
--
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
End pre_delete;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains the processing which is required after the
--   insert dml. It inserts an Assignment Process row for a QuickPay Payroll
--   Process and all the default QuickPay inclusions.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the ins procedure.
--   All business rule validation has been done of p_assignment_id.
--
-- In Arguments:
--   p_rec contains the details of the insert QuickPay Payroll Process.
--   p_assignment_id is the assignment the Assignment Process is to be created
--   for.
--   p_validate should be set to the same value as the ins procedure for
--   the QuickPay Run ins procedure.
--
-- Post Success:
--   p_assignment_action_id is set to the primary key id of the created
--   Assignment Process.
--   p_a_object_version_number is set to the object version number for the
--   Assignment Process.
--   The default QuickPay inclusions have been created.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure post_insert
  (p_rec                     in     g_rec_type
  ,p_assignment_id           in     number     default null
  ,p_validate                in     boolean    default false
  ,p_assignment_action_id       out nocopy number
  ,p_a_object_version_number    out nocopy number
  ) is
--
  v_assignment_action_id  pay_assignment_actions.assignment_action_id%TYPE;
  v_object_version_number pay_assignment_actions.object_version_number%TYPE;
  v_proc                  varchar2(72) := g_package||'post_insert';
--
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- For a QuickPay insert the assignment action
  -- and quickpay inclusion rows. (The payroll action and
  -- assignment action must be inserted in the same commit unit.
  -- Either would be invalid without the other.)
  --
  -- Insert assignment action
  --
  hrassact.qpassact
    (p_payroll_action_id     => p_rec.payroll_action_id
    ,p_assignment_id         => p_assignment_id
    ,p_assignment_action_id  => v_assignment_action_id
    ,p_object_version_number => v_object_version_number
    );
  hr_utility.set_location(v_proc, 6);
  --
  -- Insert default quickpay inclusions
  --
  -- Enhancement 3368211
  -- Check that we are not using the new QuickPay Exclusions model before
  -- doing the bulk insert of QuickPay Inclusions
  --
  if use_qpay_excl_model = 'N' then
    pay_qpi_api.bulk_default_ins
      (p_assignment_action_id => v_assignment_action_id
      ,p_validate             => p_validate
      );
  end if;
  --
  hr_utility.set_location(v_proc, 7);
  --
  p_assignment_action_id    := v_assignment_action_id;
  p_a_object_version_number := v_object_version_number;
  --
  hr_utility.set_location('Leaving:'|| v_proc, 10);
end post_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   update dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Arguments:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure post_update(p_rec in g_rec_type) is
--
  v_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
End post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   delete dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the del procedure.
--
-- In Arguments:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure post_delete(p_rec in g_rec_type) is
--
  v_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic. The functions of this
--   procedure are as follows:
--   1. Initialise the object_version_number to 1.
--   2. To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3. To insert the row into the schema.
--   4. To trap any constraint violations that may have occurred.
--   5. To raise any other errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory arguments set (except the
--   object_version_number which is initialised within this procedure).
--
-- In Arguments:
--   p_rec contains all the details of the QuickPay Run, Payroll Process.
--
-- Post Success:
--   The QuickPay Run, Payroll Process row will be inserted into the schema.
--
-- Post Failure:
--   On the insert dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
Procedure insert_dml
  (p_rec                       in out nocopy g_rec_type
  ,p_action_type               in     pay_payroll_actions.action_type%TYPE
  ,p_payroll_id                in     pay_payroll_actions.payroll_id%TYPE
  ,p_time_period_id            in     pay_payroll_actions.time_period_id%TYPE
  ,p_action_population_status  in
     pay_payroll_actions.action_population_status%TYPE
  ) is
--
  v_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: pay_payroll_actions
  --
  insert into pay_payroll_actions
    (payroll_action_id
    ,action_type
    ,business_group_id
    ,consolidation_set_id
    ,payroll_id
    ,action_population_status
    ,action_status
    ,effective_date
    ,comments
    ,current_task
    ,legislative_parameters
    ,run_type_id
    ,date_earned
    ,pay_advice_date
    ,pay_advice_message
    ,object_version_number
    ,time_period_id
    )
    values
    (p_rec.payroll_action_id
    ,p_action_type
    ,p_rec.business_group_id
    ,p_rec.consolidation_set_id
    ,p_payroll_id
    ,p_action_population_status
    ,p_rec.action_status
    ,p_rec.effective_date
    ,p_rec.comments
    ,null
    ,p_rec.legislative_parameters
    ,p_rec.run_type_id
    ,p_rec.date_earned
    ,p_rec.pay_advice_date
    ,p_rec.pay_advice_message
    ,p_rec.object_version_number
    ,p_time_period_id
    );
  --
  g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||v_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    --
    -- A check constraint has been violated
    --
    -- Unset the api dml status
    g_api_dml := false;
    constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated then
    --
    -- Parent integrity has been violated
    --
    -- Unset the api dml status
    g_api_dml := false;
    constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    --
    -- Unique integrity has been violated
    --
    g_api_dml := false;   -- Unset the api dml status
    constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
    -- Unset the api dml status
    --
    g_api_dml := false;
    Raise;
End insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The functions of this
--   procedure are as follows:
--   1. Increment the object_version_number by 1.
--   2. To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3. To update the specified row in the schema using the primary key in
--      the predicates.
--   4. To trap any constraint violations that may have occurred.
--   5. To raise any other errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Arguments:
--   p_rec should contain all the value as they are going to be set on the
--   database. (Expect for object_version_number.)
--
-- Post Success:
--   The QuickPay Run will be updated in the schema.
--
-- Post Failure:
--   On the update dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure update_dml(p_rec in out nocopy g_rec_type) is
--
  v_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Increment the object version
  --
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  -- Set the api dml status
  --
  g_api_dml := true;
  --
  -- Update the pay_payroll_actions Row
  --
  update pay_payroll_actions set
     business_group_id        = p_rec.business_group_id
    ,consolidation_set_id     = p_rec.consolidation_set_id
    ,action_status            = p_rec.action_status
    ,effective_date           = p_rec.effective_date
    ,comments                 = p_rec.comments
    ,legislative_parameters   = p_rec.legislative_parameters
    ,run_type_id              = p_rec.run_type_id
    ,date_earned              = p_rec.date_earned
    ,pay_advice_date          = p_rec.pay_advice_date
    ,pay_advice_message       = p_rec.pay_advice_message
    ,object_version_number    = p_rec.object_version_number
  where payroll_action_id = p_rec.payroll_action_id;
  --
  -- Unset the api dml status
  --
  g_api_dml := false;
  --
  hr_utility.set_location(' Leaving:'||v_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    --
    -- A check constraint has been violated
    --
    -- Unset the api dml status
    g_api_dml := false;
    constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated then
    --
    -- Parent integrity has been violated
    --
    -- Unset the api dml status
    g_api_dml := false;
    constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    --
    -- Unique integrity has been violated
    --
    g_api_dml := false;   -- Unset the api dml status
    constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
    -- Unset the api dml status
    --
    g_api_dml := false;
    Raise;
end update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of this
--   procedure are as follows:
--   1. To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2. To delete the specified row from the schema using the primary key in
--      the predicates.
--   3. To ensure that the row was deleted.
--   4. To trap any constraint violations that may have occurred.
--   5. To raise any other errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the del
--   procedure.
--
-- In Arguments:
--   p_rec has the primary key details set. i.e. p_rec.payroll_action_id is
--   not null.
--
-- Post Success:
--   The QuickPay Run row will be delete from the schema.
--
-- Post Failure:
--   On the delete dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a child integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
Procedure delete_dml(p_rec in g_rec_type) is
--
  v_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Set the api dml status
  --
  g_api_dml := true;
  --
  -- Delete the pay_payroll_actions row.
  --
  delete from pay_payroll_actions
  where payroll_action_id = p_rec.payroll_action_id;
  --
  -- Unset the api dml status
  --
  g_api_dml := false;
  --
  hr_utility.set_location(' Leaving:'||v_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    --
    -- Child integrity has been violated
    --
    -- Unset the api dml status
    g_api_dml := false;
    constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
    -- Unset the api dml status
    --
    g_api_dml := false;
    Raise;
End delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< lck_general >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This lock procedure can be called in two ways.
--     1) To lock a QuickPay Run or QuickPay Pre-payment.
--     2) To lock a Payroll Process of a specified type.
--   This procedure will attempt to lock the Payroll Process and the associated
--   Assignment Process. The row locking will only be successful if the
--   rows are not currently locked by another user, the specified object
--   version numbers match and there is no AOL request waiting or still
--   running on the concurrent manager for the Payroll Process. If the lock is
--   successfully taken, the Payroll Process row will be selected into the
--   g_old_rec data structure.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_payroll_action_id is set to the id of the Payroll Process to be locked.
--   p_p_object_version_number is set object version number of the Payroll
--   Process.
--   p_a_object_version_number is set object version number of the Assignment
--   Process.
--   p_only_action_type if the lck is to be taken out using method 2 then
--   this argument should be set to the action_type of the Payroll Process.
--   Otherwise p_only_action_type should be null.
--
-- Post Success:
--   On successful completion of the Lck process the rows to be updated or
--   deleted will be locked and the g_old_rec data structure will be set
--   with the Payroll Process details. p_a_action_status will be set to the
--   action_status of the Assignment Process.
--
-- Post Failure:
--   The Lck process can fail for six reasons:
--   1) When attempting to lock the row the row could already be locked by
--      another user. This will raise the HR_7165_OBJECT_LOCKED error.
--   2) A Payroll Process with id p_payroll_action_id doesn't exist in the HR
--      Schema. This error is trapped and reported using the message name
--      'HR_7155_OBJECT_INVALID'.
--   3) The rows although existing in the HR Schema have different object
--      version numbers than the object version numbers specified.
--      This error is trapped and reported using the message name
--      'HR_7155_OBJECT_INVALID'.
--   4) An error is raised if an AOL concurrent request is waiting to run or
--      still running on the concurrent manager for the Payroll Process.
--   5) If p_only_action_type is null the lock will fail if the Payroll
--      Process is not a QuickPay Run or QuickPay Pre-payment.
--   6) If p_only_action_type has been set the lock will fail if the Payroll
--      Process is not of that type.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure lck_general
  (p_payroll_action_id       in  pay_payroll_actions.payroll_action_id%TYPE
  ,p_p_object_version_number in  pay_payroll_actions.object_version_number%TYPE
  ,p_a_object_version_number in
                             pay_assignment_actions.object_version_number%TYPE
  ,p_only_action_type        in  pay_payroll_actions.action_type%TYPE
  ,p_actual_action_type      out nocopy pay_payroll_actions.action_type%TYPE
  ,p_a_action_status         out nocopy pay_assignment_actions.
                                                          action_status%TYPE
  ) is
  v_a_object_version_number  pay_assignment_actions.object_version_number%TYPE;
--
-- Cursor selects the 'current' row from the HR Schema
-- (Locks pay_payroll_actions first, then pay_assignment_actions.)
--
  Cursor C_Sel1 is
    select pya.payroll_action_id
         , pya.business_group_id
         , pya.consolidation_set_id
         , pya.action_status
         , pya.effective_date
         , pya.comments
         , pya.current_task
         , pya.legislative_parameters
         , pya.run_type_id
         , pya.date_earned
         , pya.pay_advice_date
         , pya.pay_advice_message
         , pya.object_version_number
         , pya.action_type
         , aga.action_status
         , aga.object_version_number
      from pay_payroll_actions    pya
         , pay_assignment_actions aga
     where /* Payroll action lock */
           pya.payroll_action_id  = p_payroll_action_id
       and (   pya.action_type          = p_only_action_type
            or (    p_only_action_type is null
                and pya.action_type    in ('Q', 'U','X')--Code added for archive
               )
           )
           /* Assignment action lock */
       and aga.payroll_action_id  = pya.payroll_action_id
       for update nowait;
--
  v_proc  varchar2(72) := g_package||'lck_general';
--
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Check the mandatory args have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => v_proc
    ,p_argument       => 'payroll_action_id'
    ,p_argument_value => p_payroll_action_id
    );
  hr_api.mandatory_arg_error
    (p_api_name       => v_proc
    ,p_argument       => 'p_object_version_number'
    ,p_argument_value => p_p_object_version_number
    );
  hr_api.mandatory_arg_error
    (p_api_name       => v_proc
    ,p_argument       => 'a_object_version_number'
    ,p_argument_value => p_a_object_version_number
    );
  hr_utility.set_location(v_proc, 6);
  --
  -- Additional logic specific to this entity:
  -- Do not allow the lock to be taken out if there is an AOL concurrent
  -- request waiting to run or still running on a concurrent manager.
  --
  chk_for_con_request
    (p_payroll_action_id => p_payroll_action_id);
  hr_utility.set_location(v_proc, 7);
  --
  -- If the primary key exists, we must now attempt to lock the
  -- row and check the object version numbers.
  --
  open  C_Sel1;
  Fetch C_Sel1 Into g_old_rec.payroll_action_id
                  , g_old_rec.business_group_id
                  , g_old_rec.consolidation_set_id
                  , g_old_rec.action_status
                  , g_old_rec.effective_date
                  , g_old_rec.comments
                  , g_old_rec.current_task
                  , g_old_rec.legislative_parameters
                  , g_old_rec.run_type_id
                  , g_old_rec.date_earned
                  , g_old_rec.pay_advice_date
                  , g_old_rec.pay_advice_message
                  , g_old_rec.object_version_number
                  , p_actual_action_type
                  , p_a_action_status
                  , v_a_object_version_number;
  --
  If C_Sel1%notfound then
    Close C_Sel1;
    --
    -- The primary key is invalid therefore we must error
    --
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
  If (p_p_object_version_number <> g_old_rec.object_version_number) or
     (p_a_object_version_number <> v_a_object_version_number)       Then
    hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
    hr_utility.raise_error;
  End If;
--
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
--
-- We need to trap the ORA LOCK exception
--
Exception
  When HR_api.Object_Locked then
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'pay_payroll_actions');
    hr_utility.raise_error;
End lck_general;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (p_payroll_action_id        in pay_payroll_actions.payroll_action_id%TYPE
  ,p_p_object_version_number  in pay_payroll_actions.object_version_number%TYPE
  ,p_a_object_version_number  in
                             pay_assignment_actions.object_version_number%TYPE
  ) is
  v_unwanted_type    pay_payroll_actions.action_type%TYPE;
  v_unwanted_status  pay_assignment_actions.action_status%TYPE;
begin
  --
  -- Lock the row only if it is a QuickPay Run action
  --
  lck_general
    (p_payroll_action_id       => p_payroll_action_id
    ,p_p_object_version_number => p_p_object_version_number
    ,p_a_object_version_number => p_a_object_version_number
    ,p_only_action_type        => 'Q'
    ,p_actual_action_type      => v_unwanted_type
    ,p_a_action_status         => v_unwanted_status
    );
end lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function is used to turn attribute arguments into the record
--   structure g_rec_type.
--
-- Pre Conditions:
--   This is a private function and can only be called from the ins or upd
--   attribute processes.
--
-- In Arguments:
--   The arguments should be set to the individual attributes of the QuickPay
--   Run Process.
--
-- Post Success:
--   The individual attributes are returned in a record structure.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this function will be a PL/SQL value error due to conversion
--   of datatypes or data lengths.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function convert_args
  (p_payroll_action_id         in number
  ,p_business_group_id         in number
  ,p_consolidation_set_id      in number
  ,p_action_status             in varchar2
  ,p_effective_date            in date
  ,p_comments                  in varchar2
  ,p_current_task              in varchar2
  ,p_legislative_parameters    in varchar2
  ,p_run_type_id               in number
  ,p_date_earned               in date
  ,p_pay_advice_date           in date
  ,p_pay_advice_message        in varchar2
  ,p_object_version_number     in number
  ) return g_rec_type is
--
  v_rec   g_rec_type;
  v_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  v_rec.payroll_action_id        := p_payroll_action_id;
  v_rec.business_group_id        := p_business_group_id;
  v_rec.consolidation_set_id     := p_consolidation_set_id;
  v_rec.action_status            := p_action_status;
  v_rec.effective_date           := p_effective_date;
  v_rec.comments                 := p_comments;
  v_rec.legislative_parameters   := p_legislative_parameters;
  v_rec.run_type_id              := p_run_type_id;
  v_rec.date_earned              := p_date_earned;
  v_rec.pay_advice_date          := p_pay_advice_date;
  v_rec.pay_advice_message       := p_pay_advice_message;
  v_rec.object_version_number    := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  return(v_rec);
--
End convert_args;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs function has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding argument value for update. When
--   we attempt to update a row through the Upd business process, certain
--   arguments can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd business process to determine which attributes
--   have NOT been specified we need to check if the argument has a reserved
--   system default value. Therefore, for all attributes which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Pre Conditions:
--   This private function can only be called from the upd process.
--
-- In Arguments:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The record structure will be returned with all system defaulted argument
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this function will be a PL/SQL value error due to
--   conversion  of datatypes or data lengths.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function convert_defs(p_rec in out nocopy g_rec_type) return g_rec_type is
--
  v_proc  varchar2(72) := g_package||'convert_defs';
--
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.payroll_action_id = hr_api.g_number) then
    p_rec.payroll_action_id := g_old_rec.payroll_action_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id := g_old_rec.business_group_id;
  End If;
  If (p_rec.consolidation_set_id = hr_api.g_number) then
    p_rec.consolidation_set_id := g_old_rec.consolidation_set_id;
  End If;
  If (p_rec.action_status = hr_api.g_varchar2) then
    p_rec.action_status := g_old_rec.action_status;
  End If;
  If (p_rec.effective_date = hr_api.g_date) then
    p_rec.effective_date := g_old_rec.effective_date;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments := g_old_rec.comments;
  End If;
  If (p_rec.current_task = hr_api.g_varchar2) then
    p_rec.current_task := g_old_rec.current_task;
  End If;
  If (p_rec.legislative_parameters = hr_api.g_varchar2) then
    p_rec.legislative_parameters := g_old_rec.legislative_parameters;
  End If;
  If (p_rec.date_earned = hr_api.g_date) then
    p_rec.date_earned := g_old_rec.date_earned;
  End If;
  If (p_rec.pay_advice_date = hr_api.g_date) then
    p_rec.pay_advice_date := g_old_rec.pay_advice_date;
  End If;
  If (p_rec.pay_advice_message = hr_api.g_varchar2) then
    p_rec.pay_advice_message := g_old_rec.pay_advice_message;
  End If;
  If (p_rec.object_version_number = hr_api.g_number) then
    p_rec.object_version_number := g_old_rec.object_version_number;
  End If;
  If (p_rec.run_type_id = hr_api.g_number) then
    p_rec.run_type_id := g_old_rec.run_type_id;
  End If;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||v_proc, 10);
  Return(p_rec);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all insert business rules
--   validation.
--
-- Pre Conditions:
--   This private procedure is called from ins procedure.
--
-- In Arguments:
--   p_rec should contain details of the QuickPay Run to validate.
--   p_assignment_id should be set to the id which will be used to create
--   the associated Assignment Process.
--
-- Post Success:
--   p_payroll_id is set assignment's payroll details as of the QuickPay Run's
--   p_rec.effective_date.
--   p_time_period_id is set to the time period which exists as of the
--   QuickPay Run's p_rec.effective_date for the payroll p_payroll_id.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicitly coded.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure insert_validate
  (p_rec             in out nocopy g_rec_type
  ,p_assignment_id   in     number
  ,p_payroll_id         out nocopy pay_payroll_actions.payroll_id%TYPE
  ,p_time_period_id     out nocopy pay_payroll_actions.time_period_id%TYPE
  ) is
  --
  v_unused_return_b    boolean;
  v_unused_return_d    date;
  v_legislation_code   per_business_groups.legislation_code%TYPE;
  v_unused_return_nam  per_time_periods.period_name%TYPE;
  v_payroll_id         pay_payroll_actions.payroll_id%TYPE;
  v_time_period_id     pay_payroll_actions.time_period_id%TYPE;
  v_proc               varchar2(72) := g_package||'insert_validate';
--
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  -- Check mandatory values have been set
  --
  check_mandatory_args(p_rec => p_rec);
  hr_utility.set_location(v_proc, 6);
  --
  -- Validate business group id
  --
  hr_api.validate_bus_grp_id(p_rec.business_group_id);
  hr_utility.set_location(v_proc, 7);
  --
  -- Validate the assignment is in the same business group
  -- (Some other validate checks are done when the assignment action is
  -- inserted as part of the post-insert logic.)
  --
  chk_assignment
    (p_assignment_id     => p_assignment_id
    ,p_business_group_id => p_rec.business_group_id
    ,p_effective_date    => p_rec.effective_date
    );
  hr_utility.set_location(v_proc, 8);
  --
  -- Validate the consolidation set exists and it is in
  -- the same business group as the QuickPay.
  --
  chk_consol_set
    (p_consolidation_set_id => p_rec.consolidation_set_id
    ,p_business_group_id    => p_rec.business_group_id
    );
  hr_utility.set_location(v_proc, 9);
  --
  -- Find out the legislation code for the current business group
  -- (Then it does not have to be derived many times in different
  -- business rule checks.)
  --
  v_legislation_code := get_legislation_code(p_rec.business_group_id);
  --
  -- Check the assignment is on a payroll as of the effective date.
  -- Check that a time period exists for the assignment's payroll as of
  -- the effective date.
  --
  chk_eff_date
    (p_effective_date    => p_rec.effective_date
    ,p_assignment_id     => p_assignment_id
    ,p_legislation_code  => v_legislation_code
    ,p_recal_date_earned => false
    ,p_payroll_id        => v_payroll_id
    ,p_time_period_id    => v_time_period_id
    ,p_period_name       => v_unused_return_nam
    ,p_new_date_earned   => v_unused_return_d
    );
  hr_utility.set_location(v_proc, 11);
  --
  -- Validate the assignment is on a payroll as of date earned.
  -- Check that a time period exists for the assignment's payroll as of
  -- date earned.
  --
  chk_date_earned
    (p_date_earned      => p_rec.date_earned
    ,p_assignment_id    => p_assignment_id
    ,p_legislation_code => v_legislation_code
    ,p_effective_date   => p_rec.effective_date
    ,p_payroll_id       => v_payroll_id
    ,p_time_period_id   => v_time_period_id
    ,p_period_name      => v_unused_return_nam
    );
  hr_utility.set_location(v_proc, 12);
  --
  -- Validate the assignment is on the same payroll
  -- as of the effective_date and date_earned.
  --
  chk_eff_earned_payroll
    (p_effective_date => p_rec.effective_date
    ,p_date_earned    => p_rec.date_earned
    ,p_assignment_id  => p_assignment_id
    ,p_raise_error    => true
    ,p_same_payroll   => v_unused_return_b
    );
  hr_utility.set_location(v_proc, 13);
  --
  -- Validate the run_type - if not null, check it exists on
  -- pay_run_types_f.
  --
  chk_run_type
    (p_run_type_id        => p_rec.run_type_id
    ,p_effective_date     => p_rec.effective_date
    ,p_business_group_id  => p_rec.business_group_id
    ,p_legislation_code   => v_legislation_code
    );
  --
  -- Set out parameters
  --
  p_payroll_id     := v_payroll_id;
  p_time_period_id := v_time_period_id;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 14);
End insert_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all update business rules
--   validation.
--
-- Pre Conditions:
--   This private procedure is called from upd procedure.
--
-- In Arguments:
--   p_rec contains the details of the proposed QuickPay Run values.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicitly coded.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure update_validate
  (p_rec in g_rec_type
  ) is
--
  v_legislation_code  per_business_groups.legislation_code%TYPE;
  v_proc              varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Call all supporting business operations
  --
  -- Check mandatory values have been set
  --
  check_mandatory_args(p_rec => p_rec);
  --
  -- Check that the payroll_action has a null current_task.
  --
  chk_cur_task
    (p_current_task => p_rec.current_task
    );
  --
  -- Check that the fields which cannot be
  -- updated have not be changed.
  --
  check_non_updateable_args(p_rec => p_rec);
  --
  -- If the consolidation set has changed, validate it exists
  -- and it is in the same business group as the QuickPay.
  --
  if p_rec.consolidation_set_id <> g_old_rec.consolidation_set_id then
    chk_consol_set
      (p_consolidation_set_id => p_rec.consolidation_set_id
      ,p_business_group_id    => p_rec.business_group_id
      );
  end if;
  --
  -- If the action_status has changed, validate it has only been
  -- changed to 'M'ark for Retry and that action is allowed to have
  -- a 'M'ark for Retry status. (Ensure this is always the last validation
  -- step because the chk_action_status procedure will update child rows.)
  --
  if p_rec.action_status <> g_old_rec.action_status then
    chk_action_status
      (p_payroll_action_id => p_rec.payroll_action_id
      ,p_old_action_status => g_old_rec.action_status
      ,p_new_action_status => p_rec.action_status
      );
  end if;
  --
  -- If run type has changed, validate the new value is correct.
  --
  if nvl(p_rec.run_type_id, hr_api.g_number) <>
     nvl(g_old_rec.run_type_id, hr_api.g_number) then
    --
    -- Find out the legislation code for the current business group.
    v_legislation_code := get_legislation_code(p_rec.business_group_id);
    --
    -- Call business rule validation.
  --
  -- Validate the run_type - if not null, check it exists on
  -- pay_run_types_f.
  --
  chk_run_type
    (p_run_type_id        => p_rec.run_type_id
    ,p_effective_date     => p_rec.effective_date
    ,p_business_group_id  => p_rec.business_group_id
    ,p_legislation_code   => v_legislation_code
    );
  end if;
  --
  -- The user is allowed to update the pay advice date and
  -- the pay advice message. No validation is required.
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of all delete business rules
--   validation.
--
-- Pre Conditions:
--   This private procedure is called from del procedure.
--
-- In Arguments:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If a business rules fails the error will not be handled by this procedure
--   unless explicitly coded.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure delete_validate(p_rec in g_rec_type) is
--
  v_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Check that the payroll_action has a null current_task.
  --
  chk_cur_task
    (p_current_task => p_rec.current_task
    );
  --
  -- The following call checks the delete is valid. If this QuickPay Run
  -- can be removed any child rows such as pay_run_results and
  -- pay_run_result_values will be deleted.
  --
  py_rollback_pkg.rollback_payroll_action(
                  p_payroll_action_id    => p_rec.payroll_action_id,
                  p_rollback_mode        => 'ROLLBACK',
                  p_leave_base_table_row => TRUE);
  --
  hr_utility.set_location('Leaving:'|| v_proc, 10);
End delete_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure ins
  (p_rec                     in out nocopy g_rec_type
  ,p_assignment_id           in     number
  ,p_assignment_action_id       out nocopy number
  ,p_a_object_version_number    out nocopy number
  ,p_validate                in     boolean default false
  ) is
--
  v_proc  varchar2(72) := g_package||'ins';
  --
  -- These variables are set by insert_validate and past to insert_dml
  --
  v_payroll_id               pay_payroll_actions.payroll_id%TYPE;
  v_time_period_id           pay_payroll_actions.time_period_id%TYPE;
  --
  -- These variables are set by pre_insert and past to insert_dml
  --
  v_action_type              pay_payroll_actions.action_type%TYPE;
  v_action_population_status pay_payroll_actions.action_population_status%TYPE;
  --
  -- These variables are set by post_insert and returned from this procedure
  --
  v_assignment_action_id     pay_assignment_actions.assignment_action_id%TYPE;
  v_a_object_version_number  pay_assignment_actions.object_version_number%TYPE;
--
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT ins_pay_payact;
  End If;
  --
  -- Call the supporting insert validate operations
  --
  insert_validate
    (p_rec            => p_rec
    ,p_assignment_id  => p_assignment_id
    ,p_payroll_id     => v_payroll_id
    ,p_time_period_id => v_time_period_id
    );
  --
  -- Call the supporting pre-insert operation
  --
  pre_insert
    (p_rec                      => p_rec
    ,p_action_type              => v_action_type
    ,p_action_population_status => v_action_population_status
    );
  --
  -- Insert the row
  --
  insert_dml
    (p_rec                      => p_rec
    ,p_action_type              => v_action_type
    ,p_payroll_id               => v_payroll_id
    ,p_time_period_id           => v_time_period_id
    ,p_action_population_status => v_action_population_status
    );
  --
  -- Call the supporting post-insert operation
  --
  post_insert
    (p_rec                     => p_rec
    ,p_assignment_id           => p_assignment_id
    ,p_validate                => p_validate
    ,p_assignment_action_id    => v_assignment_action_id
    ,p_a_object_version_number => v_a_object_version_number
    );
  --
  -- Set output parameters
  --
  p_assignment_action_id    := v_assignment_action_id;
  p_a_object_version_number := v_a_object_version_number;
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||v_proc, 10);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO ins_pay_payact;
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure ins
  (p_business_group_id         in     number
  ,p_assignment_id             in     number
  ,p_consolidation_set_id      in     number
  ,p_effective_date            in     date
  ,p_legislative_parameters    in     varchar2  default null
  ,p_run_type_id               in     number
  ,p_date_earned               in     date
  ,p_pay_advice_date           in     date      default null
  ,p_pay_advice_message        in     varchar2  default null
  ,p_comments                  in     varchar2  default null
  ,p_payroll_action_id            out nocopy number
  ,p_p_object_version_number      out nocopy number
  ,p_assignment_action_id         out nocopy number
  ,p_a_object_version_number      out nocopy number
  ,p_validate                  in     boolean   default false
  ) is
--
  v_rec   g_rec_type;
  v_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||v_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  v_rec :=
    convert_args
      (p_payroll_action_id         => null
      ,p_business_group_id         => p_business_group_id
      ,p_consolidation_set_id      => p_consolidation_set_id
      ,p_action_status             => null
      ,p_effective_date            => p_effective_date
      ,p_comments                  => p_comments
      ,p_current_task              => null
      ,p_legislative_parameters    => p_legislative_parameters
      ,p_run_type_id               => p_run_type_id
      ,p_date_earned               => p_date_earned
      ,p_pay_advice_date           => p_pay_advice_date
      ,p_pay_advice_message        => p_pay_advice_message
      ,p_object_version_number     => null
      );
  hr_utility.set_location(v_proc, 6);
  --
  -- Having converted the arguments into the pay_payact_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins
    (p_rec                     => v_rec
    ,p_assignment_id           => p_assignment_id
    ,p_assignment_action_id    => p_assignment_action_id
    ,p_a_object_version_number => p_a_object_version_number
    ,p_validate                => p_validate
    );
  hr_utility.set_location(v_proc, 7);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  -- (p_a_object_version_number and p_assignment_action_id have
  -- been set by the 'ins' procedure.)
  --
  p_payroll_action_id       := v_rec.payroll_action_id;
  p_p_object_version_number := v_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
End ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure upd
  (p_rec                     in out nocopy g_rec_type
  ,p_assignment_action_id    in     number
  ,p_a_object_version_number in     number
  ,p_validate                in     boolean default false
  ) is
--
  v_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT upd_pay_payact;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  lck
    (p_payroll_action_id       => p_rec.payroll_action_id
    ,p_p_object_version_number => p_rec.object_version_number
    ,p_a_object_version_number => p_a_object_version_number
    );
  hr_utility.set_location(v_proc, 6);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  update_validate
    (p_rec => convert_defs(p_rec)
    );
  --
  -- Call the supporting pre-update operation
  --
  pre_update(p_rec);
  --
  -- Update the row.
  --
  update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  post_update(p_rec);
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||v_proc, 10);
exception
  when hr_api.validate_enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO upd_pay_payact;
end upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure upd
  (p_payroll_action_id       in     number
  ,p_consolidation_set_id    in     number   default hr_api.g_number
  ,p_legislative_parameters  in     varchar2 default hr_api.g_varchar2
  ,p_run_type_id             in     number   default hr_api.g_number
  ,p_pay_advice_date         in     date     default hr_api.g_date
  ,p_pay_advice_message      in     varchar2 default hr_api.g_varchar2
  ,p_action_status           in     varchar2 default hr_api.g_varchar2
  ,p_comments                in     varchar2 default hr_api.g_varchar2
  ,p_assignment_action_id    in     number
  ,p_p_object_version_number in out nocopy number
  ,p_a_object_version_number in     number
  ,p_validate                in     boolean  default false
  ) is
--
  v_rec   g_rec_type;
  v_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  v_rec :=
    convert_args
      (p_payroll_action_id         => p_payroll_action_id
      ,p_business_group_id         => hr_api.g_number
      ,p_consolidation_set_id      => p_consolidation_set_id
      ,p_action_status             => p_action_status
      ,p_effective_date            => hr_api.g_date
      ,p_comments                  => p_comments
      ,p_current_task              => hr_api.g_varchar2
      ,p_legislative_parameters    => p_legislative_parameters
      ,p_run_type_id               => p_run_type_id
      ,p_date_earned               => hr_api.g_date
      ,p_pay_advice_date           => p_pay_advice_date
      ,p_pay_advice_message        => p_pay_advice_message
      ,p_object_version_number     => p_p_object_version_number
      );
  hr_utility.set_location(v_proc, 6);
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd
    (p_rec                     => v_rec
    ,p_assignment_action_id    => p_assignment_action_id
    ,p_a_object_version_number => p_a_object_version_number
    ,p_validate                => p_validate
    );
  p_p_object_version_number := v_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure del
  (p_rec                      in g_rec_type
  ,p_a_object_version_number  in number
  ,p_validate                 in boolean default false
  ) is
--
  v_proc  varchar2(72) := g_package||'del';
--
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Determine if the business process is to be validated.
  --
  if p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT del_pay_payact;
  end if;
  --
  -- We must lock the row which we need to delete.
  --
  lck
    (p_payroll_action_id       => p_rec.payroll_action_id
    ,p_p_object_version_number => p_rec.object_version_number
    ,p_a_object_version_number => p_a_object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  delete_validate(p_rec);
  --
  -- Call the supporting pre-delete operation
  --
  pre_delete(p_rec);
  --
  -- Delete the row.
  --
  delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  post_delete(p_rec);
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||v_proc, 10);
exception
  when hr_api.validate_enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO del_pay_payact;
end del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure del
  (p_payroll_action_id        in number
  ,p_p_object_version_number  in number
  ,p_a_object_version_number  in number
  ,p_validate                 in boolean default false
  ) is
--
  v_rec   g_rec_type;
  v_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  v_rec.payroll_action_id     := p_payroll_action_id;
  v_rec.object_version_number := p_p_object_version_number;
  --
  -- Having converted the arguments into the pay_payact_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del
    (p_rec                     => v_rec
    ,p_a_object_version_number => p_a_object_version_number
    ,p_validate                => p_validate
    );
  --
  hr_utility.set_location(' Leaving:'||v_proc, 10);
End del;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< default_values >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure default_values
  (p_assignment_id          in     pay_assignment_actions.assignment_id%TYPE
  ,p_df_effective_date         out nocopy pay_payroll_actions.
                                                  effective_date%TYPE
  ,p_df_date_earned            out nocopy pay_payroll_actions.date_earned%TYPE
  ,p_period_name               out nocopy per_time_periods.period_name%TYPE
  ,p_consolidation_set_id      out nocopy pay_consolidation_sets.
                                                  consolidation_set_id%TYPE
  ,p_consolidation_set_name    out nocopy pay_consolidation_sets.
                                                  consolidation_set_name%TYPE
  ,p_unprocessed_status        out nocopy varchar2
  ,p_mark_for_retry_status     out nocopy varchar2
  ,p_complete_status           out nocopy varchar2
  ,p_in_error_status           out nocopy varchar2
  ,p_start_run_prompt          out nocopy varchar2
  ,p_start_pre_prompt          out nocopy varchar2
  ,p_retry_run_prompt          out nocopy varchar2
  ,p_rerun_pre_prompt          out nocopy varchar2
  ,p_start_arc_prompt		    out nocopy varchar2
  ,p_retry_arc_prompt		    out nocopy varchar2
  ,p_qp_run_user_name          out nocopy varchar2
  ) is
  --
  -- Cursor Definitions
  --
  cursor csr_eff_date is
    select effective_date
      from fnd_sessions ses
     where ses.session_id = userenv('sessionid');
  --
  cursor csr_payroll (v_cur_date date) is
    select /*+ ORDERED INDEX(asg PER_ASSIGNMENTS_F_PK) */
           asg.payroll_id
         , pro.consolidation_set_id
         , con.consolidation_set_name
         , bus.legislation_code
         , hr_general.decode_lookup('ASSIGNMENT_ACTION_STATUS', 'U')
         , hr_general.decode_lookup('ASSIGNMENT_ACTION_STATUS', 'M')
         , hr_general.decode_lookup('ASSIGNMENT_ACTION_STATUS', 'C')
         , hr_general.decode_lookup('ASSIGNMENT_ACTION_STATUS', 'E')
         , hr_general.decode_lookup('ACTION_TYPE', 'Q')
      from per_assignments_f        asg
         , pay_payrolls_f           pro
         , pay_consolidation_sets   con
         , per_business_groups_perf bus
     where /* Assignment's Payroll details */
           asg.assignment_id        = p_assignment_id
       and v_cur_date         between asg.effective_start_date
                                  and asg.effective_end_date
       and pro.payroll_id           = asg.payroll_id
       and v_cur_date         between pro.effective_start_date
                                  and pro.effective_end_date
           /* Consolidation Set details */
       and con.consolidation_set_id = pro.consolidation_set_id
           /* Business group's legislation code details */
       and bus.business_group_id    = asg.business_group_id;
  --
  cursor csr_per_dat(v_pay_id    number
                    ,v_cur_date  date
                    ) is
    select tim.regular_payment_date
         , tim.period_name
      from per_time_periods tim
     where tim.payroll_id       = v_pay_id
       and v_cur_date     between tim.start_date
                              and tim.end_date;
  --
  --
  -- Local variables
  --
  -- The assignment's business group legislation_code:
  v_legislation_code  per_business_groups.legislation_code%TYPE;
  --
  -- The assignment's payroll as of the session effective or trunc(sysdate).
  v_payroll_id        per_assignments_f.payroll_id%TYPE;
  --
  -- Period name which exists as of v_eff_date.
  v_period_name       per_time_periods.period_name%TYPE;
  --
  -- Period regular payment date.
  v_period_reg_date   per_time_periods.regular_payment_date%TYPE;
  --
  -- The Form or Database session effective date.
  v_eff_date          date;
  --
  -- Working value which is used to set the out argument p_df_effective_date.
  v_df_effective_date pay_payroll_actions.effective_date%TYPE;
  --
  -- Working value which is used to set the out argument p_df_date_earned.
  v_df_date_earned    pay_payroll_actions.date_earned%TYPE;
  --
  -- Working value which is used to set the out argument p_period_name;
  v_df_period_name    per_time_periods.period_name%TYPE;
  --
  -- Shows if the assignment is on the same payroll as of two dates.
  v_same_payroll      boolean;
  --
  v_proc              varchar2(72) := g_package||'default_values';
  --
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Work out which date to drive off. Try to use the Form's session effective
  -- date. If that has not been defined for this database session then
  -- use trunc(sysdate).
  --
  open csr_eff_date;
  fetch csr_eff_date into v_eff_date;
  if csr_eff_date%notfound then
    v_eff_date := trunc(sysdate);
  end if;
  close csr_eff_date;
  hr_utility.set_location(v_proc, 6);
  --
  -- Obtain the assignment's payroll, consolidation set details,
  -- action status meanings, QuickPay Run user description and
  -- the business group's legislation details.
  --
  open csr_payroll (v_eff_date);
  fetch csr_payroll into v_payroll_id
                       , p_consolidation_set_id
                       , p_consolidation_set_name
                       , v_legislation_code
                       , p_unprocessed_status
                       , p_mark_for_retry_status
                       , p_complete_status
                       , p_in_error_status
                       , p_qp_run_user_name;
  if csr_payroll%found then
    close csr_payroll;
  else
    close csr_payroll;
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', v_proc);
    hr_utility.set_message_token('STEP', '7');
    hr_utility.raise_error;
  end if;
  hr_utility.set_location(v_proc, 8);
  --
  -- Obtain the button prompts from hr_lookups
  --
  p_start_run_prompt := hr_general.decode_lookup ('PAYWSRQP_BUTTONS','SR');
  p_start_pre_prompt := hr_general.decode_lookup ('PAYWSRQP_BUTTONS','SP');
  p_retry_run_prompt := hr_general.decode_lookup ('PAYWSRQP_BUTTONS','RR');
  p_rerun_pre_prompt := hr_general.decode_lookup ('PAYWSRQP_BUTTONS','RP');
  p_start_arc_prompt := hr_general.decode_lookup ('PAYWSRQP_BUTTONS','SA');
  p_retry_arc_prompt := hr_general.decode_lookup ('PAYWSRQP_BUTTONS','RA');
  if p_start_run_prompt is null or p_retry_run_prompt is null or
     p_start_pre_prompt is null or p_rerun_pre_prompt is null or
     p_start_arc_prompt is null or p_retry_arc_prompt is null then
    -- All six button labels could not be found in hr_lookups.
    -- (Where lookup_type = 'PAYWSRQP_BUTTONS'.)
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', v_proc);
    hr_utility.set_message_token('STEP', '9');
    hr_utility.raise_error;
  end if;
  hr_utility.set_location(v_proc, 10);
  --
  -- Set the out arguments p_df_effective_date and p_df_date_earned
  -- depending on a payroll time period existing and the legislation.
  --
  -- Attempt to find a payroll time period for the session date.
  --
  open csr_per_dat (v_payroll_id, v_eff_date);
  fetch csr_per_dat into v_period_reg_date
                       , v_period_name;
  if csr_per_dat%notfound then
    --
    -- No time period exists as of the session date. So do not
    -- default the date or period name out arguments.
    --
    close csr_per_dat;
    v_df_effective_date := null;
    v_df_date_earned    := null;
    v_df_period_name    := null;
    hr_utility.set_location(v_proc, 11);
  else
    --
    -- A time period does exist as of the session date. Set the
    -- period name out argument and set the date fields depending
    -- on the current legislation.
    --
    close csr_per_dat;
    hr_utility.set_location(v_proc, 12);
    --
    if v_legislation_code = 'GB' then
      --
      -- Only for GB legislation.
      --
      v_df_effective_date := v_period_reg_date;
      v_df_period_name    := v_period_name;
      --
      -- Check the assignment is on the same payroll as of the specified
      -- effective_date and derived effective_date.
      --
      -- chk_eff_earned_payroll
      --  (p_effective_date => v_df_effective_date
      --  ,p_date_earned    => v_eff_date
      --  ,p_assignment_id  => p_assignment_id
      --  ,p_raise_error    => false
      --  ,p_same_payroll   => v_same_payroll
      --  );
      --if v_same_payroll then
        --
        -- The assignment is on the same payroll so attempt to derive
        -- the date earned value.
        --
        --v_df_date_earned := get_date_earned_for_gb
        --                      (p_assignment_id  => p_assignment_id
        --                      ,p_effective_date => v_df_effective_date
        --                      );
        --hr_utility.set_location(v_proc, 13);
        --
        -- If get_date_earned_for_gb returns a null value then a suitable
        -- default value could not be found or the assignment.
        --
        --if v_df_date_earned is null then
        --  v_df_effective_date := null;
        --  v_df_period_name    := null;
        --  hr_utility.set_location(v_proc, 14);
        --else
          --
          -- Check the assignment is on the same payroll as of the specified
          -- default effective_date and default date_earned.
          --
          --chk_eff_earned_payroll
          --  (p_effective_date => v_df_effective_date
          --  ,p_date_earned    => v_eff_date
          --  ,p_assignment_id  => p_assignment_id
          --  ,p_raise_error    => false
          --  ,p_same_payroll   => v_same_payroll
          --  );
          --if not v_same_payroll then
            -- Payrolls as of v_df_effective_date and v_df_date_earned are
            -- different.
            --v_df_effective_date := null;
            --v_df_date_earned    := null;
            --v_df_period_name    := null;
            --hr_utility.set_location(v_proc, 16);
          --end if;
          --hr_utility.set_location(v_proc, 17);
        --end if;
        --hr_utility.set_location(v_proc, 18);
      --else -- payrolls as of v_eff_date and v_df_effective_date are different
        --v_df_effective_date := null;
        --v_df_date_earned    := null;
        --v_df_period_name    := null;
        --hr_utility.set_location(v_proc, 19);
      --end if;
    else
      --
      -- For all other legislations. i.e. non-GB.
      --
      v_df_effective_date := v_eff_date;
      v_df_date_earned    := v_eff_date;
      v_df_period_name    := v_period_name;
      hr_utility.set_location(v_proc, 20);
    end if;
  end if;
  --
  p_df_effective_date := v_df_effective_date;
  p_df_date_earned    := v_df_date_earned;
  p_period_name       := v_df_period_name;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 21);
end default_values;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< get_latest_status >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Returns the latest statuses and display_run_number for a given QuickPay
--   Run or QuickPay Pre-payment. Used to find out the updated Payroll and
--   Assignment Process statuses after one of the C processes has been ran.
--
-- Pre Conditions:
--   None.
--
-- In Arguments:
--   p_payroll_action_id is the id of a QuickPay Run or QuickPay Pre-payment
--   Payroll Process. This is a mandatory argument.
--
-- Post Success:
--   p_p_action_status will be set to the Payroll Process action status.
--   p_display_run_number will be set to Payroll Process display_run_number
--   value. If the Payroll Process is a QuickPay Pre-payment
--   p_display_run_number will always be null.
--   p_a_action_status will be set to the Assignment Process action status.
--
-- Post Failure:
--   The application error HR_7220_INVALID_PRIMARY_KEY will be raised if a
--   Payroll Process does not exist with an id of p_payroll_action_id.
--   p_p_action_status, p_display_run_number and p_action_status will have
--   undefined values because the end of the procedure will not be reached.
--
-- {End Of Comments}
--
procedure get_latest_status
  (p_payroll_action_id  in     pay_payroll_actions.payroll_action_id%TYPE
  ,p_p_action_status       out nocopy pay_payroll_actions.action_status%TYPE
  ,p_display_run_number    out nocopy pay_payroll_actions.
                                                     display_run_number%TYPE
  ,p_a_action_status       out nocopy pay_assignment_actions.action_status%TYPE
  ) is
  v_proc      varchar2(72) := g_package||'get_latest_status';
  v_argument  varchar2(30);
  --
  cursor cur_stat is
    select pya.action_status
         , pya.display_run_number
         , aga.action_status
      from pay_payroll_actions    pya
         , pay_assignment_actions aga
     where pya.payroll_action_id = p_payroll_action_id
       and aga.payroll_action_id = pya.payroll_action_id;
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => v_proc
    ,p_argument       => 'payroll_action_id'
    ,p_argument_value => p_payroll_action_id
    );
  --
  -- Select the action_status and display_run_number
  -- for the payroll action.
  --
  open cur_stat;
  fetch cur_stat into p_p_action_status
                    , p_display_run_number
                    , p_a_action_status;
  if cur_stat%notfound then
    close cur_stat;
    -- Error: This primary key does not exist in the database.
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  close cur_stat;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
end get_latest_status;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< start_quickpay_process >----------------------|
-- ----------------------------------------------------------------------------
--
procedure start_quickpay_process
  (p_payroll_action_id       in pay_payroll_actions.payroll_action_id%TYPE
  ,p_p_object_version_number in pay_payroll_actions.object_version_number%TYPE
  ,p_a_object_version_number in pay_assignment_actions.
                                              object_version_number%TYPE
  ,p_status                  in out nocopy varchar2
  ) is
  v_proc             varchar2(72) := g_package||'start_quickpay_process';
  v_request_id       pay_payroll_actions.request_id%TYPE;
  v_action_type      pay_payroll_actions.action_type%TYPE;
  v_a_action_status  pay_assignment_actions.action_status%TYPE;
  v_leg_code         per_business_groups.legislation_code%TYPE;
  v_process_name     varchar2(30);
  v_first_arg        varchar2(30);
  v_asactid          varchar2(30);
  v_asgid            varchar2(30);
  v_grossup          pay_element_entries_f.element_entry_id%TYPE;
  v_displ_msg        varchar2(30);
  --
  cursor get_leg_rule is
  select rule_mode
    from pay_legislative_field_info
   where legislation_code = v_leg_code
     and target_location = 'PAYWSRQP'
     and validation_type = 'DISPLAY'
     and rule_type = 'DISP_NTG_MSG';

  --
  -- Enhancement 3368211
  -- get_grossup_entry modified to support the new QuickPay Exclusions
  -- model.
  --
  cursor get_grossup_entry (p_use_qpay_excl_model varchar2) is
     SELECT EE.element_entry_id
     FROM   pay_element_types_f            ET,
            pay_element_links_f            EL,
            pay_element_entries_f          EE,
            pay_assignment_actions         ACT,
            pay_payroll_actions            PACT
     WHERE  ACT.assignment_action_id = v_asactid
     AND    PACT.payroll_action_id   = p_payroll_action_id
     AND    EE.assignment_id         = ACT.assignment_id
     AND  ((p_use_qpay_excl_model = 'N'
            AND EXISTS (
            SELECT null
            FROM   pay_quickpay_inclusions INC
            WHERE  INC.assignment_action_id = ACT.assignment_action_id
            AND    INC.element_entry_id     = EE.element_entry_id)
            OR  EXISTS (
            SELECT null
            FROM   pay_quickpay_inclusions INC
            WHERE  INC.assignment_action_id = ACT.assignment_action_id
            AND    INC.element_entry_id     = EE.target_entry_id)
           )
         OR
           (p_use_qpay_excl_model = 'Y'
            AND NOT (
              EXISTS (
              SELECT null
              FROM   pay_quickpay_exclusions EXC
              WHERE  EXC.assignment_action_id = ACT.assignment_action_id
              AND    EXC.element_entry_id     = EE.element_entry_id)
              OR EXISTS (
              SELECT null
              FROM   pay_quickpay_exclusions EXC
              WHERE  EXC.assignment_action_id = ACT.assignment_action_id
              AND    EXC.element_entry_id     = EE.target_entry_id))
           )
          )
     AND    EE.entry_type              <>  'B'
     AND    PACT.date_earned BETWEEN  EE.effective_start_date
                                  AND  EE.effective_end_date
     AND    EE.element_link_id          =  EL.element_link_id
     AND    PACT.date_earned BETWEEN  EL.effective_start_date
                                  AND  EL.effective_end_date
     AND    nvl(EE.date_earned, to_date('01/01/0001', 'DD/MM/YYYY')) <=
               PACT.date_earned
     AND    EL.element_type_id          =  ET.element_type_id
     AND    ET.grossup_flag             = 'Y'
     AND    PACT.date_earned BETWEEN  ET.effective_start_date
                                  AND  ET.effective_end_date
     AND    ET.process_in_run_flag     <>  'N'
     AND    (ET.processing_type       =  'N' OR EE.entry_type = 'D')
     AND    NOT (ACT.action_status = 'B' AND EE.creator_type = 'P')
     AND    NOT (ACT.action_status = 'B' AND EE.creator_type = 'R')
     AND    NOT (ACT.action_status = 'B' AND EE.creator_type = 'RR')
     AND    NOT (ACT.action_status = 'B' AND EE.creator_type = 'EE')
     UNION ALL
     SELECT EE.element_entry_id
     FROM   pay_element_types_f            ET,
            pay_element_links_f            EL,
            pay_element_entries_f          EE,
            pay_assignment_actions         ACT,
            pay_payroll_actions           PACT,
            pay_element_entry_values_f     EEV
     WHERE  PACT.payroll_action_id = p_payroll_action_id
     and    PACT.payroll_action_id = ACT.payroll_action_id
     and    ACT.action_status not in ('C', 'S')
     AND    EE.assignment_id         = ACT.assignment_id
     AND  ((p_use_qpay_excl_model = 'N'
            AND EXISTS (
            SELECT null
            FROM   pay_quickpay_inclusions INC
            WHERE  INC.assignment_action_id = ACT.assignment_action_id
            AND    INC.element_entry_id     = EE.element_entry_id)
            OR  EXISTS (
            SELECT null
            FROM   pay_quickpay_inclusions INC
            WHERE  INC.assignment_action_id = ACT.assignment_action_id
            AND    INC.element_entry_id     = EE.target_entry_id)
           )
         OR
           (p_use_qpay_excl_model = 'Y'
            AND NOT (
              EXISTS (
              SELECT null
              FROM   pay_quickpay_exclusions EXC
              WHERE  EXC.assignment_action_id = ACT.assignment_action_id
              AND    EXC.element_entry_id     = EE.element_entry_id)
              OR EXISTS (
              SELECT null
              FROM   pay_quickpay_exclusions EXC
              WHERE  EXC.assignment_action_id = ACT.assignment_action_id
              AND    EXC.element_entry_id     = EE.target_entry_id))
           )
          )
     AND    EE.entry_type              NOT IN ('B', 'D')
     AND    EE.effective_start_date <= PACT.date_earned
     and    EE.effective_end_date   >=
                  decode(ET.proration_group_id,
                         null, PACT.date_earned,
                         pay_interpreter_pkg.prorate_start_date (v_asactid, ET.proration_group_id))
     AND    EE.element_link_id          =  EL.element_link_id
     AND    PACT.date_earned BETWEEN  EL.effective_start_date
                                  AND  EL.effective_end_date
     AND    EL.element_type_id          =  ET.element_type_id
     AND    ET.grossup_flag             = 'Y'
     AND    PACT.date_earned BETWEEN  ET.effective_start_date
                                  AND  ET.effective_end_date
     AND    ET.process_in_run_flag     <>  'N'
     AND    EEV.element_entry_id (+)    =  EE.element_entry_id
     AND    EE.effective_start_date     = nvl(EEV.effective_start_date,
                                            EE.effective_start_date)
     AND    EE.effective_end_date       = nvl(EEV.effective_end_date,
                                            EE.effective_end_date)
     AND    ET.processing_type          =  'R'
     AND    EXISTS ( select ''
                     from pay_payroll_actions ppa,
                          per_time_periods    ptp,
                          pay_element_entries_f pee
                    where pee.element_entry_id = EE.element_entry_id
                      and ppa.payroll_action_id = ACT.payroll_action_id
                      and ppa.payroll_id = ptp.payroll_id
                      and PACT.date_earned between ptp.start_date
                                                    and ptp.end_date
                      and pee.effective_start_date <= ptp.end_date
                      and pee.effective_end_date  >= ptp.start_date
                 )
     AND    NOT (ACT.action_status = 'B' AND EE.creator_type = 'P')
     AND    NOT (ACT.action_status = 'B' AND EE.creator_type = 'R')
     AND    NOT (ACT.action_status = 'B' AND EE.creator_type = 'RR')
     AND    NOT (ACT.action_status = 'B' AND EE.creator_type = 'EE');
--
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => v_proc
    ,p_argument       => 'payroll_action_id'
    ,p_argument_value => p_payroll_action_id
    );
  --
  -- Lock the QuickPay Run or QuickPay Pre-payment action rows
  --
  lck_general
    (p_payroll_action_id       => p_payroll_action_id
    ,p_p_object_version_number => p_p_object_version_number
    ,p_a_object_version_number => p_a_object_version_number
    ,p_only_action_type        => null
    ,p_actual_action_type      => v_action_type
    ,p_a_action_status         => v_a_action_status
    );
  hr_utility.set_location(v_proc, 6);
  --
  select pbg.legislation_code
  into   v_leg_code
  from   per_business_groups_perf pbg,
         pay_payroll_actions ppa
  where  ppa.payroll_action_id = p_payroll_action_id
  and    pbg.business_group_id = ppa.business_group_id;
  --
  -- Bugfix for 2177986: Unable to process separate payment elements in QuickPay.
  -- Commenting out control_separate_check_entries.
  --
  -- if v_leg_code = 'US' or
  --   v_leg_code = 'CA' then
  --     control_separate_check_entries (pi_payroll_action_id => p_payroll_action_id);
  -- end if;
  --
  -- Work out which process to run.
  -- For a QuickPay Pre-payment always call the 'QPPREPAY' process, regardless
  -- of the action_status.
  -- For a QuickPay Run when the assignment_action action_status is
  -- Unprocessed call the 'QUICKPAY' process. For a QuickPay Run when the
  -- assignment_action action_status is Marked for Retry or In Error then call
  -- the 'RETRY' process.
  --
  if v_action_type = 'U' then
    v_process_name := 'QPPREPAY';
    v_first_arg    := 'QPPREPAY';
  elsif v_action_type     = 'Q' and
        v_a_action_status = 'U' then
    v_process_name := 'QUICKPAY';
    v_first_arg    := 'QUICKPAY';
  elsif v_action_type = 'Q' and
       (v_a_action_status = 'M' or
        v_a_action_status = 'E') then
    v_process_name := 'RETRY';
    v_first_arg    := 'RERUN';
  elsif v_action_type ='X' then
      v_process_name := 'RETRY';
      v_first_arg := 'RERUN';
  else
    -- Error: You have attempted to issue a Start or Retry operation, after
    -- querying this record but before another operation has finished.
    -- You need to query this record and issue the operation again.
    hr_utility.set_message(801, 'HR_7265_QPAY_STATUS_OUT_SYNC');
    hr_utility.raise_error;
  end if;
  hr_utility.set_location(v_proc, 8);
  --
  -- For quickpay, add extra check here to see if assignment has got any net
  -- to gross entries. If it has, then issue a warning message only if a
  -- legislation rule exists for DISP_NTG_MESG
  --
  if (v_process_name = 'QUICKPAY' or v_process_name = 'RETRY')
  then
     if (p_status = 'START') then
        open get_leg_rule;
        fetch get_leg_rule into v_displ_msg;
        if (get_leg_rule%found and v_displ_msg = 'Y') then
           SELECT assignment_action_id
           INTO   v_asactid
           FROM   pay_assignment_actions
           WHERE  payroll_action_id = p_payroll_action_id;

           --
           -- Enhancement 3368211
           -- Pass use_qpay_excl_model to get_grossup_entry to determine
           -- which QuickPay data model we should be using
           --
           open get_grossup_entry(use_qpay_excl_model);
           fetch get_grossup_entry into v_grossup;
           --
           if get_grossup_entry%found then
              p_status := 'WARNING';
              return;
           else p_status := 'CONTINUE';
           end if;
        else
           p_status := 'CONTINUE';
        end if;
     end if;
  end if;

  if (p_status = 'CONTINUE') then
        --
        -- Submit request to AOL concurrent manager
        --
        v_request_id :=
          fnd_request.submit_request
          ('PAY'
          ,program     => v_process_name
          ,description => null
          ,start_time  => null
          ,sub_request => false
          ,argument1   => v_first_arg
          ,argument2   => to_char(p_payroll_action_id)
          );
        hr_utility.set_location(v_proc, 9);
        --
        -- Detect if the request was really submitted.
        -- If it has not then handle the error.
        --
        if v_request_id = 0 then
          fnd_message.raise_error;
        end if;
        hr_utility.set_location(v_proc, 11);
        --
        -- Request has been accepted update payroll_actions
        -- with the request details.
        --
        update pay_payroll_actions
           set request_id = v_request_id
         where payroll_action_id = p_payroll_action_id;
        --
   end if;
  hr_utility.set_location(' Leaving:'|| v_proc, 12);
  --
  return;
  --
end start_quickpay_process;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< wait_quickpay_process >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure wait_quickpay_process
  (p_payroll_action_id  in     pay_payroll_actions.payroll_action_id%TYPE
  ,p_display_run_number    out nocopy pay_payroll_actions.
                                                  display_run_number%TYPE
  ,p_a_action_status       out nocopy pay_assignment_actions.action_status%TYPE
  ,p_process_info          out nocopy varchar2
  ,p_request_id            out nocopy pay_payroll_actions.request_id%TYPE
  ) is
  v_wait               boolean;
  v_phase              varchar2(255);
  v_status             varchar2(255);
  v_dev_phase          varchar2(255);
  v_dev_status         varchar2(255);
  v_message            varchar2(255);
  v_max_wait_sec       number;
  v_interval_wait_sec  number;
  v_request_id         pay_payroll_actions.request_id%TYPE;
  v_p_action_status    pay_payroll_actions.action_status%TYPE;
  v_proc               varchar2(72) := g_package||'start_quickpay_run';
  --
  cursor cur_req is
    select request_id
      from pay_payroll_actions
     where payroll_action_id = p_payroll_action_id;
  --
  cursor cur_max is
    select fnd_number.canonical_to_number(parameter_value)
      from pay_action_parameters
     where parameter_name = 'QUICKPAY_MAX_WAIT_SEC';
  --
  cursor cur_intw is
    select fnd_number.canonical_to_number(parameter_value)
      from pay_action_parameters
     where parameter_name = 'QUICKPAY_INTERVAL_WAIT_SEC';
  --
begin
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Check mandatory parameters have been set
  --
  hr_api.mandatory_arg_error
    (p_api_name       => v_proc
    ,p_argument       => 'payroll_action_id'
    ,p_argument_value => p_payroll_action_id
    );
  --
  -- Find out the concurrent request_id for this QuickPay
  --
  open cur_req;
  fetch cur_req into v_request_id;
  if cur_req%notfound then
    close cur_req;
    -- Error: This primary key does not exist in the database.
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  close cur_req;
  hr_utility.set_location(v_proc, 7);
  --
  -- Check the request_id has been set. A value of zero means the submit
  -- request was not accepted by the concurrent manager. (This value should
  -- not be in pay_payroll_actions in the first place.)
  --
  if (v_request_id is null) or (v_request_id = 0) then
    -- Error: You have attempted to wait for a request to finish, when no
    -- request has been submitted for this QuickPay Run or QuickPay
    -- Pre-payment.
    hr_utility.set_message(801, 'HR_7266_QPAY_WAIT_NO_REQUEST');
    hr_utility.raise_error;
  end if;
  hr_utility.set_location(v_proc, 9);
  --
  -- Attempt to find out the QuickPay Concurrent manager max wait time
  -- and polling interval time from pay_action_parameters. If values
  -- cannot be found in this table then default to a max wait of 300
  -- seconds and polling interval of 2 seconds.
  --
  open cur_max;
  fetch cur_max into v_max_wait_sec;
  if cur_max %notfound then
    close cur_max;
    -- Value not in table, set to the default
    v_max_wait_sec := 300;
  else
    close cur_max;
  end if;
  hr_utility.set_location(v_proc, 10);
  --
  open cur_intw;
  fetch cur_intw into v_interval_wait_sec;
  if cur_intw %notfound then
    close cur_intw;
    -- Value not in table, set to the default
    v_interval_wait_sec := 2;
  else
    close cur_intw;
  end if;
  hr_utility.set_location(v_proc, 11);
  --
  -- Waits for request to finish on the concurrent manager.
  -- Or gives up if the maximum wait time is reached.
  --
  v_wait := fnd_concurrent.wait_for_request
              (request_id => v_request_id
              ,interval   => v_interval_wait_sec
              ,max_wait   => v_max_wait_sec
              ,phase      => v_phase
              ,status     => v_status
              ,dev_phase  => v_dev_phase
              ,dev_status => v_dev_status
              ,message    => v_message
              );
  hr_utility.set_location(v_proc, 12);
  --
  -- N.B. This point in the code can be reached for one of two reasons.
  --      1) The AOL process has reached a concurrent manager 'phase'
  --         value of 'COMPLETED'.
  --      2) The wait has given up because the maximum wait time has been
  --         reached.
  --      In other words, the AOL process may have, or may not have, finished.
  --
  -- Find out the latest payroll and assignment action status
  --
  get_latest_status
    (p_payroll_action_id  => p_payroll_action_id
    ,p_p_action_status    => v_p_action_status
    ,p_display_run_number => p_display_run_number
    ,p_a_action_status    => p_a_action_status
    );
  hr_utility.set_location(v_proc, 13);
  --
  -- Work out the process information for the caller
  -- (This assumes that when the payroll_action.action_status is 'Complete' or
  -- 'In Error' the payroll_action.current_task will not be null. At the
  -- time of writing this is an unfair assumption. But it will not be in
  -- the future.)
  --
  if v_p_action_status = 'U' or
     v_p_action_status = 'M' then
    p_process_info := 'PROCESS_NOT_STARTED';
  elsif v_p_action_status = 'P' then
    p_process_info := 'PROCESS_RUNNING';
  else -- (p_p_action_status is 'C' or 'E')
    p_process_info :=  'PROCESS_FINISHED';
  end if;
  --
  p_request_id := v_request_id;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 14);
  --
end wait_quickpay_process;
--
end pay_qpq_api;

/
