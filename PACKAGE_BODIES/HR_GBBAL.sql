--------------------------------------------------------
--  DDL for Package Body HR_GBBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_GBBAL" AS
/* $Header: pygbbal.pkb 120.10.12010000.2 2009/07/30 09:39:17 jvaradra ship $ */
--------------------------------------------------------------------------------
g_assignment_action_id number;
g_start_of_year per_time_periods.regular_payment_date%type;
-- g_initialization_exists number;
g_asg_td_ytd number;
g_assignment_action_id2 number;
g_assignment_id number;
g_action_sequence number;
g_effective_date date;
g_ni_a_id number;
g_ni_b_id number;
g_ni_c_id number;
g_ni_d_id number;
g_ni_e_id number;
g_ni_f_id number;
g_ni_g_id number;
g_ni_j_id number;
g_ni_l_id number;
g_ni_s_id number;
g_ni_a_able_id number;
g_ni_b_able_id number;
g_ni_c_able_id number;
g_ni_d_able_id number;
g_ni_e_able_id number;
g_ni_f_able_id number;
g_ni_g_able_id number;
g_ni_j_able_id number;
g_ni_l_able_id number;
g_ni_s_able_id number;
g_ni_a_defbal_id number;
g_ni_b_defbal_id number;
g_ni_c_defbal_id number;
g_ni_d_defbal_id number;
g_ni_e_defbal_id number;
g_ni_f_defbal_id number;
g_ni_g_defbal_id number;
g_ni_j_defbal_id number;
g_ni_l_defbal_id number;
g_ni_s_defbal_id number;
g_ni_a_able_defbal_id number;
g_ni_b_able_defbal_id number;
g_ni_c_able_defbal_id number;
g_ni_d_able_defbal_id number;
g_ni_e_able_defbal_id number;
g_ni_f_able_defbal_id number;
g_ni_g_able_defbal_id number;
g_ni_j_able_defbal_id number;
g_ni_l_able_defbal_id number;
g_ni_s_able_defbal_id number;
g_ni_a_exists number;
g_ni_b_exists number;
g_ni_c_exists number;
g_ni_d_exists number;
g_ni_e_exists number;
g_ni_f_exists number;
g_ni_g_exists number;
g_ni_j_exists number;
g_ni_l_exists number;
g_ni_s_exists number;
g_ni_cat_indicator_table_id number;
g_ni_element_type_id number;
g_ni_a_element_type_id number;
g_ni_b_element_type_id number;
g_ni_c_element_type_id number;
g_ni_d_element_type_id number;
g_ni_e_element_type_id number;
g_ni_f_element_type_id number;
g_ni_g_element_type_id number;
g_ni_j_element_type_id number;
g_ni_l_element_type_id number;
g_ni_s_element_type_id number;
g_action_typer pay_payroll_actions.action_type%TYPE;
g_action_typeq pay_payroll_actions.action_type%TYPE;
g_action_typeb pay_payroll_actions.action_type%TYPE;
g_balance number;

-- return the start of the span (year/quarter/week)
FUNCTION span_start(
  p_input_date    DATE,
  p_frequency   NUMBER DEFAULT 1,
  p_start_dd_mm   VARCHAR2 DEFAULT '06-04-')
RETURN DATE
IS
  l_year  NUMBER(4);
  l_start DATE;
  l_start_dd_mm varchar2(6);
  l_correct_format BOOLEAN;
--
BEGIN
  l_year := FND_NUMBER.CANONICAL_TO_NUMBER(TO_CHAR(p_input_date,'YYYY'));
   --
   -- Check that the passed in start of year
   -- is in the correct format. Add a hyphen if one is missing
   -- from the end, and ensure DD-MM- only has 6 characters.
   -- If none of these 2 criteria are met, return null.
   --
   if length(p_start_dd_mm) = 5 and instr(p_start_dd_mm,'-',-1) = 3 then
      l_start_dd_mm := p_start_dd_mm||'-';
      l_correct_format := TRUE;
   elsif length(p_start_dd_mm) = 6 and instr(p_start_dd_mm,'-',-1) = 6 then
      l_start_dd_mm := p_start_dd_mm;
      l_correct_format := TRUE;
   else
      l_correct_format := FALSE;
   end if;
   --
   if l_correct_format then
      IF p_input_date >= TO_DATE(l_start_dd_mm||TO_CHAR(l_year),'DD-MM-YYYY') THEN
        l_start := TO_DATE(l_start_dd_mm||TO_CHAR(l_year),'DD-MM-YYYY');
      ELSE
        l_start := TO_DATE(l_start_dd_mm||TO_CHAR(l_year -1),'DD-MM-YYYY');
      END IF;
      -- cater for weekly based frequency based on 52 per annum
      IF p_frequency IN (52,26,13) THEN
        l_start := p_input_date - MOD(p_input_date - l_start, 7 * (52/p_frequency));
      ELSE
      -- cater for monthly based frequency based on 12 per annum
        l_start := ADD_MONTHS(l_start, (12/p_frequency) * TRUNC(MONTHS_BETWEEN(
      p_input_date,l_start)/(12/p_frequency)));
      END IF;
   end if;
--
RETURN l_start;
END span_start;
-------------------------------------------------------------------------------
--
-- Function SPAN_END. This returns the end of the person level
-- (statutory) period.
--
-------------------------------------------------------------------------------
-- return the end of the span (year/quarter/week)
FUNCTION span_end(
        p_input_date            DATE,
        p_frequency             NUMBER DEFAULT 1,
        p_start_dd_mm           VARCHAR2 DEFAULT '06-04-')
RETURN DATE
IS
        l_year  NUMBER(4);
        l_end DATE;
        l_start_dd_mm varchar2(6);
        l_correct_format BOOLEAN;
--
BEGIN
        l_year := FND_NUMBER.CANONICAL_TO_NUMBER(TO_CHAR(p_input_date,'YYYY'));
   --
   -- Check that the passed in start of year
   -- is in the correct format. Add a hyphen if one is missing
   -- from the end, and ensure DD-MM- only has 6 characters.
   -- If none of these 2 criteria are met, return null.
   --
   if length(p_start_dd_mm) = 5 and instr(p_start_dd_mm,'-',-1) = 3 then
      l_start_dd_mm := p_start_dd_mm||'-';
      l_correct_format := TRUE;
   elsif length(p_start_dd_mm) = 6 and instr(p_start_dd_mm,'-',-1) = 6 then
      l_start_dd_mm := p_start_dd_mm;
      l_correct_format := TRUE;
   else
      l_correct_format := FALSE;
   end if;
   --
   if l_correct_format then
      IF p_input_date >= TO_DATE(l_start_dd_mm||TO_CHAR(l_year),'DD-MM-YYYY') THEN
        l_end := TO_DATE(l_start_dd_mm||TO_CHAR(l_year),'DD-MM-YYYY');
      ELSE
        l_end := TO_DATE(l_start_dd_mm||TO_CHAR(l_year -1),'DD-MM-YYYY');
      END IF;
      -- cater for weekly based frequency based on 52 per annum
      IF p_frequency IN (52,26,13) THEN
        l_end := p_input_date - MOD(p_input_date - l_end, 7 * (52/p_frequency))                 + ((7 * 52/p_frequency)-1);
      ELSE
      -- cater for monthly based frequency based on 12 per annum
        l_end := (add_months (ADD_MONTHS(l_end, (12/p_frequency)
    * TRUNC(MONTHS_BETWEEN(p_input_date,l_end)/(12/p_frequency))),
          12/p_frequency) -1);
      END IF;
   end if;
--
RETURN l_end;
END span_end;
--
--------------------------------------------------------------------------------
--
--                      GET CORRECT TYPE (private)
--
--
--------------------------------------------------------------------------------
--
-- This is a validation check to ensure that the assignment action is of the
-- correct type. This is called from all assignment action mode functions.
-- The assignment id is returned (and not assignment action id) because
-- this is to be used in the expired latest balance check. This function thus
-- has two uses - to validate the assignment action, and give the corresponding
-- assignmment id for that action.
--
FUNCTION get_correct_type(p_assignment_action_id IN NUMBER)
--
RETURN NUMBER IS
--
   l_assignment_id  NUMBER;
--
    cursor get_corr_type (c_assignment_action_id IN NUMBER) is
    SELECT assignment_id
    FROM pay_assignment_actions paa,
         pay_payroll_actions    ppa
    WHERE
         paa.assignment_action_id = c_assignment_action_id
    AND  ppa.payroll_action_id = paa.payroll_action_id
    AND  ppa.action_type        in ('R', 'Q', 'I', 'V', 'B');
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
--------------------------------------------------------------------------------
--
--                      GET LATEST ACTION ID (private)
--
--
--------------------------------------------------------------------------------
-- This function returns the latest assignment action ID given an assignment
-- and effective date. This is called from all Date Mode functions.
--
FUNCTION get_latest_action_id (p_assignment_id IN NUMBER,
             p_effective_date IN DATE)
RETURN NUMBER IS
--
   l_assignment_action_id   NUMBER;
   l_master_asg_action_id       NUMBER;
   l_child_asg_action_id       NUMBER;
--

/* bug fix 4493616 start*/
cursor get_master_latest_id (c_assignment_id IN NUMBER,
                 c_effective_date IN DATE) is
    SELECT /*+ USE_NL(paa, ppa) */
         fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||
         paa.assignment_action_id),16))
    FROM pay_assignment_actions paa,
         pay_payroll_actions    ppa
    WHERE
         paa.assignment_id = c_assignment_id
    AND  ppa.payroll_action_id = paa.payroll_action_id
    AND  paa.source_action_id is null
    AND  ppa.effective_date  <= c_effective_date
    AND  ppa.action_type     in ('R', 'Q', 'I', 'V', 'B');
 -- AND  paa.action_status   = 'C';
--

cursor get_latest_id (c_assignment_id IN NUMBER,
          c_effective_date IN DATE,
          c_master_asg_action_id IN NUMBER) is
    SELECT /*+ USE_NL(paa, ppa) */
         fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||
         paa.assignment_action_id),16))
    FROM pay_assignment_actions paa,
         pay_payroll_actions    ppa
    WHERE
         paa.assignment_id = c_assignment_id
    AND  ppa.payroll_action_id = paa.payroll_action_id
    AND  paa.source_action_id is not null
    AND  ppa.effective_date <= c_effective_date
    AND  ppa.action_type        in ('R', 'Q')
  --AND  paa.action_status = 'C'
    AND  paa.source_action_id = c_master_asg_action_id ;
--
BEGIN
--

    open  get_master_latest_id(p_assignment_id, p_effective_date);
    fetch get_master_latest_id into l_master_asg_action_id;

    if   get_master_latest_id%found then

   open  get_latest_id(p_assignment_id, p_effective_date,l_master_asg_action_id);
   fetch get_latest_id into l_child_asg_action_id;

   if l_child_asg_action_id is not null then
      l_assignment_action_id := l_child_asg_action_id;
   else
      l_assignment_action_id := l_master_asg_action_id;
   end if;
   close get_latest_id;
    end if;
    close get_master_latest_id;
/* bug fix 4493616 end*/
--
RETURN l_assignment_action_id;
--
END get_latest_action_id;
--
--------------------------------------------------------------------------------
--
--                       DIMENSION RELEVANT  (private)
--
--
--------------------------------------------------------------------------------
--
-- This function checks that a value is required for the dimension
-- for this particular balance type. If so, the defined balance is returned.
--
FUNCTION dimension_relevant(p_balance_type_id      IN NUMBER,
          p_database_item_suffix IN VARCHAR2)
RETURN NUMBER IS
--
   l_defined_balance_id NUMBER;
--
   cursor relevant(c_balance_type_id IN NUMBER,
       c_db_item_suffix  IN VARCHAR2) IS
   select pdb.defined_balance_id from
    pay_defined_balances pdb,
    pay_balance_dimensions pbd
   where pdb.balance_dimension_id = pbd.balance_dimension_id
   and pbd.database_item_suffix =  c_db_item_suffix
   and pdb.balance_type_id = c_balance_type_id;
--
BEGIN
--
   open relevant(p_balance_type_id, p_database_item_suffix);
   fetch relevant into l_defined_balance_id;
   close relevant;
--
RETURN l_defined_balance_id;
--
END dimension_relevant;
--------------------------------------------------------------------------------
--
--      GET LATEST DATE (private)
--
--
--------------------------------------------------------------------------------
--
-- Find out the effective date of the latest balance of a particular
-- assignment action.
--
FUNCTION get_latest_date(
        p_assignment_action_id  NUMBER)
RETURN DATE IS
--
   l_effective_date date;
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
      l_effective_date := null;
--       raise_application_error(-20000,'This assignment action is invalid');
   end if;
   CLOSE c_bal_date;
--
   RETURN l_effective_date;
END get_latest_date;
--
-------------------------------------------------------------------------------
--
--      GET_EXPIRED_YEAR_DATE (private)
--
-------------------------------------------------------------------------------
--
-- Find out the expiry of the year of the assignment action's effective date,
-- for expiry checking in the main functions.
--
FUNCTION get_expired_year_date(
             p_action_effective_date DATE)
RETURN DATE IS
--
   l_expired_date DATE;
   l_year_add_no  NUMBER;
--
BEGIN
--
 if p_action_effective_date is not null then
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
 end if;
--
   RETURN l_expired_date;
--
END get_expired_year_date;
--
------------------------------------------------------------------------------
--
--      GET_EXPIRED_TWO_YEAR_DATE (private)
-------------------------------------------------------------------------------
--
-- Find out the expiry of the year of the assignment action's effective date,
-- for the ASG_TD_ODD_TWO_YTD and ASG_TD_EVEN_TWO_YTD
--
FUNCTION get_expired_two_year_date(
             p_action_effective_date DATE,
             p_odd_even              VARCHAR2 )
RETURN DATE IS
   --
   l_expired_date DATE;
   l_year_add_no  NUMBER;
   --
BEGIN
   --
   IF p_action_effective_date is not null THEN
      --
      IF p_action_effective_date < to_date('06-04-' ||
            to_char(p_action_effective_date,'YYYY'),'DD-MM-YYYY')  THEN
         l_year_add_no := 0;
      ELSE
         l_year_add_no := 1;
      END IF;
      --
      -- add a year depending on the odd or even dimension
      --
      IF p_odd_even = 'EVEN' THEN
         IF mod(to_number(to_char(p_action_effective_date,'yyyy')),2) = 1 THEN
           l_year_add_no := l_year_add_no + 1;
         ELSE
           l_year_add_no := l_year_add_no;
         END IF;
      ELSIF p_odd_even = 'ODD' then
        IF mod(to_number(to_char(p_action_effective_date,'yyyy')),2) = 1 THEN
           l_year_add_no := l_year_add_no;
         ELSE
           l_year_add_no := l_year_add_no + 1;
         END IF;
      END IF;
      --
      -- Set expired date to the 6th of April of the expiring year.
      --
      l_expired_date :=  ( to_date('06-04-' ||
           to_char( fnd_number.canonical_to_number(to_char(
           p_action_effective_date,'YYYY')) + l_year_add_no),'DD-MM-YYYY'));
      --
   END IF;
   --
   RETURN l_expired_date;
   --
END get_expired_two_year_date;
---------------------------------------------------------------------------
--
-- what is the latest reset date for a particular dimension
FUNCTION dimension_reset_date(
  p_dimension_name  VARCHAR2,
  p_user_date     DATE,
  p_business_group_id NUMBER)
RETURN DATE
IS
  l_start_dd_mon    VARCHAR2(7);
  l_global_name   VARCHAR2(30);
  l_period_from_date  DATE;
  l_frequency   NUMBER;
  l_start_reset   NUMBER;
BEGIN
  IF SUBSTR(p_dimension_name,31,8) = 'USER-REG' THEN -- [
    l_start_reset := INSTR(p_dimension_name,'RESET',30);
    l_start_dd_mon := SUBSTR(p_dimension_name, l_start_reset - 6, 5);
    l_frequency := FND_NUMBER.CANONICAL_TO_NUMBER(SUBSTR
                                     (p_dimension_name, l_start_reset + 6, 2));
    l_period_from_date := span_start(p_user_date,
                                      l_frequency, l_start_dd_mon);
  END IF; -- ]

  /*                                                */
  /* User Irregular Balance are not yet implemented */
  /*                                                */
  /*
  IF SUBSTR(p_dimension_name,1,14) = 'USER IRREGULAR' THEN -- [
  --      find the global set up with the reset dates
  --      need to code exception if there isn't a valid one (default to calendar
  --      also make this code a local function
    l_start_word := INSTR(p_dimension_name,'BASED ON') + 8;
    l_global_name := SUBSTR(p_dimension_name, l_start_word);
    SELECT
      effective_start_date
    INTO
      l_period_from_date
    FROM
      ff_globals_f
    WHERE   global_name = l_global_name
    AND business_group_id = p_business_group_id
    AND p_user_date BETWEEN effective_start_date AND effective_end_date;
  END IF; -- ]
  */

  RETURN l_period_from_date;
END dimension_reset_date;
--------------------------------------------------------------------------------
-- when did the director become a director
-- find the earliest person row that was date effcetive in this year with
-- director flag set
FUNCTION start_director(
        p_assignment_id         NUMBER,
        p_start_date            DATE  ,
        p_end_date              DATE )
RETURN DATE
IS
        l_event_from_date date;
BEGIN
        select nvl(min(P.effective_start_date)
                  ,fnd_date.canonical_to_date('4712/12/31'))
                into l_event_from_date
                   from per_people_f p,  /* should this be all ? */
                        per_assignments_f ass
                   where p.per_information2 = 'Y'
                   and ASS.person_id = P.person_id
                   and P.effective_start_date <= p_end_date
                   and p.effective_end_date >=   p_start_date
                   and p_end_date between
                                ass.effective_start_date and ass.effective_end_date
                   and ass.assignment_id = p_assignment_id ;

        RETURN l_event_from_date;
