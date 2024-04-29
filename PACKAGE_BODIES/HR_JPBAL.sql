--------------------------------------------------------
--  DDL for Package Body HR_JPBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_JPBAL" AS
/* $Header: pyjpbal.pkb 120.2.12000000.2 2007/03/05 08:52:41 keyazawa noship $ */
/* ------------------------------------------------------------------------------------ */
c_package	constant varchar2(31) := 'hr_jpbal.';
/* ------------------------------------------------------------------------------------
--                            EXPIRY CHECKING CODE
--
-- Check the expiry of  latest balance table.
-- If current assignment action*s start period equal to the start period
-- of the latest assignment action in latest balance table,
-- and if out parameter type is number, this function returns 0 (this means false).
-- Otherwise, if out parameter type is date, (which is utilized in balance adjustment
-- to maintain latest balance,) this function returns last date in the period.
--
-- Now this check_expiry code supports only effective_date based dimension.
-- date_earned based dimension is not supported fully in Oracle*Applications
-- from the perspective of latest balance, e.g. legislation rule BAL_ADJ_LAT_BAL.
-- ------------------------------------------------------------------------------------ */
--
/* General Process */
--
PROCEDURE check_expiry(
	p_owner_payroll_action_id	IN	NUMBER, -- latest balance pact
	p_user_payroll_action_id	IN	NUMBER, -- current pact
	p_owner_assignment_action_id	IN	NUMBER, -- latest balance assact
	p_user_assignment_action_id	IN	NUMBER, -- current assact
	p_owner_effective_date		IN	DATE,   -- latest balance effective_date
	p_user_effective_date		IN	DATE,   -- current effective_date
	p_dimension_name		IN	VARCHAR2,
	p_expiry_information	 OUT NOCOPY NUMBER)
IS
	l_proc			varchar2(61);
	--
	l_dimension_date_type	varchar2(255);
	l_owner_period_end_date	DATE;
	l_business_group_id	NUMBER;
	l_user_date_earned	DATE;
	l_owner_date_earned	DATE;
BEGIN
-- To solve gscc error
	l_proc := c_package || 'check_expiry';
--
	hr_utility.set_location('Entering : ' || l_proc, 10);
	--
	hr_utility.trace('dimension_name       : ' || p_dimension_name);
	hr_utility.trace('user_pact            : ' || to_char(p_user_payroll_action_id));
	hr_utility.trace('user_assact          : ' || to_char(p_user_assignment_action_id));
	hr_utility.trace('user_effective_date  : ' || to_char(p_user_effective_date));
	hr_utility.trace('owner_pact           : ' || to_char(p_owner_payroll_action_id));
	hr_utility.trace('owner_assact         : ' || to_char(p_owner_assignment_action_id));
	hr_utility.trace('owner_effective_date : ' || to_char(p_owner_effective_date));
	--
	l_dimension_date_type := rtrim(substrb(rpad(p_dimension_name, 44), -14));
	--
	IF l_dimension_date_type = 'EFFECTIVE_DATE' THEN
		hr_utility.trace('Date Type : EFFECTIVE_DATE');
		--
		l_owner_period_end_date := hr_jprts.dimension_reset_last_date(
							p_dimension_name,
							p_owner_effective_date);
		--
		hr_utility.trace('owner_period_end_date : ' || to_char(l_owner_period_end_date));
		--
		IF p_user_effective_date > l_owner_period_end_date  THEN
			p_expiry_information := 1;
		ELSE
			p_expiry_information := 0;
		END IF;
	--
	-- Bug.2597843. DATE_EARNED expiry checking.
	-- Note there's no guarantee that DATE_EARNED is sequential like EFFECTIVE_DATE.
	-- If your business process does not guarantee DATE_EARNED to be sequential,
	-- never use DATE_EARNED based dimensions.
	-- Additionally, feed info on DATE_EARNED must be exactly the same as that of EFFECTIVE_DATE
	-- because feeding by PYUGEN checks the feed info as of EFFECTIVE_DATE, not DATE_EARNED.
	--
	ELSIF l_dimension_date_type = 'DATE_EARNED' THEN
		hr_utility.trace('Date Type : DATE_EARNED');
		--
		select	ppa_user.business_group_id,
			ppa_user.date_earned,
			ppa_owner.date_earned
		into	l_business_group_id,
			l_user_date_earned,
			l_owner_date_earned
		from	pay_payroll_actions	ppa_owner,
			pay_payroll_actions	ppa_user
		where	ppa_user.payroll_action_id = p_user_payroll_action_id
		and	ppa_owner.payroll_action_id = p_owner_payroll_action_id;
		--
		IF p_dimension_name = hr_jprts.g_asg_fytd_jp THEN
			l_owner_period_end_date := hr_jprts.dim_reset_last_date_userdef(
								p_dimension_name,
								l_owner_date_earned,
								'FLEX',
								null,
								l_business_group_id);
		ELSE
			l_owner_period_end_date := hr_jprts.dimension_reset_last_date(
								p_dimension_name,
								l_owner_date_earned);
		END IF;
		--
		hr_utility.trace('user_date_earned      : ' || to_char(l_user_date_earned));
		hr_utility.trace('owner_date_earned     : ' || to_char(l_owner_date_earned));
		hr_utility.trace('owner_period_end_date : ' || to_char(l_owner_period_end_date));
		--
		if l_user_date_earned > l_owner_period_end_date then
			p_expiry_information := 1;
		else
			p_expiry_information := 0;
		end if;
	ELSE
		fnd_message.set_name('PAY', 'This dimension is invalid');
		fnd_message.raise_error;
	END IF;
	--
	hr_utility.trace('expiry_information : ' || to_char(p_expiry_information));
	hr_utility.set_location('Leaving : ' || l_proc, 40);
END check_expiry;
--
/* Balance Adjustment */
--
PROCEDURE check_expiry(
	p_owner_payroll_action_id	IN	NUMBER, -- latest balance pact
	p_user_payroll_action_id	IN	NUMBER, -- current pact
	p_owner_assignment_action_id	IN	NUMBER, -- latest balance assact
	p_user_assignment_action_id	IN	NUMBER, -- current assact
	p_owner_effective_date		IN	DATE,   -- latest balance effective_date
	p_user_effective_date		IN	DATE,   -- current effective_date
	p_dimension_name		IN	VARCHAR2,
	p_expiry_information	 OUT NOCOPY DATE)
IS
	l_proc			varchar2(61);
	--
	l_dimension_date_type	varchar2(255);
	l_business_group_id	NUMBER(15);
	l_owner_date_earned	DATE;
	--
	cursor csr_business_group is
		SELECT	OWNER.business_group_id,
			OWNER.date_earned
		FROM	pay_payroll_actions	OWNER
		WHERE	OWNER.payroll_action_id = p_owner_payroll_action_id;
BEGIN
-- To solve gscc error
	l_proc := c_package || 'check_expiry';
--
	hr_utility.set_location('Entering : ' || l_proc, 10);
	--
	hr_utility.trace('dimension_name : ' || p_dimension_name);
	--
	l_dimension_date_type := rtrim(substrb(rpad(p_dimension_name, 44), -14));
	--
	IF l_dimension_date_type = 'EFFECTIVE_DATE' THEN
		hr_utility.trace('Date Type : EFFECTIVE_DATE');
		--
		p_expiry_information  := hr_jprts.dimension_reset_last_date(
							p_dimension_name,
							p_owner_effective_date);
	--
	-- Bug.2597843. DATE_EARNED expiry checking.
	-- Note there's no guarantee that DATE_EARNED is sequential like EFFECTIVE_DATE.
	-- If your business process does not guarantee DATE_EARNED to be sequential,
	-- never use DATE_EARNED based dimensions.
	--
	ELSIF l_dimension_date_type = 'DATE_EARNED' THEN
		hr_utility.trace('Date Type : DATE_EARNED');
		--
		open csr_business_group;
		fetch csr_business_group into
			l_business_group_id,
			l_owner_date_earned;
		close csr_business_group;
		--
		IF p_dimension_name = hr_jprts.g_asg_fytd_jp THEN
			p_expiry_information  := hr_jprts.dim_reset_last_date_userdef(
								p_dimension_name,
								l_owner_date_earned,
								'FLEX',
								null,
								l_business_group_id);
		ELSE
			p_expiry_information  := hr_jprts.dimension_reset_last_date(
								p_dimension_name,
								l_owner_date_earned);
		END IF;
	ELSE
		fnd_message.set_name('PAY', 'This dimension is invalid');
		fnd_message.raise_error;
	END IF;
	--
	hr_utility.trace('expiry_information : ' || to_char(p_expiry_information));
	hr_utility.set_location('Leaving : ' || l_proc, 20);
END check_expiry;
--
-- Fix bug#3083339: Added function get_element_reference to retrieve element
--                  level balance references reporting purposes.
 /* ----------------------------------------------------------------------------
 --
 --			       GET_ELEMENT_REFERENCE
 --
 -- This function returns an element name for identification purposes, which is
 -- prefixed by _E depending on the balance, and used as the reported dimension
 -- name.
 -- ------------------------------------------------------------------------- */
-- This function is used in PAY_JP_PAYJPBAL_VALUES_V of Balance View Form.
 FUNCTION get_element_reference(
           p_run_result_id		IN	NUMBER,
           p_database_item_suffix	IN	VARCHAR2) RETURN VARCHAR2 IS
 --
 l_reference	VARCHAR2(80);
 --
 CURSOR get_element_name(p_run_result_id	NUMBER) IS
  SELECT  /*+ ORDERED */
          pet.element_name
  FROM
   pay_run_results prr,
   pay_run_result_values prrv,
   pay_input_values piv,
   pay_element_types pet
  WHERE prr.run_result_id = p_run_result_id
  AND prrv.run_result_id = prr.run_result_id
  AND piv.input_value_id = prrv.input_value_id
  AND pet.element_type_id = piv.element_type_id;
 --
 BEGIN
 --
  OPEN get_element_name(p_run_result_id);
  FETCH get_element_name INTO l_reference;
  CLOSE get_element_name;
  --
  l_reference := p_database_item_suffix || '(' || l_reference || ')';
  --
  RETURN l_reference;
 --
 END get_element_reference;
--
/* ------------------------------------------------------------------------------------
--
--                                DATE_EARNED_FC
--
-- This procedure is used for feed checking as of DATE_EARNED.
-- PYUGEN supports only EFFECITVE_DATE feed checking, so another feed checking
-- as of DATE_EARNED required.
--
-- ------------------------------------------------------------------------------------ */
/*
procedure date_earned_fc(
	p_payroll_action_id	in     number,
	p_asg_action_id		in     number,
	p_assignment_id		in     number,
	p_effective_date	in     date,
	p_dimension_name	in     varchar2,
	p_iv_id			in     number,
	p_bt_id			in     number,
	p_contexts		in     varchar2,
	p_feed_flag		in out nocopy number,
	p_feed_scale		in out nocopy number)
is
	l_proc varchar2(61);
begin
-- To solve gscc error
	l_proc := c_package || 'date_earned_fc';
--
	hr_utility.set_location('Entering : ' || l_proc, 10);
	--
	select	pbf.scale
	into	p_feed_scale
	from	pay_balance_feeds_f	pbf,
		pay_payroll_actions	ppa
	where	ppa.payroll_action_id = p_payroll_action_id
	and	pbf.balance_type_id = p_bt_id
	and	pbf.input_value_id = p_iv_id
	and	ppa.date_earned
		between pbf.effective_start_date and pbf.effective_end_date;
	--
	p_feed_flag := 1;
	--
	hr_utility.set_location('Leaving : ' || l_proc, 20);
exception
	when no_data_found then
		hr_utility.set_location('Leaving : ' || l_proc, 25);
		p_feed_flag  := 0;
		p_feed_scale := 0;
end date_earned_fc;
*/
--
/* ------------------------------------------------------------------------------------
--
--                       DIMENSION RELEVANT  (private)
--
-- This function checks that a value is required for the dimension
-- for this particular balance type. If so, the defined balance is returned.
--
-- ------------------------------------------------------------------------------------ */
FUNCTION dimension_relevant(p_balance_type_id	IN NUMBER,
			    p_dimension_name	IN VARCHAR2)
RETURN NUMBER IS
--
	l_defined_balance_id	NUMBER;
--
	cursor relevant(
		c_balance_type_id IN NUMBER,
		c_dimension_name  IN VARCHAR2)
	is
	SELECT  /*+ ORDERED */
         	pdb.defined_balance_id
	FROM	pay_defined_balances pdb,
   		    pay_balance_dimensions pbd
	WHERE	pdb.balance_type_id = c_balance_type_id
	AND	pbd.balance_dimension_id = pdb.balance_dimension_id
	AND	pbd.dimension_name =  c_dimension_name;
