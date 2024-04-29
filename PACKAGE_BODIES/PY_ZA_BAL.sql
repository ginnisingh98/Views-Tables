--------------------------------------------------------
--  DDL for Package Body PY_ZA_BAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PY_ZA_BAL" AS
/* $Header: pyzabal1.pkb 120.3 2005/12/19 04:15:59 amahanty noship $ */
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- return the start of the span (year/quarter/week)
FUNCTION span_start(
        p_input_date            DATE,
        p_frequency             NUMBER DEFAULT 1,
        p_start_dd_mm           VARCHAR2 DEFAULT '06-04-')
RETURN DATE
IS
        l_year  NUMBER(4);
        l_start DATE;
--
BEGIN
        l_year := TO_NUMBER(TO_CHAR(p_input_date,'YYYY'));
--
   IF p_input_date >= TO_DATE(p_start_dd_mm||TO_CHAR(l_year),'DD-MM-YYYY') THEN
        l_start := TO_DATE(p_start_dd_mm||TO_CHAR(l_year),'DD-MM-YYYY');
   ELSE
        l_start := TO_DATE(p_start_dd_mm||TO_CHAR(l_year -1),'DD-MM-YYYY');
   END IF;
   -- cater for weekly based frequency based on 52 per annum
   IF p_frequency IN (52,26,13) THEN -- [
        l_start := p_input_date - MOD(p_input_date - l_start,7 * 52/p_frequency);
   ELSE
   -- cater for monthly based frequency based on 12 per annum
        l_start := ADD_MONTHS(l_start, (12/p_frequency) * TRUNC(MONTHS_BETWEEN(
                        p_input_date,l_start)/(12/p_frequency)));
   END IF;
--
RETURN l_start;
END span_start;
--------------------------------------------------------------------------------
--
--                      GET OWNING BALANCE (private)
--
--
--------------------------------------------------------------------------------
-- This procedure checks whether there is a value in the lb table for an
-- assignment and a defined balance id.
--
PROCEDURE get_owning_balance(p_assignment_id        IN NUMBER,
                                                 p_defined_balance_id   IN NUMBER,
                                                 p_assignment_action_id OUT NOCOPY NUMBER,
                                                 p_value                        OUT NOCOPY NUMBER) IS
--
   l_value                NUMBER;
   l_assignment_action_id NUMBER;
--
    cursor c2 (c_assignment_id  IN NUMBER,
               c_defined_bal_id IN NUMBER) is
    select value,
           assignment_action_id
    from   pay_assignment_latest_balances
    where  assignment_id = c_assignment_id
    and    defined_balance_id = c_defined_bal_id;
--
BEGIN
--
   open c2(p_assignment_id, p_defined_balance_id);
   fetch c2 into l_value, l_assignment_action_id;
   close c2;
--
   p_value := l_value;
   p_assignment_action_id := l_assignment_action_id;
exception
   when others then
   p_value := null;
   p_assignment_action_id := null;

END get_owning_balance;
--
--------------------------------------------------------------------------------
--
--                      SEQUENCE (private)
--
--
--------------------------------------------------------------------------------
--
FUNCTION sequence(p_assignment_action_id IN NUMBER)
--
RETURN NUMBER IS
--
   l_action_sequence    NUMBER;
--
   cursor get_sequence(c_assignment_action_id IN NUMBER) is
   select action_sequence from
          pay_assignment_actions
   where assignment_action_id = c_assignment_action_id;
--
BEGIN
--
   open get_sequence(p_assignment_action_id);
   fetch get_sequence into l_action_sequence;
   close get_sequence;
--
RETURN l_action_sequence;
--
END sequence;
--------------------------------------------------------------------------------
--
--                      GET LATEST BALANCE (private)
--
--
--------------------------------------------------------------------------------
--
-- Retrieve the latest balance given an assignment action and def. balance
--
FUNCTION get_latest_balance (p_assignment_action_id IN NUMBER,
                             p_defined_balance_id IN NUMBER)
--
RETURN NUMBER IS
--
   l_value              NUMBER;
--
cursor c1 (c_asg_action_id IN NUMBER,
           c_defined_balance_id IN NUMBER) is
        SELECT value
        from pay_assignment_latest_balances
        Where assignment_action_id = c_asg_action_id
        and   defined_balance_id = c_defined_balance_id;
--
BEGIN
--
   open c1(p_assignment_action_id
          ,p_defined_balance_id);
   fetch c1 into l_value;
   close c1;
--
   RETURN l_value;
--
END get_latest_balance;
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
   l_assignment_id      NUMBER;
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
   l_assignment_action_id       NUMBER;
--
/* Start Bug 3229579  */
/*
cursor get_latest_id (c_assignment_id IN NUMBER,
                      c_effective_date IN DATE) is
    SELECT
         to_number(substr(max(lpad(paa.action_sequence,15,'0')||paa.assignment_action_id),16))
    FROM pay_assignment_actions paa,
         pay_payroll_actions    ppa
    WHERE
         paa.assignment_id = c_assignment_id
    AND  ppa.payroll_action_id = paa.payroll_action_id
    AND  ppa.effective_date <= c_effective_date
    AND  ppa.action_type        in ('R', 'Q', 'I', 'V', 'B'); */


cursor get_latest_id (c_assignment_id IN NUMBER,
                      c_effective_date IN DATE) is
SELECT   /*+ ORDERED
                USE_NL(PAA PPA)
                INDEX(PAA PAY_ASSIGNMENT_ACTIONS_N51)
                INDEX(PPA PAY_PAYROLL_ACTIONS_PK) */
            TO_NUMBER(SUBSTR(MAX(LPAD(paa.action_sequence,15,'0')||
                      paa.assignment_action_id),16))
   FROM     pay_assignment_actions paa,
            pay_payroll_actions ppa
   WHERE    paa.assignment_id = c_assignment_id
   AND      ppa.payroll_action_id = paa.payroll_action_id
   AND      ppa.effective_date <= c_effective_date
   AND      ppa.action_type IN ('R', 'Q', 'I', 'V', 'B');

/* End Bug 3229579  */
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
--------------------------------------------------------------------------------
--
--                      CHECK EXPIRED ACTION  (private)
--
--
--------------------------------------------------------------------------------
--
-- This function checks to see whether an expired_value can be used
-- from the pay_assignment_latest_balances table.
--
FUNCTION check_expired_action(
                                p_defined_balance_id   IN NUMBER,
                                p_assignment_id        IN NUMBER,
                                p_assignment_action_id IN NUMBER)
RETURN NUMBER IS
--
    l_value             NUMBER;
--
    cursor expired_val (c_defined_balance_id IN NUMBER,
                        c_assignment_action_id IN NUMBER,
                        c_assignment_id IN NUMBER) is
    SELECT expired_value
    FROM pay_assignment_latest_balances
    WHERE expired_assignment_action_id = c_assignment_action_id
    AND assignment_id = c_assignment_id
    AND defined_balance_id = c_defined_balance_id;
--
BEGIN
--
   open expired_val(p_defined_balance_id,
                    p_assignment_action_id,
                    p_assignment_id);
   fetch expired_val into l_value;
   close expired_val;
   --
--
RETURN l_value;
--
END check_expired_action;
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
--                      GET LATEST DATE (private)
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
--                      GET_EXPIRED_YEAR_DATE (private)
--
-------------------------------------------------------------------------------
--
-- Find out the expiry of the Tax year of the assignment action's effective date,
-- for expiry checking in the main functions.
--
FUNCTION get_expired_year_date(
             p_assignment_action_id NUMBER)
RETURN DATE IS
--
   l_expired_date       DATE;
   l_tax_year       NUMBER;
   l_year_add_no        NUMBER;
   l_payroll_id     NUMBER;
--
-- Get the tax year end date
--
   cursor tax_year (c_assignment_action_id IN NUMBER) is
    SELECT ptp.prd_information1, ppa.payroll_id
    FROM per_time_periods ptp,
         pay_payroll_actions ppa,
         pay_assignment_actions paa
    WHERE
         paa.assignment_action_id = c_assignment_action_id
    AND  paa.payroll_action_id = ppa.payroll_action_id
    AND  ppa.time_period_id = ptp.time_period_id;
--
   cursor tax_year_end (c_tax_year IN NUMBER, c_payroll_id IN NUMBER) is
    SELECT max(ptp.end_date)
    FROM per_time_periods ptp
    WHERE
         ptp.prd_information1 = c_tax_year
    AND  ptp.payroll_id = c_payroll_id;
--
BEGIN
--
   open tax_year(p_assignment_action_id);
   FETCH tax_year INTO l_tax_year, l_payroll_id;
   close tax_year;
--
   open tax_year_end(l_tax_year, l_payroll_id);
   FETCH tax_year_end INTO l_expired_date;
   close tax_year_end;
--
   RETURN l_expired_date;
--
END get_expired_year_date;
--
-------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- what is the latest reset date for a particular dimension
FUNCTION dimension_reset_date(
        p_dimension_name        VARCHAR2,
        p_user_date             DATE,
        p_business_group_id     NUMBER)
RETURN DATE
IS
        l_start_dd_mon          VARCHAR2(7);
        l_global_name           VARCHAR2(30);
        l_period_from_date      DATE;
        l_frequency             NUMBER;
        l_start_reset           NUMBER;
BEGIN
        IF SUBSTR(p_dimension_name,31,8) = 'USER-REG' THEN -- [
                l_start_reset := INSTR(p_dimension_name,'RESET',30);
                l_start_dd_mon := SUBSTR(p_dimension_name, l_start_reset - 6, 6);
                l_frequency := TO_NUMBER(SUBSTR(p_dimension_name, l_start_reset + 6, 2));
                l_period_from_date := span_start(p_user_date, l_frequency, l_start_dd_mon);
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
                AND     business_group_id = p_business_group_id
                AND     p_user_date BETWEEN effective_start_date AND effective_end_date;
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
                  ,to_date('31-12-4712','dd-mm-yyyy'))
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
--
--                          BALANCE                                   --
--  FASTFORMULA cover for evaluating balances based on assignment_action_id
--
--
--------------------------------------------------------------------------------
--
FUNCTION balance(
        p_assignment_action_id  IN NUMBER,
        p_defined_balance_id    IN NUMBER)
RETURN NUMBER
IS
--
        l_balance               NUMBER;
        l_assignment_id         NUMBER;
        l_balance_type_id       NUMBER;
        l_period_from_date      DATE := TO_DATE('01-01-0001','dd-mm-yyyy');
        l_event_from_date       DATE := TO_DATE('01-01-0001','dd-mm-yyyy') ;
        l_to_date               DATE;
        l_regular_payment_date  DATE;
        l_action_sequence       NUMBER;
        l_business_group_id     NUMBER;
        l_dimension_name        pay_balance_dimensions.dimension_name%TYPE;
        l_database_item_suffix  pay_balance_dimensions.database_item_suffix%TYPE;
        l_legislation_code      pay_balance_dimensions.legislation_code%TYPE;
        l_latest_value_exists   VARCHAR(2);
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
                DIM.legislation_code
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
         l_legislation_code;
   close balance_dimension;
--
-- Does the assignment action id exist in the latest balances table
--
   OPEN c1 (p_assignment_action_id, p_defined_balance_id);
   FETCH c1 INTO l_balance, l_assignment_id;
      IF c1%FOUND THEN l_latest_value_exists := 'T';
      ELSE l_latest_value_exists := 'F';
      END IF;
   CLOSE c1;
--
-- If the latest bal value doesn't exist further action is necessary
--
   IF l_latest_value_exists = 'F' then
--
--   for seeded person level dimensions call the person_bal function
--
     IF substr(l_database_item_suffix,1,4) = '_PER' and l_legislation_code = 'GB'
     THEN
/*-------------------------------------
        l_balance := calc_person_bal(
                                l_assignment_id,
                                p_assignment_action_id,
                                l_balance_type_id,
                                l_database_item_suffix,
                                l_to_date,
                                l_action_sequence);
-------------------------------------*/
        null;
     ELSE
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
--      evaluate user dimensions COMPANY, PENSION ..
--
        IF SUBSTR(l_dimension_name,31,4) = 'USER' THEN
           l_period_from_date := dimension_reset_date(
                                                l_dimension_name,
                                                l_regular_payment_date,
                                                l_business_group_id);
        END IF;
--
        l_balance := calc_balance(
                l_assignment_id,
                l_balance_type_id,
                l_period_from_date,
                l_event_from_date,
                l_to_date,
                l_action_sequence);
      END IF;
-- ELSE the balance remains the same from the latest balances table
   END IF;
--
   RETURN l_balance;
--
END balance;
--
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
    l_dimension_name            VARCHAR2(80);
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
      If l_dimension_name like '%_ASG_TAX_PTD' then
         l_balance := calc_asg_tax_ptd_action(p_assignment_action_id,
                                          l_balance_type_id);
      Elsif l_dimension_name  like '%_ASG_TAX_YTD' then
         l_balance := calc_asg_tax_ytd_action(p_assignment_action_id,
                                               l_balance_type_id);
      Elsif l_dimension_name like '%_ASG_TAX_MTD' then
         l_balance := calc_asg_tax_mtd_action(p_assignment_action_id,
                                               l_balance_type_id);
      Elsif l_dimension_name like  '%_ASG_TAX_QTD' then
         l_balance := calc_asg_tax_qtd_action(p_assignment_action_id,
                                               l_balance_type_id);
      Elsif l_dimension_name like '%_PAYMENTS' then
         l_balance := calc_payments_action(p_assignment_action_id,
                                               l_balance_type_id);
      Elsif l_dimension_name like '%_ASG_RUN' then
         l_balance := calc_asg_run_action(p_assignment_action_id,
                                               l_balance_type_id);
      Elsif l_dimension_name like '%_ASG_ITD' then
         l_balance := calc_asg_itd_action(p_assignment_action_id,
                                               l_balance_type_id);
      Elsif l_dimension_name like '%_ASG_CAL_PTD' then
         l_balance := calc_asg_cal_ptd_action(p_assignment_action_id,
                                          l_balance_type_id);
      Elsif l_dimension_name  like '%_ASG_CAL_YTD' then
         l_balance := calc_asg_cal_ytd_action(p_assignment_action_id,
                                               l_balance_type_id);
      Elsif l_dimension_name like '%_ASG_CAL_MTD' then
         l_balance := calc_asg_cal_mtd_action(p_assignment_action_id,
                                               l_balance_type_id);
      --Else the balance must be for a USER-REG or person level dimension
      Else
/*----------------------------------------------------------------------------
--         l_balance := balance(p_assignment_action_id, p_defined_balance_id);
----------------------------------------------------------------------------*/
         null;
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
--    This is the overloaded generic function for calculating all balances
--    in Date Mode. NB Element level balances cannot be obtained from here as
--    they require further context.
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
    l_balance_type_id           NUMBER;
    l_dimension_name            VARCHAR2(80);
    l_assignment_action_id      NUMBER;
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
      If l_dimension_name like '%_ASG_TAX_PTD' then
         l_balance := calc_asg_tax_ptd_date(p_assignment_id,
                                            l_balance_type_id,
                                            p_effective_date);
      Elsif l_dimension_name like '%_ASG_TAX_YTD' then
         l_balance := calc_asg_tax_ytd_date(p_assignment_id,
                                            l_balance_type_id,
                                            p_effective_date);
      Elsif l_dimension_name like '%_ASG_TAX_MTD' then
         l_balance := calc_asg_tax_mtd_date(p_assignment_id,
                                            l_balance_type_id,
                                            p_effective_date);
      Elsif l_dimension_name like '%_ASG_TAX_QTD' then
         l_balance := calc_asg_tax_qtd_date(p_assignment_id,
                                            l_balance_type_id,
                                            p_effective_date);
      Elsif l_dimension_name like '%_PAYMENTS' then
         l_balance := calc_payments_date(p_assignment_id,
                                            l_balance_type_id,
                                            p_effective_date);
      Elsif l_dimension_name like '%_ASG_RUN' then
         l_balance := calc_asg_run_date(p_assignment_id,
                                            l_balance_type_id,
                                            p_effective_date);
      Elsif l_dimension_name like '%_ASG_ITD' then
         l_balance := calc_asg_itd_date(p_assignment_id,
                                            l_balance_type_id,
                                            p_effective_date);
      Elsif l_dimension_name like '%_ASG_CAL_PTD' then
         l_balance := calc_asg_cal_ptd_date(p_assignment_id,
                                            l_balance_type_id,
                                            p_effective_date);
      Elsif l_dimension_name like '%_ASG_CAL_YTD' then
         l_balance := calc_asg_cal_ytd_date(p_assignment_id,
                                            l_balance_type_id,
                                            p_effective_date);
      Elsif l_dimension_name like '%_ASG_CAL_MTD' then
         l_balance := calc_asg_cal_mtd_date(p_assignment_id,
                                            l_balance_type_id,
                                            p_effective_date);
      Else
         --This will trap USER-REG and PERSON level balances
/*--------------------------------------------------------------------------
--         l_assignment_action_id := get_latest_action_id(p_assignment_id,
--                                                        p_effective_date);
--         l_balance := balance(l_assignment_action_id,
--                              p_defined_balance_id);
--------------------------------------------------------------------------*/
          null;
      End If;
--
   RETURN l_balance;
--
END calc_all_balances;
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
       l_balance := calc_asg_run(
                                 p_assignment_action_id => p_assignment_action_id,
                                 p_balance_type_id      => p_balance_type_id,
                                 p_effective_date       => p_effective_date,
                                                                 p_assignment_id                => l_assignment_id);
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
--                            DATE MODE
--
-----------------------------------------------------------------------------
--
FUNCTION calc_asg_run_date(
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
   cursor expired_time_period (c_assignment_action_id IN NUMBER) is
    SELECT ptp.end_date
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
       FETCH expired_time_period INTO l_end_date;
       close expired_time_period;
--
       if l_end_date < p_effective_date then
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
--
--      calculate balances for Assignment Run
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
                p_assignment_id                 IN NUMBER
                     )
RETURN NUMBER
IS
--
--
    l_balance           NUMBER;
        l_defined_bal_id        NUMBER;
--
BEGIN
--
--Do we need to work out a value for this dimension/balance combination.
--
 l_defined_bal_id := dimension_relevant(p_balance_type_id, '_ASG_RUN');
 if l_defined_bal_id is not null then
--
-- Run balances will never have a value in pay_assignment_latest_balances
-- table, as they are only used for the duration of the payroll run.
-- We therefore don't need to check the table, time can be saved by
-- simply calling the route code, which is incidentally the most
-- performant (ie simple) route.
--
   l_balance := py_za_routes.asg_run(p_assignment_action_id,
                                                                  p_balance_type_id);
--
 else l_balance := null;
 end if;
--
RETURN l_balance;
--
END calc_asg_run;
--
-----------------------------------------------------------------------------
---
--
--                          CALC_PAYMENTS_ACTION                              -
--
--         This is the function for calculating payments
--                in assignment action mode
--
-----------------------------------------------------------------------------
--
FUNCTION calc_payments_action(
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
       l_balance := calc_payments(
                                 p_assignment_action_id => p_assignment_action_id,
                                 p_balance_type_id      => p_balance_type_id,
                                 p_effective_date       => p_effective_date,
                                                                 p_assignment_id                => l_assignment_id);
    END IF;
--
   RETURN l_balance;
end calc_payments_action;
--
-----------------------------------------------------------------------------
---
--
--                          CALC_PAYMENTS_DATE                              -
--
--    This is the function for calculating payments in
--                            DATE MODE
--
-----------------------------------------------------------------------------
--
FUNCTION calc_payments_date(
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
   cursor expired_time_period (c_assignment_action_id IN NUMBER) is
    SELECT ptp.end_date
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
       FETCH expired_time_period INTO l_end_date;
       close expired_time_period;
--
       if l_end_date < p_effective_date then
          l_balance := 0;
       else
          l_balance := calc_payments(
                             p_assignment_action_id => l_assignment_action_id,
                             p_balance_type_id      => p_balance_type_id,
                             p_effective_date       => p_effective_date,
                             p_assignment_id        => p_assignment_id);
          end if;
    END IF;
--
   RETURN l_balance;
end calc_payments_date;
--
-----------------------------------------------------------------------------
---
--
--                          CALC_PAYMENTS                              -
--
--      calculate balances for payments
--
-----------------------------------------------------------------------------
--
-- this dimension is used in the pre-payments process - that process
-- creates interlocks for the actions that are included and the payments
-- dimension uses those interlocks to decide which run results to sum
--
--
FUNCTION calc_payments(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
                p_assignment_id                 IN NUMBER
                     )
RETURN NUMBER
IS
--
--
        l_expired_balance          NUMBER;
    l_balance              NUMBER;
    l_latest_value_exists  VARCHAR2(2);
    l_assignment_action_id NUMBER;
        l_action_eff_date          DATE;
        l_end_date                         DATE;
        l_defined_bal_id           NUMBER;
--
    cursor expired_time_period (c_assignment_action_id IN NUMBER) is
    SELECT ptp.end_date
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
--Do we need to work out a value for this dimension/balance combination.
--
 l_defined_bal_id := dimension_relevant(p_balance_type_id, '_PAYMENTS');
 if l_defined_bal_id is not null then
--
-- Is there a value in the latest balances table ..
--
   l_balance := get_latest_balance(p_assignment_action_id,
                                                                   l_defined_bal_id);
--
   if l_balance is null then l_latest_value_exists := 'F';
   else l_latest_value_exists := 'T';
   end if;
--
   if l_latest_value_exists = 'F' then
--
      --c1. See if there is a balance value for the assignment/defined balance
      get_owning_balance(p_assignment_id        =>      p_assignment_id,
                         p_defined_balance_id   =>      l_defined_bal_id,
                         p_assignment_action_id =>      l_assignment_action_id,
                         p_value                =>      l_balance);
--
      if l_balance is null then l_latest_value_exists := 'F';
      else
      --check just-retrieved action has a lower action sequence than
      --original assignment action
         if sequence(p_assignment_action_id) >
                        sequence(l_assignment_action_id) then
            -- Action from past, so usable.
            l_latest_value_exists := 'T';
            --we have to validate
            l_action_eff_date := get_latest_date(p_assignment_action_id);
            open expired_time_period(l_assignment_action_id);
            FETCH expired_time_period INTO l_end_date;
            close expired_time_period;
--
            if l_end_date < l_action_eff_date then
               l_balance := 0;
--          else the balance remains the same from c1.
            end if;
         else
         -- The action is from the future.
         -- Is the action the 'expired action' held on the table
            l_expired_balance := check_expired_action(l_defined_bal_id,
                                                      p_assignment_id,
                                                      p_assignment_action_id);
            if l_expired_balance is not null then
               --we have matched the expired action with the current action,
               --therefore we can assign the expired value as the current value.
               l_balance := l_expired_balance;
               l_latest_value_exists := 'T';
            end if;
         end if;
      end if;
--
   end if;
--
-- If the balance is STILL not found,
--
  if l_latest_value_exists = 'F' then
--
   l_balance := py_za_routes.payments(p_assignment_action_id,
                                                                  p_balance_type_id);
  end if;
--
 else l_balance := null;
 end if;
--
RETURN l_balance;
--
END calc_payments;
--
-----------------------------------------------------------------------------
---
--
--                          CALC_ASG_ITD_ACTION                              -
--
--         This is the function for calculating assignment
--         Inception to date in assignment action mode
--
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
       l_balance := calc_asg_itd(p_assignment_id            => l_assignment_id,
                                 p_assignment_action_id => p_assignment_action_id,
                                 p_balance_type_id      => p_balance_type_id,
                                 p_effective_date       => p_effective_date);
    END IF;
--
   RETURN l_balance;
end calc_asg_itd_action;
--
-----------------------------------------------------------------------------
---
--
--                          CALC_ASG_ITD_DATE                              -
--
--    This is the function for calculating assignment inception to
--                      date in DATE MODE
--
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
                                                 p_assignment_id            => p_assignment_id,
                             p_assignment_action_id => l_assignment_action_id,
                             p_balance_type_id      => p_balance_type_id,
                             p_effective_date       => p_effective_date);
    END IF;
--
   RETURN l_balance;
end calc_asg_itd_date;
--
-----------------------------------------------------------------------------
---
--
--                          CALC_ASG_ITD                              -
--
--      calculate balances for Assignment Inception to Date
--
-----------------------------------------------------------------------------
--
-- Sum of all run items since inception.
--
FUNCTION calc_asg_itd(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL, -- in for consistency
        p_assignment_id             IN NUMBER
                      )
RETURN NUMBER
IS
--
--
    l_balance               NUMBER;
    l_latest_value_exists   VARCHAR2(2);
        l_assignment_action_id  NUMBER;
        l_action_eff_date               DATE;
        l_defined_bal_id                NUMBER;
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
   l_balance := get_latest_balance(p_assignment_action_id,
                                                                   l_defined_bal_id);
--
   if l_balance is null then l_latest_value_exists := 'F';
   else l_latest_value_exists := 'T';
   end if;
--
   if l_latest_value_exists = 'F' then
--
 --See if there is a balance value for the assignment/defined balance
      get_owning_balance(p_assignment_id        =>      p_assignment_id,
                         p_defined_balance_id   =>      l_defined_bal_id,
                         p_assignment_action_id =>      l_assignment_action_id,
                         p_value                =>      l_balance);
--
      if l_balance is null then l_latest_value_exists := 'F';
      else
      --check just-retrieved action has a lower action sequence than
      --original assignment action
         if sequence(p_assignment_action_id) >
                                                                sequence(l_assignment_action_id) then
            -- Action from past, so usable.
            -- No Expiry check for Inception To Date balance.
            l_latest_value_exists := 'T';
       --else balance is from future, can't use.
         else l_balance := null;
         end if;
      end if;
   end if;
--
-- still No balance, so use route code
--
  if l_latest_value_exists = 'F' then
--
   l_balance := py_za_routes.asg_itd(p_assignment_action_id,
                                                                         p_balance_type_id);
  end if;
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
---
--
--                          CALC_ASG_TAX_PTD_ACTION
--
--         This is the function for calculating assignment
--          tax period to date in assignment action mode
--
-----------------------------------------------------------------------------
--
FUNCTION calc_ASG_TAX_PTD_action(
         p_assignment_action_id IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER
IS
--
    l_assignment_action_id      NUMBER;
    l_balance                   NUMBER;
    l_assignment_id             NUMBER;
    l_effective_date                    DATE;
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
       l_balance := calc_ASG_TAX_PTD(
                                 p_assignment_action_id => p_assignment_action_id,
                                 p_balance_type_id      => p_balance_type_id,
                                 p_effective_date       => p_effective_date,
                                                 p_assignment_id        => l_assignment_id);
    END IF;
--
   RETURN l_balance;
end calc_ASG_TAX_PTD_action;
--
-----------------------------------------------------------------------------
---
--
--                          CALC_ASG_TAX_PTD_DATE
--
--    This is the function for calculating assignment tax
--    period to date in date mode
--
-----------------------------------------------------------------------------
--
FUNCTION calc_ASG_TAX_PTD_date(
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
-- Has the processing time period expired
--
   cursor expired_time_period (c_assignment_action_id IN NUMBER) is
    SELECT ptp.end_date
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
       FETCH expired_time_period INTO l_end_date;
       close expired_time_period;
--
       if l_end_date < p_effective_date then
          l_balance := 0;
       else
          l_balance := calc_ASG_TAX_PTD(
                             p_assignment_action_id => l_assignment_action_id,
                             p_balance_type_id      => p_balance_type_id,
                             p_effective_date       => p_effective_date,
                             p_assignment_id        => p_assignment_id);
       end if;
    END IF;
--
   RETURN l_balance;
end calc_ASG_TAX_PTD_date;
--
--------------------------------------------------------------------------------
--
--                          CALC_ASG_TAX_PTD
--
--              calculate Assignment tax period to date
--
--------------------------------------------------------------------------------
--
--
-- This dimension is the total for an assignment within the processing
-- period of its current payroll.
--
FUNCTION calc_ASG_TAX_PTD(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
        p_assignment_id                 IN NUMBER
                      )
RETURN NUMBER
IS
--
--
    l_expired_balance       NUMBER;
    l_balance               NUMBER;
    l_latest_value_exists   VARCHAR2(2);
    l_assignment_action_id  NUMBER;
    l_action_eff_date       DATE;
    l_end_date              DATE;
    l_defined_bal_id        NUMBER;
--
   cursor expired_time_period (c_assignment_action_id IN NUMBER) is
    SELECT ptp.end_date
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
--Do we need to work out a value for this dimension/balance combination.
--
 l_defined_bal_id := dimension_relevant(p_balance_type_id, '_ASG_TAX_PTD');
 if l_defined_bal_id is not null then
--
-- Is there a value in the latest balances table ..
--
   l_balance := get_latest_balance(p_assignment_action_id,
                                   l_defined_bal_id);
--
   if l_balance is null then l_latest_value_exists := 'F';
   else l_latest_value_exists := 'T';
   end if;
--
   if l_latest_value_exists = 'F' then
--
      --c1. See if there is a balance value for the assignment/defined balance
      get_owning_balance(p_assignment_id        =>      p_assignment_id,
                         p_defined_balance_id   =>      l_defined_bal_id,
                         p_assignment_action_id =>      l_assignment_action_id,
                         p_value                =>      l_balance);
--
      if l_balance is null then l_latest_value_exists := 'F';
      else
      --check just-retrieved action has a lower action sequence than
      --original assignment action
         if sequence(p_assignment_action_id) >
                        sequence(l_assignment_action_id) then
            -- Action from past, so usable.
--            l_latest_value_exists := 'T';
            l_action_eff_date := get_latest_date(p_assignment_action_id);
            open expired_time_period(l_assignment_action_id);
            FETCH expired_time_period INTO l_end_date;
            close expired_time_period;
--
            if l_end_date < l_action_eff_date then
               l_balance := 0;
            else --the balance remains the same from c1.
            l_latest_value_exists := 'T';
            end if;
         else
         -- The action is from the future.
         -- Is the action the 'expired action' held on the table
            l_expired_balance := check_expired_action(l_defined_bal_id,
                                                      p_assignment_id,
                                                      p_assignment_action_id);
            if l_expired_balance is not null then
               --we have matched the expired action with the current action,
               --therefore we can assign the expired value as the current value.
               l_balance := l_expired_balance;
               l_latest_value_exists := 'T';
            end if;
         end if;
      end if;
--
   end if;
--
-- If the balance is STILL not found,
--
  if l_latest_value_exists = 'F' then
--
   l_balance := py_za_routes.ASG_TAX_PTD(p_assignment_action_id,
                                      p_balance_type_id);
  end if;
--
 else l_balance := null;
 end if;
--
RETURN l_balance;
--
END calc_ASG_TAX_PTD;
--
-----------------------------------------------------------------------------
---
--
--                          CALC_ASG_TAX_MTD_ACTION
--
--         This is the function for calculating assignment
--          tax month to date in assignment action mode
--
-----------------------------------------------------------------------------
--
FUNCTION calc_ASG_TAX_MTD_action(
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
       l_balance := calc_ASG_TAX_MTD(
                                 p_assignment_action_id => p_assignment_action_id,
                                 p_balance_type_id      => p_balance_type_id,
                                 p_effective_date       => p_effective_date,
                                                 p_assignment_id        => l_assignment_id);
    END IF;
--
   RETURN l_balance;
end calc_ASG_TAX_MTD_action;
--
-----------------------------------------------------------------------------
---
--
--                          CALC_ASG_TAX_MTD_DATE
--
--    This is the function for calculating assignment tax
--    month to date in date mode
--
-----------------------------------------------------------------------------
--
FUNCTION calc_ASG_TAX_MTD_date(
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
-- Has the processing time period expired (Month end date)
--
   cursor expired_time_period (c_assignment_action_id IN NUMBER) is
    SELECT ptp.pay_advice_date
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
       FETCH expired_time_period INTO l_end_date;
       close expired_time_period;
--
       if l_end_date < p_effective_date then
          l_balance := 0;
       else
          l_balance := calc_ASG_TAX_MTD(
                             p_assignment_action_id => l_assignment_action_id,
                             p_balance_type_id      => p_balance_type_id,
                             p_effective_date       => p_effective_date,
                             p_assignment_id        => p_assignment_id);
       end if;
    END IF;
--
   RETURN l_balance;
end calc_ASG_TAX_MTD_date;
--
--------------------------------------------------------------------------------
--
--                          CALC_ASG_TAX_MTD
--
--              calculate Assignment tax month to date
--
--------------------------------------------------------------------------------
--
--
-- This dimension is the tax month total for an assignment within
-- its current payroll.
--
FUNCTION calc_ASG_TAX_MTD(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
        p_assignment_id                 IN NUMBER
                      )
RETURN NUMBER
IS
--
--
        l_expired_balance               NUMBER;
    l_balance                   NUMBER;
    l_latest_value_exists       VARCHAR2(2);
    l_assignment_action_id      NUMBER;
        l_action_eff_date               DATE;
        l_owning_month_end_date         DATE;
        l_defined_bal_id                NUMBER;
        l_original_month_end_date       DATE;
--
-- Has the processing time period expired (Month end date)
--
   cursor owning_month_end_date (c_assignment_action_id IN NUMBER) is
    SELECT ptp.pay_advice_date
    FROM per_time_periods ptp,
         pay_payroll_actions ppa,
         pay_assignment_actions paa
    WHERE
         paa.assignment_action_id = c_assignment_action_id
    AND  paa.payroll_action_id = ppa.payroll_action_id
    AND  ppa.time_period_id = ptp.time_period_id;
--
   cursor original_month_end_date (c_assignment_action_id IN NUMBER) is
    SELECT ptp.pay_advice_date
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
--Do we need to work out a value for this dimension/balance combination.
--
 l_defined_bal_id := dimension_relevant(p_balance_type_id, '_ASG_TAX_MTD');
 if l_defined_bal_id is not null then
--
-- Is there a value in the latest balances table ..
--
   l_balance := get_latest_balance(p_assignment_action_id,
                                   l_defined_bal_id);
--
   if l_balance is null then l_latest_value_exists := 'F';
   else l_latest_value_exists := 'T';
   end if;
--
   if l_latest_value_exists = 'F' then
--
      --c1. See if there is a balance value for the assignment/defined balance
      get_owning_balance(p_assignment_id        =>      p_assignment_id,
                         p_defined_balance_id   =>      l_defined_bal_id,
                         p_assignment_action_id =>      l_assignment_action_id,
                         p_value                =>      l_balance);
--
      if l_balance is null then l_latest_value_exists := 'F';
      else
      --check just-retrieved action has a lower action sequence than
      --original assignment action
         if sequence(p_assignment_action_id) >
                        sequence(l_assignment_action_id) then
            -- Action from past, so usable.
            l_latest_value_exists := 'T';
--
            open original_month_end_date(p_assignment_action_id);
            FETCH original_month_end_date INTO l_original_month_end_date;
            close original_month_end_date;
--
            open owning_month_end_date(l_assignment_action_id);
            FETCH owning_month_end_date INTO l_owning_month_end_date;
            close owning_month_end_date;
--                      has the balance expired?
            if l_owning_month_end_date < l_original_month_end_date then
               l_balance := 0;
--          else the balance remains the same from c1.
            end if;
         else
         -- The action is from the future.
         -- Is the action the 'expired action' held on the table
            l_expired_balance := check_expired_action(l_defined_bal_id,
                                                      p_assignment_id,
                                                      p_assignment_action_id);
            if l_expired_balance is not null then
               --we have matched the expired action with the current action,
               --therefore we can assign the expired value as the current value.
               l_balance := l_expired_balance;
               l_latest_value_exists := 'T';
            end if;
         end if;
      end if;
--
   end if;
--
-- If the balance is STILL not found,
--
  if l_latest_value_exists = 'F' then
--
   l_balance := py_za_routes.ASG_TAX_MTD(p_assignment_action_id,
                                      p_balance_type_id);
  end if;
--
 else l_balance := null;
 end if;
--
RETURN l_balance;
--
END calc_ASG_TAX_MTD;
--
-----------------------------------------------------------------------------
---
--
--                          GET_QUARTERS (private)
--
--    This is  a local procedure to establish the Tax Quarters for the
--    latest assignment action and the effective date. This is used by the
--        CALC_ASG_TAX_QTD_DATE and CALC_ASG_TAX_QTD functions.
--
-----------------------------------------------------------------------------
--
PROCEDURE get_quarters(
                                          p_latest_action_id       IN  NUMBER,
                                          p_latest_action_quarter  OUT NOCOPY NUMBER,
                                          p_eff_date_for_quarter   IN  DATE       DEFAULT NULL,
                                          p_effective_date_quarter OUT NOCOPY NUMBER,
                                          p_orig_action_id                 IN  NUMBER DEFAULT NULL,
                                          p_orig_action_quarter    OUT NOCOPY NUMBER)
IS
--
    l_latest_action_quarter     NUMBER;
    l_payroll_id                NUMBER;
    l_effective_date_quarter    NUMBER;
    l_orig_action_quarter       NUMBER;
--
   cursor latest_action_quarter (c_assignment_action_id IN NUMBER) is
    SELECT ptp.prd_information2, ppa.payroll_id
    FROM per_time_periods ptp,
         pay_payroll_actions ppa,
         pay_assignment_actions paa
    WHERE
         paa.assignment_action_id = c_assignment_action_id
    AND  paa.payroll_action_id = ppa.payroll_action_id
    AND  ppa.time_period_id = ptp.time_period_id;
--
   cursor effective_date_quarter (c_effective_date IN DATE, c_payroll_id IN NUMBER) is
    SELECT ptp.prd_information2
    FROM per_time_periods ptp
    WHERE
         ptp.start_date <= c_effective_date
    AND  ptp.end_date   >= c_effective_date
    AND  ptp.payroll_id = c_payroll_id;
--
   cursor orig_action_quarter (c_assignment_action_id IN NUMBER) is
    SELECT ptp.prd_information2
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
  if p_eff_date_for_quarter is not null then
        open latest_action_quarter(p_latest_action_id);
        FETCH latest_action_quarter INTO l_latest_action_quarter, l_payroll_id;
        close latest_action_quarter;
--
        open effective_date_quarter(p_eff_date_for_quarter, l_payroll_id);
        FETCH effective_date_quarter INTO l_effective_date_quarter;
        close effective_date_quarter;
--
        p_latest_action_quarter          := l_latest_action_quarter;
        p_effective_date_quarter         := l_effective_date_quarter;
  else
        open latest_action_quarter(p_latest_action_id);
        FETCH latest_action_quarter INTO l_latest_action_quarter, l_payroll_id;
        close latest_action_quarter;
--
        open orig_action_quarter(p_orig_action_id);
        FETCH orig_action_quarter INTO l_orig_action_quarter;
        close orig_action_quarter;
--
        p_latest_action_quarter := l_latest_action_quarter;
        p_orig_action_quarter   := l_orig_action_quarter;
  end if;
--
exception
   when others then
   p_latest_action_quarter := null;
   p_orig_action_quarter   := null;
   p_effective_date_quarter := null;
end get_quarters;
-----------------------------------------------------------------------------
--
--
--                          CALC_ASG_TAX_QTD_ACTION
--
--         This is the function for calculating assignment
--          tax Quarter to date in assignment action mode
--
-----------------------------------------------------------------------------
--
FUNCTION calc_ASG_TAX_QTD_action(
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
       l_balance := calc_ASG_TAX_QTD(
                                 p_assignment_action_id => p_assignment_action_id,
                                 p_balance_type_id      => p_balance_type_id,
                                 p_effective_date       => p_effective_date,
                                                 p_assignment_id        => l_assignment_id);
    END IF;
--
   RETURN l_balance;
end calc_ASG_TAX_QTD_action;
--
-----------------------------------------------------------------------------
---
--
--                          CALC_ASG_TAX_QTD_DATE
--
--    This is the function for calculating assignment tax
--    Quarter to date in date mode
--
-----------------------------------------------------------------------------
--
FUNCTION calc_ASG_TAX_QTD_date(
         p_assignment_id        IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER
IS
--
    l_assignment_action_id      NUMBER;
    l_balance                   NUMBER;
    l_latest_action_quarter     NUMBER;
    l_payroll_id                NUMBER;
    l_effective_date_quarter    NUMBER;
        l_orig_action_quarter       NUMBER;
--
BEGIN
--
    l_assignment_action_id := get_latest_action_id(p_assignment_id,
                                                   p_effective_date);
    IF l_assignment_action_id is null THEN
       l_balance := 0;
    ELSE
--
           --Establish in which tax quarters the latest assignment action and the
           --effective date fall
           get_quarters(p_latest_action_id                 => l_assignment_action_id,
                                        p_latest_action_quarter    => l_latest_action_quarter,
                                        p_eff_date_for_quarter     => p_effective_date,
                                        p_effective_date_quarter   => l_effective_date_quarter,
                                        p_orig_action_quarter      => l_orig_action_quarter);
--
       if l_latest_action_quarter <> l_effective_date_quarter then
          l_balance := 0;
       else
          l_balance := calc_ASG_TAX_QTD(
                             p_assignment_action_id => l_assignment_action_id,
                             p_balance_type_id      => p_balance_type_id,
                             p_effective_date       => p_effective_date,
                             p_assignment_id        => p_assignment_id);
       end if;
    END IF;
--
   RETURN l_balance;
end calc_ASG_TAX_QTD_date;
--
--------------------------------------------------------------------------------
--
--                          CALC_ASG_TAX_QTD
--
--              calculate Assignment tax Quarter to date
--
--------------------------------------------------------------------------------
--
--
-- This dimension is the tax Quarter total for an assignment within
-- its current payroll.
--
FUNCTION calc_ASG_TAX_QTD(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
        p_assignment_id                 IN NUMBER
                      )
RETURN NUMBER
IS
--
--
        l_expired_balance       NUMBER;
    l_balance               NUMBER;
    l_latest_value_exists   VARCHAR2(2);
    l_assignment_action_id  NUMBER;
        l_action_eff_date           DATE;
        l_end_date                      DATE;
        l_defined_bal_id            NUMBER;
        l_latest_action_quarter NUMBER;
        l_orig_action_quarter   NUMBER;
        l_effective_date_quarter NUMBER;
--
--
BEGIN
--
--Do we need to work out a value for this dimension/balance combination.
--
 l_defined_bal_id := dimension_relevant(p_balance_type_id, '_ASG_TAX_QTD');
 if l_defined_bal_id is not null then
--
-- Is there a value in the latest balances table ..
--
   l_balance := get_latest_balance(p_assignment_action_id,
                                   l_defined_bal_id);
--
   if l_balance is null then l_latest_value_exists := 'F';
   else l_latest_value_exists := 'T';
   end if;
--
   if l_latest_value_exists = 'F' then
--
      --c1. See if there is a latest balance value for the assignment/defined balance
      get_owning_balance(p_assignment_id        =>      p_assignment_id,
                         p_defined_balance_id   =>      l_defined_bal_id,
                         p_assignment_action_id =>      l_assignment_action_id,
                         p_value                =>      l_balance);
--
      if l_balance is null then l_latest_value_exists := 'F';
      else
      --check just-retrieved action has a lower action sequence than
      --original assignment action
         if sequence(p_assignment_action_id) >
                        sequence(l_assignment_action_id) then
            --Action from past, so usable.
            l_latest_value_exists := 'T';
                        --Establish in which tax quarters the latest- and the original
                        --assignment actions fall
                        get_quarters(
                                        p_latest_action_id                 => l_assignment_action_id,
                                        p_latest_action_quarter    => l_latest_action_quarter,
                                        p_orig_action_id                   => p_assignment_action_id,
                                        p_orig_action_quarter      => l_orig_action_quarter,
                                        p_effective_date_quarter   => l_effective_date_quarter);
--
--                      has the balance expired?
            if l_latest_action_quarter <> l_orig_action_quarter then
                           --expired, can't use balance
               l_balance := 0;
--          else the balance remains the same from c1.
            end if;
         else
         -- The action is from the future.
         -- Is the action the 'expired action' held on the table
            l_expired_balance := check_expired_action(l_defined_bal_id,
                                                      p_assignment_id,
                                                      p_assignment_action_id);
            if l_expired_balance is not null then
               --we have matched the expired action with the current action,
               --therefore we can assign the expired value as the current value.
               l_balance := l_expired_balance;
               l_latest_value_exists := 'T';
            end if;
         end if;
      end if;
--
   end if;
--
-- If the balance is STILL not found,
--
  if l_latest_value_exists = 'F' then
--
   l_balance := py_za_routes.ASG_TAX_QTD(p_assignment_action_id,
                                                                         p_balance_type_id);
  end if;
--
 else l_balance := null;
 end if;
--
RETURN l_balance;
--
END calc_ASG_TAX_QTD;
--
-----------------------------------------------------------------------------
---
--
--                          CALC_ASG_TAX_YTD_ACTION
--
--    This is the function for calculating assignment tax year to
--                      date in asg action mode
--
-----------------------------------------------------------------------------
--
FUNCTION calc_asg_tax_ytd_action(
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
--
    ELSE
--
       l_balance := calc_asg_tax_ytd(
                                 p_assignment_action_id => p_assignment_action_id,
                                 p_balance_type_id      => p_balance_type_id,
                                 p_effective_date       => p_effective_date,
                                                                 p_assignment_id                => l_assignment_id);
    END IF;
--
   RETURN l_balance;
end calc_asg_tax_ytd_action;
--
-----------------------------------------------------------------------------
---
--
--                          CALC_ASG_TAX_YTD_DATE                              -
--
--    This is the function for calculating assignment tax year to
--                      date in date mode
--
-----------------------------------------------------------------------------
--
FUNCTION calc_asg_tax_ytd_date(
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
--
--     Is effective date (sess) later than the expiry of the tax year of the
--     assignment action.
--
       if p_effective_date > get_expired_year_date(l_assignment_action_id) then
         l_balance := 0;
       else
--
       l_balance := calc_asg_tax_ytd(
                                 p_assignment_action_id => l_assignment_action_id,
                                 p_balance_type_id      => p_balance_type_id,
                                 p_effective_date       => p_effective_date,
                                 p_assignment_id        => p_assignment_id);
       end if;
    END IF;
--
   RETURN l_balance;
end calc_asg_tax_ytd_date;
--
--------------------------------------------------------------------------------
--
--                          CALC_ASG_TAX_YTD                                    --
--      calculate balances for Assignment tax year to date
--
--------------------------------------------------------------------------------
--
-- This dimension is the total for an assignment within the tax
-- year of any payrolls he has been on this year
--
FUNCTION calc_asg_tax_ytd(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
                p_assignment_id                 IN NUMBER
                     )
RETURN NUMBER
IS
--
                l_expired_balance               NUMBER;
        l_balance               NUMBER;
        l_session_date          DATE;
        l_assignment_id         NUMBER;
        l_action_eff_date       DATE;
        l_latest_value_exists   VARCHAR2(2);
        l_assignment_action_id  NUMBER;
        l_defined_bal_id                NUMBER;
--
BEGIN
--
--Do we need to work out a value for this dimension/balance combination.
--
 l_defined_bal_id := dimension_relevant(p_balance_type_id, '_ASG_TAX_YTD');
 if l_defined_bal_id is not null then
--
   l_balance := get_latest_balance(p_assignment_action_id,
                                   l_defined_bal_id);
--
   if l_balance is null then l_latest_value_exists := 'F';
   else l_latest_value_exists := 'T';
   end if;
--
   if l_latest_value_exists = 'F' then
--
      --c1. See if there is a balance value for the assignment/defined balance
      get_owning_balance(p_assignment_id        =>      p_assignment_id,
                         p_defined_balance_id   =>      l_defined_bal_id,
                         p_assignment_action_id =>      l_assignment_action_id,
                         p_value                =>      l_balance);
--
      if l_balance is null then l_latest_value_exists := 'F';
      else
      --check just-retrieved action has a lower action sequence than
      --original assignment action
         if sequence(p_assignment_action_id) >
                        sequence(l_assignment_action_id) then
            -- Action from past, so usable.
            l_latest_value_exists := 'T';
            --we have to validate
            if nvl(p_effective_date,get_latest_date(p_assignment_action_id))
                     > get_expired_year_date(l_assignment_action_id) then
               l_balance := 0;
--          else the balance remains the same from c1 fetch.
            end if;
         else
         -- The action is from the future.
         -- Is the action the 'expired action' held on the table
            l_expired_balance := check_expired_action(l_defined_bal_id,
                                                      p_assignment_id,
                                                      p_assignment_action_id);
            if l_expired_balance is not null then
               --we have matched the expired action with the current action,
               --therefore we can assign the expired value as the current value.
               l_balance := l_expired_balance;
               l_latest_value_exists := 'T';
            end if;
         end if;
      end if;
--
   end if;
--
-- If the balance is STILL not found,
--
   if l_latest_value_exists = 'F' then
--
-- Use parameter assignment action id to calculate route code
--
   l_balance := py_za_routes.asg_tax_ytd(p_assignment_action_id,
                                       p_balance_type_id);
--
   end if;
--
 else l_balance := null;
 end if;
--
RETURN l_balance;
--
END calc_asg_tax_ytd;
--
-----------------------------------------------------------------------------
---
--
--                          CALC_ASG_CAL_PTD_ACTION
--
--         This is the function for calculating assignment
--         Calendar period to date in assignment action mode
--
-----------------------------------------------------------------------------
--
FUNCTION calc_ASG_CAL_PTD_action(
         p_assignment_action_id IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER
IS
--
    l_assignment_action_id      NUMBER;
    l_balance                   NUMBER;
    l_assignment_id             NUMBER;
    l_effective_date                    DATE;
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
       l_balance := calc_ASG_CAL_PTD(
                                 p_assignment_action_id => p_assignment_action_id,
                                 p_balance_type_id      => p_balance_type_id,
                                 p_effective_date       => p_effective_date,
                                                 p_assignment_id        => l_assignment_id);
    END IF;
--
   RETURN l_balance;
end calc_ASG_CAL_PTD_action;
--
-----------------------------------------------------------------------------
---
--
--                          CALC_ASG_CAL_PTD_DATE
--
--    This is the function for calculating assignment Calendar
--    period to date in date mode
--
-----------------------------------------------------------------------------
--
FUNCTION calc_ASG_CAL_PTD_date(
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
-- Has the processing time period expired
--
   cursor expired_time_period (c_assignment_action_id IN NUMBER) is
    SELECT ptp.end_date
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
       FETCH expired_time_period INTO l_end_date;
       close expired_time_period;
--
       if l_end_date < p_effective_date then
          l_balance := 0;
       else
          l_balance := calc_ASG_CAL_PTD(
                             p_assignment_action_id => l_assignment_action_id,
                             p_balance_type_id      => p_balance_type_id,
                             p_effective_date       => p_effective_date,
                             p_assignment_id        => p_assignment_id);
       end if;
    END IF;
--
   RETURN l_balance;
end calc_ASG_CAL_PTD_date;
--
--------------------------------------------------------------------------------
--
--                          CALC_ASG_CAL_PTD
--
--              calculate Assignment Calendar period to date
--
--------------------------------------------------------------------------------
--
--
-- This dimension is the total for an assignment within the processing
-- period of its current payroll.
--
FUNCTION calc_ASG_CAL_PTD(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
        p_assignment_id                 IN NUMBER
                      )
RETURN NUMBER
IS
--
--
        l_expired_balance       NUMBER;
    l_balance               NUMBER;
    l_latest_value_exists   VARCHAR2(2);
    l_assignment_action_id  NUMBER;
        l_action_eff_date           DATE;
        l_end_date                      DATE;
        l_defined_bal_id            NUMBER;
--
   cursor expired_time_period (c_assignment_action_id IN NUMBER) is
    SELECT ptp.end_date
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
--Do we need to work out a value for this dimension/balance combination.
--
 l_defined_bal_id := dimension_relevant(p_balance_type_id, '_ASG_CAL_PTD');
 if l_defined_bal_id is not null then
--
-- Is there a value in the latest balances table ..
--
   l_balance := get_latest_balance(p_assignment_action_id,
                                   l_defined_bal_id);
--
   if l_balance is null then l_latest_value_exists := 'F';
   else l_latest_value_exists := 'T';
   end if;
--
   if l_latest_value_exists = 'F' then
--
      --c1. See if there is a balance value for the assignment/defined balance
      get_owning_balance(p_assignment_id        =>      p_assignment_id,
                         p_defined_balance_id   =>      l_defined_bal_id,
                         p_assignment_action_id =>      l_assignment_action_id,
                         p_value                =>      l_balance);
--
      if l_balance is null then l_latest_value_exists := 'F';
      else
      --check just-retrieved action has a lower action sequence than
      --original assignment action
         if sequence(p_assignment_action_id) >
                        sequence(l_assignment_action_id) then
            -- Action from past, so usable.
            l_latest_value_exists := 'T';
            l_action_eff_date := get_latest_date(p_assignment_action_id);
            open expired_time_period(l_assignment_action_id);
            FETCH expired_time_period INTO l_end_date;
            close expired_time_period;
--                      has the balance expired?
            if l_end_date < l_action_eff_date then
               l_balance := 0;
--          else the balance remains the same from c1.
            end if;
         else
         -- The action is from the future.
         -- Is the action the 'expired action' held on the table
            l_expired_balance := check_expired_action(l_defined_bal_id,
                                                      p_assignment_id,
                                                      p_assignment_action_id);
            if l_expired_balance is not null then
               --we have matched the expired action with the current action,
               --therefore we can assign the expired value as the current value.
               l_balance := l_expired_balance;
               l_latest_value_exists := 'T';
            end if;
         end if;
      end if;
--
   end if;
--
-- If the balance is STILL not found,
--
  if l_latest_value_exists = 'F' then
--
   l_balance := py_za_routes.ASG_CAL_PTD(p_assignment_action_id,
                                      p_balance_type_id);
  end if;
--
 else l_balance := null;
 end if;
--
RETURN l_balance;
--
END calc_ASG_CAL_PTD;
--
-----------------------------------------------------------------------------
---
--
--                          CALC_ASG_CAL_MTD_ACTION
--
--         This is the function for calculating assignment
--         Calendar month to date in assignment action mode
--
-----------------------------------------------------------------------------
--
FUNCTION calc_ASG_CAL_MTD_action(
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
       l_balance := calc_ASG_CAL_MTD(
                                 p_assignment_action_id => p_assignment_action_id,
                                 p_balance_type_id      => p_balance_type_id,
                                 p_effective_date       => p_effective_date,
                                                 p_assignment_id        => l_assignment_id);
    END IF;
--
   RETURN l_balance;
end calc_ASG_CAL_MTD_action;
--
-----------------------------------------------------------------------------
---
--
--                          CALC_ASG_CAL_MTD_DATE
--
--    This is the function for calculating assignment Calendar
--    month to date in date mode
--
-----------------------------------------------------------------------------
--
FUNCTION calc_ASG_CAL_MTD_date(
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
-- Has the processing time period expired (Month end date)
--
   cursor expired_time_period (c_assignment_action_id IN NUMBER) is
    SELECT ptp.pay_advice_date
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
       FETCH expired_time_period INTO l_end_date;
       close expired_time_period;
--
       if l_end_date < p_effective_date then
          l_balance := 0;
       else
          l_balance := calc_ASG_CAL_MTD(
                             p_assignment_action_id => l_assignment_action_id,
                             p_balance_type_id      => p_balance_type_id,
                             p_effective_date       => p_effective_date,
                             p_assignment_id        => p_assignment_id);
       end if;
    END IF;
--
   RETURN l_balance;
end calc_ASG_CAL_MTD_date;
--
--------------------------------------------------------------------------------
--
--                          CALC_ASG_CAL_MTD
--
--              calculate Assignment Calendar month to date
--
--------------------------------------------------------------------------------
--
--
-- This dimension is the Calendar month total for an assignment within
-- its current payroll.
--
FUNCTION calc_ASG_CAL_MTD(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
        p_assignment_id                 IN NUMBER
                      )
RETURN NUMBER
IS
--
--
        l_expired_balance               NUMBER;
    l_balance                   NUMBER;
    l_latest_value_exists       VARCHAR2(2);
    l_assignment_action_id      NUMBER;
        l_action_eff_date               DATE;
        l_owning_month_end_date         DATE;
        l_defined_bal_id                NUMBER;
        l_original_month_end_date       DATE;
--
-- Has the processing time period expired (Month end date)
--
   cursor owning_month_end_date (c_assignment_action_id IN NUMBER) is
    SELECT ptp.pay_advice_date
    FROM per_time_periods ptp,
         pay_payroll_actions ppa,
         pay_assignment_actions paa
    WHERE
         paa.assignment_action_id = c_assignment_action_id
    AND  paa.payroll_action_id = ppa.payroll_action_id
    AND  ppa.time_period_id = ptp.time_period_id;
--
   cursor original_month_end_date (c_assignment_action_id IN NUMBER) is
    SELECT ptp.pay_advice_date
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
--Do we need to work out a value for this dimension/balance combination.
--
 l_defined_bal_id := dimension_relevant(p_balance_type_id, '_ASG_CAL_MTD');
 if l_defined_bal_id is not null then
--
-- Is there a value in the latest balances table ..
--
   l_balance := get_latest_balance(p_assignment_action_id,
                                   l_defined_bal_id);
--
   if l_balance is null then l_latest_value_exists := 'F';
   else l_latest_value_exists := 'T';
   end if;
--
   if l_latest_value_exists = 'F' then
--
      --c1. See if there is a balance value for the assignment/defined balance
      get_owning_balance(p_assignment_id        =>      p_assignment_id,
                         p_defined_balance_id   =>      l_defined_bal_id,
                         p_assignment_action_id =>      l_assignment_action_id,
                         p_value                =>      l_balance);
--
      if l_balance is null then l_latest_value_exists := 'F';
      else
      --check just-retrieved action has a lower action sequence than
      --original assignment action
         if sequence(p_assignment_action_id) >
                        sequence(l_assignment_action_id) then
            -- Action from past, so usable.
            l_latest_value_exists := 'T';
--
            open original_month_end_date(p_assignment_action_id);
            FETCH original_month_end_date INTO l_original_month_end_date;
            close original_month_end_date;
--
            open owning_month_end_date(l_assignment_action_id);
            FETCH owning_month_end_date INTO l_owning_month_end_date;
            close owning_month_end_date;
--                      has the balance expired?
            if l_owning_month_end_date < l_original_month_end_date then
               l_balance := 0;
--          else the balance remains the same from c1.
            end if;
         else
         -- The action is from the future.
         -- Is the action the 'expired action' held on the table
            l_expired_balance := check_expired_action(l_defined_bal_id,
                                                      p_assignment_id,
                                                      p_assignment_action_id);
            if l_expired_balance is not null then
               --we have matched the expired action with the current action,
               --therefore we can assign the expired value as the current value.
               l_balance := l_expired_balance;
               l_latest_value_exists := 'T';
            end if;
         end if;
      end if;
--
   end if;
--
-- If the balance is STILL not found,
--
  if l_latest_value_exists = 'F' then
--
   l_balance := py_za_routes.ASG_CAL_MTD(p_assignment_action_id,
                                      p_balance_type_id);
  end if;
--
 else l_balance := null;
 end if;
--
RETURN l_balance;
--
END calc_ASG_CAL_MTD;
--
-----------------------------------------------------------------------------
---
--
--                          CALC_ASG_CAL_YTD_ACTION
--
--    This is the function for calculating assignment Calendar year to
--                      date in asg action mode
--
-----------------------------------------------------------------------------
--
FUNCTION calc_asg_cal_ytd_action(
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
--
    ELSE
--
       l_balance := calc_asg_cal_ytd(
                                 p_assignment_action_id => p_assignment_action_id,
                                 p_balance_type_id      => p_balance_type_id,
                                 p_effective_date       => p_effective_date,
                                                                 p_assignment_id                => l_assignment_id);
    END IF;
--
   RETURN l_balance;
end calc_asg_cal_ytd_action;
--
-----------------------------------------------------------------------------
---
--
--                          CALC_ASG_CAL_YTD_DATE                              -
--
--    This is the function for calculating assignment Calendar year to
--                      date in date mode
--
-----------------------------------------------------------------------------
--
FUNCTION calc_asg_cal_ytd_date(
         p_assignment_id        IN NUMBER,
         p_balance_type_id      IN NUMBER,
         p_effective_date       IN DATE)
RETURN NUMBER
IS
--
    l_assignment_action_id      NUMBER;
    l_balance                   NUMBER;
    l_end_date                  DATE;
        l_calendar_year                         NUMBER;
--
   cursor calendar_year (c_assignment_action_id IN NUMBER) is
    SELECT to_number(ptp.prd_information3)
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
--
--     Is effective date later than the expiry of the Calendar year of the
--     assignment action?
--
           open calendar_year(l_assignment_action_id);
           fetch calendar_year into l_calendar_year;
           close calendar_year;

       if to_number(to_char(p_effective_date, 'YYYY')) <> l_calendar_year then
         l_balance := 0;
       else
--
       l_balance := calc_asg_cal_ytd(
                                 p_assignment_action_id => l_assignment_action_id,
                                 p_balance_type_id      => p_balance_type_id,
                                 p_effective_date       => p_effective_date,
                                 p_assignment_id        => p_assignment_id);
       end if;
    END IF;
--
   RETURN l_balance;
end calc_asg_cal_ytd_date;
--
--------------------------------------------------------------------------------
--
--                          CALC_ASG_CAL_YTD                                    --
--      calculate balances for Assignment Calendar year to date
--
--------------------------------------------------------------------------------
--
-- This dimension is the total for an assignment within the Calendar
-- year of any payrolls he has been on this year
--
FUNCTION calc_asg_cal_ytd(
        p_assignment_action_id  IN NUMBER,
        p_balance_type_id       IN NUMBER,
        p_effective_date        IN DATE DEFAULT NULL,
                p_assignment_id                 IN NUMBER
                     )
RETURN NUMBER
IS
--
                l_expired_balance               NUMBER;
        l_balance               NUMBER;
        l_session_date          DATE;
        l_assignment_id         NUMBER;
        l_action_eff_date       DATE;
        l_latest_value_exists   VARCHAR2(2);
        l_assignment_action_id  NUMBER;
        l_defined_bal_id                NUMBER;
                l_original_cal_year             NUMBER;
                l_owning_cal_year               NUMBER;
--
                cursor original_cal_year (c_assignment_action IN NUMBER) is
                select to_number(ptp.prd_information3)
                from per_time_periods ptp,
                         pay_payroll_actions ppa,
                         pay_assignment_actions paa
                where
                         paa.assignment_action_id = c_assignment_action
                and      ppa.payroll_action_id    = paa.payroll_action_id
                and      ptp.time_period_id               = ppa.time_period_id;
--
                cursor owning_cal_year (c_assignment_action IN NUMBER) is
                select to_number(ptp.prd_information3)
                from per_time_periods ptp,
                         pay_payroll_actions ppa,
                         pay_assignment_actions paa
                where
                         paa.assignment_action_id = c_assignment_action
                and      ppa.payroll_action_id    = paa.payroll_action_id
                and      ptp.time_period_id               = ppa.time_period_id;
--
BEGIN
--
--Do we need to work out a value for this dimension/balance combination.
--
 l_defined_bal_id := dimension_relevant(p_balance_type_id, '_ASG_CAL_YTD');
 if l_defined_bal_id is not null then
--
   l_balance := get_latest_balance(p_assignment_action_id,
                                   l_defined_bal_id);
--
   if l_balance is null then l_latest_value_exists := 'F';
   else l_latest_value_exists := 'T';
   end if;
--
   if l_latest_value_exists = 'F' then
--
      --c1. See if there is a balance value for the assignment/defined balance
      get_owning_balance(p_assignment_id        =>      p_assignment_id,
                         p_defined_balance_id   =>      l_defined_bal_id,
                         p_assignment_action_id =>      l_assignment_action_id,
                         p_value                =>      l_balance);
--
      if l_balance is null then l_latest_value_exists := 'F';
      else
      --check just-retrieved action has a lower action sequence than
      --original assignment action
         if sequence(p_assignment_action_id) >
                        sequence(l_assignment_action_id) then
            -- Action from past, so usable.
            l_latest_value_exists := 'T';
                        --Establish the Calendar year ends for the original and the
                        --owning actions
                        open original_cal_year(p_assignment_action_id);
                        fetch original_cal_year into l_original_cal_year;
                        close original_cal_year;
                        --
                        open owning_cal_year(l_assignment_action_id);
                        fetch owning_cal_year into l_owning_cal_year;
                        close owning_cal_year;
            --we have to validate
            if l_original_cal_year <> l_owning_cal_year then
               l_balance := 0;
--          else the balance remains the same from c1 fetch.
            end if;
         else
         -- The action is from the future.
         -- Is the action the 'expired action' held on the table
            l_expired_balance := check_expired_action(l_defined_bal_id,
                                                      p_assignment_id,
                                                      p_assignment_action_id);
            if l_expired_balance is not null then
               --we have matched the expired action with the current action,
               --therefore we can assign the expired value as the current value.
               l_balance := l_expired_balance;
               l_latest_value_exists := 'T';
            end if;
         end if;
      end if;
--
   end if;
--
-- If the balance is STILL not found,
--
   if l_latest_value_exists = 'F' then
--
-- Use parameter assignment action id to calculate route code
--
   l_balance := py_za_routes.asg_cal_ytd(p_assignment_action_id,
                                       p_balance_type_id);
--
   end if;
--
 else l_balance := null;
 end if;
--
RETURN l_balance;
--
END calc_asg_cal_ytd;
--


--------------------------------------------------------------------------------
--
--                          CALC_BALANCE                                   --
--  General function for accumulating a balance between two dates
--
--------------------------------------------------------------------------------

FUNCTION calc_balance(
        p_assignment_id         IN NUMBER,
        p_balance_type_id       IN NUMBER,      -- balance
        p_period_from_date      IN DATE,                -- since regular pay date of period
        p_event_from_date       IN DATE,                -- since effective date of
        p_to_date               IN DATE,                -- sum up to this date
        p_action_sequence       IN NUMBER)      -- sum up to this sequence
RETURN NUMBER
IS
--
--
        l_balance       NUMBER;
--
BEGIN
--
        SELECT
                NVL(SUM(TARGET.result_value * FEED.scale),0)
        INTO
                l_balance
        FROM
                pay_balance_feeds_f             FEED
                ,pay_run_result_values          TARGET
                ,pay_run_results                RR
                ,pay_payroll_actions            PACT
                ,per_time_periods               PPTP
                ,pay_assignment_actions         ASSACT
        WHERE
                        FEED.balance_type_id = P_BALANCE_TYPE_ID
        AND     FEED.input_value_id = TARGET.input_value_id
        AND     TARGET.run_result_id = RR.run_result_id
        AND     RR.assignment_action_id = ASSACT.assignment_action_id
        AND     ASSACT.payroll_action_id = PACT.payroll_action_id
        AND     PACT.effective_date BETWEEN FEED.effective_start_date AND FEED.effective_end_date
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
                errbuf                  OUT NOCOPY     VARCHAR2,
                retcode                 OUT NOCOPY     NUMBER,
                p_business_group_id     IN      NUMBER,
                p_suffix                IN      VARCHAR2,
                p_level                 IN      VARCHAR2,
                p_start_dd_mm           IN      VARCHAR2,
                p_frequency             IN      NUMBER,
                p_global_name           IN      VARCHAR2 DEFAULT NULL)
IS
BEGIN
        errbuf := NULL;
        retcode := 0;
---------------------------
-- INSERT INTO FF_ROUTES --
---------------------------
        DECLARE
                l_route_text    ff_routes.text%TYPE;
                l_bal_next              number;
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
                                        TARGET.assignment_action_id =
                                AND     TARGET.balance_type_id =
                                AND     TARGET.balance_dimension_id = ' || TO_CHAR(l_bal_next);
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
                l_dim_name      VARCHAR2(256);
                l_dim_type      VARCHAR2(1);
                l_dim_level     VARCHAR2(3);
                l_req_id        NUMBER;

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
--                          EXPIRY CHECKING CODE                                                                                --
--                                                                            --
--------------------------------------------------------------------------------
PROCEDURE check_expiry(
                p_owner_payroll_action_id               IN      NUMBER,
                p_user_payroll_action_id                IN      NUMBER,
                p_owner_assignment_action_id            IN      NUMBER,
                p_user_assignment_action_id             IN      NUMBER,
                p_owner_effective_date                  IN      DATE,
                p_user_effective_date                   IN      DATE,
                p_dimension_name                        IN      VARCHAR2,
                p_expiry_information                    OUT NOCOPY     NUMBER)
IS
                p_user_start_period     DATE;
                p_owner_start_period    DATE;
BEGIN

        -- This is only for USER REGULAR BALANCES
        p_user_start_period  := hr_gbbal.dimension_reset_date(p_dimension_name, p_user_effective_date,null);
        p_owner_start_period := hr_gbbal.dimension_reset_date(p_dimension_name, p_owner_effective_date,null);
        IF p_user_start_period = p_owner_start_period THEN
                p_expiry_information := 0; -- FALSE
--              dbms_output.put_line('  p_expiry_information = FALSE ');
        ELSE
                p_expiry_information := 1; -- TRUE
--              dbms_output.put_line('  p_expiry_information = TRUE ');
        END IF;

END check_expiry;
-------------------------------------------------------------------------------
--
-- Bug 3491357 : ZA BRA Enhancement
-- balance values retrieved from pay_balance_pkg  only

--
-- Has the processing time period expired
--
      FUNCTION expired_time_period (c_assignment_action_id NUMBER)
      RETURN DATE IS
--
       l_end_date                  DATE;
--
      BEGIN
           SELECT ptp.end_date
           INTO   l_end_date
           FROM   per_time_periods ptp,
                  pay_payroll_actions ppa,
                  pay_assignment_actions paa
           WHERE  paa.assignment_action_id = c_assignment_action_id
           AND    paa.payroll_action_id = ppa.payroll_action_id
           AND    ppa.time_period_id = ptp.time_period_id;
--
      RETURN l_end_date;
      END expired_time_period;

--
--To find out if the processing time period has expired (Month end date)
--
      FUNCTION expired_time_period_month (
                       c_assignment_action_id NUMBER)
      RETURN DATE IS
--
      l_end_date                  DATE;
--
      BEGIN
           SELECT ptp.pay_advice_date
           INTO   l_end_date
           FROM   per_time_periods ptp,
                  pay_payroll_actions ppa,
                  pay_assignment_actions paa
           WHERE  paa.assignment_action_id = c_assignment_action_id
           AND    paa.payroll_action_id = ppa.payroll_action_id
           AND    ppa.time_period_id = ptp.time_period_id;
--
      RETURN l_end_date;
      END expired_time_period_month;
--
--To find out if the effective date is later than the expiry of the Calendar year of the
--assignment action
--
      FUNCTION calendar_year (
                    c_assignment_action_id NUMBER)
      RETURN NUMBER IS
--
         l_calendar_year      NUMBER ;
--
      BEGIN
         SELECT  to_number(ptp.prd_information3)
         INTO    l_calendar_year
         FROM    per_time_periods ptp,
                 pay_payroll_actions ppa,
                 pay_assignment_actions paa
         WHERE   paa.assignment_action_id = c_assignment_action_id
         AND     paa.payroll_action_id = ppa.payroll_action_id
         AND     ppa.time_period_id = ptp.time_period_id;
--
      RETURN l_calendar_year;
      END calendar_year;
--
--    This is  a local procedure to establish the Tax Quarters for the
--    latest assignment action and the effective date.
--
      PROCEDURE get_quarters(
                           p_latest_action_id       IN  NUMBER,
                           p_latest_action_quarter  OUT NOCOPY NUMBER,
                           p_eff_date_for_quarter   IN  DATE,
                           p_effective_date_quarter OUT NOCOPY NUMBER)
      IS
--
         l_latest_action_quarter     NUMBER;
         l_payroll_id                NUMBER;
         l_effective_date_quarter    NUMBER;
--
         CURSOR latest_action_quarter (c_assignment_action_id IN NUMBER) is
         SELECT ptp.prd_information2, ppa.payroll_id
         FROM   per_time_periods ptp,
                pay_payroll_actions ppa,
                pay_assignment_actions paa
         WHERE  paa.assignment_action_id = c_assignment_action_id
         AND    paa.payroll_action_id = ppa.payroll_action_id
         AND    ppa.time_period_id = ptp.time_period_id;
--
         CURSOR effective_date_quarter (c_effective_date IN DATE, c_payroll_id IN NUMBER) is
         SELECT  ptp.prd_information2
         FROM    per_time_periods ptp
         WHERE   ptp.start_date <= c_effective_date
         AND     ptp.end_date   >= c_effective_date
         AND     ptp.payroll_id = c_payroll_id;
--
      BEGIN
--
        OPEN latest_action_quarter(p_latest_action_id);
        FETCH latest_action_quarter INTO l_latest_action_quarter, l_payroll_id;
        close latest_action_quarter;
--
        OPEN effective_date_quarter(p_eff_date_for_quarter, l_payroll_id);
        FETCH effective_date_quarter INTO l_effective_date_quarter;
        CLOSE effective_date_quarter;
--
        p_latest_action_quarter          := l_latest_action_quarter;
        p_effective_date_quarter         := l_effective_date_quarter;
--
      EXCEPTION
         WHEN OTHERS THEN
         p_latest_action_quarter := null;
         p_effective_date_quarter := null;
--
      END get_quarters;

--
-- Returns the balance values (Date Mode)
      FUNCTION get_balance_value
                (
                 p_assignment_id       IN  NUMBER,
                 p_balance_type_id     IN  NUMBER,
                 p_dimension           IN  VARCHAR2,
                 p_effective_date      IN  DATE
                 )
      RETURN NUMBER IS
      --Variables
         l_latest_asg_action       NUMBER;
         l_defined_balance_id      NUMBER;
         l_balance_value           NUMBER ;
         l_latest_action_quarter   NUMBER ;
         l_effective_date_quarter  NUMBER ;

         -- This cursor gives the latest assignment action ID given an assignment
         -- and effective date.
         --
         CURSOR csr_get_latest_id (c_assignment_id  IN NUMBER,
                              c_effective_date      IN DATE)
         IS
         SELECT /*+ ORDERED
                USE_NL(PAA PPA)
                INDEX(PAA PAY_ASSIGNMENT_ACTIONS_N51)
                INDEX(PPA PAY_PAYROLL_ACTIONS_PK) */
			TO_NUMBER(SUBSTR(MAX(LPAD(paa.action_sequence,15,'0')||
                      paa.assignment_action_id),16))
         FROM     pay_assignment_actions paa,
                  pay_payroll_actions ppa
         WHERE    paa.assignment_id = c_assignment_id
         AND      ppa.payroll_action_id = paa.payroll_action_id
         AND      ppa.effective_date <= c_effective_date
         AND      ppa.action_type IN ('R', 'Q', 'I', 'V', 'B');
--
         CURSOR csr_defined_balance_id(c_balance_type_id IN NUMBER,
                             c_db_item_suffix  IN VARCHAR2)
         IS
         SELECT  pdb.defined_balance_id
         FROM    pay_defined_balances pdb,
                 pay_balance_dimensions pbd
         WHERE   pdb.balance_dimension_id = pbd.balance_dimension_id
         AND     pbd.database_item_suffix = c_db_item_suffix
         AND     pdb.balance_type_id = c_balance_type_id;
--
         BEGIN
           OPEN csr_get_latest_id(p_assignment_id, p_effective_date);
           FETCH csr_get_latest_id INTO l_latest_asg_action;
           CLOSE csr_get_latest_id;

           OPEN  csr_defined_balance_id(p_balance_type_id, p_dimension);
           FETCH csr_defined_balance_id INTO l_defined_balance_id;
           CLOSE csr_defined_balance_id;

           IF p_dimension = '_ASG_TAX_QTD' THEN
           --Establish in which tax quarters the latest assignment action and the
           --effective date fall
           get_quarters(p_latest_action_id         => l_latest_asg_action,
                        p_latest_action_quarter    => l_latest_action_quarter,
                        p_eff_date_for_quarter     => p_effective_date,
                        p_effective_date_quarter   => l_effective_date_quarter);
           END IF ;

           IF l_defined_balance_id IS NULL THEN
              l_balance_value := NULL ;
           ELSE
              IF (
                  l_latest_asg_action IS NULL
                  OR
                  --If effective date later than the expiry of the tax year of the
                  --assignment action. then set the balance value to zero
                  (p_dimension = '_ASG_TAX_YTD'
                    AND p_effective_date > get_expired_year_date(l_latest_asg_action)
                  )
                  OR
                  --IF effective date later than the expiry of the Calendar year of the
                  --assignment action then set balance value to zero
                  (p_dimension = '_ASG_CAL_YTD'
                    AND to_number(to_char(p_effective_date, 'YYYY')) <> calendar_year(l_latest_asg_action)
                  )
                  OR
                  -- Has the processing time period expired (Month end date)
                  ( (p_dimension = '_ASG_CAL_MTD' OR p_dimension = '_ASG_TAX_MTD')
                    AND expired_time_period_month(l_latest_asg_action) < p_effective_date
                  )
                  OR
                  -- Has the processing time period expired
                  (  (p_dimension   = '_ASG_TAX_PTD'
                      OR p_dimension = '_ASG_CAL_PTD'
                      OR p_dimension = '_PAYMENTS'
                      OR p_dimension = '_ASG_RUN'
                      )
                    AND expired_time_period(l_latest_asg_action) < p_effective_date
                  )
                  OR
                  --Check if the tax quarters for the latest assignment action and the
                  --effective date are the same
                 (p_dimension = '_ASG_TAX_QTD'
                    AND l_latest_action_quarter <> l_effective_date_quarter
                  )
                )
                THEN
                 l_balance_value := 0;
              ELSE
                 l_balance_value := pay_balance_pkg.get_value
                      (
                       p_defined_balance_id   => l_defined_balance_id,
                       p_assignment_action_id => l_latest_asg_action
                      );
              END IF;
           END IF;
--
      RETURN l_balance_value;
      hr_utility.set_location('py_za_bal.get_balance_value',10);
      hr_utility.set_location('l_defined_balance_id'||to_char(l_defined_balance_id),10);
      hr_utility.set_location('l_balance_value'||to_char(l_balance_value),10);

      EXCEPTION
          WHEN OTHERS THEN
           hr_utility.set_location('py_za_bal.get_balance_value',20);
           hr_utility.set_message(801,'Sql Err Code: '||to_char(sqlcode));
           hr_utility.raise_error;

      END get_balance_value;

-- Bug 4365925
-- Returns the balance values (Date Mode)
      FUNCTION get_balance_value
                (
                 p_defined_balance_id  IN NUMBER,
                 p_assignment_id       IN  NUMBER,
                 p_effective_date      IN  DATE
                 )
      RETURN NUMBER IS
      --Variables
         l_latest_asg_action       NUMBER;
         l_balance_value           NUMBER ;

         -- This cursor gives the latest assignment action ID given an assignment
         -- and effective date.
         --
         CURSOR csr_get_latest_id (c_assignment_id  IN NUMBER,
                              c_effective_date      IN DATE)
         IS
         SELECT /*+ ORDERED
                USE_NL(PAA PPA)
                INDEX(PAA PAY_ASSIGNMENT_ACTIONS_N51)
                INDEX(PPA PAY_PAYROLL_ACTIONS_PK) */
			TO_NUMBER(SUBSTR(MAX(LPAD(paa.action_sequence,15,'0')||
                      paa.assignment_action_id),16))
         FROM     pay_assignment_actions paa,
                  pay_payroll_actions ppa
         WHERE    paa.assignment_id = c_assignment_id
         AND      ppa.payroll_action_id = paa.payroll_action_id
         AND      ppa.effective_date <= c_effective_date
         AND      ppa.action_type IN ('R', 'Q', 'I', 'V', 'B');

         BEGIN
           OPEN csr_get_latest_id(p_assignment_id, p_effective_date);
           FETCH csr_get_latest_id INTO l_latest_asg_action;
           CLOSE csr_get_latest_id;

           IF p_defined_balance_id IS NULL THEN
              l_balance_value := NULL ;
           ELSE
              IF l_latest_asg_action IS NULL THEN
                 l_balance_value := 0;
              ELSE
                 l_balance_value := pay_balance_pkg.get_value
                      (
                       p_defined_balance_id   => p_defined_balance_id,
                       p_assignment_action_id => l_latest_asg_action
                      );
              END IF;
           END IF;
--
      RETURN l_balance_value;
      hr_utility.set_location('py_za_bal.get_balance_value',50);
      hr_utility.set_location('l_balance_value'||to_char(l_balance_value),50);

      EXCEPTION
          WHEN OTHERS THEN
           hr_utility.set_location('py_za_bal.get_balance_value',60);
           hr_utility.set_message(801,'Sql Err Code: '||to_char(sqlcode));
           hr_utility.raise_error;

      END get_balance_value;
--Bug 4365925 changes end
--
-- Returns the balance values ( assignment action mode )
--
      FUNCTION get_balance_value_action
                 ( p_assignment_action_id  IN  NUMBER
                 , p_balance_type_id       IN  NUMBER
                 , p_dimension             IN  VARCHAR2
                 )
      RETURN NUMBER IS
         --Variables
         l_balance_value             NUMBER;
         l_assignment_id             NUMBER;
         l_defined_balance_id        NUMBER;

         CURSOR csr_defined_balance_id(c_balance_type_id IN NUMBER,
                                    c_db_item_suffix  IN VARCHAR2)
         IS
         SELECT  pdb.defined_balance_id
         FROM    pay_defined_balances pdb,
                 pay_balance_dimensions pbd
         WHERE   pdb.balance_dimension_id = pbd.balance_dimension_id
         AND     pbd.database_item_suffix = c_db_item_suffix
         AND     pdb.balance_type_id = c_balance_type_id;

      BEGIN
         l_assignment_id := get_correct_type(p_assignment_action_id);

         OPEN csr_defined_balance_id(p_balance_type_id, p_dimension);
         FETCH csr_defined_balance_id INTO l_defined_balance_id;
         CLOSE csr_defined_balance_id;

         IF (l_assignment_id IS NULL OR l_defined_balance_id IS NULL )THEN
--
--  The assignment action is not a payroll or quickpay type, so return null
--
           l_balance_value := NULL ;
         ELSE
           l_balance_value := pay_balance_pkg.get_value
                   (
                    p_defined_balance_id   => l_defined_balance_id,
                    p_assignment_action_id => p_assignment_action_id
                   );
         END IF ;
      RETURN l_balance_value;
      hr_utility.set_location('py_za_bal.get_balance_value_action',30);
      hr_utility.set_location('l_defined_balance_id'||to_char(l_defined_balance_id),30);
      hr_utility.set_location('l_balance_value'||to_char(l_balance_value),30);
--
      EXCEPTION
           WHEN OTHERS THEN
           hr_utility.set_location('py_za_bal.get_balance_value_action',40);
           hr_utility.set_message(801,'Sql Err Code: '||to_char(sqlcode));
           hr_utility.raise_error;

      END get_balance_value_action;
--
------------------------------------------------------------------

END py_za_bal;

/