END start_director;
--------------------------------------------------------------------------------
-- Function:    per_datemode_balance
-- Description: Introduced for bug fix 3436701, this expires Person level
-- balances before calling the core balance UE process to get the value.
-- The Core BUE cannot be called in datemode directly as this causes an
-- error from the view, because it issues DML and commits.
--------------------------------------------------------------------------------
Function per_datemode_balance(p_assignment_action_id in number,
                              p_defined_balance_id   in number,
                              p_database_item_suffix in varchar2,
                              p_effective_date       in date) return number is
--
    cursor expired_time_period (c_assignment_action_id IN NUMBER) is
    SELECT ptp.end_date, ppa.effective_date
    FROM per_time_periods ptp,
         pay_payroll_actions ppa,
         pay_assignment_actions paa
    WHERE
         paa.assignment_action_id = c_assignment_action_id
    AND  paa.payroll_action_id = ppa.payroll_action_id
    AND  ppa.time_period_id = ptp.time_period_id;
--
    l_period_end_date       DATE;
    l_date_paid             DATE;
    l_balance               NUMBER;
    l_action_eff_date       DATE;
    l_expiry_date           DATE;
--
BEGIN
--
  IF p_database_item_suffix in ('_PER_TD_STAT_PTD',
                                '_PER_TD_PTD',
                                '_PER_NI_PTD',
                                '_PER_TD_CPE_STAT_PTD') THEN
     open expired_time_period(p_assignment_action_id);
     fetch expired_time_period INTO l_period_end_date, l_date_paid;
     close expired_time_period;
     --hr_utility.trace('PER - Dates: end='||l_period_end_date||' paid='|| l_date_paid);
     --
     l_expiry_date := greatest(l_period_end_date,l_date_paid);
     --
  ELSIF p_database_item_suffix in ('_PER_TD_YTD',
                                   '_PER_TD_DIR_YTD',
                                   '_PER_TD_CPE_YTD') THEN
     l_action_eff_date := get_latest_date(p_assignment_action_id);
     --
     l_expiry_date := get_expired_year_date(l_action_eff_date);
  ELSIF p_database_item_suffix = '_PER_TD_EVEN_TWO_YTD' THEN
     --
     l_action_eff_date := get_latest_date(p_assignment_action_id);
     l_expiry_date := get_expired_two_year_date(l_action_eff_date,'EVEN');
  ELSIF p_database_item_suffix = '_PER_TD_ODD_TWO_YTD' THEN
     --
     l_action_eff_date := get_latest_date(p_assignment_action_id);
     l_expiry_date := get_expired_two_year_date(l_action_eff_date,'ODD');
  ELSE
     -- A non-covered PER expiry, call pkg without expiring here
     l_expiry_date := to_date('31/12/4712','DD/MM/YYYY');
  END IF;
  --
  -- Expiry dates set, check the effective date
  --
  /*Bug fix 5104943*/
 IF p_database_item_suffix in ('_PER_TD_STAT_PTD', '_PER_TD_PTD','_PER_NI_PTD','_PER_TD_CPE_STAT_PTD') THEN
    if  p_effective_date > l_expiry_date then
        -- Balance has expired
        l_balance := 0;
    else
        l_balance := pay_balance_pkg.get_value(p_defined_balance_id,
                 p_assignment_action_id);
    end if;
 ELSE
          if  p_effective_date >= l_expiry_date then
        -- Balance has expired
        l_balance := 0;
    else
        l_balance := pay_balance_pkg.get_value(p_defined_balance_id,
                 p_assignment_action_id);
    end if;
 END IF;

--
RETURN l_balance;
--
END per_datemode_balance;
--------------------------------------------------------------------------------
--
--                               BALANCE                                   --
--  Called from calc_all_balances for User Regulars and other non UK seeded
--  balances, also called from pay_gb_balances_v.
--
--------------------------------------------------------------------------------
--
FUNCTION balance(
        p_assignment_action_id  IN NUMBER,
        p_defined_balance_id    IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL)
RETURN NUMBER
IS
--
        l_balance               NUMBER;
        l_balance1              NUMBER;
        l_assignment_id         NUMBER;
        l_balance_type_id       NUMBER;
        l_period_from_date      DATE := FND_DATE.CANONICAL_TO_DATE('0001/01/01');
        l_event_from_date       DATE := FND_DATE.CANONICAL_TO_DATE('0001/01/01');
        l_to_date               DATE;
        l_regular_payment_date  DATE;
        l_action_sequence       NUMBER;
        l_business_group_id     NUMBER;
        l_dimension_bgid        NUMBER;
        l_dimension_name        pay_balance_dimensions.dimension_name%TYPE;
        l_database_item_suffix  pay_balance_dimensions.database_item_suffix%TYPE;
        l_legislation_code      pay_balance_dimensions.legislation_code%TYPE;
        l_latest_value_exists   VARCHAR(2);
        l_period_end_date       DATE;
        l_date_paid             DATE;
--
        cursor c1  (c_asg_action_id IN NUMBER,
                    c_defined_balance_id IN NUMBER)is
        SELECT value, assignment_id
        from  pay_assignment_latest_balances
        Where assignment_action_id = c_asg_action_id
        and   defined_balance_id = c_defined_balance_id;
--
        cursor action_context is
        SELECT
                BAL_ASSACT.assignment_id,
                BAL_ASSACT.action_sequence,
                BACT.effective_date,
                PTP.regular_payment_date,
                BACT.business_group_id
        FROM
                pay_assignment_actions  BAL_ASSACT,
                pay_payroll_actions             BACT,
                per_time_periods                        PTP
        WHERE
                BAL_ASSACT.assignment_action_id = p_assignment_action_id
        AND     PTP.time_period_id = BACT.time_period_id
        AND     BACT.payroll_action_id = BAL_ASSACT.payroll_action_id;
--
        cursor balance_dimension is
        SELECT
                DB.balance_type_id,
                DIM.dimension_name,
                DIM.database_item_suffix ,
                DIM.legislation_code,
                DIM.business_group_id
        FROM
                pay_defined_balances    DB,
                pay_balance_dimensions  DIM
        WHERE   DB.defined_balance_id = p_defined_balance_id
        AND     DIM.balance_dimension_id = DB.balance_dimension_id;
--
BEGIN
--
-- get the context of the using action
--
   open action_context;
   FETCH action_context INTO
         l_assignment_id,
         l_action_sequence,
         l_to_date,
         l_regular_payment_date,
         l_business_group_id;
   CLOSE action_context;
--
-- from the item name determine what balance and dimension it is
--
   open balance_dimension;
   FETCH balance_dimension INTO
         l_balance_type_id,
         l_dimension_name,
         l_database_item_suffix ,
         l_legislation_code,
         l_dimension_bgid;
   close balance_dimension;
--
-- Bug 2755875. New routes added that are core routes. In this case
-- the core BUE must be called with the passed-in parameters.
-- This will use the latest balance if it exists.
-- Check the BGID incase this is a user-defined user-reg dimension.
-- Bug 2886012, handle the exception just incase no dimension found.

   IF l_legislation_code is null AND l_dimension_bgid is null then
   --
     BEGIN
        l_balance := pay_balance_pkg.get_value(
                    p_assignment_action_id => p_assignment_action_id,
                    p_defined_balance_id   => p_defined_balance_id);
     EXCEPTION WHEN NO_DATA_FOUND THEN
        l_balance := null;
     END;
   --
   ELSE -- A GB or user balance

   -- Does the assignment action id exist in the latest balances table
   --
    /* Commented for bug fix 4452262*/
    /*  OPEN c1 (p_assignment_action_id, p_defined_balance_id);
      FETCH c1 INTO l_balance, l_assignment_id;
         IF c1%FOUND THEN l_latest_value_exists := 'T';
         ELSE l_latest_value_exists := 'F';
         END IF;
      CLOSE c1;
      */

      /*For bug fix 4452262*/
      l_latest_value_exists := 'F';
      for i in c1 (p_assignment_action_id, p_defined_balance_id)
      loop
            l_balance       :=  nvl(l_balance,0) + nvl(i.value,0);
      l_assignment_id := i.assignment_id;

      l_latest_value_exists := 'T';

      end loop;
   --
   -- Bug 923689. Raise NDF to stop date-format error from span_start.
   --
      IF l_to_date is null
         then RAISE NO_DATA_FOUND;
      end if;
   --
   -- If the latest bal value doesn't exist further action is necessary
   --
      IF l_latest_value_exists = 'F' then
   --
   --   for seeded person level dimensions call the core function
   --
        IF substr(l_database_item_suffix,1,4) = '_PER'
                and l_legislation_code = 'GB' THEN
          BEGIN
            -- Bug fix 3436701.
            IF p_effective_date is not null then
              -- This is a Datemode call for PER level balance
              l_balance1 := per_datemode_balance(p_assignment_action_id,
                                                p_defined_balance_id,
                                                l_database_item_suffix,
                                                p_effective_date);

              /*For bug fix 4452262*/
       g_balance := nvl(g_balance,0) + nvl(l_balance1,0);
             l_balance := g_balance;


            ELSE
             -- Assignment Action mode call as before
              l_balance := pay_balance_pkg.get_value(p_defined_balance_id,
                                                 p_assignment_action_id);


            END IF;
           EXCEPTION WHEN NO_DATA_FOUND THEN
            l_balance := null;
          END;
   --
        ELSE  -- Not a person-level balance, either USER-REG OR CALENDAR
   --
   --      IMPORTANT NOTE: For user-regs this must never call core
   --      balance package, must work out route locally.
   --
   --      from the dimension work out the from dates
   --      CALENDAR has no event start
   --
           IF l_dimension_name = '_ASG_CALENDAR_YTD' THEN
              l_period_from_date := TRUNC(l_regular_payment_date,'YYYY');
           END IF;
           IF l_dimension_name = '_ASG_CALENDAR_QTD' THEN
              l_period_from_date := TRUNC(l_regular_payment_date,'Q');
           END IF;
   --
   --      evaluate user-defined (USER-REG) dimensions
   --
           IF SUBSTR(l_dimension_name,31,4) = 'USER' THEN
              l_period_from_date := dimension_reset_date(
                                                l_dimension_name,
                                                l_regular_payment_date,
                                                l_business_group_id);
           END IF;
   --
   --      USER REGS MUST USE THIS GENERIC ROUTE FUNCTION.
   --
           l_balance := calc_balance(
                l_assignment_id,
                l_balance_type_id,
                l_period_from_date,
                l_event_from_date,
                l_to_date,
                l_action_sequence);
        END IF; -- Person Level Balance
     END IF; -- Latest Balance
   END IF; -- Core Balance
--
   RETURN l_balance;
--
END balance;
--
--------------------------------------------------------------------------------
--
--                          GET_LATEST_ELEMENT_BAL (Private)
--    calculate latest balances for element dimensions
--
--------------------------------------------------------------------------------
--
FUNCTION get_latest_element_bal(
        p_assignment_action_id  IN NUMBER,
        p_defined_bal_id        IN NUMBER,
        p_source_id           IN NUMBER)
--
RETURN NUMBER IS
--
   l_balance               NUMBER;
   l_db_item_suffix        VARCHAR2(30);
   l_defined_bal_id      NUMBER;
--
   cursor element_latest_bal(c_assignment_action_id IN NUMBER,
           c_defined_bal_id     IN NUMBER,
           c_source_id            IN NUMBER) is
   select palb.value
   from pay_assignment_latest_balances palb,
        pay_balance_context_values pbcv
   where pbcv.context_id = c_source_id
   and   pbcv.latest_balance_id = palb.latest_balance_id
   and   palb.assignment_action_id = c_assignment_action_id
   and   palb.defined_balance_id = c_defined_bal_id;
--
BEGIN
--
   open element_latest_bal(p_assignment_action_id,
         p_defined_bal_id,
         p_source_id);
   fetch element_latest_bal into l_balance;
   close element_latest_bal;
--
RETURN l_balance;
--
END get_latest_element_bal;

--
-----------------------------------------------------------------------------
--
--      CALC_ELEMENT_CO_REF_ITD_BAL
-----------------------------------------------------------------------------
--
/* For bug fix 4452262*/
FUNCTION calc_element_co_itd_bal(p_assignment_action_id IN NUMBER,
                   p_balance_type_id      IN NUMBER,
               p_source_id          IN NUMBER,
               p_source_text          IN VARCHAR2)
RETURN NUMBER IS
--
   l_balance      NUMBER;
   l_defined_bal_id NUMBER;
   l_context NUMBER;
--

cursor get_context_id is
SELECT CONTEXT_ID
FROM FF_CONTEXTS
where context_name ='SOURCE_TEXT';

BEGIN
--
   l_defined_bal_id := dimension_relevant(p_balance_type_id, '_ELEMENT_CO_REF_ITD');

   open get_context_id;
   fetch get_context_id into l_context;
   close get_context_id;

   if l_defined_bal_id is not null then

      l_balance := get_latest_element_bal(p_assignment_action_id,
                  l_defined_bal_id,
                  p_source_id);
      if l_balance is null then
           pay_balance_pkg.set_context('ORIGINAL_ENTRY_ID'
                                    , p_source_id);
     pay_balance_pkg.set_context('SOURCE_TEXT'
                                    , p_source_text);

          l_balance := pay_balance_pkg.get_value(l_defined_bal_id, p_assignment_action_id);
     end if;
   else l_balance := null;
--
   end if;
--
RETURN l_balance;
--
END calc_element_co_itd_bal;
-----------------------------------------------------------------------------
--
--      CALC_ELEMENT_ITD_BAL
-----------------------------------------------------------------------------
--
FUNCTION calc_element_itd_bal(p_assignment_action_id IN NUMBER,
                p_balance_type_id      IN NUMBER,
            p_source_id      IN NUMBER)
RETURN NUMBER IS
--
   l_balance      NUMBER;
   l_defined_bal_id NUMBER;
--
BEGIN
--
   l_defined_bal_id := dimension_relevant(p_balance_type_id, '_ELEMENT_ITD');
   if l_defined_bal_id is not null then
      l_balance := get_latest_element_bal(p_assignment_action_id,
                  l_defined_bal_id,
                  p_source_id);
      if l_balance is null then
         pay_balance_pkg.set_context('ORIGINAL_ENTRY_ID'
                                    , p_source_id);
         l_balance := pay_balance_pkg.get_value(l_defined_bal_id,
                                            p_assignment_action_id);
--
      end if;
   else l_balance := null;
--
   end if;
--
RETURN l_balance;
--
END calc_element_itd_bal;
--
-----------------------------------------------------------------------------
--
--                      CALC_ELEMENT_PTD_BAL
-----------------------------------------------------------------------------
--
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
   l_defined_bal_id := dimension_relevant(p_balance_type_id, '_ELEMENT_PTD');
   if l_defined_bal_id is not null then

      l_balance := get_latest_element_bal(p_assignment_action_id,
                                          l_defined_bal_id,
                                          p_source_id);
      if l_balance is null then
--
         pay_balance_pkg.set_context('ORIGINAL_ENTRY_ID'
                                    , p_source_id);
         l_balance := pay_balance_pkg.get_value(l_defined_bal_id,
                                            p_assignment_action_id);
      end if;
   else l_balance := null;
--
   end if;
--
RETURN l_balance;
--
END calc_element_ptd_bal;
--
-----------------------------------------------------------------------------
--
--                          CALC_ALL_BALANCES
--    This is the generic overloaded function for calculating all balances
--    in assignment action mode. NB Element level balances cannot be called
--    from here as they require further context.
-----------------------------------------------------------------------------
--
FUNCTION calc_all_balances(
         p_assignment_action_id IN NUMBER,
         p_defined_balance_id   IN NUMBER)
--
RETURN NUMBER
IS
--
    l_balance                   NUMBER;
    l_balance_type_id           NUMBER;
    l_dimension_name          VARCHAR2(80);
--
    cursor get_balance_type_id(c_defined_balance_id IN NUMBER) IS
      select pdb.balance_type_id,
             pbd.dimension_name
      from   pay_balance_dimensions pbd,
             pay_defined_balances   pdb
      where  pdb.defined_balance_id = c_defined_balance_id
      and    pdb.balance_dimension_id = pbd.balance_dimension_id;
--
BEGIN
--
   open get_balance_type_id(p_defined_balance_id);
   FETCH get_balance_type_id INTO
         l_balance_type_id, l_dimension_name;
   CLOSE get_balance_type_id;