--
BEGIN
--
	open relevant(p_balance_type_id, p_dimension_name);
	fetch relevant into l_defined_balance_id;
	close relevant;
--
RETURN l_defined_balance_id;
--
END dimension_relevant;
--
/* ------------------------------------------------------------------------------------
--
--                          GET_LATEST_ELEMENT_BAL (Private)
--
-- Calculate latest balances for element dimensions
--
-- ------------------------------------------------------------------------------------ */
FUNCTION get_latest_element_bal(
	p_assignment_action_id  IN NUMBER,
	p_defined_bal_id        IN NUMBER,
	p_source_id 	        IN NUMBER)
--
RETURN NUMBER IS
--
	l_balance		NUMBER;
	l_db_item_suffix	VARCHAR2(30);
	l_defined_bal_id	NUMBER;
--
	cursor element_latest_bal(
			c_assignment_action_id IN NUMBER,
			c_defined_bal_id	    IN NUMBER,
			c_source_id            IN NUMBER)
	is
	SELECT	palb.value
   	FROM	pay_assignment_latest_balances	palb,
   		pay_balance_context_values	pbcv
	WHERE	pbcv.context_id = c_source_id
	AND	palb.latest_balance_id = pbcv.latest_balance_id
	AND	palb.assignment_action_id = c_assignment_action_id
	AND	palb.defined_balance_id = c_defined_bal_id;
--
BEGIN
--
	open element_latest_bal(
			p_assignment_action_id,
			p_defined_bal_id,
			p_source_id);
	fetch element_latest_bal into l_balance;
	close element_latest_bal;
--
RETURN l_balance;
--
END get_latest_element_bal;
--
/* ------------------------------------------------------------------------------------
--
--                      GET CORRECT TYPE (private)
--
-- This is a validation check to ensure that the assignment action is of the
-- correct type. This is called from all assignment action mode functions.
-- The assignment id is returned (and not assignment action id) because
-- this is to be used in the expired latest balance check. This function thus
-- has two uses - to validate the assignment action, and give the corresponding
-- assignmment id for that action.
--
-- ------------------------------------------------------------------------------------ */
FUNCTION get_correct_type(p_assignment_action_id IN NUMBER)
--
RETURN NUMBER IS
--
	l_assignment_id	NUMBER;
--
	cursor get_corr_type (c_assignment_action_id IN NUMBER)
	is
	SELECT  /*+ ORDERED */
            paa.assignment_id
	FROM	pay_assignment_actions paa,
            pay_payroll_actions    ppa
	WHERE   paa.assignment_action_id = c_assignment_action_id
	AND	ppa.payroll_action_id = paa.payroll_action_id
	AND	ppa.action_type in ('R', 'Q', 'I', 'V', 'B');
--
BEGIN
--
	open get_corr_type(p_assignment_action_id);
	fetch get_corr_type into l_assignment_id;
	close get_corr_type;
--
RETURN l_assignment_id;
--
END get_correct_type;
--
/* ------------------------------------------------------------------------------------
--
--                      GET LATEST ACTION ID (private)
--
-- This function returns the latest assignment action ID given an assignment
-- and effective date. This is called from all Date Mode functions.
--
-- ------------------------------------------------------------------------------------ */
FUNCTION get_latest_action_id (p_assignment_id IN NUMBER,
			       p_effective_date IN DATE)
RETURN NUMBER IS
--
	l_assignment_action_id 	NUMBER;
--
	cursor get_latest_id (c_assignment_id IN NUMBER,
			      c_effective_date IN DATE)
	is
    	SELECT  /*+ ORDERED */
         	TO_NUMBER(substr(max(lpad(paa.action_sequence,15,'0')||
        	paa.assignment_action_id),16))
	FROM	pay_assignment_actions paa,
		    pay_payroll_actions    ppa
	WHERE	paa.assignment_id = c_assignment_id
	AND	ppa.payroll_action_id = paa.payroll_action_id
	AND	ppa.effective_date <= c_effective_date
	AND	ppa.action_type in ('R', 'Q', 'I', 'V', 'B');
--
BEGIN
--
	open get_latest_id(p_assignment_id, p_effective_date);
	fetch get_latest_id into l_assignment_action_id;
	close get_latest_id;
--
RETURN l_assignment_action_id;
--
END get_latest_action_id;
--
/* ------------------------------------------------------------------------------------
--
--                          BALANCE                                                  --
--
--  FASTFORMULA cover for evaluating balances based on assignment_action_id
--
-- ------------------------------------------------------------------------------------ */
FUNCTION balance(
	p_assignment_action_id	IN NUMBER,
	p_defined_balance_id    IN NUMBER) RETURN NUMBER
IS
	l_balance		NUMBER;
	l_assignment_id		NUMBER;
	l_balance_type_id	NUMBER;
	l_effective_date	DATE ;
	l_date_earned		DATE ;
	l_from_date		DATE;
	l_to_date		DATE;
	l_action_sequence	NUMBER;
	l_action_type		pay_payroll_actions.action_type%TYPE;
	l_business_group_id	NUMBER;
	l_dimension_name	pay_balance_dimensions.dimension_name%TYPE;
	l_dimension_jp_type	VARCHAR2(15);
        l_latest_value_exists   VARCHAR(2);
	--
        cursor action_context
        is
        SELECT  BAL_ASSACT.assignment_id,
                BAL_ASSACT.action_sequence,
		BACT.action_type,
                BACT.effective_date,
		BACT.date_earned,
                BACT.business_group_id
        FROM	pay_payroll_actions     BACT,
	        pay_assignment_actions  BAL_ASSACT
        WHERE   BAL_ASSACT.assignment_action_id = p_assignment_action_id
        AND     BACT.payroll_action_id = BAL_ASSACT.payroll_action_id;
	--
        cursor balance_dimension
        is
        SELECT	DB.balance_type_id,
                DIM.dimension_name
        FROM	pay_balance_dimensions  DIM,
        	pay_defined_balances    DB
        WHERE   DB.defined_balance_id = p_defined_balance_id
        AND     DIM.balance_dimension_id = DB.balance_dimension_id;
BEGIN
	--
	-- get the context of the using action
	--
 	OPEN action_context;
	FETCH action_context INTO
		l_assignment_id,
		l_action_sequence,
		l_action_type,
		l_effective_date,
		l_date_earned,
		l_business_group_id;
	CLOSE action_context;
	--
	-- from the item name determine what balance and dimension it is
	--
	OPEN balance_dimension;
	FETCH balance_dimension INTO
		l_balance_type_id,
		l_dimension_name;
	CLOSE balance_dimension;
--
  if l_dimension_name in (
    hr_jprts.g_asg_run,
    hr_jprts.g_asg_mtd_jp,
    hr_jprts.g_ast_ytd_jp,
    hr_jprts.g_asg_aug2jul_jp,
    hr_jprts.g_asg_jul2jun_jp,
    hr_jprts.g_asg_proc_ptd,
    hr_jprts.g_asg_itd,
    hr_jprts.g_payment,
    hr_jprts.g_asg_fytd2_jp
    ) then
    l_balance := pay_balance_pkg.get_value(
                   p_defined_balance_id,
                   p_assignment_action_id);
  --
  elsif l_dimension_name = hr_jprts.g_retro then
    l_balance := hr_jprts.retro_jp(
                    p_assignment_action_id,
                    l_balance_type_id);
    --
    -- This function can not call the calculation of Element dimension because it needs source_id.
    --
  --
  elsif l_dimension_name in (
    hr_jprts.g_element_itd,
    hr_jprts.g_element_ptd) then
    fnd_message.set_name('PAY', 'This dimension is invalid');
    fnd_message.raise_error;
  --
  elsif l_dimension_name = hr_jprts.g_asg_fytd_jp then
     l_from_date := hr_jprts.dimension_reset_date_userdef(
                      l_dimension_name,
                      l_date_earned,
                      'FLEX',
                      null,
                      l_business_group_id);
     l_to_date := l_date_earned;
     --
     l_balance := hr_jprts.calc_bal_date_earned(
                    l_assignment_id,
                    l_balance_type_id,
                    l_from_date,
                    l_to_date,
                    l_action_sequence);
     --
  -- User Defined Dimension
  -- pay_balance_pkg.get_value cannot be used for user defined dimension.
  -- route refer to pay_jp_balances_v(call hr_jpbal.balance this code).
  --
  -- rtrim is used for support dimension that was created before bug2597843 fix.
  --
  elsif substrb(rtrim(l_dimension_name),-8) = 'USER-REG' then
    --
    -- UTF8 support
    --
    l_dimension_jp_type := rtrim(substrb(rpad(l_dimension_name, 44), -14));
    --
    IF l_dimension_jp_type = 'EFFECTIVE_DATE' THEN
    --
      l_from_date := hr_jprts.dimension_reset_date(
                       l_dimension_name,
                       l_effective_date);
      l_to_date := l_effective_date;
    --
      l_balance := hr_jprts.calc_bal_eff_date(
                     l_assignment_id,
                     l_balance_type_id,
                     l_from_date,
                     l_to_date,
                     l_action_sequence);
    elsif l_dimension_jp_type = 'DATE_EARNED' then
    --
      l_from_date := hr_jprts.dimension_reset_date(
                       l_dimension_name,
                       l_date_earned);
      l_to_date := l_date_earned;
      --
      l_balance := hr_jprts.calc_bal_date_earned(
                     l_assignment_id,
                     l_balance_type_id,
                     l_from_date,
                     l_to_date,
                     l_action_sequence);
    end if;
  -- Specified dimension is not supported
  else
    fnd_message.set_name('PAY', 'This dimension is invalid');
    fnd_message.raise_error;
  end if;
--
	RETURN l_balance;
END balance;
--
/* ------------------------------------------------------------------------------------
--
--                                  BALANCE
--
-- FASTFORMULA cover for evaluating balances based on assignment_action_id.
-- If input parameter is item_name, this function call upper balance function.
--
-- ------------------------------------------------------------------------------------ */
FUNCTION balance(
	p_assignment_action_id	IN NUMBER,
	p_item_name		IN VARCHAR2)
RETURN NUMBER
IS
	l_balance	NUMBER;
	CURSOR csr_assact
	IS
	SELECT  /*+ ORDERED */
         	pdb.defined_balance_id
	FROM    pay_assignment_actions		paa,
      		pay_payroll_actions		ppa,
	     	ff_database_items		ffd,
    		ff_user_entities		ffu,
    		hr_organization_information	hoi,
            pay_defined_balances		pdb
	WHERE	paa.assignment_action_id=p_assignment_action_id
	AND	ppa.payroll_action_id=paa.payroll_action_id
	AND	ffd.user_name=p_item_name
	AND	ffu.user_entity_id=ffd.user_entity_id
	AND	ffu.creator_type='B'
	AND	nvl(ffu.business_group_id,ppa.business_group_id)=ppa.business_group_id
	AND	hoi.organization_id=ppa.business_group_id
	AND	hoi.org_information_context='Business Group Information'
	AND	nvl(ffu.legislation_code,hoi.org_information9)=hoi.org_information9
	AND	pdb.defined_balance_id=ffu.creator_id;
BEGIN
-- To solve gscc error.
	l_balance := 0;
--
	for l_rec in csr_assact loop
		l_balance := balance(
				p_assignment_action_id,
				l_rec.defined_balance_id);
	end loop;
--
RETURN l_balance;
END balance;
--
/* ------------------------------------------------------------------------------------
--
--                             CREATE DIMENSION
--
-- Create the user defined dimension.
-- Now end user can not Ele-level,Person-level dimension.
-- Because 'SRS_USERBAL_LEVEL' that is lookup_type in hr_lookups table
-- does not have lookup_codes(ELEMENT, PERSON).
-- So end user can not select dimension type. Only ASSIGNEMNT level.
-- (hr_jpbal.balance doesn't have the parameter of element_entry_id)
--
-- ------------------------------------------------------------------------------------ */
PROCEDURE create_dimension(
	errbuf		 	OUT NOCOPY VARCHAR2,
	retcode		 	OUT NOCOPY NUMBER,
	p_business_group_id	IN NUMBER,
	p_suffix		IN VARCHAR2,
	p_level			IN VARCHAR2,
	p_dim_date_type		IN VARCHAR2,
	p_start_dd_mm		IN VARCHAR2,
	p_frequency		IN NUMBER)
