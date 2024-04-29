--------------------------------------------------------
--  DDL for Package Body HR_DIRBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DIRBAL" AS
/* $Header: pydirbal.pkb 120.1.12000000.3 2007/07/05 12:34:49 sbairagi noship $ */
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--			FUNCTION get_balance
-- 			Date Mode
-------------------------------------------------------------------------------
/* We can check whether the balance has
   expired before getting it, due to the fact that we navigate back to the
   last assignment action and use the effective (session) date passed in
   as criteria for expiry checking.
   Calls the asg action mode function, which now calls core BUE.
*/
FUNCTION get_balance (p_assignment_id 	IN NUMBER,
		      p_defined_balance_id IN NUMBER,
		      p_effective_date     IN DATE)
RETURN NUMBER IS
--
    l_assignment_action_id	NUMBER;
    l_balance			NUMBER;
    l_expired			BOOLEAN;
--
-- This gets the most recent assignment action of seq generating type, using
-- the effective date and assignment ID passed in
--
    cursor get_latest_id is
    SELECT
         fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||
         paa.assignment_action_id),16))
    FROM pay_assignment_actions paa,
         pay_payroll_actions    ppa
    WHERE
         paa.assignment_id = p_assignment_id
    AND  ppa.payroll_action_id = paa.payroll_action_id
    AND  ppa.effective_date <= p_effective_date
    AND  ppa.action_type        in ('R', 'Q', 'I', 'V', 'B');
--
BEGIN
--
    open get_latest_id;
    fetch get_latest_id into l_assignment_action_id;
    close get_latest_id;
    if l_assignment_action_id is null then
       l_balance := 0;
    else
       --Check expiry even before getting the VALUE, according to effective date
       l_expired :=
         balance_expired(p_assignment_action_id => l_assignment_action_id,
                         p_defined_balance_id   => p_defined_balance_id,
                         p_effective_date       => p_effective_date);
       --
       if l_expired = TRUE then
          l_balance := 0;
       else
          --get the balance value using the latest assignment action
          l_balance := get_balance(
			p_assignment_action_id => l_assignment_action_id,
                      	p_defined_balance_id   => p_defined_balance_id);
       end if;
    end if;
--
RETURN l_balance;
--
END get_balance;
-------------------------------------------------------------------------------
--			FUNCTION get_balance
--			Assignment Action Mode
--   Now calls the Core BUE directly, this function now just a cover for this.
-------------------------------------------------------------------------------
FUNCTION get_balance (p_assignment_action_id IN NUMBER,
		      p_defined_balance_id   IN NUMBER)
RETURN NUMBER IS
--
   l_balance		  NUMBER;
--
BEGIN
--
-- Call the Core package with the relevant info, and ensure that the
-- exception no data found is handled by returning a null, as this is
-- the current UK method of implementation.
-- All balances can be retrieved by this method including USER-REGs.
--
   BEGIN
     l_balance := pay_balance_pkg.get_value(
                    p_assignment_action_id => p_assignment_action_id,
                    p_defined_balance_id   => p_defined_balance_id);
     EXCEPTION WHEN NO_DATA_FOUND THEN
        l_balance := null;
     END;
--
RETURN l_balance;
--
END get_balance;
-------------------------------------------------------------------------------
--                      FUNCTION get_balance
--  This function is used only in PAYGBTPL report.
-------------------------------------------------------------------------------
FUNCTION get_balance (p_assignment_action_id IN NUMBER,
                      p_defined_balance_id   IN NUMBER,
                      p_dimension_id         IN NUMBER,
                      p_period_id            IN NUMBER,
                      p_ptd_bal_dim_id       IN NUMBER)
RETURN NUMBER IS
--
    l_action_effective date;
    l_period_start     date;
    l_period_end       date;
    l_balance          number;

    l_time_period_id  number;
--
BEGIN
    l_balance := 0;

    select   ppa.time_period_id
     into     l_time_period_id
     from     pay_payroll_actions ppa,
              pay_assignment_actions paa
     where    paa.assignment_action_id = p_assignment_action_id
     and      ppa.payroll_action_id = paa.payroll_action_id;

    /* select   ptp.start_date,
              ptp.regular_payment_date
     into     l_period_start,
              l_period_end
     from     per_time_periods ptp
     where    ptp.time_period_id = p_period_id;*/

     if p_dimension_id = p_ptd_bal_dim_id then
        if (l_time_period_id=p_period_id) then
            l_balance := hr_dirbal.get_balance(p_assignment_action_id,p_defined_balance_id);
        end if;
     else
            l_balance := hr_dirbal.get_balance(p_assignment_action_id,p_defined_balance_id);
    end if;