--
      If l_dimension_name like '%_ASG_YTD' then
         l_balance := calc_asg_ytd_action(p_assignment_action_id,
                                          l_balance_type_id);
      Elsif l_dimension_name  like '%_ASG_PROC_YTD' then
         l_balance := calc_asg_proc_ytd_action(p_assignment_action_id,
                                               l_balance_type_id);
      Elsif l_dimension_name like '%_ASG_RUN' then
         l_balance := calc_asg_run_action(p_assignment_action_id,
                                               l_balance_type_id);
      Elsif l_dimension_name like  '%_ASG_TD_YTD' then
         l_balance := calc_asg_td_ytd_action(p_assignment_action_id,
                                               l_balance_type_id);
      Elsif l_dimension_name like  '%_ASG_ITD' then
         l_balance := calc_asg_itd_action(p_assignment_action_id,
                                               l_balance_type_id);
      Elsif l_dimension_name like '%_ASG_QTD' then
         l_balance := calc_asg_qtd_action(p_assignment_action_id,
                                               l_balance_type_id);
      Elsif l_dimension_name like '%_ASG_STAT_YTD' then
         l_balance := calc_asg_stat_ytd_action(p_assignment_action_id,
                                               l_balance_type_id);
      Elsif l_dimension_name like '%_ASG_PROC_PTD' then
         l_balance := calc_asg_proc_ptd_action(p_assignment_action_id,
                                               l_balance_type_id);
      Elsif l_dimension_name like  '%_ASG_TD_ITD' then
         l_balance := calc_asg_td_itd_action(p_assignment_action_id,
                                               l_balance_type_id);
      Elsif l_dimension_name like '%_ASG_TRANSFER_PTD' then
         l_balance := calc_asg_tfr_ptd_action(p_assignment_action_id,
                                               l_balance_type_id);
      --
      -- added odd and even by skutteti
      --
      Elsif l_dimension_name like '%_ASG_TD_ODD_TWO_YTD' then
         l_balance := calc_asg_td_odd_two_ytd_action(p_assignment_action_id,
                                                    l_balance_type_id);
      Elsif l_dimension_name like '%_ASG_TD_EVEN_TWO_YTD' then
         l_balance := calc_asg_td_even_two_ytd_actio(p_assignment_action_id,
                                             l_balance_type_id);
      Elsif l_dimension_name like '%_PAYMENTS' then
         l_balance := calc_payment_action(p_assignment_action_id,
                                               l_balance_type_id);
      Elsif l_dimension_name like '%_SOE_RUN' then
         l_balance := calc_payment_action(p_assignment_action_id,
                                               l_balance_type_id);
      Elsif l_dimension_name like '%_PER_PTD' then
         --hr_utility.trace('PER - Action');
         l_balance := calc_per_ptd_action(p_assignment_action_id,
                                               l_balance_type_id);
      --Else for all other dimensions
      Else
         l_balance := pay_balance_pkg.get_value(p_defined_balance_id,
                                              p_assignment_action_id);
      End If;
--
   RETURN l_balance;
--
END calc_all_balances;
--
-----------------------------------------------------------------------------
--
--                          CALC_ALL_BALANCES
--
--  This is the overloaded generic function for calculating all balances
--  in Date Mode. NB Element level balances cannot be obtained from here as
--  they require further context.
--  This now calls the Core balance package, which could not be called directly
--  from a view in date mode as core date-mode creates an asg action.
-----------------------------------------------------------------------------
--
FUNCTION calc_all_balances(
         p_effective_date       IN DATE,
         p_assignment_id        IN NUMBER,
         p_defined_balance_id   IN NUMBER)
--
RETURN NUMBER
IS
--
    l_balance                   NUMBER;
    l_balance1                  NUMBER;
    l_balance_type_id           NUMBER;
    l_route_id                  NUMBER;
    l_dimension_name            VARCHAR2(80);
    l_assignment_action_id      NUMBER;
    l_context_name              VARCHAR2(80);
    l_context_value             VARCHAR2(80);
--
    cursor get_balance_type_id(c_defined_balance_id IN NUMBER) IS
      select pdb.balance_type_id,
             pbd.dimension_name,
             pbd.route_id
      from   pay_balance_dimensions pbd,
             pay_defined_balances   pdb
      where  pdb.defined_balance_id = c_defined_balance_id
      and    pdb.balance_dimension_id = pbd.balance_dimension_id;
--
    cursor get_context(p_route_id   IN NUMBER,
                       p_act_id     IN NUMBER,
                       p_context_01 IN VARCHAR2,
                       p_context_02 IN VARCHAR2
                       )
    is
       select  pca.context_value,
               ffc.context_name
        from   pay_action_contexts     pca,
               ff_contexts             ffc,
               ff_route_context_usages frc,
               pay_balance_dimensions  pbd
        where  pbd.route_id = p_route_id
        and    pbd.route_id = frc.route_id
        and    frc.context_id = ffc.context_id
        and    ffc.context_id = pca.context_id
        and    pca.assignment_action_id = p_act_id
        and   (ffc.context_name = p_context_01 OR ffc.context_name = p_context_02)
        and   (ffc.context_name <> 'SOURCE_TEXT'
         or   (ffc.context_name = 'SOURCE_TEXT' AND
             exists ( select 1
                      from   pay_run_results       rr,
                             pay_run_result_values rrv,
                             pay_input_values_f    piv,
                             pay_element_types_f   petf
                      where  rr.assignment_action_id = pca.assignment_action_id
                      and    rr.element_type_id    = petf.element_type_id
                      and    rr.run_result_id      = rrv.run_result_id
                      and    piv.input_value_id    = rrv.input_value_id
                      and    piv.name              = 'Reference'
                      and    nvl(rrv.result_value, 'Unknown') = pca.context_value
                      and    petf.element_name     IN
                      (
                      'CAO Scotland', 'CAO Scotland NTPP', 'CMA Scotland', 'CMA Scotland NTPP', 'Court Order',
                      'Court Order NTPP', 'Court Order Non Priority', 'Court Order Non Priority NTPP',
                      'EAS Scotland', 'EAS Scotland NTPP', 'Setup Court Order Balance'
                      )
                    )
              )
              );
--
BEGIN
--
   open get_balance_type_id(p_defined_balance_id);
   FETCH get_balance_type_id INTO
         l_balance_type_id, l_dimension_name, l_route_id;
   CLOSE get_balance_type_id;

   -- begin bug fix 4311080
   l_assignment_action_id := get_latest_action_id(p_assignment_id, p_effective_date);

/* for Bug 6262406 */
/*
   OPEN  get_context(l_route_id, l_assignment_action_id);
   FETCH get_context INTO l_context_value, l_context_name;
   CLOSE get_context;

   IF l_context_name = 'SOURCE_TEXT' then
      pay_balance_pkg.set_context(l_context_name, l_context_value);
   END IF;

   -- end bug fix 4311080 */
--
      If l_dimension_name like '%_ASG_YTD' then
         l_balance := calc_asg_ytd_date(p_assignment_id,
                                        l_balance_type_id,
          p_effective_date);
      Elsif l_dimension_name like '%_ASG_PROC_YTD' then
         l_balance := calc_asg_proc_ytd_date(p_assignment_id,
                                             l_balance_type_id,
               p_effective_date);
      Elsif l_dimension_name like '%_ASG_RUN' then
         l_balance := calc_asg_run_date(p_assignment_id,
                                        l_balance_type_id,
          p_effective_date);
      Elsif l_dimension_name like '%_ASG_TD_YTD' then
         l_balance := calc_asg_td_ytd_date(p_assignment_id,
                                           l_balance_type_id,
             p_effective_date);
      Elsif l_dimension_name like '%_ASG_ITD' then
         l_balance := calc_asg_itd_date(p_assignment_id,
                                        l_balance_type_id,
          p_effective_date);
      Elsif l_dimension_name like  '%_ASG_QTD' then
         l_balance := calc_asg_qtd_date(p_assignment_id,
                                        l_balance_type_id,
          p_effective_date);
      Elsif l_dimension_name like  '%_ASG_STAT_YTD' then
         l_balance := calc_asg_stat_ytd_date(p_assignment_id,
                                             l_balance_type_id,
               p_effective_date);
      Elsif l_dimension_name like '%_ASG_PROC_PTD' then
         l_balance := calc_asg_proc_ptd_date(p_assignment_id,
                                             l_balance_type_id,
               p_effective_date);
      Elsif l_dimension_name like '%_ASG_TD_ITD' then
         l_balance := calc_asg_td_itd_date(p_assignment_id,
                                           l_balance_type_id,
             p_effective_date);
      Elsif l_dimension_name like '%_ASG_TRANSFER_PTD' then
         l_balance := calc_asg_tfr_ptd_date(p_assignment_id,
                                            l_balance_type_id,
              p_effective_date);
      Elsif l_dimension_name like '%_ASG_TD_ODD_TWO_YTD' then
         l_balance := calc_asg_td_odd_two_ytd_date(p_assignment_id,
                                               l_balance_type_id,
                                               p_effective_date);
      Elsif l_dimension_name like '%_ASG_TD_EVEN_TWO_YTD' then
         l_balance := calc_asg_td_even_two_ytd_date(p_assignment_id,
                                               l_balance_type_id,
                                               p_effective_date);
      Elsif l_dimension_name like '%_PAYMENTS' then
         l_balance := calc_payment_date(p_assignment_id,
                                        l_balance_type_id,
          p_effective_date);
      Elsif l_dimension_name like '%_SOE_RUN' then
         l_balance := calc_payment_date(p_assignment_id,
                                        l_balance_type_id,
                                        p_effective_date);
      Elsif l_dimension_name like '%_PER_PTD' then
         --hr_utility.trace('PER - Date');
         l_balance := calc_per_ptd_date(p_assignment_id,
                                        l_balance_type_id,
                                        p_effective_date);
      /*For bug fix 4452262*/
/* for Bug 6262406 */
      Elsif l_dimension_name like '%_PER_CO_TD_REF_ITD' or l_dimension_name like '%_PER_CO_TD_REF_PTD' then
        FOR J IN get_context(l_route_id, l_assignment_action_id, 'SOURCE_TEXT', 'SOURCE_TEXT')
        LOOP
           IF j.context_name = 'SOURCE_TEXT' then
              pay_balance_pkg.set_context(j.context_name, j.context_value);
           END IF;
           l_balance := balance(l_assignment_action_id, p_defined_balance_id, p_effective_date);
        END LOOP;
        g_balance := 0;

      Elsif l_dimension_name like '%_ELEMENT_ITD' or  l_dimension_name like '%_ELEMENT_PTD' or
            l_dimension_name like '%_ELEMENT_CO_REF_ITD' then
        l_balance := balance(l_assignment_action_id, p_defined_balance_id, p_effective_date);
        g_balance := 0;

      Else
         -- For all other dimensions
         -- latest assignment action is set at the top, so comment out this called
         -- l_assignment_action_id := get_latest_action_id(p_assignment_id, p_effective_date);
         g_balance := 0;
         l_balance := balance(l_assignment_action_id,
                              p_defined_balance_id,
                              p_effective_date);
      End If;
--
   RETURN l_balance;
--
END calc_all_balances;

--
-----------------------------------------------------------------------------
--
--      CALC_PER_PTD
-----------------------------------------------------------------------------
--

FUNCTION calc_per_ptd(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
        p_assignment_id   IN NUMBER)
RETURN NUMBER IS
--
        l_balance               NUMBER;
        l_defined_bal_id  NUMBER;
--
BEGIN
--
--Do we need to work out a value for this dimension/balance combination.
--
  l_defined_bal_id := dimension_relevant(p_balance_type_id, '_PER_PTD');
  --hr_utility.trace('PER - Dimension relevant?');
  IF l_defined_bal_id IS NOT NULL THEN
    --hr_utility.trace('PER - Dimension is relevant');
    --
    -- Call core balance pkg with the defined balance just retrieved.
    l_balance := pay_balance_pkg.get_value(l_defined_bal_id,
                                           p_assignment_action_id);

  ELSE
   --hr_utility.trace('PER - Dimension not relevant');
   l_balance := null;
  END IF;
  RETURN l_balance;
--
END calc_per_ptd;

-----------------------------------------------------------------------
FUNCTION calc_per_ptd_action(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL)
RETURN NUMBER
IS
--
    l_assignment_action_id      NUMBER;
    l_balance                   NUMBER;
    l_assignment_id             NUMBER;
    l_action_eff_date            DATE;
--
BEGIN
--
  --
  --  Check if assignment action is of type ('R', 'Q', 'I', 'V', 'B')
  --
  l_assignment_id := get_correct_type(p_assignment_action_id);
  --hr_utility.trace('PER - Ass id='||l_assignment_id );
  IF l_assignment_id is null THEN
    l_balance := null;
  ELSE
    --hr_utility.trace('PER - get bal');
    l_balance := calc_per_ptd(
                              p_assignment_action_id => p_assignment_action_id,
                              p_balance_type_id      => p_balance_type_id,
                              p_effective_date       => p_effective_date,
                              p_assignment_id        => l_assignment_id);
    --hr_utility.trace('PER - Bal='|| l_balance);
  END IF;
  --
  RETURN l_balance;
end calc_per_ptd_action;

-----------------------------------------------------------------------
FUNCTION calc_per_ptd_date(
        p_assignment_id         IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE)
RETURN NUMBER
IS
--
    l_assignment_action_id      NUMBER;
    l_balance                   NUMBER;
    l_end_date                  DATE;
    l_action_eff_date           DATE;
--
BEGIN
  --
  l_assignment_action_id := get_latest_action_id(p_assignment_id,
               p_effective_date);
  --hr_utility.trace('PER - Action id='||l_assignment_action_id );
  IF l_assignment_action_id is null then
     l_balance := 0;
  ELSE
    --   Chk date now
    l_action_eff_date := get_latest_date(l_assignment_action_id);
    --hr_utility.trace('PER - Action dt='||l_action_eff_date );
    --
    --   Is effective date (sess) later than the action effective date.
    --
    IF p_effective_date > l_action_eff_date THEN
      --hr_utility.trace('PER - Not Getting Bal');
      l_balance := 0;
    ELSE
      --hr_utility.trace('PER - Getting Bal');
      l_balance := calc_per_ptd(
                                p_assignment_action_id => l_assignment_action_id,
                                p_balance_type_id      => p_balance_type_id,
                                p_effective_date       => p_effective_date,
        p_assignment_id        => p_assignment_id);
      --hr_utility.trace('PER - Bal='||l_balance);
    END IF;
  END IF;
  --
  RETURN l_balance;