IS
	l_start_dd_mm		varchar2(5);
	l_database_item_suffix	pay_balance_dimensions.database_item_suffix%type;
	l_dimension_name 	pay_balance_dimensions.dimension_name%type;
	l_route_id		number;
	l_balance_dimension_id	number;
	l_route_text		ff_routes.text%type;
	l_dimension_type	pay_balance_dimensions.dimension_type%type;
	l_expiry_checking_level	pay_balance_dimensions.expiry_checking_level%type;
	l_expiry_checking_code	pay_balance_dimensions.expiry_checking_code%type;
	l_description		pay_balance_dimensions.description%type;
	l_request_id		number := fnd_profile.value('CONC_REQUEST_ID');
	l_rowid			rowid;
	--
	cursor csr_language_code is
		select	language_code
		from	fnd_languages
		where	installed_flag in ('B', 'I');
BEGIN
	errbuf := NULL;
	retcode := 0;
	--
	-- Check DD-MM
	--
	l_start_dd_mm := to_char(to_date(p_start_dd_mm || '-' || '2000', 'DD-MM-YYYY'), 'DD-MM');
	--
	-- Fill the dimension name
	-- Bug.2597843 Removed trailing space characters
	--
	l_database_item_suffix	:= upper('_ASG_' || '_' || p_suffix);
	l_dimension_name	:= rpad(l_database_item_suffix, 30)
				|| rpad(p_dim_date_type, 15)
				|| l_start_dd_mm
				|| ' RESET'
				|| TO_CHAR(p_frequency, '00')
				|| ' USER-REG';
	-- ---------------------------
	-- INSERT INTO FF_ROUTES    --
	-- ---------------------------
	select	ff_routes_s.nextval
	into	l_route_id
	from	dual;
	--
	select	pay_balance_dimensions_s.nextval
	into	l_balance_dimension_id
	from	dual;
	--
	l_route_text :=
'	pay_jp_balances_v TARGET,
	pay_dummy_feeds_v FEED
WHERE	TARGET.assignment_action_id = &B1
AND	TARGET.balance_type_id = &U1
AND	TARGET.balance_dimension_id = ' || to_char(l_balance_dimension_id);
	--
	insert into ff_routes(
		route_id,
		route_name,
		user_defined_flag,
		description,
		text)
	values(	l_route_id,
		'ROUTE_NAME_' || to_char(l_route_id),
		'N',
		'Route for User Defined Assignment Balance Dimension ' || l_dimension_name,
		l_route_text);
	-- -----------------------------------------
	-- INSERT INTO FF_ROUTE_CONTEXT_USAGES    --
	-- -----------------------------------------
	insert into ff_route_context_usages(
		route_id,
		context_id,
		sequence_no)
	select	l_route_id,
		context_id,
		1
	FROM	ff_contexts
	WHERE	context_name = 'ASSIGNMENT_ACTION_ID';
	-- ------------------------------------
	-- INSERT INTO FF_ROUTE_PARAMETER    --
	-- ------------------------------------
	insert into ff_route_parameters(
		route_parameter_id,
		route_id,
		sequence_no,
		parameter_name,
		data_type)
	values(	ff_route_parameters_s.nextval,
		l_route_id,
		1,
		'Balance Type Id',
		'N');
	-- -----------------------------
	-- CREATION DIMENSION NAME    --
	-- -----------------------------
	-- Bug.2597843
	-- DATE_EARNED based dimension is not supported fully,
	-- so latest balance should not be created.
	-- Dimension type is set to 'N'(Not fed, Not stored).
	-- This solution of dimension_type = 'N' for DATE_EARNED based dimension
	-- is rejected from the perspective of performance.
	-- Yes, there's limitation which causes inconsistency between latest balance
	-- and sum of result values by route, but now, we are going to leave
	-- this DATE_EARNED dimension bugs.
	--
	-- If we are going to support dimension_type = 'F'(Fed, Not Stored) for
	-- DATE_EARNED dimension, feed_checking_type needs to be "F"
	-- which means feed_checking_code is called for every run result
	-- to check feed information as of DATE_EARNED, not EFFECTIVE_DATE
	-- which is default behavior. This will cause serere performance issue.
	--
	l_dimension_type	:= 'A';
	l_expiry_checking_level	:= 'P';
	l_expiry_checking_code	:= 'hr_jpbal.check_expiry';
	l_description		:= hr_jp_standard_pkg.get_message('PAY', 'PAY_JP_USER_DEF_ASG_DIM_DESC', 'US', 'REQUEST_ID', to_char(l_request_id));
	--
	insert into pay_balance_dimensions(
		balance_dimension_id,
		business_group_id,
		legislation_code,
		route_id,
		database_item_suffix,
		dimension_name,
		dimension_type,
		description,
		legislation_subgroup,
		payments_flag,
		expiry_checking_level,
		expiry_checking_code,
		feed_checking_type,
		feed_checking_code,
		-- for Run Balances
		SAVE_RUN_BALANCE_ENABLED,
		DIMENSION_LEVEL,
		PERIOD_TYPE,
		START_DATE_CODE,
		-- for Group Level dimension (run balance compliant)
		ASG_ACTION_BALANCE_DIM_ID,
		-- for hrdyndbi DBI Generator (run balance compliant)
		DATABASE_ITEM_FUNCTION)
	values(	l_balance_dimension_id,
		p_business_group_id,
		null,
		l_route_id,
		l_database_item_suffix,
		l_dimension_name,
		l_dimension_type,
		l_description,
		null,
		'N',
		l_expiry_checking_level,
		l_expiry_checking_code,
		null,
		null,
		null,
		null,
		null,
		null,
		null,
		null);
	--
	for l_rec in csr_language_code loop
		l_database_item_suffix	:= hr_jp_standard_pkg.get_message('PAY', 'PAY_JP_USER_DEF_ASG_DIM_SUFFIX', l_rec.language_code, 'SUFFIX', p_suffix);
		l_description		:= hr_jp_standard_pkg.get_message('PAY', 'PAY_JP_USER_DEF_ASG_DIM_DESC', l_rec.language_code, 'REQUEST_ID', to_char(l_request_id));
		--
		begin
			select	rowid
			into	l_rowid
			from	pay_balance_dimensions_tl
			where	balance_dimension_id = l_balance_dimension_id
			and	language = l_rec.language_code
			for update nowait;
			--
			update	pay_balance_dimensions_tl
			set	dimension_name = l_database_item_suffix,
				database_item_suffix = l_database_item_suffix,
				description = l_description
			where	rowid = l_rowid;
		exception
			when no_data_found then
				insert into pay_balance_dimensions_tl(
					BALANCE_DIMENSION_ID,
					LANGUAGE,
					SOURCE_LANG,
					DIMENSION_NAME,
					DATABASE_ITEM_SUFFIX,
					DESCRIPTION)
				values(	l_balance_dimension_id,
					l_rec.language_code,
					l_rec.language_code,
					l_database_item_suffix,
					l_database_item_suffix,
					l_description);
		end;
	end loop;
END create_dimension;
--
/* ------------------------------------------------------------------------------------
--
--                          CALC_BALANCE_DATE                                        --
--
-- This is the function for calculating assignment processing
-- of any dimension in date mode
--
-- ------------------------------------------------------------------------------------ */
--
-- This function only support USER-REG dimension.
--
FUNCTION calc_balance_date(
         p_assignment_id	IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE,
	 p_dimension_name	IN VARCHAR2)
RETURN NUMBER
IS
--
        l_assignment_action_id      NUMBER;
        l_assact_id_for_effect      NUMBER;
        l_assact_id_for_earned      NUMBER;
        l_balance                   NUMBER;
	l_dimension_jp_type	VARCHAR2(15);
	l_last_effective_date	DATE;
	l_last_date_earned	DATE;
	l_frequency		NUMBER;
	l_start_dd_mm		VARCHAR2(6);
	l_next_start_date	DATE;
	l_defined_balance_id	NUMBER;
--
/* -- c_effective_date <= session_date */
	cursor get_latest_id_for_earned (
			c_assignment_id		IN NUMBER,
	      		c_effective_date	IN DATE)
	is
    	SELECT	TO_NUMBER(substr(max(lpad(ASSACT.action_sequence,15,'0')||
        	ASSACT.assignment_action_id),16))
	FROM	pay_payroll_actions    PACT,
		pay_assignment_actions ASSACT
	WHERE	ASSACT.assignment_id = c_assignment_id
	AND	PACT.payroll_action_id = ASSACT.payroll_action_id
	AND	PACT.date_earned <= c_effective_date
	AND	PACT.action_type in ('R', 'Q', 'I', 'V', 'B');
--
	cursor last_date (c_assignment_action_id IN NUMBER)
	is
	SELECT	ppa.effective_date	effect_date,
		ppa.date_earned		earned_date
	FROM	pay_payroll_actions	ppa,
		pay_assignment_actions	paa
	WHERE	paa.assignment_action_id = c_assignment_action_id
	AND	paa.payroll_action_id = ppa.payroll_action_id;
--
	l_last_date	last_date%ROWTYPE;
--
BEGIN
--
	l_defined_balance_id := dimension_relevant(p_balance_type_id, p_dimension_name);
	/* -- check relevant dimension. if it is not so(defined_balance_id is null), return null */
--
	if l_defined_balance_id is not null then
--
		l_assact_id_for_effect := get_latest_action_id(	p_assignment_id,
                	                                        p_effective_date);
--
		/* -- p_effective_date <= session_date */
		OPEN get_latest_id_for_earned(	p_assignment_id,
		       				p_effective_date);
		FETCH get_latest_id_for_earned INTO l_assact_id_for_earned;
		CLOSE get_latest_id_for_earned;
--
-- Fix bug#3051183: Corrected to support UTF8.
--
		l_dimension_jp_type := RTRIM(SUBSTRB(RPAD(p_dimension_name, 44), -14));
--
		IF l_dimension_jp_type = 'EFFECTIVE_DATE' THEN
--
			IF l_assact_id_for_effect is null THEN
				l_balance := 0;
			ELSE
--
				OPEN last_date(l_assact_id_for_effect);
				FETCH last_date INTO l_last_date;
				l_last_effective_date := l_last_date.effect_date;
				CLOSE last_date;
--
				l_assignment_action_id := l_assact_id_for_effect;
				l_next_start_date := hr_jprts.dimension_reset_last_date(p_dimension_name,l_last_effective_date) + 1;
--
				/* -- p_effective_date <= session_date */
				if l_next_start_date <= p_effective_date then
					l_balance := 0;
				else
					l_balance := balance(	l_assignment_action_id,
								l_defined_balance_id);
				end if;
			END IF;
--
		ELSIF l_dimension_jp_type = 'DATE_EARNED' then
--
			IF l_assact_id_for_earned is null THEN
				l_balance := 0;
			ELSE
--
				OPEN last_date(l_assact_id_for_earned);
				FETCH last_date INTO l_last_date;
				l_last_date_earned := l_last_date.earned_date;
				CLOSE last_date;
--
				l_assignment_action_id := l_assact_id_for_earned;
				l_next_start_date := hr_jprts.dimension_reset_last_date(p_dimension_name,l_last_date_earned) + 1;
--
				/* -- p_effective_date <= session_date */
				if l_next_start_date <= p_effective_date then
					l_balance := 0;
		       		else
					l_balance := balance(	l_assignment_action_id,
								l_defined_balance_id);
				end if;
			END IF;
		END IF;
	else l_balance := null;
	end if;
--
RETURN l_balance;
END calc_balance_date;
--
/* ------------------------------------------------------------------------------------
--
--                          CALC_ASG_RUN_ACTION                                      --
--
-- This is the function for calculating assignment runs in
-- assignment action mode
--
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_asg_run_action(
         p_assignment_action_id IN NUMBER,
         p_balance_type_id      IN NUMBER)
RETURN NUMBER
IS
--
	l_assignment_action_id      NUMBER;
	l_balance                   NUMBER;
	l_assignment_id             NUMBER;
--
BEGIN
--
	l_assignment_id := get_correct_type(p_assignment_action_id);
	IF l_assignment_id is null THEN
--
/* --  The assignment action is not a payroll or quickpay type, so return null */
--
		l_balance := null;
	ELSE
--
		l_balance := calc_asg_run(
                                 p_assignment_action_id => p_assignment_action_id,
                                 p_balance_type_id      => p_balance_type_id,
				 p_assignment_id	=> l_assignment_id);
	END IF;
--
RETURN l_balance;
END calc_asg_run_action;
--
/* ------------------------------------------------------------------------------------
--
--                          CALC_ASG_RUN_DATE                                        --
--
-- This is the function for calculating assignment run in
-- DATE MODE
--
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_asg_run_date(
         p_assignment_id	IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER
IS
--
	l_assignment_action_id	NUMBER;
	l_balance		NUMBER;
	l_end_date		DATE;
	l_defined_balance_id	NUMBER;
--
	cursor expired_time_period(c_assignment_action_id IN NUMBER)
	is
	SELECT	/*+ ORDERED */
            ptp.end_date
	FROM	pay_assignment_actions	paa,
       		pay_payroll_actions	ppa,
            per_time_periods	ptp
	WHERE	paa.assignment_action_id = c_assignment_action_id
	AND	ppa.payroll_action_id = paa.payroll_action_id
	AND	ptp.time_period_id = ppa.time_period_id;