--
RETURN l_balance;
--
END get_balance;
-------------------------------------------------------------------------------
--		FUNCTION balance_expired
--		This function checks the expiry of an action's value ,
--		depending on which dimension type the value is for
-- This function is still required after addition of Core BUE changes.
-------------------------------------------------------------------------------
FUNCTION balance_expired (p_assignment_action_id IN NUMBER,
                          p_owning_action_id     IN NUMBER DEFAULT NULL,
		          p_defined_balance_id   IN NUMBER,
			  p_database_item_suffix IN VARCHAR2 DEFAULT NULL,
 			  p_effective_date       IN DATE,
			  p_action_effective_date IN DATE DEFAULT NULL)
--
RETURN BOOLEAN IS
--
--Check the expiry of an action depending on the defined balance's dimension
--type.
--
   l_database_item_suffix	VARCHAR2(30);
   l_expired			BOOLEAN := FALSE;
   l_return_date		DATE;
--
   cursor get_dimension_type(c_defined_balance_id   IN NUMBER) IS
   select database_item_suffix
   from pay_balance_dimensions pbd,
        pay_defined_balances   pdb
   where pbd.balance_dimension_id = pdb.balance_dimension_id
   and   pdb.defined_balance_id = c_defined_balance_id;
--
BEGIN
--
  if p_database_item_suffix is null then	--date mode call
     open get_dimension_type(p_defined_balance_id);
     fetch get_dimension_type into l_database_item_suffix;
     close get_dimension_type;
--
  else
     l_database_item_suffix := p_database_item_suffix;
  end if;
--
-- On yearlys, check the beginning date of the tax yr of the
-- original asg action (the owning action). If the effective date
-- of the previous action is before the start yr date, then it
-- has expired and cannot be used.
-- However, if the owning action is null this means the call to this
-- function is in date mode, so the expiry of that action has to be checked.
-- PQP - pass in the db item suffix for 2 yearly check.
--
  if instr(l_database_item_suffix,'YTD') > 0 then
     -- yearly balance, so call yearly expiry
     if p_owning_action_id is not null then
        -- Asg Action call, use start date.
        l_return_date := start_year_date(p_owning_action_id,
                                         l_database_item_suffix);
        if nvl(p_action_effective_date,get_action_date(p_assignment_action_id))
                             < l_return_date
               or l_return_date is null then
          l_expired := TRUE;
        end if;
        --
     else
        -- date mode call, so use expiry of single action
        l_return_date :=
           expired_year_date(nvl(p_action_effective_date,
                    (get_action_date(p_assignment_action_id))));
        if p_effective_date >= l_return_date
           or l_return_date is null then
           l_expired := TRUE;
        end if;
     end if;
  elsif instr(l_database_item_suffix,'PTD') > 0 then
     --period balance, so call period expiry
     if p_effective_date > expired_period_date(p_assignment_action_id) then
        l_expired := TRUE;
     end if;
  elsif instr(l_database_item_suffix,'RUN') > 0 then
     --run balance, so call period expiry
     if p_effective_date > expired_period_date(p_assignment_action_id) then
        l_expired := TRUE;
     end if;
  elsif instr(l_database_item_suffix,'PAYMENTS') > 0 then
     --again call period expiry
     if p_effective_date > expired_period_date(p_assignment_action_id) then
        l_expired := TRUE;
     end if;
  elsif instr(l_database_item_suffix,'QTD') > 0 then
     --quarterly balance, so call quarterly expiry
     l_return_date := expired_quarter_date
                           (nvl(p_action_effective_date,(get_action_date(p_assignment_action_id))));
        if p_effective_date > l_return_date
           or l_return_date is null then
        l_expired := TRUE;
     end if;
  end if;
--
RETURN l_expired;
--
END balance_expired;
-------------------------------------------------------------------------------
--              FUNCTION start_year_date
--              This function returns the Start of Year for an
--              Assignment Action.
-------------------------------------------------------------------------------
FUNCTION start_year_date(p_assignment_action_id  IN NUMBER,
                         p_database_item_suffix  IN VARCHAR2)