end calc_per_ptd_date;
--
-----------------------------------------------------------------------------
---
--
--                          CALC_ASG_PROC_YTD_ACTION
--
--    This is the function for calculating assignment year to
--                      date in asg action mode
--
-----------------------------------------------------------------------------
--
FUNCTION calc_asg_proc_ytd_action(
         p_assignment_action_id IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER
IS
--
    l_assignment_action_id      NUMBER;
    l_balance                   NUMBER;
    l_assignment_id             NUMBER;
    l_effective_date            DATE;
--
BEGIN
--
    l_assignment_id := get_correct_type(p_assignment_action_id);
    IF l_assignment_id is null THEN
--
--  The assignment action is not a payroll or quickpay type, so return null
--
    l_balance := null;
    ELSE
--
       l_balance := calc_asg_proc_ytd(
                                 p_assignment_action_id => p_assignment_action_id,
                                 p_balance_type_id      => p_balance_type_id,
                                 p_effective_date       => p_effective_date,
         p_assignment_id        => l_assignment_id);
    END IF;
--
   RETURN l_balance;
end calc_asg_proc_ytd_action;
--
-----------------------------------------------------------------------------
---
--
--                          CALC_ASG_PROC_YTD_DATE                              -
--
--    This is the function for calculating assignment proc year to
--                      date in date mode
--
-----------------------------------------------------------------------------
--
FUNCTION calc_asg_proc_ytd_date(
         p_assignment_id        IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER
IS
--
    l_assignment_action_id      NUMBER;
    l_balance                   NUMBER;
    l_end_date                  DATE;
    l_action_eff_date           DATE;
--
BEGIN
--
    l_assignment_action_id := get_latest_action_id(p_assignment_id,
               p_effective_date);
    IF l_assignment_action_id is null then
       l_balance := 0;
    ELSE
--     start expiry chk now
       l_action_eff_date := get_latest_date(l_assignment_action_id);
--
--     Is effective date (sess) later than the expiry of the financial year of the
--     effective date.
--
       if p_effective_date >= get_expired_year_date(l_action_eff_date) then
         l_balance := 0;
       else
--
       l_balance := calc_asg_proc_ytd(
                                 p_assignment_action_id => l_assignment_action_id,
                                 p_balance_type_id      => p_balance_type_id,
                                 p_effective_date       => p_effective_date,
         p_assignment_id  => p_assignment_id);
       end if;
    END IF;
--
   RETURN l_balance;
end calc_asg_proc_ytd_date;
--
--------------------------------------------------------------------------------
--
--                          CALC_ASG_PROC_YTD                                    --
--  calculate balances for Assignment process year to date
--
--------------------------------------------------------------------------------
-- Assignment Process Year -
-- This dimension is the total for an assignment within the processing
-- year of his current payroll, OR if the assignment has transferred
-- payroll within the current processing year, it is the total since
-- he joined the current payroll.

-- This dimension should be used for the year dimension of balances
-- which are reset to zero on transferring payroll.
--
FUNCTION calc_asg_proc_ytd(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
        p_assignment_id       IN NUMBER
                           )
RETURN NUMBER
IS
--
        l_balance               NUMBER;
        l_defined_bal_id  NUMBER;
--
BEGIN
--
--Do we need to work out a value for this dimension/balance combination.
--
 l_defined_bal_id := dimension_relevant(p_balance_type_id, '_ASG_PROC_YTD');
 if l_defined_bal_id is not null then
   --
   -- Call core balance pkg with the defined balance just retrieved.
   l_balance := pay_balance_pkg.get_value(l_defined_bal_id,
                                          p_assignment_action_id);
   --
 else l_balance := null;
 end if;
   RETURN l_balance;
--
   END calc_asg_proc_ytd;
-----------------------------------------------------------------------------
---
--
--                          CALC_ASG_QTD_ACTION                              -
--
--    This is the function for calculating assignment quarter to
--                      date in asg action mode
--
-----------------------------------------------------------------------------
--
FUNCTION calc_asg_qtd_action(
         p_assignment_action_id IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER
IS
--
    l_assignment_action_id      NUMBER;
    l_balance                   NUMBER;
    l_assignment_id             NUMBER;
    l_effective_date            DATE;
--
BEGIN
--
    l_assignment_id := get_correct_type(p_assignment_action_id);
    IF l_assignment_id is null THEN
--
--  The assignment action is not a payroll or quickpay type, so return null
--
       l_balance := null;
    ELSE
--
       l_balance := calc_asg_qtd(
                                 p_assignment_action_id => p_assignment_action_id,
                                 p_balance_type_id      => p_balance_type_id,
                                 p_effective_date       => p_effective_date,
         p_assignment_id  => l_assignment_id);
    END IF;
--
   RETURN l_balance;
end calc_asg_qtd_action;
--
-----------------------------------------------------------------------------
---
--
--                          CALC_ASG_QTD_DATE                              -
--
--    This is the function for calculating assignment quarter
--                to date in DATE MODE
--
-----------------------------------------------------------------------------
--
FUNCTION calc_asg_qtd_date(
         p_assignment_id        IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER
IS
--
    l_assignment_action_id      NUMBER;
    l_balance                   NUMBER;
    l_conv_us_gb_qd             DATE;
    l_quarter_expiry_date       DATE;
    l_action_eff_date           DATE;
--
BEGIN
--
    l_assignment_action_id := get_latest_action_id(p_assignment_id,
               p_effective_date);
    IF l_assignment_action_id is null THEN
    l_balance := 0;
    ELSE
    l_balance := calc_asg_qtd(
                             p_assignment_action_id => l_assignment_action_id,
                             p_balance_type_id      => p_balance_type_id,
           p_effective_date       => p_effective_date,
                             p_assignment_id        => p_assignment_id);
    END IF;
--
   RETURN l_balance;
end calc_asg_qtd_date;
--
--------------------------------------------------------------------------------
--
--                          CALC_ASG_QTD                                    --
--      calculate balances for Assignment Quarter to date
--
--------------------------------------------------------------------------------
-- This dimension is the total for an assignment within the quarter. It uses
--
FUNCTION calc_asg_qtd(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
  p_assignment_id   IN NUMBER
                     )
RETURN NUMBER
IS
--
        l_balance               NUMBER;
        l_defined_bal_id  NUMBER;
--
BEGIN
--
--Do we need to work out a value for this dimension/balance combination.
--
 l_defined_bal_id := dimension_relevant(p_balance_type_id, '_ASG_QTD');
 if l_defined_bal_id is not null then
   --
   -- Call core balance pkg with the defined balance just retrieved.
   --
   l_balance := pay_balance_pkg.get_value(l_defined_bal_id,
                                          p_assignment_action_id);
 end if;
--
   RETURN l_balance;
--
   END calc_asg_qtd;
--
-----------------------------------------------------------------------------
---
--
--                          CALC_ASG_YTD_ACTION                              -
--
--    This is the function for calculating assignment year to
--                      date in asg action mode
--
-----------------------------------------------------------------------------
--
FUNCTION calc_asg_ytd_action(
         p_assignment_action_id IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER
IS
--
    l_assignment_action_id      NUMBER;
    l_balance                   NUMBER;
    l_assignment_id             NUMBER;
    l_effective_date      DATE;
--
BEGIN
--
    l_assignment_id := get_correct_type(p_assignment_action_id);
    IF l_assignment_id is null THEN
--
--  The assignment action is not a payroll or quickpay type, so return null
--
       l_balance := null;
    ELSE
--
       l_balance := calc_asg_ytd(
                                 p_assignment_action_id => p_assignment_action_id,
                                 p_balance_type_id      => p_balance_type_id,
                                 p_effective_date       => p_effective_date,
         p_assignment_id  => l_assignment_id);
    END IF;
--
   RETURN l_balance;
end calc_asg_ytd_action;
--
-----------------------------------------------------------------------------
---
--
--                          CALC_ASG_YTD_DATE                              -
--
--    This is the function for calculating assignment year to
--          date in date mode
--
-----------------------------------------------------------------------------
--
FUNCTION calc_asg_ytd_date(
         p_assignment_id        IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER
IS
--
    l_assignment_action_id      NUMBER;
    l_balance                   NUMBER;
    l_end_date                  DATE;
    l_action_eff_date   DATE;
--
BEGIN
--
    l_assignment_action_id := get_latest_action_id(p_assignment_id,
                                                   p_effective_date);
    IF l_assignment_action_id is null THEN
       l_balance := 0;
    ELSE
--     start expiry chk now
       l_action_eff_date := get_latest_date(l_assignment_action_id);
--
--     Is effective date (sess) later than the expiry of the financial year of the
--     effective date.
--
       if p_effective_date >= get_expired_year_date(l_action_eff_date) then
         l_balance := 0;
       else
--
         l_balance := calc_asg_ytd(
                                 p_assignment_action_id => l_assignment_action_id,
                                 p_balance_type_id      => p_balance_type_id,
                                 p_effective_date       => p_effective_date,
                                 p_assignment_id        => p_assignment_id);
       end if;
    END IF;
--
   RETURN l_balance;
end calc_asg_ytd_date;
--
--------------------------------------------------------------------------------
--
--                          CALC_ASG_YTD                                    --
--    calculate balances for Assignment year to date
--      Call core balance package.
--------------------------------------------------------------------------------
--
-- Assignment Year -
--
-- This dimension is the total for an assignment within the processing
-- year of any payrolls he has been on this year. That is in the case
-- of a transfer the span will go back to the start of the processing
-- year he was on at the start of year.
--
-- This dimension should be used for the year dimension of balances
-- which are not reset to zero on transferring payroll.
-- If this has been called from the date mode function, the effective date
-- will be set, otherwise session date is used.
--
FUNCTION calc_asg_ytd(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
        p_assignment_id   IN NUMBER
                     )
RETURN NUMBER
IS
--
  l_expired_balance NUMBER;
        l_balance               NUMBER;
        l_session_date          DATE;
        l_assignment_id         NUMBER;
        l_action_eff_date       DATE;
        l_latest_value_exists   VARCHAR2(2);
        l_assignment_action_id  NUMBER;
        l_defined_bal_id  NUMBER;
--
BEGIN
--
-- Similar to proc yr, we need to find out firstly whether there is a
-- value in latest balances, and then find out whether this can be used.
-- The latest balances table is then checked again to see whether there was
-- a value in the past, not necessarily for this assignment action, and whether
-- it is valid.
-- If not, the route code will be used to calculate the correct balance figure.
--
--Do we need to work out a value for this dimension/balance combination.
--
 l_defined_bal_id := dimension_relevant(p_balance_type_id, '_ASG_YTD');
 if l_defined_bal_id is not null then
--
   l_balance := pay_balance_pkg.get_value(l_defined_bal_id,
                                          p_assignment_action_id);
--
 else l_balance := null;
 end if;
--
RETURN l_balance;
--
END calc_asg_ytd;
--
-----------------------------------------------------------------------------
---
--
--                          CALC_ASG_STAT_YTD_ACTION                              -
--
--    This is the function for calculating assignment stat. year to
--                      date in asg action mode
--
-----------------------------------------------------------------------------
--
FUNCTION calc_asg_stat_ytd_action(
         p_assignment_action_id IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER
IS
--
    l_assignment_action_id      NUMBER;
    l_balance                   NUMBER;
    l_assignment_id             NUMBER;
    l_effective_date      DATE;
--
BEGIN
--
    l_assignment_id := get_correct_type(p_assignment_action_id);
    IF l_assignment_id is null THEN
--
--  The assignment action is not a payroll or quickpay type, so return null
--
       l_balance := null;
--
    ELSE
--
       l_balance := calc_asg_stat_ytd(
                                 p_assignment_action_id => p_assignment_action_id,
                                 p_balance_type_id      => p_balance_type_id,
                                 p_effective_date       => p_effective_date,
         p_assignment_id  => l_assignment_id);
    END IF;
--
   RETURN l_balance;
end calc_asg_stat_ytd_action;
--
-----------------------------------------------------------------------------
---
--
--                          CALC_ASG_STAT_YTD_DATE                              -
--
--    This is the function for calculating assignment stat. year to
--                      date in date mode
--
-----------------------------------------------------------------------------
--
FUNCTION calc_asg_stat_ytd_date(
         p_assignment_id        IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER
IS
--
    l_assignment_action_id      NUMBER;
    l_balance                   NUMBER;
    l_end_date                  DATE;
    l_action_eff_date           DATE;
--
BEGIN
--
    l_assignment_action_id := get_latest_action_id(p_assignment_id,
                                                   p_effective_date);
    IF l_assignment_action_id is null THEN
       l_balance := 0;
    ELSE
--     start expiry chk now
       l_action_eff_date := get_latest_date(l_assignment_action_id);
--
--     Is effective date (sess) later than the expiry of the financial year of the
--     effective date.
--
       if p_effective_date >= get_expired_year_date(l_action_eff_date) then
         l_balance := 0;
       else
--
       l_balance := calc_asg_stat_ytd(
                                 p_assignment_action_id => l_assignment_action_id,
                                 p_balance_type_id      => p_balance_type_id,
                                 p_effective_date       => p_effective_date,
                                 p_assignment_id        => p_assignment_id);
       end if;
    END IF;
--
   RETURN l_balance;
end calc_asg_stat_ytd_date;
--
--------------------------------------------------------------------------------
--
--                          CALC_ASG_STAT_YTD                                    --
--      calculate balances for Assignment stat year to date
--
--------------------------------------------------------------------------------
--
-- This dimension is the total for an assignment within the statutory
-- year (since the previous 6th April)of any payrolls he has been on this year
--
FUNCTION calc_asg_stat_ytd(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
  p_assignment_id   IN NUMBER
                     )
RETURN NUMBER
IS
--
  l_expired_balance NUMBER;
        l_balance               NUMBER;
        l_session_date          DATE;
        l_assignment_id         NUMBER;
        l_action_eff_date       DATE;
        l_latest_value_exists   VARCHAR2(2);
        l_assignment_action_id  NUMBER;
        l_defined_bal_id  NUMBER;
--
BEGIN
--
--Do we need to work out a value for this dimension/balance combination.
--
 l_defined_bal_id := dimension_relevant(p_balance_type_id, '_ASG_STAT_YTD');
 if l_defined_bal_id is not null then
--
   l_balance := pay_balance_pkg.get_value(l_defined_bal_id,
                                          p_assignment_action_id);
--
 else l_balance := null;
 end if;
--
RETURN l_balance;
--
END calc_asg_stat_ytd;
--
-----------------------------------------------------------------------------
---
--
--                          CALC_ASG_PROC_PTD_ACTION
--
--         This is the function for calculating assignment
--          proc. period to date in assignment action mode
--
-----------------------------------------------------------------------------
--
FUNCTION calc_asg_proc_ptd_action(
         p_assignment_action_id IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER
IS
--
    l_assignment_action_id      NUMBER;
    l_balance                   NUMBER;
    l_assignment_id             NUMBER;
    l_effective_date    DATE;
--
BEGIN
--
    l_assignment_id := get_correct_type(p_assignment_action_id);
    IF l_assignment_id is null THEN
--
--  The assignment action is not a payroll or quickpay type, so return null
--
       l_balance := null;
    ELSE
--
       l_balance := calc_asg_proc_ptd(
                                 p_assignment_action_id => p_assignment_action_id
,
                                 p_balance_type_id      => p_balance_type_id,
                                 p_effective_date       => p_effective_date,
         p_assignment_id  => l_assignment_id);
    END IF;
--
   RETURN l_balance;
end calc_asg_proc_ptd_action;
--
-----------------------------------------------------------------------------
---
--
--                          CALC_ASG_PROC_PTD_DATE
--
--    This is the function for calculating assignment processing
--    period to date in date mode
--
-----------------------------------------------------------------------------
--
FUNCTION calc_asg_proc_ptd_date(
         p_assignment_id        IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER
IS
--
    l_assignment_action_id      NUMBER;
    l_balance                   NUMBER;
    l_period_end_date           DATE;
    l_date_paid                 DATE;
--
-- Has the processing time period expired
--
   cursor expired_time_period (c_assignment_action_id IN NUMBER) is
    SELECT ptp.end_date, ppa.effective_date
    FROM per_time_periods ptp,
         pay_payroll_actions ppa,
         pay_assignment_actions paa
    WHERE
         paa.assignment_action_id = c_assignment_action_id
    AND  paa.payroll_action_id = ppa.payroll_action_id
    AND  ppa.time_period_id = ptp.time_period_id;
--
BEGIN
--
    l_assignment_action_id := get_latest_action_id(p_assignment_id,
                                                   p_effective_date);
    IF l_assignment_action_id is null THEN
       l_balance := 0;
    ELSE
       open expired_time_period(l_assignment_action_id);
       FETCH expired_time_period INTO l_period_end_date, l_date_paid;
       close expired_time_period;
--
       if greatest(l_period_end_date,l_date_paid) < p_effective_date then
          l_balance := 0;
       else
          l_balance := calc_asg_proc_ptd(
                             p_assignment_action_id => l_assignment_action_id,
                             p_balance_type_id      => p_balance_type_id,
                             p_effective_date       => p_effective_date,
                             p_assignment_id        => p_assignment_id);
       end if;
    END IF;
--
   RETURN l_balance;
end calc_asg_proc_ptd_date;
--
-----------------------------------------------------------------------------
---
--
--                          CALC_ASG_PROC_PTD                              -
--      calculate balances for Assignment process period to date
--      Calls Core Balance pkg.
--
-----------------------------------------------------------------------------
---
--
-- This dimension is the total for an assignment within the processing
-- period of his current payroll, OR if the assignment has transferred
-- payroll within the current processing period, it is the total since
-- he joined the current payroll.
--
-- This dimension should be used for the period dimension of balances
-- which are reset to zero on transferring payroll.
--
FUNCTION calc_asg_proc_ptd(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
  p_assignment_id   IN NUMBER
                          )
--
RETURN NUMBER
IS
--
--
  l_expired_balance NUMBER;
  l_assignment_action_id  NUMBER;
        l_balance               NUMBER;
        l_latest_value_exists   VARCHAR2(2);
  l_action_eff_date DATE;
  l_end_date    DATE;
      l_defined_bal_id  NUMBER;
--
BEGIN
--
--Do we need to work out a value for this dimension/balance combination.
--
 l_defined_bal_id := dimension_relevant(p_balance_type_id, '_ASG_PROC_PTD');
 if l_defined_bal_id is not null then
--
   l_balance := pay_balance_pkg.get_value(l_defined_bal_id,
                                          p_assignment_action_id);
--
 else l_balance := null;
 end if;
--
RETURN l_balance;
--
END calc_asg_proc_ptd;
--
--
-----------------------------------------------------------------------------
---
--
--                          CALC_ASG_RUN_ACTION                              -
--
--         This is the function for calculating assignment
--                runs in assignment action mode
--
-----------------------------------------------------------------------------
--
FUNCTION calc_asg_run_action(
         p_assignment_action_id IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER
IS
--
    l_assignment_action_id      NUMBER;
    l_balance                   NUMBER;
    l_assignment_id             NUMBER;
    l_effective_date          DATE;
--
BEGIN
--
    l_assignment_id := get_correct_type(p_assignment_action_id);
    IF l_assignment_id is null THEN
--
--  The assignment action is not a payroll or quickpay type, so return null
--
       l_balance := null;
    ELSE
--
       l_balance := calc_asg_run(
                                 p_assignment_action_id => p_assignment_action_id
,
                                 p_balance_type_id      => p_balance_type_id,
                                 p_effective_date       => p_effective_date,
         p_assignment_id  => l_assignment_id);
    END IF;
--
   RETURN l_balance;
end calc_asg_run_action;
--
-----------------------------------------------------------------------------
---
--
--                          CALC_ASG_RUN_DATE                              -
--
--    This is the function for calculating assignment run in
--                DATE MODE
--
-----------------------------------------------------------------------------
--
FUNCTION calc_asg_run_date(
         p_assignment_id  IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER
IS
--
    l_assignment_action_id  NUMBER;
    l_balance     NUMBER;
    l_period_end_date           DATE;
    l_date_paid                 DATE;
--
   cursor expired_time_period (c_assignment_action_id IN NUMBER) is
    SELECT ptp.end_date, ppa.effective_date
    FROM per_time_periods ptp,
         pay_payroll_actions ppa,
         pay_assignment_actions paa
    WHERE
         paa.assignment_action_id = c_assignment_action_id
    AND  paa.payroll_action_id = ppa.payroll_action_id
    AND  ppa.time_period_id = ptp.time_period_id;
--
BEGIN
--
    l_assignment_action_id := get_latest_action_id(p_assignment_id,
                                                   p_effective_date);
    IF l_assignment_action_id is null THEN
       l_balance := 0;
    ELSE
       open expired_time_period(l_assignment_action_id);
       FETCH expired_time_period INTO l_period_end_date, l_date_paid;
       close expired_time_period;
--
       if greatest(l_period_end_date,l_date_paid) < p_effective_date then
          l_balance := 0;
       else
          l_balance := calc_asg_run(
                             p_assignment_action_id => l_assignment_action_id,
           p_balance_type_id      => p_balance_type_id,
                             p_effective_date       => p_effective_date,
                             p_assignment_id        => p_assignment_id);
       end if;
    END IF;
--
   RETURN l_balance;
end calc_asg_run_date;
--
-----------------------------------------------------------------------------
---
--
--                          CALC_ASG_RUN                              -
--      calculate balances for Assignment Run . Now calls core package.
--
-----------------------------------------------------------------------------
--
-- Run
--    the simplest dimension retrieves run values where the context
--    is this assignment action and this balance feed. Balance is the
--    specified input value. The related payroll action determines the
--    date effectivity of the feeds
--
FUNCTION calc_asg_run(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
  p_assignment_id   IN NUMBER
                     )
RETURN NUMBER
IS
--
--
        l_balance               NUMBER;
  l_defined_bal_id  NUMBER;
--
BEGIN
--
--Do we need to work out a value for this dimension/balance combination.
--
 l_defined_bal_id := dimension_relevant(p_balance_type_id, '_ASG_RUN');
 if l_defined_bal_id is not null then
--
-- Call core balance pkg with the defined balance just retrieved.
--
   l_balance := pay_balance_pkg.get_value(l_defined_bal_id,
                                          p_assignment_action_id);
--
 else l_balance := null;
 end if;
--
RETURN l_balance;
--
END calc_asg_run;
--
-----------------------------------------------------------------------------
--
--                          CALC_PAYMENT_ACTION                              -
--
--         This is the function for calculating payments
--                in assignment action mode
-----------------------------------------------------------------------------
--
FUNCTION calc_payment_action(
         p_assignment_action_id IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER
IS
--
    l_assignment_action_id      NUMBER;
    l_balance                   NUMBER;
    l_assignment_id             NUMBER;
    l_effective_date    DATE;
--
BEGIN
--
    l_assignment_id := get_correct_type(p_assignment_action_id);
    IF l_assignment_id is null THEN
--
--  The assignment action is not a payroll or quickpay type, so return null
--
       l_balance := null;
    ELSE
--
       l_balance := calc_payment(
                                 p_assignment_action_id => p_assignment_action_id
,
                                 p_balance_type_id      => p_balance_type_id,
                                 p_effective_date       => p_effective_date,
         p_assignment_id  => l_assignment_id);
    END IF;
--
   RETURN l_balance;
end calc_payment_action;
--
-----------------------------------------------------------------------------
--
--                          CALC_PAYMENT_DATE                              -
--
--    This is the function for calculating payments in
--                            DATE MODE
-----------------------------------------------------------------------------
--
FUNCTION calc_payment_date(
         p_assignment_id        IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER
IS
--
    l_assignment_action_id      NUMBER;
    l_balance                   NUMBER;
    l_period_end_date           DATE;
    l_date_paid                 DATE;
--
   cursor expired_time_period (c_assignment_action_id IN NUMBER) is
    SELECT ptp.end_date, ppa.effective_date
    FROM per_time_periods ptp,
         pay_payroll_actions ppa,
         pay_assignment_actions paa
    WHERE
         paa.assignment_action_id = c_assignment_action_id
    AND  paa.payroll_action_id = ppa.payroll_action_id
    AND  ppa.time_period_id = ptp.time_period_id;
--
BEGIN
--
    l_assignment_action_id := get_latest_action_id(p_assignment_id,
                                                   p_effective_date);
    IF l_assignment_action_id is null THEN
       l_balance := 0;
    ELSE
       open expired_time_period(l_assignment_action_id);
       FETCH expired_time_period INTO l_period_end_date, l_date_paid;
       close expired_time_period;
--
       if greatest(l_period_end_date,l_date_paid) < p_effective_date then
          l_balance := 0;
       else
          l_balance := calc_payment(
                             p_assignment_action_id => l_assignment_action_id,
                             p_balance_type_id      => p_balance_type_id,
                             p_effective_date       => p_effective_date,
                             p_assignment_id        => p_assignment_id);
          end if;
    END IF;
--
   RETURN l_balance;
end calc_payment_date;
--
-----------------------------------------------------------------------------
--
--                          CALC_PAYMENT                              -
--
--      calculate balances for payments . Now calls core package.
-----------------------------------------------------------------------------
--
-- this dimension is used in the pre-payments process - that process
-- creates interlocks for the actions that are included and the payments
-- dimension uses those interlocks to decide which run results to sum
--
--
FUNCTION calc_payment(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
  p_assignment_id   IN NUMBER
                     )
RETURN NUMBER
IS
--
        l_balance               NUMBER;
        l_latest_value_exists   VARCHAR2(2);
        l_assignment_action_id  NUMBER;
  l_action_eff_date DATE;
  l_end_date    DATE;
  l_defined_bal_id  NUMBER;
--
BEGIN
--
--Do we need to work out a value for this dimension/balance combination.
--
 l_defined_bal_id := dimension_relevant(p_balance_type_id, '_PAYMENTS');
 if l_defined_bal_id is not null then
--
   -- Call core balance pkg with the defined balance just retrieved.
   l_balance := pay_balance_pkg.get_value(l_defined_bal_id,
                                          p_assignment_action_id);
--
 else l_balance := null;
 end if;
--
RETURN l_balance;
--
END calc_payment;
--
-----------------------------------------------------------------------------
--
--                          CALC_ASG_ITD_ACTION                              -
--
--         This is the function for calculating assignment
--         Inception to date in assignment action mode
-----------------------------------------------------------------------------
--
FUNCTION calc_asg_itd_action(
         p_assignment_action_id IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER
IS
--
    l_assignment_action_id      NUMBER;
    l_balance                   NUMBER;
    l_assignment_id             NUMBER;
    l_effective_date    DATE;
--
BEGIN
--
    l_assignment_id := get_correct_type(p_assignment_action_id);
    IF l_assignment_id is null THEN
--
--  The assignment action is not a payroll or quickpay type, so return null
--
       l_balance := null;
    ELSE
--
       l_balance := calc_asg_itd(p_assignment_id  => l_assignment_id,
                                 p_assignment_action_id => p_assignment_action_id,
                                 p_balance_type_id      => p_balance_type_id,
                                 p_effective_date       => p_effective_date);
    END IF;
--
   RETURN l_balance;
end calc_asg_itd_action;
--
-----------------------------------------------------------------------------
--
--                          CALC_ASG_ITD_DATE                              -
--
--    This is the function for calculating assignment inception to
--                      date in DATE MODE
-----------------------------------------------------------------------------
--
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
--
BEGIN
--
    l_assignment_action_id := get_latest_action_id(p_assignment_id,
                                                   p_effective_date);
    IF l_assignment_action_id is null THEN
       l_balance := 0;
    ELSE
       l_balance := calc_asg_itd(
           p_assignment_id      => p_assignment_id,
                             p_assignment_action_id => l_assignment_action_id,
                             p_balance_type_id      => p_balance_type_id,
                             p_effective_date       => p_effective_date);
    END IF;
--
   RETURN l_balance;
end calc_asg_itd_date;
--
-----------------------------------------------------------------------------
--
--                          CALC_ASG_ITD                              -
--
--      calculate balances for Assignment Inception to Date
-----------------------------------------------------------------------------
--
-- Sum of all run items since inception.
--
FUNCTION calc_asg_itd(
  p_assignment_id   IN NUMBER,
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL -- in for consistency
                      )
RETURN NUMBER
IS
--
--
        l_balance               NUMBER;
        l_latest_value_exists   VARCHAR2(2);
    l_assignment_action_id  NUMBER;
  l_action_eff_date DATE;
  l_defined_bal_id  NUMBER;
--
BEGIN
--
--Do we need to work out a value for this dimension/balance combination.
--
 l_defined_bal_id := dimension_relevant(p_balance_type_id, '_ASG_ITD');
 if l_defined_bal_id is not null then
--
-- Is there a value in the latest balances table ..
--
   l_balance := pay_balance_pkg.get_value(l_defined_bal_id,
                                          p_assignment_action_id);
--
 else l_balance := null;
 end if;
--
RETURN l_balance;
--
END calc_asg_itd;
--
--
-----------------------------------------------------------------------------
--
--                          CALC_ASG_TD_ITD_ACTION                              -
--
--         This is the function for calculating assignment tax district
--         Inception to date in assignment action mode
-----------------------------------------------------------------------------
--
FUNCTION calc_asg_td_itd_action(
         p_assignment_action_id IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER
IS
--
    l_assignment_action_id      NUMBER;
    l_balance                   NUMBER;
    l_assignment_id             NUMBER;
    l_effective_date    DATE;
--
BEGIN
--
    l_assignment_id := get_correct_type(p_assignment_action_id);
    IF l_assignment_id is null THEN
--
--  The assignment action is not a payroll or quickpay type, so return null
--
       l_balance := null;
    ELSE
--
       l_balance := calc_asg_td_itd(p_assignment_id => l_assignment_id,
                                 p_assignment_action_id => p_assignment_action_id,
                                 p_balance_type_id      => p_balance_type_id,
                                 p_effective_date       => p_effective_date);
    END IF;
--
   RETURN l_balance;
end calc_asg_td_itd_action;
--
-----------------------------------------------------------------------------
--
--                          CALC_ASG_TD_ITD_DATE                              -
--
--    This is the function for calculating assignment inception tax district
--                      to date in DATE MODE
-----------------------------------------------------------------------------
--
FUNCTION calc_asg_td_itd_date(
         p_assignment_id        IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER
IS
--
    l_assignment_action_id      NUMBER;
    l_balance                   NUMBER;
    l_end_date                  DATE;
--
BEGIN
--
    l_assignment_action_id := get_latest_action_id(p_assignment_id,
                                                   p_effective_date);
    IF l_assignment_action_id is null THEN
       l_balance := 0;
    ELSE
       l_balance := calc_asg_td_itd(p_assignment_id => p_assignment_id,
                             p_assignment_action_id => l_assignment_action_id,
                             p_balance_type_id      => p_balance_type_id,
                             p_effective_date       => p_effective_date);
    END IF;
--
   RETURN l_balance;
end calc_asg_td_itd_date;
--
-----------------------------------------------------------------------------
--
--                          CALC_ASG_TD_ITD                              -
--
--      calculate balances for Assignment tax district Inception to Date
--      Calls Core Balance pkg.
-----------------------------------------------------------------------------
--
-- Sum of all run items since inception (tax district)
--
FUNCTION calc_asg_td_itd(
  p_assignment_id   IN NUMBER,
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL -- in for consistency
                      )
RETURN NUMBER
IS
--
        l_balance               NUMBER;
  l_defined_bal_id  NUMBER;
--
BEGIN
--
--Do we need to work out a value for this dimension/balance combination.
--
 l_defined_bal_id := dimension_relevant(p_balance_type_id, '_ASG_TD_ITD');
 if l_defined_bal_id is not null then
   --
   -- Call core balance pkg with the defined balance just retrieved.
   l_balance := pay_balance_pkg.get_value(l_defined_bal_id,
                                          p_assignment_action_id);
   --
 else l_balance := null;
 end if;
--
RETURN l_balance;
--
END calc_asg_td_itd;
--
-----------------------------------------------------------------------------
--
--                          CALC_ASG_TFR_PTD_ACTION
--
--         This is the function for calculating assignment
--          transfer period to date in assignment action mode
-----------------------------------------------------------------------------
--
FUNCTION calc_asg_tfr_ptd_action(
         p_assignment_action_id IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER
IS
--
    l_assignment_action_id      NUMBER;
    l_balance                   NUMBER;
    l_assignment_id             NUMBER;
    l_effective_date    DATE;
--
BEGIN
--
    l_assignment_id := get_correct_type(p_assignment_action_id);
    IF l_assignment_id is null THEN
--
--  The assignment action is not a payroll or quickpay type, so return null
--
       l_balance := null;
    ELSE
--
       l_balance := calc_asg_tfr_ptd(
                                 p_assignment_action_id => p_assignment_action_id
,
                                 p_balance_type_id      => p_balance_type_id,
                                 p_effective_date       => p_effective_date,
         p_assignment_id  => l_assignment_id);
    END IF;
--
   RETURN l_balance;
end calc_asg_tfr_ptd_action;
--
-----------------------------------------------------------------------------
--
--                          CALC_ASG_TFR_PTD_DATE
--
--    This is the function for calculating assignment transfer
--    period to date in date mode
-----------------------------------------------------------------------------
--
FUNCTION calc_asg_tfr_ptd_date(
         p_assignment_id        IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER
IS
--
    l_assignment_action_id      NUMBER;
    l_balance                   NUMBER;
    l_period_end_date           DATE;
    l_date_paid                 DATE;
--
-- Has the processing time period expired
--
   cursor expired_time_period (c_assignment_action_id IN NUMBER) is
    SELECT ptp.end_date, ppa.effective_date
    FROM per_time_periods ptp,
         pay_payroll_actions ppa,
         pay_assignment_actions paa
    WHERE
         paa.assignment_action_id = c_assignment_action_id
    AND  paa.payroll_action_id = ppa.payroll_action_id
    AND  ppa.time_period_id = ptp.time_period_id;
--
BEGIN
--
    l_assignment_action_id := get_latest_action_id(p_assignment_id,
                                                   p_effective_date);
    IF l_assignment_action_id is null THEN
       l_balance := 0;
    ELSE
       open expired_time_period(l_assignment_action_id);
       FETCH expired_time_period INTO l_period_end_date, l_date_paid;
       close expired_time_period;
--
       if greatest(l_period_end_date,l_date_paid) < p_effective_date then
          l_balance := 0;
       else
          l_balance := calc_asg_tfr_ptd(
                             p_assignment_action_id => l_assignment_action_id,
                             p_balance_type_id      => p_balance_type_id,
                             p_effective_date       => p_effective_date,
                             p_assignment_id        => p_assignment_id);
       end if;
    END IF;
--
   RETURN l_balance;
end calc_asg_tfr_ptd_date;
--
--------------------------------------------------------------------------------
--
--                          CALC_ASG_TFR_PTD                                   --
--    calculate Assignment transfer period to date
--              Call the Core Balance function
--------------------------------------------------------------------------------
--
--
-- This dimension is the total for an assignment within the processing
-- period of his current payroll, OR if the assignment has transferred
-- payroll it includes run results generated from actions that are
-- within the same statutory period.
-- The start of the statutory period is based on a fixed calendar which
-- begins on the 6th April of each calendar year. Monthly periods
-- start at the 6th of each month, weekly based periods are at 7 day
-- intervals from the 6th April.
-- The regular payment date for the payroll period determines which
-- statutory period it is in so the statutory start of period is
-- compared against the regular payment date of the payroll period
-- that the actions were created for.
--
FUNCTION calc_asg_tfr_ptd(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
  p_assignment_id   IN NUMBER
                      )
RETURN NUMBER
IS
--
        l_balance               NUMBER;
        l_assignment_action_id  NUMBER;
  l_action_eff_date DATE;
  l_defined_bal_id  NUMBER;
--
BEGIN
--
--Do we need to work out a value for this dimension/balance combination.
--
 l_defined_bal_id := dimension_relevant(p_balance_type_id, '_ASG_TRANSFER_PTD');
 if l_defined_bal_id is not null then
--
   l_balance := pay_balance_pkg.get_value(l_defined_bal_id,
                                          p_assignment_action_id);
--
 else l_balance := null;
 end if;
--
RETURN l_balance;
--
END calc_asg_tfr_ptd;
--
-----------------------------------------------------------------------------
--
--                          CALC_ASG_TD_YTD_ACTION                              -
--
--    This is the function for calculating assignment td year to
--                      date in asg action mode
-----------------------------------------------------------------------------
--
FUNCTION calc_asg_td_ytd_action(
         p_assignment_action_id IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER
IS
--
    l_assignment_action_id      NUMBER;
    l_balance                   NUMBER;
    l_assignment_id             NUMBER;
    l_effective_date    DATE;
--
BEGIN
--
    l_assignment_id := get_correct_type(p_assignment_action_id);
    IF l_assignment_id is null THEN
--
--  The assignment action is not a payroll or quickpay type, so return null
--
       l_balance := null;
    ELSE
--
       l_balance := calc_asg_td_ytd(
                                 p_assignment_action_id => p_assignment_action_id,
                                 p_balance_type_id      => p_balance_type_id,
                                 p_effective_date       => p_effective_date,
         p_assignment_id  => l_assignment_id);
    END IF;
--
   RETURN l_balance;
end calc_asg_td_ytd_action;
--
------------------------------------------------------------------------------
--
--      CALC_ASG_TD_YTD
--  This function is for assignment tax district year to date
--      Calls core balance package
------------------------------------------------------------------------------
--
FUNCTION calc_asg_td_ytd(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
  p_assignment_id   IN NUMBER
                     )
RETURN NUMBER
IS
--
--
        l_balance               NUMBER;
        l_session_date          DATE;
        l_action_eff_date       DATE;
        l_expired_balance       NUMBER;
        l_assignment_id         NUMBER;
        l_assignment_action_id  NUMBER;
        l_latest_value_exists   VARCHAR2(2);
  l_defined_bal_id  NUMBER;
--
   BEGIN
--
--Do we need to work out a value for this dimension/balance combination.
--
 l_defined_bal_id := dimension_relevant(p_balance_type_id, '_ASG_TD_YTD');
 if l_defined_bal_id is not null then
--
   l_balance := pay_balance_pkg.get_value(l_defined_bal_id,
                                          p_assignment_action_id);
--
 else l_balance := null;
 end if;
--
RETURN l_balance;
--
END calc_asg_td_ytd;
--
-----------------------------------------------------------------------------
--
--                          CALC_ASG_TD_YTD_DATE                              -
--
--    This is the function for calculating assignment year to
--                      date in date mode
-----------------------------------------------------------------------------
--
FUNCTION calc_asg_td_ytd_date(
         p_assignment_id        IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER
IS
--
    l_assignment_action_id      NUMBER;
    l_balance                   NUMBER;
    l_end_date                  DATE;
    l_action_eff_date           DATE;
--
BEGIN
--
    l_assignment_action_id := get_latest_action_id(p_assignment_id,
                                                   p_effective_date);
    IF l_assignment_action_id is null THEN
       l_balance := 0;
    ELSE
--     start expiry chk now
       l_action_eff_date := get_latest_date(l_assignment_action_id);
--
--     Is effective date (sess) later than the expiry of the financial year of the
--     effective date.
--
       if p_effective_date >= get_expired_year_date(l_action_eff_date) then
         l_balance := 0;
       else
--
       l_balance := calc_asg_td_ytd(
                                 p_assignment_action_id => l_assignment_action_id,
                                 p_balance_type_id      => p_balance_type_id,
                                 p_effective_date       => p_effective_date,
                                 p_assignment_id        => p_assignment_id);
       end if;
    END IF;
--
   RETURN l_balance;
end calc_asg_td_ytd_date;
--
-----------------------------------------------------------------------------
--added by skutteti
-----------------------------------------------------------------------------
--
--                       CALC_ASG_TD_ODD_TWO_YTD_ACTION
--
--    This is the function for calculating assignment td two years to
--                      date in asg action mode
--
-----------------------------------------------------------------------------
--
FUNCTION calc_asg_td_odd_two_ytd_action(
         p_assignment_action_id IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE DEFAULT NULL)
RETURN NUMBER
IS
--
    l_assignment_action_id      NUMBER;
    l_balance                   NUMBER;
    l_assignment_id             NUMBER;
    l_effective_date            DATE;
--
BEGIN
--
    l_assignment_id := get_correct_type(p_assignment_action_id);
    IF l_assignment_id is null THEN
--
--  The assignment action is not a payroll or quickpay type, so return null
--
       l_balance := null;
    ELSE
--
       l_balance := calc_asg_td_odd_two_ytd(
                             p_assignment_action_id => p_assignment_action_id,
                             p_balance_type_id      => p_balance_type_id,
                             p_effective_date       => p_effective_date,
                             p_assignment_id        => l_assignment_id);
    END IF;
--
   RETURN l_balance;
end calc_asg_td_odd_two_ytd_action;
--
-----------------------------------------------------------------------------
--
--                       CALC_ASG_TD_ODD_TWO_YTD_DATE
--
--    This is the function for calculating assignment two years to
--                      date in date mode
--
-----------------------------------------------------------------------------
--
FUNCTION calc_asg_td_odd_two_ytd_date(
         p_assignment_id        IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER
IS
--
    l_assignment_action_id      NUMBER;
    l_balance                   NUMBER;
    l_end_date                  DATE;
    l_action_eff_date           DATE;
--
BEGIN
   --
   l_assignment_action_id := get_latest_action_id(p_assignment_id,
                                                  p_effective_date);
   IF l_assignment_action_id is null THEN
      l_balance := 0;
   ELSE
   --     start expiry chk now
      l_action_eff_date := get_latest_date(l_assignment_action_id);
   --
   --     Is effective date (sess) later than the expiry of the
   --     financial year of the  effective date.
   --
      if p_effective_date >= get_expired_two_year_date(l_action_eff_date
                                                      ,'ODD') then
         l_balance := 0;
      else
      --
      l_balance := calc_asg_td_odd_two_ytd(
                             p_assignment_action_id => l_assignment_action_id,
                             p_balance_type_id      => p_balance_type_id,
                             p_effective_date       => p_effective_date,
                             p_assignment_id        => p_assignment_id);
      end if;
   END IF;
   --
   RETURN l_balance;
   --
end calc_asg_td_odd_two_ytd_date;
--
------------------------------------------------------------------------------
--
--                      CALC_ASG_TD_ODD_TWO_YTD
--      This function is for assignment tax district two years to date
--      Calls Core balance package
------------------------------------------------------------------------------
--
FUNCTION calc_asg_td_odd_two_ytd(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
        p_assignment_id         IN NUMBER
                     )
RETURN NUMBER
IS
--
        l_balance               NUMBER;
        l_defined_bal_id        NUMBER;
--
   BEGIN
--
--Do we need to work out a value for this dimension/balance combination.
--
 l_defined_bal_id := dimension_relevant(p_balance_type_id,
                                        '_ASG_TD_ODD_TWO_YTD');
 if l_defined_bal_id is not null then
   --
   -- Call core balance pkg with the defined balance just retrieved.
   l_balance := pay_balance_pkg.get_value(l_defined_bal_id,
                                          p_assignment_action_id);
   --
 else l_balance := null;
 end if;
--
RETURN l_balance;
--
END calc_asg_td_odd_two_ytd;
-------------------------------------------------------------------------------
--
--                       CALC_ASG_TD_EVEN_TWO_YTD_ACTION
--
--    This is the function for calculating assignment td two years to
--                      date in asg action mode
--
-----------------------------------------------------------------------------
--
FUNCTION calc_asg_td_even_two_ytd_actio(
         p_assignment_action_id IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE DEFAULT NULL)
RETURN NUMBER
IS
--
    l_assignment_action_id      NUMBER;
    l_balance                   NUMBER;
    l_assignment_id             NUMBER;
    l_effective_date            DATE;
--
BEGIN
--
    l_assignment_id := get_correct_type(p_assignment_action_id);
    IF l_assignment_id is null THEN
--
--  The assignment action is not a payroll or quickpay type, so return null
--
       l_balance := null;
    ELSE
--
       l_balance := calc_asg_td_even_two_ytd(
                                 p_assignment_action_id => p_assignment_action_id,
                                 p_balance_type_id      => p_balance_type_id,
                                 p_effective_date       => p_effective_date,
                                 p_assignment_id        => l_assignment_id);
    END IF;
--
   RETURN l_balance;
end calc_asg_td_even_two_ytd_actio;
--
-----------------------------------------------------------------------------
--
--                       CALC_ASG_TD_EVEN_TWO_YTD_DATE
--
--    This is the function for calculating assignment two years to
--                      date in date mode
-----------------------------------------------------------------------------
--
FUNCTION calc_asg_td_even_two_ytd_date(
         p_assignment_id        IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER
IS
--
    l_assignment_action_id      NUMBER;
    l_balance                   NUMBER;
    l_end_date                  DATE;
    l_action_eff_date           DATE;
--
BEGIN
--
   l_assignment_action_id := get_latest_action_id(p_assignment_id,
                                                  p_effective_date);
   IF l_assignment_action_id is null THEN
      l_balance := 0;
   ELSE
      --     start expiry chk now
      l_action_eff_date := get_latest_date(l_assignment_action_id);
      --
      --   Is effective date (sess) later than the expiry of the
      --   financial year of the effective date.
      --
      if p_effective_date >= get_expired_two_year_date(l_action_eff_date
                                                      ,'EVEN')  then
         l_balance := 0;
      else
         --
         l_balance := calc_asg_td_even_two_ytd(
                             p_assignment_action_id => l_assignment_action_id,
                             p_balance_type_id      => p_balance_type_id,
                             p_effective_date       => p_effective_date,
                             p_assignment_id        => p_assignment_id);
      end if;
   END IF;
   --
   RETURN l_balance;
end calc_asg_td_even_two_ytd_date;
--
------------------------------------------------------------------------------
--
--                      CALC_ASG_TD_EVEN_TWO_YTD
--      This function is for assignment tax district two years to date
------------------------------------------------------------------------------
--
FUNCTION calc_asg_td_even_two_ytd(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
        p_assignment_id         IN NUMBER
                     )
RETURN NUMBER
IS
--
        l_balance               NUMBER;
        l_defined_bal_id        NUMBER;
--
   BEGIN
--
--Do we need to work out a value for this dimension/balance combination.
--
 l_defined_bal_id := dimension_relevant(p_balance_type_id,
                                        '_ASG_TD_EVEN_TWO_YTD');
 if l_defined_bal_id is not null then
   --
   -- Call core balance pkg with the defined balance just retrieved.
   l_balance := pay_balance_pkg.get_value(l_defined_bal_id,
                                          p_assignment_action_id);
   --
 else l_balance := null;
 end if;
--
RETURN l_balance;
--
END calc_asg_td_even_two_ytd;
----------------------------------------------------------------------------------
--
--                          CALC_BALANCE                                   --
--  General function for accumulating a balance between two dates
--
--------------------------------------------------------------------------------

FUNCTION calc_balance(
  p_assignment_id   IN NUMBER,
  p_balance_type_id IN NUMBER,  -- balance
  p_period_from_date  IN DATE,    -- since regular pay date of period
  p_event_from_date IN DATE,    -- since effective date of
  p_to_date   IN DATE,    -- sum up to this date
  p_action_sequence IN NUMBER)  -- sum up to this sequence
RETURN NUMBER
IS
--
--
  l_balance NUMBER;
--
BEGIN
--
        SELECT  /*+ ORDERED INDEX (ASSACT PAY_ASSIGNMENT_ACTIONS_N51,
                                   PACT   PAY_PAYROLL_ACTIONS_PK,
                                   FEED   PAY_BALANCE_FEEDS_F_UK2,
                                   PPTP   PER_TIME_PERIODS_PK,
                                   RR     PAY_RUN_RESULTS_N50,
                                   TARGET PAY_RUN_RESULT_VALUES_PK) */
                NVL(SUM(fnd_number.canonical_to_number(TARGET.result_value) * FEED.scale),0)
        INTO
                l_balance
        FROM
                 pay_assignment_actions         ASSACT
                ,pay_payroll_actions            PACT
                ,pay_balance_feeds_f            FEED
                ,per_time_periods               PPTP
                ,pay_run_results                RR
                ,pay_run_result_values          TARGET
        WHERE
                FEED.balance_type_id = P_BALANCE_TYPE_ID
        AND     FEED.input_value_id = TARGET.input_value_id
        AND     TARGET.run_result_id = RR.run_result_id
        AND     RR.assignment_action_id = ASSACT.assignment_action_id
        AND     ASSACT.payroll_action_id = PACT.payroll_action_id
        AND     nvl(TARGET.result_value,'0') <> '0'
        AND     PACT.effective_date BETWEEN
                      FEED.effective_start_date AND FEED.effective_end_date
        AND     RR.status IN ('P','PA')
        AND     PACT.time_period_id = PPTP.time_period_id
        AND     PPTP.regular_payment_date >= P_PERIOD_FROM_DATE
        AND     PACT.effective_date >= P_EVENT_FROM_DATE
        AND     PACT.effective_date <= P_TO_DATE
        AND     ASSACT.action_sequence <= NVL(P_ACTION_SEQUENCE,ASSACT.action_sequence)
        AND     ASSACT.assignment_id = P_ASSIGNMENT_ID;

  RETURN l_balance;
--
END calc_balance;
--

--------------------------------------------------------------------------------
--                                                                            --
--                          CREATE DIMENSION                                  --
--                                                                            --
--------------------------------------------------------------------------------

PROCEDURE create_dimension(
    errbuf     OUT NOCOPY VARCHAR2,
    retcode    OUT NOCOPY NUMBER,
    p_business_group_id IN  NUMBER,
    p_suffix    IN  VARCHAR2,
    p_level     IN  VARCHAR2,
    p_start_dd_mm   IN  VARCHAR2,
    p_frequency   IN  NUMBER,
    p_global_name   IN  VARCHAR2 DEFAULT NULL)
IS
BEGIN
  errbuf := NULL;
  retcode := 0;
---------------------------
-- INSERT INTO FF_ROUTES --
---------------------------
  DECLARE
    l_route_text  ff_routes.text%TYPE;
    l_bal_next    number;
  BEGIN
    SELECT
      pay_balance_dimensions_s.NEXTVAL
    INTO
      l_bal_next
    FROM DUAL;

    l_route_text :=
        'pay_gb_balances_v TARGET,
        pay_dummy_feeds_v FEED
        WHERE
          TARGET.assignment_action_id = &B1
        AND TARGET.balance_type_id = &U1
        AND TARGET.balance_dimension_id = ' || TO_CHAR(l_bal_next);
--
--

    INSERT INTO FF_ROUTES
    (
      route_id,
      route_name,
      user_defined_flag,
      description,
      text
    )
    VALUES
    (
      ff_routes_s.NEXTVAL,
      'ROUTE_NAME_' || ff_routes_s.CURRVAL ,
      'N',
      'User balance dimension for '||
                         UPPER(RPAD(p_suffix,30,' ')) || 'USER-REG ASG '||
                         p_start_dd_mm || ' RESET'|| TO_CHAR(p_frequency,'00'),
      l_route_text
    );
  END;

-----------------------------------------
-- INSERT INTO FF_ROUTE_CONTEXT_USAGES --
-----------------------------------------

  BEGIN
    INSERT INTO ff_route_context_usages
    (
      route_id,
      context_id,
      sequence_no
    )
    SELECT
      ff_routes_s.CURRVAL,
      context_id,
      1
    FROM
      ff_contexts
    WHERE
      context_name = 'ASSIGNMENT_ACTION_ID';
  END;

------------------------------------
-- INSERT INTO FF_ROUTE_PARAMETER --
------------------------------------

  BEGIN
    INSERT INTO ff_route_parameters
    (
      route_parameter_id,
      route_id,
      sequence_no,
      parameter_name,
      data_type
    )
    VALUES
    (
      ff_route_parameters_s.NEXTVAL,
      ff_routes_s.CURRVAL,
      1,
      'BALANCE TYPE ID',
      'N'
    );
  END;

-----------------------------
-- CREATION DIMENSION NAME --
-----------------------------

  DECLARE
    l_dim_name  VARCHAR2(256);
    l_dim_type  VARCHAR2(1);
    l_dim_level VARCHAR2(3);
    l_req_id  NUMBER;

  BEGIN

    -- fill the dimension type
    IF p_level = 'ASSIGNMENT' THEN
      l_dim_type := 'A';
      l_dim_level := 'ASG';
    ELSIF p_level = 'PERSON' THEN
      l_dim_type := 'P';
      l_dim_level := 'PER';
    ELSIF p_level = 'ELEMENT' THEN
      l_dim_type := 'P';
      l_dim_level := 'ELE';
    ELSE
      l_dim_type := 'P';
      l_dim_level := 'PER';
    END IF;


    -- Fill the dimension name
    IF p_global_name IS NULL THEN
      -- USER REGULAR
                        l_dim_name := UPPER(RPAD(p_suffix,30,' ')) || 'USER-REG ';
      l_dim_name := l_dim_name || l_dim_level || ' ' ;
      l_dim_name := l_dim_name || p_start_dd_mm || ' RESET';
      l_dim_name := l_dim_name || TO_CHAR(p_frequency,'00');
    ELSE
      -- USER IRREGULAR
      /****************************/
      /*   Not yet implemented    */
      /****************************/
      /*
      l_dim_name := 'USER IRREGULAR DIMENSION FOR ';
      l_dim_name := l_dim_name || p_level || ' BASED ON ' || p_global_name;
      */
      null;
    END IF;

    -- Find the current request id
    l_req_id := fnd_profile.value('CONC_REQUEST_ID');

    -- insert into the table
    INSERT INTO pay_balance_dimensions
    (
      balance_dimension_id,
      business_group_id,
      legislation_code,
      route_id,
      database_item_suffix,
      dimension_name,
      dimension_type,
      description,
      feed_checking_code,
      legislation_subgroup,
      payments_flag,
      expiry_checking_code,
      expiry_checking_level,
      feed_checking_type
    )
    VALUES
    (
      pay_balance_dimensions_s.CURRVAL,
      p_business_group_id,
      NULL,
      ff_routes_s.CURRVAL,
      p_suffix,
      l_dim_name,
      l_dim_type,
      'User dimension defined by Request Id ' || l_req_id,
      NULL,
      NULL,
      'N',
      'hr_gbbal.check_expiry',
      'P',
      NULL
    );

  END;
END create_dimension;
--------------------------------------------------------------------------------
--                                                                            --
--                          EXPIRY CHECKING CODE                    --
--                                                                            --
--------------------------------------------------------------------------------
PROCEDURE check_expiry(
    p_owner_payroll_action_id   IN  NUMBER,
    p_user_payroll_action_id    IN  NUMBER,
    p_owner_assignment_action_id    IN  NUMBER,
    p_user_assignment_action_id   IN  NUMBER,
    p_owner_effective_date      IN  DATE,
    p_user_effective_date     IN  DATE,
    p_dimension_name      IN  VARCHAR2,
    p_expiry_information     OUT NOCOPY NUMBER)
IS
    p_user_start_period DATE;
    p_owner_start_period  DATE;
BEGIN

  -- This is only for USER REGULAR BALANCES
  p_user_start_period  := hr_gbbal.dimension_reset_date(p_dimension_name, p_user_effective_date,null);
  p_owner_start_period := hr_gbbal.dimension_reset_date(p_dimension_name, p_owner_effective_date,null);
  IF p_user_start_period = p_owner_start_period THEN
    p_expiry_information := 0; -- FALSE
  ELSE
    p_expiry_information := 1; -- TRUE
  END IF;

END check_expiry;
--------------------------------------------------------------------------------
--                          EXPIRY CHECKING CODE  For Prevention              --
--                          of loss of latest balance (for 115.63)
--------------------------------------------------------------------------------

PROCEDURE check_expiry(
    p_owner_payroll_action_id     IN  NUMBER,
    p_user_payroll_action_id      IN  NUMBER,
    p_owner_assignment_action_id  IN  NUMBER,
    p_user_assignment_action_id   IN  NUMBER,
    p_owner_effective_date        IN  DATE,
    p_user_effective_date         IN  DATE,
    p_dimension_name              IN  VARCHAR2,
    p_expiry_information         OUT NOCOPY DATE)

IS
   p_owner_start_period  DATE;
   l_regular_payment_date DATE;

BEGIN

   SELECT PTP.regular_payment_date
     INTO l_regular_payment_date
     FROM per_time_periods    PTP,
          pay_payroll_actions BACT
    WHERE BACT.payroll_action_id = p_owner_payroll_action_id
      AND PTP.time_period_id = BACT.time_period_id;

   IF p_dimension_name = '_ASG_CALENDAR_QTD             USER-REG ASG 01-01 RESET 04'
   THEN
      p_expiry_information := TRUNC(ADD_MONTHS(l_regular_payment_date, 3), 'Q')-1;

   ELSIF p_dimension_name = '_ASG_QTD                      USER-REG ASG 06-04 RESET 04'
   THEN
      p_owner_start_period := hr_gbbal.dimension_reset_date(p_dimension_name, p_owner_effective_date,null);

      p_expiry_information := ADD_MONTHS(p_owner_start_period,3) - 1;
      -- TRUNC(ADD_MONTHS(p_owner_effective_date, 3), 'Q')+ 4;

   ELSIF p_dimension_name = '_ASG_CALENDAR_YTD             USER-REG ASG 01-01 RESET 01'
   THEN
      p_expiry_information := TRUNC(ADD_MONTHS(l_regular_payment_date, 12), 'Y')-1;

   END IF;

END check_expiry;

-------------------------------------------------------------------------------
--
--     FUNCTION get_element_reference.
--     This function returns an element balance reference number
--     for identification purposes, which is suffixed by ITD or PTD
--     depending on the balance, and used as the reported dimension name.
--     Where there is no reference, the displayed dimension defaults to
--     _ELEMENT_PTD or _ELEMENT_ITD.
--     Bug 1146055, use Run Results instead of element entries,
--     note still uses view pay_input_values.
--
-------------------------------------------------------------------------------
--
FUNCTION get_element_reference(p_run_result_id        IN NUMBER,
             p_database_item_suffix IN VARCHAR2)
RETURN VARCHAR2 IS
--
l_reference varchar2(60);
l_suffix varchar2(4);
l_prefix varchar2(20);
l_original_entry_id number;
--
cursor get_run_result_value (c_run_result_id  NUMBER) is
  SELECT prrv.result_value
  FROM   pay_run_result_values prrv,
         pay_run_results prr,
         pay_input_values iv
  WHERE  prr.run_result_id = c_run_result_id
  AND    prr.run_result_id = prrv.run_result_id
  AND    iv.name  = 'Reference'
  AND    iv.input_value_id = prrv.input_value_id;

cursor get_source_id(c_run_result_id NUMBER) IS
  SELECT prr.source_id
  FROM   pay_run_results prr
  WHERE  prr.run_result_id = c_run_result_id;

--
BEGIN
--
  open get_run_result_value (p_run_result_id);
  fetch get_run_result_value into l_reference;
  close get_run_result_value;

  open  get_source_id (p_run_result_id);
  fetch get_source_id into l_original_entry_id;
  close get_source_id;
--
  /*For bug fix 4452262*/
  if p_database_item_suffix in ('_ELEMENT_ITD','_ELEMENT_PTD') then

      l_prefix := substr(p_database_item_suffix,1, length(p_database_item_suffix)-3);
      l_suffix := substr(p_database_item_suffix, -4);
      l_reference := l_prefix|| l_original_entry_id || l_suffix;

  elsif  p_database_item_suffix in ('_ELEMENT_CO_REF_ITD') then

      l_prefix := substr(p_database_item_suffix,1, length(p_database_item_suffix)-3);
      l_suffix := substr(p_database_item_suffix, -4);
      l_reference := l_prefix|| l_reference || l_suffix;

  elsif (l_reference is null or l_reference = 'Unknown') then
      l_reference := p_database_item_suffix;

  else
      l_reference := p_database_item_suffix;
  end if;
--
RETURN l_reference;
END get_element_reference;

-------------------------------------------------------------------------------
--
--     FUNCTION get_context_references.
--     This function returns context value,  which is suffixed by ITD or PTD
--     depending on the balance, and used as the reported dimension name.
--     Where there is no context value, the displayed dimension defaults to
--     database item suffix.
--
-------------------------------------------------------------------------------

FUNCTION get_context_references(p_context_value        IN VARCHAR2,
              p_database_item_suffix IN VARCHAR2)
RETURN VARCHAR2 IS
--
l_context varchar2(60);
l_suffix varchar2(4);
l_prefix varchar2(15);
--
BEGIN

   if p_context_value is null or  p_context_value = 'Unknown' then
      l_context := p_database_item_suffix;
   else
          l_context := p_database_item_suffix;
          l_suffix := substr(p_database_item_suffix, -4);
          l_prefix := substr(p_database_item_suffix,1,11);
          l_context := l_prefix || p_context_value || l_suffix;

   end if;
--
RETURN l_context;
END get_context_references;

-----------------------------------------------------------------------
function ni_category_exists_in_year (p_assignment_action_id in number,
                                     p_category in varchar2)
RETURN number is
   l_return number;
   l_regular_payment_date per_time_periods.regular_payment_date%type;
   l_niable_def_id pay_defined_balances.defined_balance_id%type;
   l_nitotal_def_id pay_defined_balances.defined_balance_id%type;
   l_nitotal_value number;
   l_niable_value number;
--

/*Added for bug fix 4088228, to get the child assignment_action_id*/

cursor csr_child_asg_actid
is
    SELECT max(paa.assignment_action_id)
    FROM pay_assignment_actions paa
    WHERE
         paa.source_action_id = p_assignment_action_id
    AND  paa.source_action_id is not null;

cursor csr_latest_bal (c_asg_action_id IN NUMBER,
           c_defined_balance_id IN NUMBER) is
        SELECT value
        from pay_assignment_latest_balances
        Where assignment_action_id = c_asg_action_id
        and   defined_balance_id = c_defined_balance_id;

cursor CSR_ni_entries is
select distinct pel.element_type_id element_type_id,
    nvl(ent.original_entry_id, ent.element_entry_id) source_id
       from pay_element_entries_f ent,
      pay_element_links_f pel,
      pay_user_rows_f urows,
      pay_payroll_actions bact,
      per_time_periods bptp,
      pay_assignment_actions bassact
        where bassact.assignment_action_id = p_assignment_action_id
  and   UROWS.user_table_id = g_ni_cat_indicator_table_id
        and   fnd_number.canonical_to_number(UROWS.ROW_LOW_RANGE_OR_NAME)  = PEL.ELEMENT_TYPE_ID
  and   g_start_of_year between
        UROWS.effective_start_date and UROWS.effective_end_date
  and   bact.payroll_action_id = bassact.payroll_action_id
  and   bptp.time_period_id = bact.time_period_id
  and   ent.assignment_id = bassact.assignment_id
        and  ent.effective_end_date >= g_start_of_year
  and  ent.effective_start_date <= bptp.end_date
  and  ent.element_link_id = pel.element_link_id
  and  pel.business_group_id + 0 = bact.business_group_id
  and ent.effective_end_date between
    pel.effective_start_date and pel.effective_end_date;

cursor CSR_ni_run_results_exist (p_source_id number) is
select    max(decode(PRR.element_type_id,g_ni_a_element_type_id,1,0))
        , max(decode(PRR.element_type_id,g_ni_b_element_type_id,1,0))
        , max(decode(PRR.element_type_id,g_ni_c_element_type_id,1,0))
        , max(decode(PRR.element_type_id,g_ni_d_element_type_id,1,0))
        , max(decode(PRR.element_type_id,g_ni_e_element_type_id,1,0))
        , max(decode(PRR.element_type_id,g_ni_f_element_type_id,1,0))
        , max(decode(PRR.element_type_id,g_ni_g_element_type_id,1,0))
        , max(decode(PRR.element_type_id,g_ni_j_element_type_id,1,0))
        , max(decode(PRR.element_type_id,g_ni_l_element_type_id,1,0))
        , max(decode(PRR.element_type_id,g_ni_s_element_type_id,1,0))
from
                PAY_RUN_RESULTS        PRR
         ,      PER_TIME_PERIODS       PPTP
         ,      PAY_PAYROLL_ACTIONS    PACT
         ,      PAY_ASSIGNMENT_ACTIONS ASSACT
         ,      PAY_ASSIGNMENT_ACTIONS BASSACT
         where  PRR.source_id = p_source_id
         and    PRR.source_type = 'I'
         AND    PACT.PAYROLL_ACTION_ID   = ASSACT.PAYROLL_ACTION_ID
   AND    PACT.ACTION_TYPE <> 'I'
         AND    PPTP.TIME_PERIOD_ID      = PACT.TIME_PERIOD_ID
         AND    PPTP.regular_payment_date >= g_start_of_year
         AND    BASSACT.ASSIGNMENT_ACTION_ID = p_assignment_action_id
         AND    ASSACT.ACTION_SEQUENCE <= BASSACT.ACTION_SEQUENCE
         AND    ASSACT.ASSIGNMENT_ACTION_ID  = PRR.ASSIGNMENT_ACTION_ID
         AND    ASSACT.ASSIGNMENT_ID       = BASSACT.ASSIGNMENT_ID;

cursor CSR_run_results_exist is
select    max(decode(FEED.balance_type_id,g_ni_a_id,1,g_ni_a_able_id,1,0))
        , max(decode(FEED.balance_type_id,g_ni_b_id,1,g_ni_b_able_id,1,0))
        , max(decode(FEED.balance_type_id,g_ni_c_id,1,g_ni_c_able_id,1,0))
        , max(decode(FEED.balance_type_id,g_ni_d_id,1,g_ni_d_able_id,1,0))
        , max(decode(FEED.balance_type_id,g_ni_e_id,1,g_ni_e_able_id,1,0))
        , max(decode(FEED.balance_type_id,g_ni_f_id,1,g_ni_f_able_id,1,0))
        , max(decode(FEED.balance_type_id,g_ni_g_id,1,g_ni_g_able_id,1,0))
        , max(decode(FEED.balance_type_id,g_ni_j_id,1,g_ni_j_able_id,1,0))
        , max(decode(FEED.balance_type_id,g_ni_l_id,1,g_ni_l_able_id,1,0))
        , max(decode(FEED.balance_type_id,g_ni_s_id,1,g_ni_s_able_id,1,0))
from
    PAY_BALANCE_FEEDS_F    FEED
         ,      PAY_RUN_RESULT_VALUES  PRRV
         ,      PAY_RUN_RESULTS        PRR
         ,      PER_TIME_PERIODS       PPTP
         ,      PAY_PAYROLL_ACTIONS    PACT
         ,      PAY_ASSIGNMENT_ACTIONS ASSACT
         ,      PAY_ASSIGNMENT_ACTIONS BASSACT
   WHERE   FEED.balance_type_id in (
     g_ni_a_id, g_ni_a_able_id
    ,g_ni_b_id, g_ni_b_able_id
    ,g_ni_c_id, g_ni_c_able_id
    ,g_ni_d_id, g_ni_d_able_id
    ,g_ni_e_id, g_ni_e_able_id
    ,g_ni_f_id, g_ni_f_able_id
    ,g_ni_g_id, g_ni_g_able_id
    ,g_ni_j_id, g_ni_j_able_id
    ,g_ni_l_id, g_ni_l_able_id
    ,g_ni_s_id, g_ni_s_able_id
    )
         AND    PRR.RUN_RESULT_ID       = PRRV.RUN_RESULT_ID
         AND    PACT.PAYROLL_ACTION_ID   = ASSACT.PAYROLL_ACTION_ID
   AND    PACT.action_type in ('I',g_action_typer,g_action_typeq,g_action_typeb)
         AND    PPTP.TIME_PERIOD_ID      = PACT.TIME_PERIOD_ID
         AND    PPTP.regular_payment_date >= g_start_of_year
         AND    BASSACT.ASSIGNMENT_ACTION_ID = p_assignment_action_id
         AND    PRRV.RESULT_VALUE IS NOT NULL
         AND    PRRV.RESULT_VALUE <> '0'
         AND    PPTP.regular_payment_date is not null
   AND    FEED.INPUT_VALUE_ID = PRRV.INPUT_VALUE_ID
   AND    PACT.effective_date between
        FEED.effective_start_date and FEED.effective_end_date
         AND    ASSACT.ACTION_SEQUENCE <= BASSACT.ACTION_SEQUENCE
         AND    ASSACT.ASSIGNMENT_ACTION_ID = PRR.ASSIGNMENT_ACTION_ID
         AND    ASSACT.ASSIGNMENT_ID       = BASSACT.ASSIGNMENT_ID;
--BUG Changed cursor for improving performance 3221422
--Remove this cursor for bug 4120063
/*
cursor CSR_initialization_exists is
select   1
from per_time_periods ptp
where ptp.regular_payment_date >= g_start_of_year
and ptp.time_period_id in
    (
    select
    null
    from pay_payroll_actions pact
    where pact.action_type = 'I'
    );
*/
--
cursor csr_asg_action_info (c_assignment_action_id IN NUMBER) IS
   select paa.assignment_id,
          paa.action_sequence,
          ppa.effective_date
   from pay_assignment_actions paa,
        pay_payroll_actions ppa
   where paa.assignment_action_id = c_assignment_action_id
   and   paa.payroll_action_id = ppa.payroll_action_id;
--
l_ni_a_exists_adj number;
l_ni_b_exists_adj number;
l_ni_c_exists_adj number;
l_ni_d_exists_adj number;
l_ni_e_exists_adj number;
l_ni_f_exists_adj number;
l_ni_g_exists_adj number;
l_ni_j_exists_adj number;
l_ni_l_exists_adj number;
l_ni_s_exists_adj number;

/*Added for bug fix 4088228*/
v_assignment_action_id  pay_assignment_actions.assignment_action_id%TYPE;
p_assignment_action_id_child pay_assignment_actions.assignment_action_id%TYPE;
v_master_exist  varchar2(1);

begin
--

 /*Added for bug fix 4088228*/

  open csr_child_asg_actid;
  fetch csr_child_asg_actid into v_assignment_action_id;
  close csr_child_asg_actid;

if v_assignment_action_id is not null then
    p_assignment_action_id_child := v_assignment_action_id;
else
    p_assignment_action_id_child := p_assignment_action_id;
end if;

if p_assignment_action_id_child is null or p_category is null then --Bug fix 4099228
  return null;
end if;
--
if g_ni_a_id is null then -- first call this session
        begin
                select user_table_id
                into g_ni_cat_indicator_table_id
                        from pay_user_tables
                where user_table_name = 'NI_CATEGORY_INDICATOR_ELEMENTS'
                and legislation_code = 'GB';
       -- if not found raise error
       EXCEPTION WHEN no_data_found THEN
          g_action_typer := 'R';
          g_action_typeq := 'Q';
          g_action_typeb := 'B';
        end;

       end if;

if g_ni_a_id is null then -- first call this session
select   max(decode(balance_name, 'NI A Total',balance_type_id,0))
        ,max(decode(balance_name, 'NI A Able' ,balance_type_id,0))
        ,max(decode(balance_name, 'NI B Total',balance_type_id,0))
        ,max(decode(balance_name, 'NI B Able' ,balance_type_id,0))
        ,max(decode(balance_name, 'NI C Total',balance_type_id,0))
        ,max(decode(balance_name, 'NI C Able' ,balance_type_id,0))
        ,max(decode(balance_name, 'NI D Total',balance_type_id,0))
        ,max(decode(balance_name, 'NI D Able' ,balance_type_id,0))
        ,max(decode(balance_name, 'NI E Total',balance_type_id,0))
        ,max(decode(balance_name, 'NI E Able' ,balance_type_id,0))
        ,max(decode(balance_name, 'NI F Total',balance_type_id,0))
        ,max(decode(balance_name, 'NI F Able' ,balance_type_id,0))
        ,max(decode(balance_name, 'NI G Total',balance_type_id,0))
        ,max(decode(balance_name, 'NI G Able' ,balance_type_id,0))
        ,max(decode(balance_name, 'NI J Total',balance_type_id,0))
        ,max(decode(balance_name, 'NI J Able' ,balance_type_id,0))
        ,max(decode(balance_name, 'NI L Total',balance_type_id,0))
        ,max(decode(balance_name, 'NI L Able' ,balance_type_id,0))
        ,max(decode(balance_name, 'NI S Total',balance_type_id,0))
        ,max(decode(balance_name, 'NI S Able' ,balance_type_id,0))
        into
         g_ni_a_id, g_ni_a_able_id
        ,g_ni_b_id, g_ni_b_able_id
        ,g_ni_c_id, g_ni_c_able_id
        ,g_ni_d_id, g_ni_d_able_id
        ,g_ni_e_id, g_ni_e_able_id
        ,g_ni_f_id, g_ni_f_able_id
        ,g_ni_g_id, g_ni_g_able_id
        ,g_ni_j_id, g_ni_j_able_id
        ,g_ni_l_id, g_ni_l_able_id
        ,g_ni_s_id, g_ni_s_able_id
        from pay_balance_types
        where balance_name in (
         'NI A Total', 'NI A Able'
        ,'NI B Total', 'NI B Able'
        ,'NI C Total', 'NI C Able'
        ,'NI D Total', 'NI D Able'
        ,'NI E Total', 'NI E Able'
        ,'NI F Total', 'NI F Able'
        ,'NI G Total', 'NI G Able'
        ,'NI J Total', 'NI J Able'
        ,'NI L Total', 'NI L Able'
        ,'NI S Total', 'NI S Able'
        )
        and legislation_code = 'GB';
end if;
--
if g_ni_element_type_id is null then -- first call this session
        select
        max(ptp.regular_payment_date)
        ,max(decode(e.element_name,'NI',e.element_type_id,0))
        ,max(decode(e.element_name,'NI A',e.element_type_id,0))
        ,max(decode(e.element_name,'NI B',e.element_type_id,0))
        ,max(decode(e.element_name,'NI C',e.element_type_id,0))
        ,max(decode(e.element_name,'NI D',e.element_type_id,0))
        ,max(decode(e.element_name,'NI E',e.element_type_id,0))
        ,max(decode(e.element_name,'NI F',e.element_type_id,0))
        ,max(decode(e.element_name,'NI G',e.element_type_id,0))
        ,max(decode(e.element_name,'NI J Deferment',e.element_type_id,0))
        ,max(decode(e.element_name,'NI L Deferment',e.element_type_id,0))
        ,max(decode(e.element_name,'NI S',e.element_type_id,0))
             into
             l_regular_payment_date
             ,g_ni_element_type_id
             ,g_ni_a_element_type_id
             ,g_ni_b_element_type_id
             ,g_ni_c_element_type_id
             ,g_ni_d_element_type_id
             ,g_ni_e_element_type_id
             ,g_ni_f_element_type_id
             ,g_ni_g_element_type_id
             ,g_ni_j_element_type_id
             ,g_ni_l_element_type_id
             ,g_ni_s_element_type_id
             from pay_element_types_f e,
                  per_time_periods ptp,
                  pay_payroll_actions bact,
                  pay_assignment_actions bassact
             where element_name in (     'NI'
                                        ,'NI A'
                                        ,'NI B'
                                        ,'NI C'
                                        ,'NI D'
                                        ,'NI E'
                                        ,'NI F'
                                        ,'NI G'
                                        ,'NI J Deferment'
                                        ,'NI L Deferment'
                                        ,'NI S')
               and e.legislation_code = 'GB'
               and bassact.assignment_action_id = p_assignment_action_id_child -- bug fix 4088228
               and bassact.payroll_action_id = bact.payroll_action_id
               and ptp.time_period_id = bact.time_period_id
               and bact.date_earned between
                    e.effective_start_date and e.effective_end_date;
end if;
--
   -- first time through check whether any balance initializations have happened
   -- in the tax year - if not we don't need to check the initialization on
   -- individual balances.



   begin
    if g_start_of_year is null then -- first call this session
       g_start_of_year := hr_gbbal.span_start(l_regular_payment_date, 1, '06-04');
       /*
       open  CSR_initialization_exists;
       fetch CSR_initialization_exists into g_initialization_exists;
       close CSR_initialization_exists;
       */
    end if;
   end;
   --
   -- setup balance dimension id
   --
   if g_asg_td_ytd is null then
      select balance_dimension_id
      into g_asg_td_ytd
      from pay_balance_dimensions
      where dimension_name = '_ASG_TD_YTD';
   end if;
   --
   -- Check to see whether there are any latest balances for the
   -- NI <CAT> Total or NI <CAT> Able balances, for the dimension
   -- _ASG_TD_YTD. If so, we do not need to loop through the
   -- run results below. Use already cached balance type id's.
   --
   IF g_ni_a_defbal_id is null then
    -- First call this session, set up defined balances.
    select max(decode(balance_type_id,g_ni_a_id,defined_balance_id,0))
          ,max(decode(balance_type_id,g_ni_a_able_id,defined_balance_id,0))
          ,max(decode(balance_type_id,g_ni_b_id,defined_balance_id,0))
          ,max(decode(balance_type_id,g_ni_b_able_id,defined_balance_id,0))
          ,max(decode(balance_type_id,g_ni_c_id,defined_balance_id,0))
          ,max(decode(balance_type_id,g_ni_c_able_id,defined_balance_id,0))
          ,max(decode(balance_type_id,g_ni_d_id,defined_balance_id,0))
          ,max(decode(balance_type_id,g_ni_d_able_id,defined_balance_id,0))
          ,max(decode(balance_type_id,g_ni_e_id,defined_balance_id,0))
          ,max(decode(balance_type_id,g_ni_e_able_id,defined_balance_id,0))
          ,max(decode(balance_type_id,g_ni_f_id,defined_balance_id,0))
          ,max(decode(balance_type_id,g_ni_f_able_id,defined_balance_id,0))
          ,max(decode(balance_type_id,g_ni_g_id,defined_balance_id,0))
          ,max(decode(balance_type_id,g_ni_g_able_id,defined_balance_id,0))
          ,max(decode(balance_type_id,g_ni_j_id,defined_balance_id,0))
          ,max(decode(balance_type_id,g_ni_j_able_id,defined_balance_id,0))
          ,max(decode(balance_type_id,g_ni_l_id,defined_balance_id,0))
          ,max(decode(balance_type_id,g_ni_l_able_id,defined_balance_id,0))
          ,max(decode(balance_type_id,g_ni_s_id,defined_balance_id,0))
          ,max(decode(balance_type_id,g_ni_s_able_id,defined_balance_id,0))
    into
      g_ni_a_defbal_id,
      g_ni_a_able_defbal_id,
      g_ni_b_defbal_id,
      g_ni_b_able_defbal_id,
      g_ni_c_defbal_id,
      g_ni_c_able_defbal_id,
      g_ni_d_defbal_id,
      g_ni_d_able_defbal_id,
      g_ni_e_defbal_id,
      g_ni_e_able_defbal_id,
      g_ni_f_defbal_id,
      g_ni_f_able_defbal_id,
      g_ni_g_defbal_id,
      g_ni_g_able_defbal_id,
      g_ni_j_defbal_id,
      g_ni_j_able_defbal_id,
      g_ni_l_defbal_id,
      g_ni_l_able_defbal_id,
      g_ni_s_defbal_id,
      g_ni_s_able_defbal_id
    from pay_defined_balances
    where balance_dimension_id = g_asg_td_ytd
    and balance_type_id in
     (g_ni_a_id, g_ni_a_able_id
        ,g_ni_b_id, g_ni_b_able_id
        ,g_ni_c_id, g_ni_c_able_id
        ,g_ni_d_id, g_ni_d_able_id
        ,g_ni_e_id, g_ni_e_able_id
        ,g_ni_f_id, g_ni_f_able_id
        ,g_ni_g_id, g_ni_g_able_id
        ,g_ni_j_id, g_ni_j_able_id
        ,g_ni_l_id, g_ni_l_able_id
        ,g_ni_s_id, g_ni_s_able_id)
    and legislation_code = 'GB'
    and business_group_id is null;
   --
   END IF; -- Setup cached defined balances
   --
   -- Choose the relevant defined balance for latest balance
   -- call according to category.
   --
   If p_category = 'A' then
      l_nitotal_def_id := g_ni_a_defbal_id;
      l_niable_def_id := g_ni_a_able_defbal_id;
   Elsif p_category = 'B' then
      l_nitotal_def_id := g_ni_b_defbal_id;
      l_niable_def_id := g_ni_b_able_defbal_id;
   Elsif p_category = 'C' then
      l_nitotal_def_id := g_ni_c_defbal_id;
      l_niable_def_id := g_ni_c_able_defbal_id;
   Elsif p_category = 'D' then
      l_nitotal_def_id := g_ni_d_defbal_id;
      l_niable_def_id := g_ni_d_able_defbal_id;
   Elsif p_category = 'E' then
      l_nitotal_def_id := g_ni_e_defbal_id;
      l_niable_def_id := g_ni_e_able_defbal_id;
   Elsif p_category = 'F' then
      l_nitotal_def_id := g_ni_f_defbal_id;
      l_niable_def_id := g_ni_f_able_defbal_id;
   Elsif p_category = 'G' then
      l_nitotal_def_id := g_ni_g_defbal_id;
      l_niable_def_id := g_ni_g_able_defbal_id;
   Elsif p_category = 'J' then
      l_nitotal_def_id := g_ni_j_defbal_id;
      l_niable_def_id := g_ni_j_able_defbal_id;
   Elsif p_category = 'L' then
      l_nitotal_def_id := g_ni_l_defbal_id;
      l_niable_def_id := g_ni_l_able_defbal_id;
   Elsif p_category = 'S' then
      l_nitotal_def_id := g_ni_s_defbal_id;
      l_niable_def_id := g_ni_s_able_defbal_id;
   End If;
   --


   if p_assignment_action_id_child <> nvl(g_assignment_action_id2, -1) then --bug fix 4088228
     --
     open csr_asg_action_info(p_assignment_action_id_child);  --bug fix 4088228
     fetch csr_asg_action_info into g_assignment_id,
                                    g_action_sequence,
                                    g_effective_date;
     close csr_asg_action_info;
     --
     g_assignment_action_id2 := p_assignment_action_id_child; -- bug fix 4088228
     --
   end if;
   --
   -- Check to see if any latest balances first.
   --
   l_nitotal_value := null;
   l_niable_value := null;
   --
   open csr_latest_bal(p_assignment_action_id_child, l_nitotal_def_id);  -- bug fix 4088228
   fetch csr_latest_bal into l_nitotal_value;
   close csr_latest_bal;
   --
   open csr_latest_bal(p_assignment_action_id_child, l_niable_def_id); --bug fix 4088228
   fetch csr_latest_bal into l_niable_value;
   close csr_latest_bal;
   --
   -- If either total or able latest balances are null, then the
   -- Run Results cursors are used.
   --
   IF l_nitotal_value is null OR l_niable_value is null THEN
      --
      -- if a non zero result exists for either the NI Cat Total or the
      -- NI Cat Niable balance within the year the category has existed
      -- Prior to April 00 NI Cat Total indicated a category was reported
      -- for the assignment.  However the introduction of the EET threshold
      -- and balances means that even without a deduction being taken
      -- EET balances, Able Balances and EES Rebate balances need to be
      -- reported.
      -- If NI Earnings are above the LEL than NI Cat Able is recorded up
      -- test NI Cat Total which will be non zero in this instance.
      -- first call for this assignment action
      if nvl(g_assignment_action_id,-1) <> p_assignment_action_id_child then --bug fix 4088228

         g_assignment_action_id := p_assignment_action_id_child; --bug fix 4088228
       -- first check for the normal run indirects in the year
       -- The normal way for NI Balances is fed is from indirects
       -- returned by the NI Formula.
       -- exceptionally users adjust NI balances in a run or adjustment
       -- by giving an individual NI Category Element to an assignment
       -- the ni_run_result cursor caters for these two types of
       -- results using the optimal N51 index to retreive results.
       -- To achieve this it joins first to the element entries
       -- Table for a list of NI elements defined in a user table.
       begin
       g_ni_a_exists := 0;
       g_ni_b_exists := 0;
       g_ni_c_exists := 0;
       g_ni_d_exists := 0;
       g_ni_e_exists := 0;
       g_ni_f_exists := 0;
       g_ni_g_exists := 0;
       g_ni_j_exists := 0;
       g_ni_l_exists := 0;
       g_ni_s_exists := 0;
       if g_action_typer is null then -- [ ? check for user table redundant
       for l_entry in CSR_ni_entries loop -- { loop through the entries
        -- for NI itself look for the indirect results it has produced
        if l_entry.element_type_id = g_ni_element_type_id then -- [ NI
                open  CSR_ni_run_results_exist(l_entry.source_id);
                fetch CSR_ni_run_results_exist
                        into     l_ni_a_exists_adj
                                ,l_ni_b_exists_adj
                                ,l_ni_c_exists_adj
                                ,l_ni_d_exists_adj
                                ,l_ni_e_exists_adj
                                ,l_ni_f_exists_adj
                                ,l_ni_g_exists_adj
                                ,l_ni_j_exists_adj
                                ,l_ni_l_exists_adj
                                ,l_ni_s_exists_adj;
                close CSR_ni_run_results_exist;
                if l_ni_a_exists_adj = 1 then g_ni_a_exists := 1; end if;
                if l_ni_b_exists_adj = 1 then g_ni_b_exists := 1; end if;
                if l_ni_c_exists_adj = 1 then g_ni_c_exists := 1; end if;
                if l_ni_d_exists_adj = 1 then g_ni_d_exists := 1; end if;
                if l_ni_e_exists_adj = 1 then g_ni_e_exists := 1; end if;
                if l_ni_f_exists_adj = 1 then g_ni_f_exists := 1; end if;
                if l_ni_g_exists_adj = 1 then g_ni_g_exists := 1; end if;
                if l_ni_j_exists_adj = 1 then g_ni_j_exists := 1; end if;
                if l_ni_l_exists_adj = 1 then g_ni_l_exists := 1; end if;
                if l_ni_s_exists_adj = 1 then g_ni_s_exists := 1; end if;
        end if; -- ] NI
                if l_entry.element_type_id = g_ni_a_element_type_id
                                         then g_ni_a_exists := 1; end if;
                if l_entry.element_type_id = g_ni_b_element_type_id
                                         then g_ni_b_exists := 1; end if;
                if l_entry.element_type_id = g_ni_c_element_type_id
                                         then g_ni_c_exists := 1; end if;
                if l_entry.element_type_id = g_ni_d_element_type_id
                                         then g_ni_d_exists := 1; end if;
                if l_entry.element_type_id = g_ni_e_element_type_id
                                         then g_ni_e_exists := 1; end if;
                if l_entry.element_type_id = g_ni_f_element_type_id
                                         then g_ni_f_exists := 1; end if;
                if l_entry.element_type_id = g_ni_g_element_type_id
                                         then g_ni_g_exists := 1; end if;
                if l_entry.element_type_id = g_ni_j_element_type_id
                                         then g_ni_j_exists := 1; end if;
                if l_entry.element_type_id = g_ni_l_element_type_id
                                         then g_ni_l_exists := 1; end if;
                if l_entry.element_type_id = g_ni_s_element_type_id
                                         then g_ni_s_exists := 1; end if;
        end loop; -- } ni_entries loop
      end if; -- ]
    end;
    begin
    -- now select initialization in the year
    -- initialization results don't have source_id set to the NI Element
    -- so for these actions use a more expensive execution plan that
    -- retrieves all initialization results in the year and then tests
    -- whether any feed the NI Balances. Condition this step out all together
    -- if no initialization actions are detected in the year. If no seeded
    -- user table exists then also use this cursor
    if /* g_initialization_exists = 1 or  */
       g_action_typer = 'R' then
      --
      open  CSR_run_results_exist;
      fetch CSR_run_results_exist
                        into     l_ni_a_exists_adj
                                ,l_ni_b_exists_adj
                                ,l_ni_c_exists_adj
                                ,l_ni_d_exists_adj
                                ,l_ni_e_exists_adj
                                ,l_ni_f_exists_adj
                                ,l_ni_g_exists_adj
                                ,l_ni_j_exists_adj
                                ,l_ni_l_exists_adj
                                ,l_ni_s_exists_adj;
      close CSR_run_results_exist;
    end if;
    end;
  --
  --
  if l_ni_a_exists_adj = 1 then g_ni_a_exists := 1; end if;
  if l_ni_b_exists_adj = 1 then g_ni_b_exists := 1; end if;
  if l_ni_c_exists_adj = 1 then g_ni_c_exists := 1; end if;
  if l_ni_d_exists_adj = 1 then g_ni_d_exists := 1; end if;
  if l_ni_e_exists_adj = 1 then g_ni_e_exists := 1; end if;
  if l_ni_f_exists_adj = 1 then g_ni_f_exists := 1; end if;
  if l_ni_g_exists_adj = 1 then g_ni_g_exists := 1; end if;
  if l_ni_j_exists_adj = 1 then g_ni_j_exists := 1; end if;
  if l_ni_l_exists_adj = 1 then g_ni_l_exists := 1; end if;
  if l_ni_s_exists_adj = 1 then g_ni_s_exists := 1; end if;
 --
 end if; -- g_asg_action = p_asg_action.
 --
ELSIF l_nitotal_value = 0 AND l_niable_value = 0 THEN
 --
 -- There are latest balances but they are zero so could be
 -- from a previous asg action. The rest of this category's
 -- balances are not needed anyway, so return a 0.
 --
 if P_category = 'A' then g_ni_a_exists := 0; end if;
 if P_category = 'B' then g_ni_b_exists := 0; end if;
 if P_category = 'C' then g_ni_c_exists := 0; end if;
 if P_category = 'D' then g_ni_d_exists := 0; end if;
 if P_category = 'E' then g_ni_e_exists := 0; end if;
 if P_category = 'F' then g_ni_f_exists := 0; end if;
 if P_category = 'G' then g_ni_g_exists := 0; end if;
 if P_category = 'J' then g_ni_j_exists := 0; end if;
 if P_category = 'L' then g_ni_l_exists := 0; end if;
 if P_category = 'S' then g_ni_s_exists := 0; end if;
 --
ELSE
 --
 -- The latest balances are not null or 0, so there must be a
 -- balance value for this category, set the individual existance
 -- variables due to reset of master return variable below.
 --
 if P_category = 'A' then g_ni_a_exists := 1; end if;
 if P_category = 'B' then g_ni_b_exists := 1; end if;
 if P_category = 'C' then g_ni_c_exists := 1; end if;
 if P_category = 'D' then g_ni_d_exists := 1; end if;
 if P_category = 'E' then g_ni_e_exists := 1; end if;
 if P_category = 'F' then g_ni_f_exists := 1; end if;
 if P_category = 'G' then g_ni_g_exists := 1; end if;
 if P_category = 'J' then g_ni_j_exists := 1; end if;
 if P_category = 'L' then g_ni_l_exists := 1; end if;
 if P_category = 'S' then g_ni_s_exists := 1; end if;

END IF; -- (Latest balances)
 --
 l_return := 0;
 if P_category = 'A' then l_return := g_ni_a_exists; end if;
 if P_category = 'B' then l_return := g_ni_b_exists; end if;
 if P_category = 'C' then l_return := g_ni_c_exists; end if;
 if P_category = 'D' then l_return := g_ni_d_exists; end if;
 if P_category = 'E' then l_return := g_ni_e_exists; end if;
 if P_category = 'F' then l_return := g_ni_f_exists; end if;
 if P_category = 'G' then l_return := g_ni_g_exists; end if;
 if P_category = 'J' then l_return := g_ni_j_exists; end if;
 if P_category = 'L' then l_return := g_ni_l_exists; end if;
 if P_category = 'S' then l_return := g_ni_s_exists; end if;
 --
return l_return;
end ni_category_exists_in_year;
--
FUNCTION get_master_action_id(p_action_type IN VARCHAR2,
                              p_action_id   IN NUMBER)
RETURN NUMBER
IS
   l_action_id   number;
BEGIN
     l_action_id := null;
     if (p_action_type in ('R','Q')) then
        select nvl(assact.source_action_id, assact.assignment_action_id)
        into   l_action_id
        from   pay_assignment_actions assact
        where  assact.assignment_action_id = p_action_id;
     end if;

     return l_action_id;
END get_master_action_id;
--
--
END hr_gbbal;

/