--
BEGIN
--
	l_defined_balance_id := dimension_relevant(p_balance_type_id, hr_jprts.g_asg_run);
/* -- check relevant dimension. if it is not so(defined_balance_id is null), return null */
	if l_defined_balance_id is not null then
--
		l_assignment_action_id := get_latest_action_id(
							p_assignment_id,
							p_effective_date);
		IF l_assignment_action_id is null THEN
			l_balance := 0;
		ELSE
			OPEN expired_time_period(l_assignment_action_id);
			FETCH expired_time_period INTO l_end_date;
			CLOSE expired_time_period;
--
			if l_end_date < p_effective_date then
				l_balance := 0;
			else
			l_balance := calc_asg_run(
	                             p_assignment_action_id => l_assignment_action_id,
			 	     p_balance_type_id      => p_balance_type_id,
	                             p_assignment_id        => p_assignment_id);
			end if;
	    	END IF;
	else l_balance := null;
	end if;
--
RETURN l_balance;
END calc_asg_run_date;
--
/* ------------------------------------------------------------------------------------
--
--                          CALC_ASG_RUN                                             --
--
--      calculate balances for Assignment Run
--
-- ------------------------------------------------------------------------------------ */
/* -- Run
--    the simplest dimension retrieves run values where the context
--    is this assignment action and this balance feed. Balance is the
--    specified input value. The related payroll action determines the
--    date effectivity of the feeds */
FUNCTION calc_asg_run(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
	p_assignment_id		IN NUMBER)
RETURN NUMBER
IS
--
--
        l_balance               NUMBER;
	l_defined_bal_id	NUMBER;
--
BEGIN
--
/* --Do we need to work out nocopy a value for this dimension/balance combination.
--Used dimension_name in dimension_relevant because of unique column */
--
	l_defined_bal_id := dimension_relevant(p_balance_type_id, hr_jprts.g_asg_run);
	if l_defined_bal_id is not null then
--
/* -- Run balances will never have a value in pay_assignment_latest_balances
-- table, as they are only used for the duration of the payroll run.
-- We therefore don't need to check the table, time can be saved by
-- simply calling the route code, which is incidentally the most
-- performant (ie simple) route. */
--
    l_balance := pay_balance_pkg.get_value(
                   l_defined_bal_id,
                   p_assignment_action_id);
--
	else l_balance := null;
	end if;
--
RETURN l_balance;
--
END calc_asg_run;
--
/* ------------------------------------------------------------------------------------
--
--                          CALC_ASG_PROC_PTD_ACTION
--
-- This is the function for calculating assignment processing
-- period to date in assignment action mode
--
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_asg_proc_ptd_action(
         p_assignment_action_id IN NUMBER,
         p_balance_type_id      IN NUMBER)
RETURN NUMBER
IS
--
	l_assignment_action_id      NUMBER;
	l_balance                   NUMBER;
	l_assignment_id             NUMBER;
--
BEGIN
--
	l_assignment_id := get_correct_type(p_assignment_action_id);
	IF l_assignment_id is null THEN
--
/* --  The assignment action is not a payroll or quickpay type, so return null */
--
		l_balance := null;
	ELSE
--
		l_balance := calc_asg_proc_ptd(
                                 p_assignment_action_id => p_assignment_action_id,
                                 p_balance_type_id      => p_balance_type_id,
				 p_assignment_id	=> l_assignment_id);
	END IF;
--
RETURN l_balance;
END calc_asg_proc_ptd_action;
--
/* ------------------------------------------------------------------------------------
--
--                          CALC_ASG_PROC_PTD_DATE
--
-- This is the function for calculating assignment processing
-- period to date in date mode
--
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_asg_proc_ptd_date(
         p_assignment_id        IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER
IS
--
	l_assignment_action_id  NUMBER;
	l_balance               NUMBER;
	l_end_date              DATE;
	l_defined_balance_id	NUMBER;
--
/* -- Has the processing time period expired */
--
	cursor expired_time_period(c_assignment_action_id IN NUMBER)
	is
	SELECT	/*+ ORDERED */
            ptp.end_date
	FROM	pay_assignment_actions	paa,
     		pay_payroll_actions	ppa,
            per_time_periods	ptp
	WHERE	paa.assignment_action_id = c_assignment_action_id
	AND	ppa.payroll_action_id = paa.payroll_action_id
	AND	ptp.time_period_id = ppa.time_period_id;
--
BEGIN
--
	l_defined_balance_id := dimension_relevant(p_balance_type_id, hr_jprts.g_asg_proc_ptd);
	/* -- check relevant dimension. if it is not so(defined_balance_id is null), return null */
--
	if l_defined_balance_id is not null then
--
		l_assignment_action_id := get_latest_action_id(	p_assignment_id,
	                                                   	p_effective_date);
		IF l_assignment_action_id is null THEN
			l_balance := 0;
		ELSE
			OPEN expired_time_period(l_assignment_action_id);
			FETCH expired_time_period INTO l_end_date;
			CLOSE expired_time_period;
--
			if l_end_date < p_effective_date then
				l_balance := 0;
			else
				l_balance := calc_asg_proc_ptd(
	                             p_assignment_action_id => l_assignment_action_id,
	                             p_balance_type_id      => p_balance_type_id,
	                             p_assignment_id        => p_assignment_id);
			end if;
		END IF;
	else l_balance := null;
	end if;
--
RETURN l_balance;
END calc_asg_proc_ptd_date;
--
/* ------------------------------------------------------------------------------------
--
--                          CALC_ASG_PROC_PTD                                        --
--
-- calculate balances for Assignment process period to date
--
-- ------------------------------------------------------------------------------------ */
/* -- This dimension is the total for an assignment within the processing
-- period of his current payroll, OR if the assignment has transferred
-- payroll within the current processing period, it is the total since
-- he joined the current payroll.
--
-- This dimension should be used for the period dimension of balances
-- which are reset to zero on transferring payroll. */
--
FUNCTION calc_asg_proc_ptd(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
	p_assignment_id		IN NUMBER)
--
RETURN NUMBER
IS
--
	l_expired_balance	NUMBER;
	l_assignment_action_id  NUMBER;
        l_balance               NUMBER;
        l_latest_value_exists   VARCHAR2(2);
	l_action_eff_date	DATE;
	l_end_date		DATE;
     	l_defined_bal_id	NUMBER;
--
BEGIN
--
	l_defined_bal_id := dimension_relevant(p_balance_type_id, hr_jprts.g_asg_proc_ptd);
--
	if l_defined_bal_id is not null then
    l_balance := pay_balance_pkg.get_value(
                   l_defined_bal_id,
                   p_assignment_action_id);
--
  else
    l_balance := null;
  end if;
--
RETURN l_balance;
END calc_asg_proc_ptd;
--
/* ------------------------------------------------------------------------------------
--
--                          CALC_ASG_MTD_JP_ACTION                                   --
--
-- This is the function for calculating JP specific assignment processing
-- month to date in assignment action mode
--
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_asg_mtd_jp_action(
		p_assignment_action_id	IN NUMBER,
		p_balance_type_id	IN NUMBER)
--		p_dimension_name	IN VARCHAR2)
RETURN NUMBER
IS
--
	l_assignment_action_id      NUMBER;
	l_balance                   NUMBER;
	l_assignment_id             NUMBER;
--
BEGIN
--
	l_assignment_id := get_correct_type(p_assignment_action_id);
	IF l_assignment_id is null THEN
--
/* --  The assignment action is not a payroll or quickpay type, so return null */
--
		l_balance := null;
	ELSE
--
		l_balance := calc_asg_mtd_jp(
                                 p_assignment_action_id => p_assignment_action_id,
                                 p_balance_type_id      => p_balance_type_id,
				 p_assignment_id	=> l_assignment_id);
--				 p_dimension_name	=> p_dimension_name);
	END IF;
--
RETURN l_balance;
END calc_asg_mtd_jp_action;
--
/* ------------------------------------------------------------------------------------
--
--                          CALC_ASG_MTD_JP_DATE                                     --
--
-- This is the function for calculating JP specific assignment processing
-- month to date in date mode
--
-- ------------------------------------------------------------------------------------ */
--
FUNCTION calc_asg_mtd_jp_date(
	p_assignment_id		IN NUMBER,
	p_balance_type_id	IN NUMBER,
	p_effective_date	IN DATE)
--	p_dimension_name	IN VARCHAR2)
RETURN NUMBER
IS
--
	l_assignment_action_id	NUMBER;
	l_balance		NUMBER;
	l_last_start_date	DATE;
	l_defined_balance_id	NUMBER;
--
	cursor last_start_date(c_assignment_action_id IN NUMBER)
	is
	SELECT	/*+ ORDERED */
            trunc(ppa.effective_date,'MM')
	FROM    pay_assignment_actions	paa,
            pay_payroll_actions	ppa
	WHERE	paa.assignment_action_id = c_assignment_action_id
	AND	    ppa.payroll_action_id = paa.payroll_action_id;
--
BEGIN
--
	l_defined_balance_id := dimension_relevant(	p_balance_type_id,
							hr_jprts.g_asg_mtd_jp);
	/* -- check relevant dimension. if it is not so(defined_balance_id is null), return null */
--
	if l_defined_balance_id is not null then
--
		l_assignment_action_id := get_latest_action_id(
							p_assignment_id,
							p_effective_date);
		IF l_assignment_action_id is null THEN
			l_balance := 0;
		ELSE
			OPEN last_start_date(l_assignment_action_id);
			FETCH last_start_date INTO l_last_start_date;
			CLOSE last_start_date;
--
			if add_months(l_last_start_date,1) <= p_effective_date then
				l_balance := 0;
			else
			l_balance := calc_asg_mtd_jp(
	                                 p_assignment_action_id => l_assignment_action_id,
	                                 p_balance_type_id      => p_balance_type_id,
					 p_assignment_id	=> p_assignment_id);
--					 P_dimension_name	=> p_dimension_name);
			end if;
		END IF;
	else
		l_balance := null;
	end if;
--
RETURN l_balance;
END calc_asg_mtd_jp_date;
--
/* ------------------------------------------------------------------------------------
--
--                          CALC_ASG_MTD_JP                                          --
--
-- Calculate balances for JP specific Assignment process month to date
--
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_asg_mtd_jp(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
	p_assignment_id		IN NUMBER)
--	p_dimension_name	IN VARCHAR2)
RETURN NUMBER
IS
--
--
	l_expired_balance	NUMBER;
	l_assignment_action_id  NUMBER;
        l_balance               NUMBER;
        l_latest_value_exists   VARCHAR2(2);
	l_action_eff_date	DATE;
	l_end_date		DATE;
     	l_defined_bal_id	NUMBER;
--
BEGIN
--
  l_defined_bal_id := dimension_relevant(p_balance_type_id,hr_jprts.g_asg_mtd_jp);
--
  if l_defined_bal_id is not null then
    l_balance := pay_balance_pkg.get_value(
                   l_defined_bal_id,
                   p_assignment_action_id);
--
  else
    l_balance := null;
  end if;
--
RETURN l_balance;
END calc_asg_mtd_jp;
--
/* ------------------------------------------------------------------------------------
--
--                          CALC_ASG_YTD_JP_ACTION                                   --
--
-- This is the function for calculating JP specific assignment processing
-- year to date in assignment action mode
--
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_asg_ytd_jp_action(
		p_assignment_action_id	IN NUMBER,
		p_balance_type_id	IN NUMBER)
--		p_dimension_name	IN VARCHAR2)
RETURN NUMBER
IS
--
	l_assignment_action_id      NUMBER;
	l_balance                   NUMBER;
	l_assignment_id             NUMBER;
--
BEGIN
--
	l_assignment_id := get_correct_type(p_assignment_action_id);
	IF l_assignment_id is null THEN
--
/* --  The assignment action is not a payroll or quickpay type, so return null */
--
		l_balance := null;
	ELSE
--
		l_balance := calc_asg_ytd_jp(
                                 p_assignment_action_id,
                                 p_balance_type_id,
				 l_assignment_id);
--				 p_dimension_name);
	END IF;