--
RETURN DATE IS
--
   cursor csr_start_fin_yr(c_assignment_action_id in number) is
   select to_date('06-04-' || to_char( to_number(
          to_char( PTP.regular_payment_date,'YYYY'))
             +  decode(sign( PTP.regular_payment_date - to_date('06-04-'
                 || to_char(PTP.regular_payment_date,'YYYY'),'DD-MM-YYYY')),
           -1,-1,0)),'DD-MM-YYYY') finyear, BACT.payroll_id
   from
        per_time_periods      PTP,
        pay_payroll_actions   BACT,
        pay_assignment_actions ACT
   where PTP.time_period_id = BACT.time_period_id
   and   ACT.assignment_action_id = c_assignment_action_id
   and   BACT.payroll_action_id = ACT.payroll_action_id;
   --
   -- cursor to get the start of the expiry code year as current fin year
   -- minus 1 if the current tax year is odd and cur tax year if the
   -- year is even
   --
   CURSOR csr_start_fin_yr_odd_ytd(c_assignment_action_id in number ) is
   SELECT to_date('06-04-' || to_char( fnd_number.canonical_to_number(
          to_char( PTP.regular_payment_date,'YYYY'))
             +  decode(sign( PTP.regular_payment_date - to_date('06-04-'
                 || to_char(PTP.regular_payment_date,'YYYY'),'DD-MM-YYYY')),
           -1,-1,0) -
          mod(
           fnd_number.canonical_to_number(
          to_char( PTP.regular_payment_date,'YYYY'))
             +  decode(sign( PTP.regular_payment_date - to_date('06-04-'
                 || to_char(PTP.regular_payment_date,'YYYY'),'DD-MM-YYYY')),
           -1,-1,0),2)
            ),'DD-MM-YYYY') finyear, BACT.payroll_id
   FROM
         per_time_periods      PTP,
         pay_payroll_actions   BACT,
         pay_assignment_actions ACT
   WHERE PTP.time_period_id = BACT.time_period_id
   AND   ACT.assignment_action_id = c_assignment_action_id
   AND   BACT.payroll_action_id = ACT.payroll_action_id;
   --
   -- cursor to get the start of the expiry code year as current fin year
   -- minus 1 if the current tax year is even and cur tax year if the
   -- year is odd
   --
   CURSOR csr_start_fin_yr_even_ytd(c_assignment_action_id in number ) is
   SELECT to_date('06-04-' || to_char( fnd_number.canonical_to_number(
          to_char( PTP.regular_payment_date,'YYYY'))
             +  decode(sign( PTP.regular_payment_date - to_date('06-04-'
                 || to_char(PTP.regular_payment_date,'YYYY'),'DD-MM-YYYY')),
           -1,-1,0) -
          mod(
           fnd_number.canonical_to_number(
          to_char( PTP.regular_payment_date,'YYYY'))
             +  decode(sign( PTP.regular_payment_date - to_date('06-04-'
                 || to_char(PTP.regular_payment_date,'YYYY'),'DD-MM-YYYY')),
           -1,0,-1),2)
            ),'DD-MM-YYYY') finyear, BACT.payroll_id
   FROM
         per_time_periods      PTP,
         pay_payroll_actions   BACT,
         pay_assignment_actions ACT
   WHERE PTP.time_period_id = BACT.time_period_id
   AND   ACT.assignment_action_id = c_assignment_action_id
   AND   BACT.payroll_action_id = ACT.payroll_action_id;
   --
   --
   cursor csr_start_pay_yr(c_tax_yr_start in date,
                           c_payroll_id in number) is
   select min(TP.start_date)
   from   per_time_periods TP
   where  TP.payroll_id = c_payroll_id
   and    TP.regular_payment_date  >= c_tax_yr_start;
   --
   l_year_add_no        NUMBER;
   l_pay_year_start     DATE;
   l_tax_year_start     DATE;
   l_payroll_id         NUMBER;