--
RETURN l_balance;
END calc_asg_ytd_jp_action;
--
/* ------------------------------------------------------------------------------------
--
--                          CALC_ASG_YTD_JP_DATE                                     --
--
-- This is the function for calculating JP specific assignment processing
-- year to date in date mode
--
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_asg_ytd_jp_date(
		p_assignment_id		IN NUMBER,
		p_balance_type_id	IN NUMBER,
		p_effective_date	IN DATE)
--		p_dimension_name	IN VARCHAR2)
RETURN NUMBER
IS
--
	l_assignment_action_id	NUMBER;
	l_balance		NUMBER;
	l_last_start_date	DATE;
	l_defined_balance_id	NUMBER;
--
	cursor last_start_date(c_assignment_action_id IN NUMBER)
	is
	SELECT	/*+ ORDERED */
            trunc(ppa.effective_date,'YYYY')
	FROM	pay_assignment_actions	paa,
            pay_payroll_actions	ppa
	WHERE	paa.assignment_action_id = c_assignment_action_id
	AND	    ppa.payroll_action_id = paa.payroll_action_id;
--
BEGIN
--
	l_defined_balance_id := dimension_relevant(p_balance_type_id, hr_jprts.g_ast_ytd_jp);
	/* -- check relevant dimension. if it is not so(defined_balance_id is null), return null */
--
	if l_defined_balance_id is not null then
--
		l_assignment_action_id := get_latest_action_id(p_assignment_id,
	                                                   p_effective_date);
		IF l_assignment_action_id is null THEN
			l_balance := 0;
		ELSE
			OPEN last_start_date(l_assignment_action_id);
			FETCH last_start_date INTO l_last_start_date;
			CLOSE last_start_date;
--
			if add_months(l_last_start_date,12) <= p_effective_date then
				l_balance := 0;
			else
				l_balance := calc_asg_ytd_jp(
	                                 l_assignment_action_id,
	                                 p_balance_type_id,
					 p_assignment_id);
--					 p_dimension_name);
			end if;
		END IF;
	else
		l_balance := null;
	end if;
--
RETURN l_balance;
END calc_asg_ytd_jp_date;
--
/* ------------------------------------------------------------------------------------
--
--                          CALC_ASG_YTD_JP                                          --
--
-- Calculate balances for JP specific Assignment process year to date
--
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_asg_ytd_jp(
	p_assignment_action_id  IN NUMBER,
	p_balance_type_id       IN NUMBER,
	p_assignment_id		IN NUMBER)
--	p_dimension_name	IN VARCHAR2)
RETURN NUMBER
IS
--
	l_expired_balance	NUMBER;
	l_assignment_action_id  NUMBER;
        l_balance               NUMBER;
        l_latest_value_exists   VARCHAR2(2);
	l_action_eff_date	DATE;
	l_end_date		DATE;
     	l_defined_bal_id	NUMBER;
--
BEGIN
--
  l_defined_bal_id := dimension_relevant(p_balance_type_id, hr_jprts.g_ast_ytd_jp);
--
  if l_defined_bal_id is not null then
    l_balance := pay_balance_pkg.get_value(
                   l_defined_bal_id,
                   p_assignment_action_id);
--
  else
    l_balance := null;
  end if;
--
RETURN l_balance;
END calc_asg_ytd_jp;
--
/* ------------------------------------------------------------------------------------
--
--                          CALC_ASG_FYTD_JP_ACTION                                  --
--
-- This is the function for calculating JP specific assignment processing
-- Financial year to date in assignment action mode
--
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_asg_fytd_jp_action(
	p_assignment_action_id	IN NUMBER,
	p_balance_type_id	IN NUMBER)
--	p_dimension_name	IN VARCHAR2)
RETURN NUMBER
IS
--
	l_assignment_action_id      NUMBER;
	l_balance                   NUMBER;
	l_assignment_id             NUMBER;
--
BEGIN
--
	l_assignment_id := get_correct_type(p_assignment_action_id);
	IF l_assignment_id is null THEN
--
/* --  The assignment action is not a payroll or quickpay type, so return null */
--
		l_balance := null;
	ELSE
--
		l_balance := calc_asg_fytd_jp(
                                 p_assignment_action_id => p_assignment_action_id,
                                 p_balance_type_id      => p_balance_type_id,
				 p_assignment_id	=> l_assignment_id);
--				 p_dimension_name	=> p_dimension_name);
	END IF;
--
RETURN l_balance;
END calc_asg_fytd_jp_action;
--
/* ------------------------------------------------------------------------------------
--
--                          CALC_ASG_FYTD_JP_DATE                                    --
--
-- This is the function for calculating JP specific assignment processing
-- Financial year to date in date mode
--
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_asg_fytd_jp_date(
		p_assignment_id 	IN NUMBER,
		p_balance_type_id      IN NUMBER,
		p_effective_date       IN DATE)
--		p_dimension_name	IN VARCHAR2)
RETURN NUMBER
IS
--
	l_assignment_action_id      NUMBER;
	l_balance                   NUMBER;
	l_last_start_date		DATE;
	l_date_earned		DATE;
	l_defined_balance_id	NUMBER;
--
	cursor last_start_date(c_assignment_action_id IN NUMBER)
	is
	SELECT  /*+ ORDERED */
          	add_months(nvl(FND_DATE.CANONICAL_TO_DATE(HROG.org_information11),trunc(PACT.date_earned,'YYYY')),
		floor(months_between(PACT.date_earned,nvl(FND_DATE.CANONICAL_TO_DATE(HROG.org_information11),
		trunc(PACT.date_earned,'YYYY')))/12)*12)	last_start_date
	FROM    pay_assignment_actions		ASSACT,
    		pay_payroll_actions		PACT,
        	hr_organization_information	HROG
	WHERE	ASSACT.assignment_action_id = c_assignment_action_id
	AND	PACT.payroll_action_id = ASSACT.payroll_action_id
	AND	HROG.organization_id = PACT.business_group_id
	AND	HROG.org_information_context = 'Business Group Information';
--
	cursor get_latest_id (c_assignment_id IN NUMBER,
			      c_effective_date IN DATE)
	is
    	SELECT  /*+ ORDERED */
        	TO_NUMBER(substr(max(lpad(ASSACT.action_sequence,15,'0')||
        	ASSACT.assignment_action_id),16))
	FROM    pay_assignment_actions ASSACT,
           	pay_payroll_actions    PACT
	WHERE	ASSACT.assignment_id = c_assignment_id
	AND	PACT.payroll_action_id = ASSACT.payroll_action_id
	AND	PACT.date_earned <= c_effective_date
	AND	PACT.action_type in ('R', 'Q', 'I', 'V', 'B');
--
BEGIN
--
	l_defined_balance_id := dimension_relevant(p_balance_type_id, hr_jprts.g_asg_fytd_jp);
	/* -- check relevant dimension. if it is not so(defined_balance_id is null), return null */
--
	if l_defined_balance_id is not null then
--
		/* -- p_effective_date <= session_date */
		OPEN get_latest_id(	p_assignment_id,
	       				p_effective_date);
		FETCH get_latest_id INTO l_assignment_action_id;
		CLOSE get_latest_id;
--
		IF l_assignment_action_id is null THEN
			l_balance := 0;
		ELSE
			OPEN last_start_date(l_assignment_action_id);
			FETCH last_start_date INTO l_last_start_date;
			CLOSE last_start_date;
--
		/* -- p_effective_date <= session_date */
			if add_months(l_last_start_date,12) <= p_effective_date then
				l_balance := 0;
			else
				l_balance := calc_asg_fytd_jp(
		                                 p_assignment_action_id => l_assignment_action_id,
		                                 p_balance_type_id      => p_balance_type_id,
						 p_assignment_id	=> p_assignment_id);
--						 p_dimension_name	=> p_dimension_name);
			end if;
		END IF;
	else
		l_balance := null;
	end if;
--
RETURN l_balance;
END calc_asg_fytd_jp_date;
--
/* ------------------------------------------------------------------------------------
--
--                          CALC_ASG_FYTD_JP                                         --
--
-- Calculate balances for JP specific Assignment process financial year to date
--
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_asg_fytd_jp(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
	p_assignment_id		IN NUMBER)
--	p_dimension_name	IN VARCHAR2)
RETURN NUMBER
IS
--
	l_balance               NUMBER;
	l_defined_bal_id	NUMBER;
--
BEGIN
--
/* --Do we need to work out nocopy a value for this dimension/balance combination.
--Used dimension_name in dimension_relevant because of unique column */
--
	l_defined_bal_id := dimension_relevant(p_balance_type_id, hr_jprts.g_asg_fytd_jp);
	if l_defined_bal_id is not null then
--
/* -- This balances will never have a value in pay_assignment_latest_balances
-- table, as they are only used for the duration of the payroll run.
-- We therefore don't need to check the table, time can be saved by
-- simply calling the route code, which is incidentally the most
-- performant (ie simple) route. */
--
   -- Remain hr_jprts.asg_fytd_jp function since better than
   -- using dimension_reset_date_userdef/calc_bal_date_earned
   --
		l_balance := hr_jprts.asg_fytd_jp(
				p_assignment_action_id,
				p_balance_type_id);
--
	else
		l_balance := null;
	end if;
--
RETURN l_balance;
END calc_asg_fytd_jp;
--
--
/* ------------------------------------------------------------------------------------
--
--                          CALC_ASG_FYTD2_JP_ACTION                                  --
--
-- This is the function for calculating JP specific assignment processing
-- Business year to date in assignment action mode
--
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_asg_fytd2_jp_action(
  p_assignment_action_id IN NUMBER,
  p_balance_type_id      IN NUMBER)
RETURN NUMBER
IS
--
  l_assignment_action_id      NUMBER;
  l_balance                   NUMBER;
  l_assignment_id             NUMBER;
--
BEGIN
--
  l_assignment_id := get_correct_type(p_assignment_action_id);
--
  IF l_assignment_id is null THEN
--
/* --  The assignment action is not a payroll or quickpay type, so return null */
--
      l_balance := null;
  ELSE
--
    l_balance := calc_asg_fytd2_jp(
                   p_assignment_action_id => p_assignment_action_id,
                   p_balance_type_id      => p_balance_type_id,
                   p_assignment_id        => l_assignment_id);
  END IF;
--
RETURN l_balance;
END calc_asg_fytd2_jp_action;
--
/* ------------------------------------------------------------------------------------
--
--                          CALC_ASG_FYTD_JP2_DATE                                    --
--
-- This is the function for calculating JP specific assignment processing
-- Business year to date in date mode
--
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_asg_fytd2_jp_date(
           p_assignment_id 	 IN NUMBER,
           p_balance_type_id IN NUMBER,
           p_effective_date  IN DATE)
RETURN NUMBER
IS
--
  l_assignment_action_id      NUMBER;
  l_balance                   NUMBER;
  l_last_start_date		DATE;
  l_effective_date		DATE;
  l_defined_balance_id	NUMBER;
--
  cursor last_start_date(c_assignment_action_id IN NUMBER)
  is
  SELECT  /*+ ORDERED */
          add_months(nvl(FND_DATE.CANONICAL_TO_DATE(HROG.org_information11),trunc(PACT.effective_date,'YYYY')),
            floor(months_between(PACT.effective_date,nvl(FND_DATE.CANONICAL_TO_DATE(HROG.org_information11),
            trunc(PACT.effective_date,'YYYY')))/12)*12)	last_start_date
  FROM    pay_assignment_actions      ASSACT,
          pay_payroll_actions         PACT,
          hr_organization_information HROG
  WHERE   ASSACT.assignment_action_id = c_assignment_action_id
  AND     PACT.payroll_action_id = ASSACT.payroll_action_id
  AND     HROG.organization_id = PACT.business_group_id
  AND     HROG.org_information_context = 'Business Group Information';
--
  cursor get_latest_id (
           c_assignment_id IN NUMBER,
           c_effective_date IN DATE)
  is
  SELECT  /*+ ORDERED */
          TO_NUMBER(substr(max(lpad(ASSACT.action_sequence,15,'0')||
          ASSACT.assignment_action_id),16))
  FROM    pay_assignment_actions ASSACT,
          pay_payroll_actions    PACT
  WHERE   ASSACT.assignment_id = c_assignment_id
  AND     PACT.payroll_action_id = ASSACT.payroll_action_id
  AND     PACT.effective_date <= c_effective_date
  AND     PACT.action_type in ('R', 'Q', 'I', 'V', 'B');
--
BEGIN
--
  l_defined_balance_id := dimension_relevant(p_balance_type_id, hr_jprts.g_asg_fytd2_jp);
  /* -- check relevant dimension. if it is not so(defined_balance_id is null), return null */
--
  if l_defined_balance_id is not null then
--
    /* -- p_effective_date <= session_date */
    OPEN get_latest_id(
           p_assignment_id,
           p_effective_date);
    FETCH get_latest_id INTO l_assignment_action_id;
    CLOSE get_latest_id;