--
BEGIN
   --
   -- PQP, check whether this is the two-year expiry
   --
   if p_database_item_suffix = '_ASG_TD_ODD_TWO_YTD' then
      --
      open csr_start_fin_yr_odd_ytd(p_assignment_action_id);
      fetch csr_start_fin_yr_odd_ytd into l_tax_year_start, l_payroll_id;
      close csr_start_fin_yr_odd_ytd;
      --
   elsif p_database_item_suffix = '_ASG_TD_EVEN_TWO_YTD' then
      --
      open csr_start_fin_yr_even_ytd(p_assignment_action_id);
      fetch csr_start_fin_yr_even_ytd into l_tax_year_start, l_payroll_id;
      close csr_start_fin_yr_even_ytd;
      --
   else
      --
      -- Get the start of the financial year for the regular YTD
      --
      open csr_start_fin_yr(p_assignment_action_id);
      fetch csr_start_fin_yr into l_tax_year_start, l_payroll_id;
      close csr_start_fin_yr;
      --
   end if;
   --
   -- Get the start of the first period in the financial year,
   -- this is the expiry date.
   --
   open csr_start_pay_yr(l_tax_year_start, l_payroll_id);
   fetch csr_start_pay_yr into l_pay_year_start;
   close csr_start_pay_yr;
   --
RETURN l_pay_year_start;
--
END start_year_date;
--
-------------------------------------------------------------------------------
--		FUNCTION expired_year_date
--		This function returns the expiry of an eff.date's tax year
-------------------------------------------------------------------------------
FUNCTION expired_year_date(p_action_effective_date IN DATE)
--
RETURN DATE IS
--
   l_expired_date       DATE;
   l_year_add_no        NUMBER;
--
BEGIN
--
   if  p_action_effective_date <
                  to_date('06-04-' || to_char(p_action_effective_date,'YYYY'),
                 'DD-MM-YYYY')  then
        l_year_add_no := 0;
   else l_year_add_no := 1;
   end if;
--
-- Set expired date to the 6th of April next.
--
   l_expired_date :=
     ( to_date('06-04-' || to_char( fnd_number.canonical_to_number(to_char(
     p_action_effective_date,'YYYY')) + l_year_add_no),'DD-MM-YYYY'));
--
   RETURN l_expired_date;
--
END expired_year_date;
--
-------------------------------------------------------------------------------
--		FUNCTION expired_period_date
--		This function returns the expiry of an action's time period
-------------------------------------------------------------------------------
FUNCTION expired_period_date(p_assignment_action_id IN NUMBER)
--
RETURN DATE IS
--
  l_end_date 	DATE;
--
    cursor expired_time_period (c_assignment_action_id IN NUMBER) is
    select ptp.end_date
    from per_time_periods ptp,
         pay_payroll_actions ppa,
         pay_assignment_actions paa
    WHERE
         paa.assignment_action_id = c_assignment_action_id
    AND  paa.payroll_action_id = ppa.payroll_action_id
    AND  ppa.time_period_id = ptp.time_period_id;
--
BEGIN
--
   open expired_time_period(p_assignment_action_id);
   fetch expired_time_period into l_end_date;
   close expired_time_period;
--
RETURN l_end_date;
--
END expired_period_date;
-------------------------------------------------------------------------------
-- 		FUNCTION expired_quarter_date
--		This function returns the expiry of an eff.dates quarter
-------------------------------------------------------------------------------
FUNCTION expired_quarter_date(p_action_effective_date IN DATE)
--
RETURN DATE IS
--
   l_expired_date	DATE;
   l_conv_us_gb_qd      DATE;
--
BEGIN
--
   --First convert to GB quarters
   l_conv_us_gb_qd := (trunc(p_action_effective_date -5,'Q')+5);
   --Then find the date of expiry of the quarter
   l_expired_date :=  ((ROUND(ADD_MONTHS(l_conv_us_gb_qd,1) + 16,'Q')) -1) + 5;
--
RETURN l_expired_date;
--
END expired_quarter_date;
-------------------------------------------------------------------------------
--		FUNCTION get_action_date
--		This function gets the effective date of an assignment action
-------------------------------------------------------------------------------
FUNCTION get_action_date(p_assignment_action_id IN NUMBER)
RETURN DATE IS
--
   l_effective_date     date;
--
   cursor c_bal_date is
   SELECT    ppa.effective_date
   FROM      pay_payroll_actions ppa,
             pay_assignment_actions paa
   WHERE     paa.payroll_action_id = ppa.payroll_action_id
   AND       paa.assignment_action_id = p_assignment_action_id;
--
 begin
--
   OPEN  c_bal_date;
   FETCH c_bal_date into l_effective_date;
   if c_bal_date%NOTFOUND then
      --raise_application_error(-20000,'This assignment action is invalid');
      --cant use as violates pragma wnds, so set date to null
      l_effective_date := null;
   end if;
   CLOSE c_bal_date;
--
   RETURN l_effective_date;
END get_action_date;
--
-------------------------------------------------------------------------------
--
END hr_dirbal;

/