--
    IF l_assignment_action_id is null THEN
      l_balance := 0;
    ELSE
      OPEN last_start_date(l_assignment_action_id);
      FETCH last_start_date INTO l_last_start_date;
      CLOSE last_start_date;
--
      /* -- p_effective_date <= session_date */
      if add_months(l_last_start_date,12) <= p_effective_date then
        l_balance := 0;
      else
        l_balance := calc_asg_fytd2_jp(
                       p_assignment_action_id => l_assignment_action_id,
                       p_balance_type_id      => p_balance_type_id,
                       p_assignment_id	=> p_assignment_id);
      end if;
    END IF;
  else
    l_balance := null;
  end if;
--
RETURN l_balance;
END calc_asg_fytd2_jp_date;
--
/* ------------------------------------------------------------------------------------
--
--                          CALC_ASG_FYTD2_JP                                         --
--
-- Calculate balances for JP specific Assignment process financial year to date
--
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_asg_fytd2_jp(
  p_assignment_action_id IN NUMBER,
  p_balance_type_id IN NUMBER,
  p_assignment_id IN NUMBER)
RETURN NUMBER
IS
--
  l_balance  NUMBER;
  l_defined_bal_id  NUMBER;
--
BEGIN
--
  l_defined_bal_id := dimension_relevant(p_balance_type_id, hr_jprts.g_asg_fytd2_jp);
--
  if l_defined_bal_id is not null then
--
    l_balance := pay_balance_pkg.get_value(
                   l_defined_bal_id,
                   p_assignment_action_id);
--
  else
    l_balance := null;
  end if;
--
RETURN l_balance;
END calc_asg_fytd2_jp;
--
/* ------------------------------------------------------------------------------------
--
--                          CALC_ASG_APR2MAR_JP_ACTION
--
-- This is the function for calculating JP specific assignment process
-- between Apr and Mar in assignment action mode
--
-- ------------------------------------------------------------------------------------ */
function calc_asg_apr2mar_jp_action(
  p_assignment_action_id in number,
  p_balance_type_id      in number)
return number
is
--
  l_assignment_action_id number;
  l_balance              number;
  l_assignment_id        number;
--
begin
--
  l_assignment_id := get_correct_type(p_assignment_action_id);
--
  if l_assignment_id is null then
  --
    l_balance := null;
  --
	else
  --
    l_balance := calc_asg_apr2mar_jp(
                   p_assignment_action_id => p_assignment_action_id,
                   p_balance_type_id      => p_balance_type_id,
                   p_assignment_id        => l_assignment_id);
  --
	end if;
--
return l_balance;
end calc_asg_apr2mar_jp_action;
--
/* ------------------------------------------------------------------------------------
--
--                          CALC_ASG_APR2MAR_JP_DATE
--
-- This is the function for calculating JP specific assignment process
-- between Apr and Mar in date mode
--
-- ------------------------------------------------------------------------------------ */
function calc_asg_apr2mar_jp_date(
  p_assignment_id   in number,
  p_balance_type_id in number,
  p_effective_date  in date)
return number
is
--
  l_assignment_action_id number;
  l_balance              number;
  l_last_start_date      date;
  l_defined_balance_id   number;
--
  cursor last_start_date(c_assignment_action_id in number)
  is
  select /*+ ORDERED */
         add_months(trunc(add_months(ppa.effective_date,9),'YYYY'),-9)
	from   pay_assignment_actions	paa,
         pay_payroll_actions	ppa
	where  paa.assignment_action_id = c_assignment_action_id
	and    ppa.payroll_action_id = paa.payroll_action_id;
--
begin
--
  l_defined_balance_id := dimension_relevant(p_balance_type_id, pyjpexc.c_asg_aprtd);
  --
  if l_defined_balance_id is not null then
  --
    l_assignment_action_id := get_latest_action_id(
                                p_assignment_id,
                                p_effective_date);
  --
    if l_assignment_action_id is null then
      l_balance := 0;
		else
    --
      open last_start_date(l_assignment_action_id);
      fetch last_start_date into l_last_start_date;
      close last_start_date;
    --
      if add_months(l_last_start_date,12) <= p_effective_date then
        l_balance := 0;
      else
      --
        l_balance := calc_asg_apr2mar_jp(
                       p_assignment_action_id => l_assignment_action_id,
                       p_balance_type_id      => p_balance_type_id,
                       p_assignment_id        => p_assignment_id);
      --
      end if;
    --
		end if;
  --
	else
  --
    l_balance := null;
  --
  end if;
--
return l_balance;
end calc_asg_apr2mar_jp_date;
--
/* ------------------------------------------------------------------------------------
---
--
--                          CALC_ASG_APR2MAR_JP                                      --
--
-- Calculate balances for JP specific Assignment process between Apr and Mar
--
-- ------------------------------------------------------------------------------------ */
function calc_asg_apr2mar_jp(
  p_assignment_action_id in number,
  p_balance_type_id      in number,
  p_assignment_id        in number)
return number
is
--
  l_expired_balance      number;
  l_assignment_action_id number;
  l_balance              number;
  l_latest_value_exists  varchar2(2);
  l_action_eff_date      date;
  l_end_date             date;
  l_defined_bal_id       number;
--
begin
--
  l_defined_bal_id := dimension_relevant(p_balance_type_id, pyjpexc.c_asg_aprtd);
--
  if l_defined_bal_id is not null then
  --
    l_balance := pay_balance_pkg.get_value(
                   l_defined_bal_id,
                   p_assignment_action_id);
  --
  else
    l_balance := null;
  end if;
--
return l_balance;
end calc_asg_apr2mar_jp;
--
/* ------------------------------------------------------------------------------------
--
--                          CALC_ASG_AUG2JUL_JP_ACTION                               --
--
-- This is the function for calculating JP specific assignment process
-- between Jan and Aug in assignment action mode
--
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_asg_aug2jul_jp_action(
         p_assignment_action_id IN NUMBER,
         p_balance_type_id      IN NUMBER)
--	p_dimension_name	IN VARCHAR2)
RETURN NUMBER
IS
--
	l_assignment_action_id      NUMBER;
	l_balance                   NUMBER;
	l_assignment_id             NUMBER;
--
BEGIN
--
	l_assignment_id := get_correct_type(p_assignment_action_id);
	IF l_assignment_id is null THEN
--
/* --  The assignment action is not a payroll or quickpay type, so return null */
--
		l_balance := null;
	ELSE
--
		l_balance := calc_asg_aug2jul_jp(
                                 p_assignment_action_id => p_assignment_action_id,
                                 p_balance_type_id      => p_balance_type_id,
				 p_assignment_id	=> l_assignment_id);
--				 p_dimension_name	=> p_dimension_name);
	END IF;
--
RETURN l_balance;
END calc_asg_aug2jul_jp_action;
--
/* ------------------------------------------------------------------------------------
--
--                          CALC_ASG_AUG2JUL_JP_DATE                                 --
--
-- This is the function for calculating JP specific assignment process
-- between Jan and Aug in date mode
--
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_asg_aug2jul_jp_date(
		p_assignment_id		IN NUMBER,
		p_balance_type_id	IN NUMBER,
		p_effective_date	IN DATE)
--	p_dimension_name	IN VARCHAR2)
RETURN NUMBER
IS
--
	l_assignment_action_id      NUMBER;
	l_balance                   NUMBER;
	l_last_start_date		DATE;
	l_defined_balance_id	NUMBER;
--
	cursor last_start_date(c_assignment_action_id IN NUMBER)
	is
	SELECT  /*+ ORDERED */
		add_months(trunc(add_months(ppa.effective_date,5),'YYYY'),-5)
	FROM	pay_assignment_actions	paa,
            pay_payroll_actions	ppa
	WHERE	paa.assignment_action_id = c_assignment_action_id
	AND	ppa.payroll_action_id = paa.payroll_action_id;
--
BEGIN
--
	l_defined_balance_id := dimension_relevant(p_balance_type_id, hr_jprts.g_asg_aug2jul_jp);
	/* -- check relevant dimension. if it is not so(defined_balance_id is null), return null */
--
	if l_defined_balance_id is not null then
--
		l_assignment_action_id := get_latest_action_id(
							p_assignment_id,
							p_effective_date);
		IF l_assignment_action_id is null THEN
			l_balance := 0;
		ELSE
			OPEN last_start_date(l_assignment_action_id);
			FETCH last_start_date INTO l_last_start_date;
			CLOSE last_start_date;
--
			if add_months(l_last_start_date,12) <= p_effective_date then
				l_balance := 0;
			else
				l_balance := calc_asg_aug2jul_jp(
		                                 p_assignment_action_id => l_assignment_action_id,
		                                 p_balance_type_id      => p_balance_type_id,
						 p_assignment_id	=> p_assignment_id);
--						 p_dimension_name	=> p_dimension_name);
			end if;
		END IF;
	else
		l_balance := null;
	end if;
--
RETURN l_balance;
END calc_asg_aug2jul_jp_date;
--
/* ------------------------------------------------------------------------------------
---
--
--                          CALC_ASG_AUG2JUL_JP                                      --
--
-- Calculate balances for JP specific Assignment process between Jan and Aug
--
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_asg_aug2jul_jp(
		p_assignment_action_id  IN NUMBER,
		p_balance_type_id       IN NUMBER,
		p_assignment_id		IN NUMBER)
--		p_dimension_name	IN VARCHAR2)
RETURN NUMBER
IS
--
	l_expired_balance	NUMBER;
	l_assignment_action_id  NUMBER;
        l_balance               NUMBER;
        l_latest_value_exists   VARCHAR2(2);
	l_action_eff_date	DATE;
	l_end_date		DATE;
     	l_defined_bal_id	NUMBER;
--
BEGIN
--
  l_defined_bal_id := dimension_relevant(p_balance_type_id, hr_jprts.g_asg_aug2jul_jp);
--
  if l_defined_bal_id is not null then
    l_balance := pay_balance_pkg.get_value(
                   l_defined_bal_id,
                   p_assignment_action_id);
--
  else
    l_balance := null;
  end if;
--
RETURN l_balance;
END calc_asg_aug2jul_jp;
--
/* ------------------------------------------------------------------------------------
--
--                          CALC_ASG_JUL2JUN_JP_ACTION                               --
--
-- This is the function for calculating JP specific assignment process
-- between Jan and Jul in assignment action mode
--
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_asg_jul2jun_jp_action(
         p_assignment_action_id IN NUMBER,
         p_balance_type_id      IN NUMBER)
RETURN NUMBER
IS
--
	l_assignment_action_id      NUMBER;
	l_balance                   NUMBER;
	l_assignment_id             NUMBER;
--
BEGIN
--
	l_assignment_id := get_correct_type(p_assignment_action_id);
	IF l_assignment_id is null THEN
--
/* --  The assignment action is not a payroll or quickpay type, so return null */
--
		l_balance := null;
	ELSE
--
		l_balance := calc_asg_jul2jun_jp(
                                 p_assignment_action_id => p_assignment_action_id,
                                 p_balance_type_id      => p_balance_type_id,
		                         p_assignment_id	=> l_assignment_id);
	END IF;
--
RETURN l_balance;
END calc_asg_jul2jun_jp_action;
--
/* ------------------------------------------------------------------------------------
--
--                          CALC_ASG_JUL2JUN_JP_DATE                                 --
--
-- This is the function for calculating JP specific assignment process
-- between Jan and Jul in date mode
--
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_asg_jul2jun_jp_date(
		p_assignment_id		IN NUMBER,
		p_balance_type_id	IN NUMBER,
		p_effective_date	IN DATE)
RETURN NUMBER
IS
--
	l_assignment_action_id      NUMBER;
	l_balance                   NUMBER;
	l_last_start_date		DATE;
	l_defined_balance_id	NUMBER;
--
	cursor last_start_date(c_assignment_action_id IN NUMBER)
	is
	SELECT	/*+ ORDERED */
            add_months(trunc(add_months(ppa.effective_date,6),'YYYY'),-6)
	FROM	pay_assignment_actions	paa,
            pay_payroll_actions	ppa
	WHERE	paa.assignment_action_id = c_assignment_action_id
	AND	paa.payroll_action_id = ppa.payroll_action_id;
--
BEGIN
--
	l_defined_balance_id := dimension_relevant(p_balance_type_id, hr_jprts.g_asg_jul2jun_jp);
	/* -- check relevant dimension. if it is not so(defined_balance_id is null), return null */
--
	if l_defined_balance_id is not null then
--
		l_assignment_action_id := get_latest_action_id(
							p_assignment_id,
							p_effective_date);
		IF l_assignment_action_id is null THEN
			l_balance := 0;
		ELSE
			OPEN last_start_date(l_assignment_action_id);
			FETCH last_start_date INTO l_last_start_date;
			CLOSE last_start_date;
--
			if add_months(l_last_start_date,12) <= p_effective_date then
				l_balance := 0;
			else
				l_balance := calc_asg_jul2jun_jp(
                                 p_assignment_action_id => l_assignment_action_id,
                                 p_balance_type_id      => p_balance_type_id,
                                 p_assignment_id	=> p_assignment_id);
			end if;
		END IF;
	else
		l_balance := null;
	end if;
--
RETURN l_balance;
END calc_asg_jul2jun_jp_date;
--
/* ------------------------------------------------------------------------------------
---
--
--                          CALC_ASG_JUL2JUN_JP                                      --
--
-- Calculate balances for JP specific Assignment process between Jan and Jul
--
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_asg_jul2jun_jp(
		p_assignment_action_id  IN NUMBER,
		p_balance_type_id       IN NUMBER,
		p_assignment_id		IN NUMBER)
RETURN NUMBER
IS
--
	l_expired_balance	NUMBER;
	l_assignment_action_id  NUMBER;
    l_balance               NUMBER;
    l_latest_value_exists   VARCHAR2(2);
	l_action_eff_date	DATE;
	l_end_date		DATE;
  	l_defined_bal_id	NUMBER;
--
BEGIN
--
  l_defined_bal_id := dimension_relevant(p_balance_type_id, hr_jprts.g_asg_jul2jun_jp);
--
  if l_defined_bal_id is not null then
    l_balance := pay_balance_pkg.get_value(
                   l_defined_bal_id,
                   p_assignment_action_id);
--
  else
    l_balance := null;
  end if;
--
RETURN l_balance;
END calc_asg_jul2jun_jp;
--
/* ------------------------------------------------------------------------------------
---
--
--                          CALC_ASG_ITD_ACTION                                      --
--
--         This is the function for calculating assignment
--         Inception to date in assignment action mode
--
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_asg_itd_action(
         p_assignment_action_id IN NUMBER,
         p_balance_type_id      IN NUMBER)
RETURN NUMBER
IS
--
	l_assignment_action_id      NUMBER;
	l_balance                   NUMBER;
	l_assignment_id             NUMBER;
	l_effective_date		DATE;
--
BEGIN
--
	l_assignment_id := get_correct_type(p_assignment_action_id);
	IF l_assignment_id is null THEN
--
/* --  The assignment action is not a payroll or quickpay type, so return null */
--
		l_balance := null;
	ELSE
--
		l_balance := calc_asg_itd(
				p_assignment_action_id	=> p_assignment_action_id,
				p_balance_type_id => p_balance_type_id,
				p_assignment_id      => l_assignment_id);
	END IF;
--
RETURN l_balance;
end calc_asg_itd_action;
--
/* ------------------------------------------------------------------------------------
---
--
--                          CALC_ASG_ITD_DATE                                        --
--
--    This is the function for calculating assignment inception to
--                      date in DATE MODE
--
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_asg_itd_date(
         p_assignment_id        IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER
IS
--
	l_assignment_action_id      NUMBER;
	l_balance                   NUMBER;
	l_end_date                  DATE;
	l_defined_balance_id	NUMBER;
--
BEGIN
--
	l_defined_balance_id := dimension_relevant(p_balance_type_id, hr_jprts.g_asg_itd);
	/* -- check relevant dimension. if it is not so(defined_balance_id is null), return null */
--
	if l_defined_balance_id is not null then
--
	l_assignment_action_id := get_latest_action_id(	p_assignment_id,
							p_effective_date);
		IF l_assignment_action_id is null THEN
			l_balance := 0;
		ELSE
			l_balance := calc_asg_itd(
	                             p_assignment_action_id => l_assignment_action_id,
	                             p_balance_type_id      => p_balance_type_id,
				     p_assignment_id	    => p_assignment_id);
		END IF;
	else
		l_balance := null;
	end if;
--
RETURN l_balance;
end calc_asg_itd_date;
--
/* ------------------------------------------------------------------------------------
---
--
--                          CALC_ASG_ITD                                             --
--
--      calculate balances for Assignment Inception to Date
--
-- ------------------------------------------------------------------------------------ */
/* -- Sum of all run items since inception. */
--
FUNCTION calc_asg_itd(
		p_assignment_action_id  IN NUMBER,
		p_balance_type_id       IN NUMBER,
		p_assignment_id		IN NUMBER)
--		p_effective_date        IN DATE DEFAULT NULL) -- in for consistency
RETURN NUMBER
IS
--
	l_balance               NUMBER;
	l_latest_value_exists   VARCHAR2(2);
	l_assignment_action_id  NUMBER;
	l_action_eff_date	DATE;
	l_defined_bal_id	NUMBER;
--
BEGIN
--
  l_defined_bal_id := dimension_relevant(p_balance_type_id, hr_jprts.g_asg_itd);
--
  if l_defined_bal_id is not null then
    l_balance := pay_balance_pkg.get_value(
                   l_defined_bal_id,
                   p_assignment_action_id);
--
  else
    l_balance := null;
  end if;
--
RETURN l_balance;
--
END calc_asg_itd;
--
/* ------------------------------------------------------------------------------------
--
--                          CALC_RETRO_ACTION                                        --
--
-- Actually, this function is not used so that hr_routes.retro_jp does not exist.
-- This is the function for calculating retro pay process
-- in assignment action mode.
--
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_retro_action(
         p_assignment_action_id IN NUMBER,
         p_balance_type_id      IN NUMBER)
RETURN NUMBER
IS
--
	l_assignment_action_id      NUMBER;
	l_balance                   NUMBER;
	l_assignment_id             NUMBER;
	l_effective_date         	DATE;
--
BEGIN
--
	l_assignment_id := get_correct_type(p_assignment_action_id);
	IF l_assignment_id is null THEN
--
/* --  The assignment action is not a payroll or quickpay type, so return null */
--
		l_balance := null;
	ELSE
--
		l_balance := calc_retro(
                                 p_assignment_action_id => p_assignment_action_id,
                                 p_balance_type_id      => p_balance_type_id,
				 p_assignment_id	=> l_assignment_id);
	END IF;
--
RETURN l_balance;
END calc_retro_action;
--
/* ------------------------------------------------------------------------------------
--
--                          CALC_RETRO_DATE                                          --
--
-- Actually, this function is not used so that hr_routes.retro_jp does not exist.
-- This is the function for calculating retro pay process
-- in date mode.
--
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_retro_date(
         p_assignment_id	IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER
IS
--
	l_assignment_action_id	NUMBER;
	l_balance		NUMBER;
	l_end_date		DATE;
	l_defined_balance_id	NUMBER;
--
	cursor expired_time_period(c_assignment_action_id IN NUMBER)
	is
	SELECT	/*+ ORDERED */
            ptp.end_date
	FROM	pay_assignment_actions	paa,
    		pay_payroll_actions	ppa,
            per_time_periods	ptp
	WHERE	paa.assignment_action_id = c_assignment_action_id
	AND	ppa.payroll_action_id = paa.payroll_action_id
	AND	ptp.time_period_id = ppa.time_period_id;
--
BEGIN
--
	l_defined_balance_id := dimension_relevant(p_balance_type_id, hr_jprts.g_retro);
	/* -- check relevant dimension. if it is not so(defined_balance_id is null), return null */
--
	if l_defined_balance_id is not null then
--
		l_assignment_action_id := get_latest_action_id(
							p_assignment_id,
							p_effective_date);
		IF l_assignment_action_id is null THEN
			l_balance := 0;
		ELSE
			OPEN expired_time_period(l_assignment_action_id);
			FETCH expired_time_period INTO l_end_date;
			CLOSE expired_time_period;
--
			if l_end_date < p_effective_date then
				l_balance := 0;
			else
				l_balance := calc_retro(
	                             p_assignment_action_id => l_assignment_action_id,
			 	     p_balance_type_id      => p_balance_type_id,
	                             p_assignment_id        => p_assignment_id);
			end if;
		END IF;
	else
		l_balance := null;
	end if;
--
RETURN l_balance;
END calc_retro_date;
--
/* ------------------------------------------------------------------------------------
--
--                          CALC_RETRO                                               --
--
--	Actually, this function is not used so that hr_routes.retro_jp does not exist.
--      calculate balances for retro pay process
--
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_retro(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
	p_assignment_id		IN NUMBER)
RETURN NUMBER
IS
--
	l_balance               NUMBER;
	l_defined_bal_id	NUMBER;
--
BEGIN
--
/* --Do we need to work out nocopy a value for this dimension/balance combination.
--Used dimension_name in dimension_relevant because of unique column */
--
	l_defined_bal_id := dimension_relevant(p_balance_type_id, hr_jprts.g_retro);
	if l_defined_bal_id is not null then
--
/* -- Run balances will never have a value in pay_assignment_latest_balances
-- table, as they are only used for the duration of the payroll run.
-- We therefore don't need to check the table, time can be saved by
-- simply calling the route code, which is incidentally the most
-- performant (ie simple) route. */
--
/* -- Actually, this function is not used so that hr_routes.retro_jp does not exist. */
	l_balance := hr_jprts.retro_jp(
				p_assignment_action_id,
				p_balance_type_id);
--
	else
		l_balance := null;
	end if;
--
RETURN l_balance;
END calc_retro;
--
/* ------------------------------------------------------------------------------------
--
--                          CALC_PAYMENT_ACTION                                      --
--
-- This is the function for calculating payment process
-- in assignment action mode
--
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_payment_action(
         p_assignment_action_id IN NUMBER,
         p_balance_type_id      IN NUMBER)
RETURN NUMBER
IS
--
	l_assignment_action_id	NUMBER;
	l_balance		NUMBER;
	l_assignment_id		NUMBER;
	l_effective_date	DATE;
--
BEGIN
--
	l_assignment_id := get_correct_type(p_assignment_action_id);
	IF l_assignment_id is null THEN
--
/* --  The assignment action is not a payroll or quickpay type, so return null */
--
		l_balance := null;
	ELSE
--
		l_balance := calc_payment(
                                 p_assignment_action_id => p_assignment_action_id,
                                 p_balance_type_id      => p_balance_type_id,
				 p_assignment_id	=> l_assignment_id);
	END IF;
--
RETURN l_balance;
END calc_payment_action;
--
/* ------------------------------------------------------------------------------------
--
--                          CALC_PAYMENT_DATE                                        --
--
-- This is the function for calculating payment process
-- in date mode
--
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_payment_date(
         p_assignment_id        IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER
IS
--
	l_assignment_action_id      NUMBER;
	l_balance                   NUMBER;
	l_end_date                  DATE;
	l_defined_balance_id	NUMBER;
--
	cursor expired_time_period(c_assignment_action_id IN NUMBER)
	is
	SELECT  /*+ ORDERED */
           	ptp.end_date
	FROM	pay_assignment_actions	paa,
        	pay_payroll_actions	ppa,
            per_time_periods	ptp
	WHERE	paa.assignment_action_id = c_assignment_action_id
	AND	    ppa.payroll_action_id = paa.payroll_action_id
	AND 	ptp.time_period_id = ppa.time_period_id;
--
BEGIN
--
	l_defined_balance_id := dimension_relevant(p_balance_type_id, hr_jprts.g_payment);
	/* -- check relevant dimension. if it is not so(defined_balance_id is null), return null */
--
	if l_defined_balance_id is not null then
--
		l_assignment_action_id := get_latest_action_id(
						p_assignment_id,
						p_effective_date);
		IF l_assignment_action_id is null THEN
			l_balance := 0;
		ELSE
			OPEN expired_time_period(l_assignment_action_id);
			FETCH expired_time_period INTO l_end_date;
			CLOSE expired_time_period;
--
			if l_end_date < p_effective_date then
				l_balance := 0;
			else
				l_balance := calc_payment(
		                             p_assignment_action_id => l_assignment_action_id,
		                             p_balance_type_id      => p_balance_type_id,
		                             p_assignment_id        => p_assignment_id);
			end if;
		END IF;
	else
		l_balance := null;
	end if;
--
RETURN l_balance;
END calc_payment_date;
--
/* ------------------------------------------------------------------------------------
--
--                          CALC_PAYMENT                                             --
--
-- Calculate balances for payment process
--
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_payment(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
	p_assignment_id		IN NUMBER)
RETURN NUMBER
IS
--
	l_expired_balance	NUMBER;
        l_balance               NUMBER;
        l_latest_value_exists   VARCHAR2(2);
        l_assignment_action_id  NUMBER;
	l_action_eff_date	DATE;
	l_end_date		DATE;
	l_defined_bal_id	NUMBER;
--
BEGIN
--
	l_defined_bal_id := dimension_relevant(p_balance_type_id, hr_jprts.g_payment);
--
	if l_defined_bal_id is not null then
    l_balance := pay_balance_pkg.get_value(
                   l_defined_bal_id,
                   p_assignment_action_id);
--
  else
    l_balance := null;
  end if;
--
RETURN l_balance;
END calc_payment;
--
/* ------------------------------------------------------------------------------------
--
--			CALC_ELEMENT_ITD_BAL
--
-- This is the function for calculating element itd balance
--
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_element_itd_bal(p_assignment_action_id IN NUMBER,
     			      p_balance_type_id      IN NUMBER,
			      p_source_id	     IN NUMBER)
RETURN NUMBER IS
--
	l_balance		NUMBER;
	l_defined_bal_id	NUMBER;
--
BEGIN
--
	l_defined_bal_id := dimension_relevant(p_balance_type_id, hr_jprts.g_element_itd);
	if l_defined_bal_id is not null then
		l_balance := get_latest_element_bal(
					p_assignment_action_id,
					l_defined_bal_id,
					p_source_id);
		if l_balance is null then
--
-- Fix bug#3083339: Set context to identify element name in the element level
--                  dimension rows.
--
            -- This set source_id will be used in pay_balance_pkg.get_value function.
			pay_balance_pkg.set_context(
                         p_context_name  => 'ORIGINAL_ENTRY_ID',
                         p_context_value => p_source_id);
--
           l_balance := pay_balance_pkg.get_value(
                          l_defined_bal_id,
                          p_assignment_action_id);
		end if;
	else
		l_balance := null;
--
	end if;
--
RETURN l_balance;
END calc_element_itd_bal;
--
/* ------------------------------------------------------------------------------------
--
--                      CALC_ELEMENT_PTD_BAL
--
-- This is the function for calculating element ptd balance
--
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_element_ptd_bal(p_assignment_action_id IN NUMBER,
                              p_balance_type_id      IN NUMBER,
                              p_source_id            IN NUMBER)
RETURN NUMBER IS
--
	l_balance        NUMBER;
	l_defined_bal_id NUMBER;
--
BEGIN
--
	l_defined_bal_id := dimension_relevant(p_balance_type_id, hr_jprts.g_element_ptd);
	if l_defined_bal_id is not null then
--
		l_balance := get_latest_element_bal(
					p_assignment_action_id,
					l_defined_bal_id,
					p_source_id);
		if l_balance is null then
--
           -- This set source_id will be used in pay_balance_pkg.get_value function.
           pay_balance_pkg.set_context(
                             p_context_name  => 'ORIGINAL_ENTRY_ID',
                             p_context_value => p_source_id);
           l_balance := pay_balance_pkg.get_value(
                          l_defined_bal_id,
                          p_assignment_action_id);
         --l_balance := hr_routes.element_ptd(
         --               p_assignment_action_id,
         --               p_balance_type_id,
         --               p_source_id);
		end if;
	else
		l_balance := null;
--
	end if;
--
RETURN l_balance;
END calc_element_ptd_bal;
--
/* ------------------------------------------------------------------------------------
--
--                            CALC_ALL_BALANCES
--                        -- assignment action Mode -
--
-- This is the generic overloaded function for calculating all balances
-- in assignment action mode. NB Element level balances cannot be called
-- from here as they require further context.
--
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_all_balances(
         p_assignment_action_id IN NUMBER,
         p_defined_balance_id   IN NUMBER)
--
RETURN NUMBER
IS
--
	l_balance                   NUMBER;
    	l_balance_type_id           NUMBER;
	l_dimension_name	        VARCHAR2(80);
--
	cursor get_balance_type_id(c_defined_balance_id IN NUMBER)
	IS
	SELECT  /*+ ORDERED */
            pdb.balance_type_id,
		    pbd.dimension_name
	FROM	pay_defined_balances   pdb,
		    pay_balance_dimensions pbd
	WHERE	pdb.defined_balance_id = c_defined_balance_id
	AND	    pbd.balance_dimension_id = pdb.balance_dimension_id;
--
BEGIN
--
	OPEN get_balance_type_id(p_defined_balance_id);
	FETCH get_balance_type_id INTO l_balance_type_id, l_dimension_name;
	CLOSE get_balance_type_id;
--
	If l_dimension_name = hr_jprts.g_asg_run then
		l_balance := calc_asg_run_action(
					p_assignment_action_id,
					l_balance_type_id);
	ELSIF l_dimension_name = hr_jprts.g_asg_mtd_jp then
		l_balance := calc_asg_mtd_jp_action(
					p_assignment_action_id,
					l_balance_type_id);
--					l_dimension_name);
	ELSIF l_dimension_name = hr_jprts.g_ast_ytd_jp then
		l_balance := calc_asg_ytd_jp_action(
					p_assignment_action_id,
					l_balance_type_id);
--					l_dimension_name);
  --
	elsif l_dimension_name = pyjpexc.c_asg_aprtd then
  --
    l_balance := calc_asg_apr2mar_jp_action(
                   p_assignment_action_id,
                   l_balance_type_id);
  --
	ELSIF l_dimension_name = hr_jprts.g_asg_aug2jul_jp then
		l_balance := calc_asg_aug2jul_jp_action(
					p_assignment_action_id,
					l_balance_type_id);
--					l_dimension_name);
	ELSIF l_dimension_name = hr_jprts.g_asg_jul2jun_jp then
        -- calc_asg_jul2jun_jp_action is necessary
        -- this should be used in pay_jp_bal_matrix_by_act_v
		l_balance := calc_asg_jul2jun_jp_action(
					p_assignment_action_id,
					l_balance_type_id);
	ELSIF l_dimension_name = hr_jprts.g_asg_proc_ptd then
		l_balance := calc_asg_proc_ptd_action(
					p_assignment_action_id,
					l_balance_type_id);
	ELSIF l_dimension_name = hr_jprts.g_asg_itd then
		l_balance := calc_asg_itd_action(p_assignment_action_id,
						l_balance_type_id);
	ELSIF l_dimension_name = hr_jprts.g_asg_fytd_jp then
		l_balance := calc_asg_fytd_jp_action(
					p_assignment_action_id,
					l_balance_type_id);
--					l_dimension_name);
	ELSIF l_dimension_name = hr_jprts.g_asg_fytd2_jp then
        -- calc_asg_fytd2_jp_action might be necessary
		l_balance := calc_asg_fytd2_jp_action(
					p_assignment_action_id,
					l_balance_type_id);
	/* -- Actually, this function is not used so that hr_routes.retro_jp does not exist. */
	ELSIF l_dimension_name = hr_jprts.g_retro then
		l_balance := calc_retro_action(p_assignment_action_id,
                                               l_balance_type_id);
	ELSIF l_dimension_name = hr_jprts.g_payment then
		l_balance := calc_payment_action(
					p_assignment_action_id,
					l_balance_type_id);
/* -- This function can not call the calculation of Element dimension.
-- Because it needs source_id.
--      ELSIF l_dimension_name = hr_jprts.g_element_itd then
--         	fnd_message.set_name('PAY','This dimension is invalid');
--	       	fnd_message.raise_error;
		--l_balance := NULL;
--      ELSIF l_dimension_name = hr_jprts.g_element_ptd then
--         	fnd_message.set_name('PAY','This dimension is invalid');
--         	fnd_message.raise_error;
--		l_balance := NULL; */
      --ELSE the balance must be for a USER-REG level dimension
      ELSE
      		l_balance := balance(p_assignment_action_id, p_defined_balance_id);
      End If;
--
RETURN l_balance;
END calc_all_balances;
--
/* ------------------------------------------------------------------------------------
--
--                            CALC_ALL_BALANCES
--                             -  Date Mode -
--
-- This is the overloaded generic function for calculating all balances
-- in Date Mode. NB Element level balances cannot be obtained from here as
-- they require further context.
--
-- ------------------------------------------------------------------------------------ */
FUNCTION calc_all_balances(
         p_effective_date       IN DATE,
         p_assignment_id        IN NUMBER,
         p_defined_balance_id   IN NUMBER)
--
RETURN NUMBER
IS
--
	l_balance                   NUMBER;
	l_balance_type_id           NUMBER;
	l_dimension_name            VARCHAR2(80);
	l_assignment_action_id      NUMBER;
--
	cursor get_balance_type_id(c_defined_balance_id IN NUMBER)
	IS
	SELECT	/*+ ORDERED */
            pdb.balance_type_id,
		pbd.dimension_name
	FROM	pay_defined_balances   pdb,
		    pay_balance_dimensions pbd
	WHERE	pdb.defined_balance_id = c_defined_balance_id
	AND	    pbd.balance_dimension_id = pdb.balance_dimension_id;
--
BEGIN
--
	OPEN get_balance_type_id(p_defined_balance_id);
	FETCH get_balance_type_id INTO l_balance_type_id, l_dimension_name;
	CLOSE get_balance_type_id;
--
	If l_dimension_name = hr_jprts.g_asg_run then
		l_balance := calc_asg_run_date(
					p_assignment_id,
                                        l_balance_type_id,
					p_effective_date);
	ELSIF l_dimension_name = hr_jprts.g_asg_mtd_jp then
		l_balance := calc_asg_mtd_jp_date(
					p_assignment_id,
					l_balance_type_id,
					p_effective_date);
	ELSIF l_dimension_name = hr_jprts.g_ast_ytd_jp then
		l_balance := calc_asg_ytd_jp_date(
					p_assignment_id,
					l_balance_type_id,
					p_effective_date);
  --
	elsif l_dimension_name = pyjpexc.c_asg_aprtd then
  --
    l_balance := calc_asg_apr2mar_jp_date(
                   p_assignment_id,
                   l_balance_type_id,
                   p_effective_date);
  --
	ELSIF l_dimension_name = hr_jprts.g_asg_aug2jul_jp then
		l_balance := calc_asg_aug2jul_jp_date(
					p_assignment_id,
					l_balance_type_id,
					p_effective_date);
	ELSIF l_dimension_name = hr_jprts.g_asg_jul2jun_jp then
        -- calc_asg_jul2jun_jp_date is necessary
        -- this should be used in pay_jp_bal_matrix_by_date_v
		l_balance := calc_asg_jul2jun_jp_date(
					p_assignment_id,
					l_balance_type_id,
					p_effective_date);
	ELSIF l_dimension_name = hr_jprts.g_asg_proc_ptd then
		l_balance := calc_asg_proc_ptd_date(
					p_assignment_id,
					l_balance_type_id,
					p_effective_date);
	ELSIF l_dimension_name = hr_jprts.g_asg_itd then
		l_balance := calc_asg_itd_date(
					p_assignment_id,
					l_balance_type_id,
					p_effective_date);
	ELSIF l_dimension_name = hr_jprts.g_asg_fytd_jp then
		l_balance := calc_asg_fytd_jp_date(
					p_assignment_id,
					l_balance_type_id,
					p_effective_date);
	ELSIF l_dimension_name = hr_jprts.g_asg_fytd2_jp then
        -- calc_asg_fytd2_jp_action might be necessary
		l_balance := calc_asg_fytd2_jp_date(
					p_assignment_id,
					l_balance_type_id,
					p_effective_date);
	/* -- Actually, this function is not used so that hr_routes.retro_jp does not exist. */
	ELSIF l_dimension_name = hr_jprts.g_retro then
		l_balance := calc_retro_date(
					p_assignment_id,
					l_balance_type_id,
					p_effective_date);
	ELSIF l_dimension_name = hr_jprts.g_payment then
		l_balance := calc_payment_date(
					p_assignment_id,
                                        l_balance_type_id,
					p_effective_date);
/* -- This function can not call the calculation of Element dimension.
-- Because it needs source_id.
--      ELSIF l_dimension_name = hr_jprts.g_element_itd then
--         	fnd_message.set_name('PAY','This dimension is invalid');
--        	fnd_message.raise_error;
--		l_balance := NULL;
--      ELSIF l_dimension_name = hr_jprts.g_element_ptd then
--         	fnd_message.set_name('PAY','This dimension is invalid');
--       	fnd_message.raise_error;
--		l_balance := NULL; */
----
-- This comment is no more effective because new function has been added
-- for hr_jprts.g_asg_jul2jun_jp and hr_jprts.g_asg_fytd2_jp
--
	ELSE
		--This will trap USER-REG level balances
		l_balance := calc_balance_date(
					p_assignment_id,
					l_balance_type_id,
					p_effective_date,
					l_dimension_name);
	END IF;
--
RETURN l_balance;
--
END calc_all_balances;
--
END hr_jpbal;

/
