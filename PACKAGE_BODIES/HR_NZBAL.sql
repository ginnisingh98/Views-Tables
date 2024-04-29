--------------------------------------------------------
--  DDL for Package Body HR_NZBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NZBAL" as
/* $Header: pynzbal.pkb 120.2 2005/09/15 23:26:12 snekkala noship $ */
--
-- Change List
-- ----------
-- DATE        Name            Vers     Bug No    Description
-- -----------+---------------+--------+--------+-----------------------+
-- 16-Sep-2005 snekkala        115.15   4259348  Modified cursor name to
--                                               get_assgt_action_id_4
--                                               after opening the cursor
-- 01-Aug-2005 snekkala        115.14   4259438  Modfied for performance fixes
-- 18-Aug-2004 sshankar        115.13   3181581  Added function balance as it is being used by
--                                               view pay_nz_balances_v, view not created by any
--                                               script.
-- 10-Aug-2004 sshankar        115.12   3181581  Modified following functions to use
--                                               pay_balance_pkg.get_value :
--                                                  CALC_ASG_4WEEK
--                                                  CALC_ASG_FY_QTD
--                                                  CALC_ASG_FY_YTD
--                                                  CALC_ASG_HOL_YTD
--                                                  CALC_ASG_PTD
--                                                  CALC_ASG_RUN
--                                                  CALC_ASG_TD
--                                                  CALC_ALL_BALANCES
--                                                  CALC_ASG_YTD
--                                                  CALC_PAYMENT
--                                               Removed the following functions which are
--                                               not needed any more:
--                                                  GET_LATEST_BALANCE
--                                                  CHECK_EXPIRED_ACTION
--                                                  GET_OWNING_BALANCE
--                                                  BALANCE
--                                                  CALC_BALANCE
--                                                  SEQUENCE
-- 08-Aug-2003 punmehta        115.11   3072939  Replaced > than condition with >= for
-- 		                                 checking expired year date in all the
-- 		                                 relevant functions
-- 11-Jul-2003 vgsriniv        115.10   3043157  Modified function calc_asg_hol_ytd_date
-- 03-Dec-2002 srrajago        115.9    2689221  Included 'nocopy' option for all the 'out'
--                                               parameters of the procedure get_owning_balance.
-- 21-Mar-2002 vgsriniv        115.8    2264070  Modified the cursor  get_pay_period_start_date
--                                               in the function calc_asg_hol_ytd_date
-- 18-Feb-2002 vgsriniv                 2203667  Added cursor get_next_pay_period_start_date
--						 to get next pay period start date
-- 13-Feb-2002 vgsriniv                 2203667  Changed the function calc_asg_
--                                               hol_ytd to get the effective
--                                               date for the current period
-- 19-Nov-2001 vgsriniv                 2097319  In the function calc_asg_hol_ytd_date,added a
--						 cursor get_dates to get date_earned and
--                                               effective_dates.Changed the cursor get_assgt_action_id
--                                               for handling the payrolls with offsets.Included a loop
--                                               to get the annual advance leaves upto Holiday anniversary
--                                               date.
-- 12 Nov 2001 vgsriniv        115.2    2097319  Added a cursor to fetch
--                                               assignment action id in the
--                                               funcion calc_asg_hol_ytd_date
--  20-oct-2000 sgoggin  1472624    Added qualifier to end_date.
-- 13-Aug-1999 sclarke          1.0                 Created
-- 01-Sep-1999 sclarke          1.0                 Fixed get_expiry_date to use the different spans
-- 21-Sep-1999 sclarke                              asg_4week date mode fixed
-- -----------+---------------+--------+--------+-----------------------+
--
g_fin_year_start  constant varchar2(6) := '01-04-';
--
--------------------------------------------------------------------------------
--
--                      get correct type (private)
--
--------------------------------------------------------------------------------
--
-- this is a validation check to ensure that the assignment action is of the
-- correct type. this is called from all assignment action mode functions.
-- the assignment id is returned (and not assignment action id) because
-- this is to be used in the expired latest balance check. this function thus
-- has two uses - to validate the assignment action, and give the corresponding
-- assignmment id for that action.
--
function get_correct_type(p_assignment_action_id in number)
return number is
  --
  l_assignment_id  number;
  --
  cursor get_corr_type  ( c_assignment_action_id in number ) is
    select  assignment_id
    from    pay_assignment_actions          paa
    ,       pay_payroll_actions             ppa
    where   paa.assignment_action_id        = c_assignment_action_id
            and       ppa.payroll_action_id = paa.payroll_action_id
            and       ppa.action_type       in ('R', 'Q', 'I', 'V', 'B');
  --
begin
  --
  open  get_corr_type(p_assignment_action_id);
  fetch get_corr_type into l_assignment_id;
  close get_corr_type;
  --
  return l_assignment_id;
  --
end get_correct_type;
--------------------------------------------------------------------------------
--
--                      get latest action id (private)
--
--------------------------------------------------------------------------------
-- this function returns the latest assignment action id given an assignment
-- and effective date. this is called from all date mode functions.
--
function get_latest_action_id   (   p_assignment_id     in number
                                ,   p_effective_date    in date
                                )
return number is
  --
  l_assignment_action_id   number;
  --
/* Bug 4259438 Modified cursor for performance */
  CURSOR get_latest_id  (   c_assignment_id  IN NUMBER
                        ,   c_effective_date IN DATE
                        )
  IS
    SELECT TO_NUMBER(SUBSTR(MAX(LPAD(paa.action_sequence,15,'0')||paa.assignment_action_id),16))
      FROM pay_assignment_actions        paa
         , pay_payroll_actions           ppa
         , per_assignments_f             paf
         , pay_payrolls_f                ppf
         , per_time_periods              ptp
     WHERE paf.assignment_id             = c_assignment_id
       AND paf.assignment_id             = paa.assignment_id
       AND ppf.payroll_id                = ppa.payroll_id
       AND ppf.payroll_id                = paf.payroll_id
       AND ppa.payroll_id                = ptp.payroll_id
       AND ppf.payroll_id                = ptp.payroll_id
       AND ptp.time_period_id            = ppa.time_period_id
       AND ppa.effective_date            BETWEEN ptp.start_date
                                             AND ptp.end_date
       AND  ppa.effective_date           BETWEEN paf.effective_start_date
                                             AND paf.effective_end_date
       AND ppa.payroll_action_id         = paa.payroll_action_id
       AND ppa.effective_date           <= c_effective_date
       AND c_effective_date              BETWEEN paf.effective_start_date
                                             AND paf.effective_end_date
       AND ppa.action_type               IN ('R','Q','I','V','B');
  --
begin
  --
  open  get_latest_id(p_assignment_id, p_effective_date);
  fetch get_latest_id into l_assignment_action_id;
  close get_latest_id;
  --
  return l_assignment_action_id;
  --
end get_latest_action_id;
--

--------------------------------------------------------------------------------
--
--                       dimension relevant  (private)
--
--------------------------------------------------------------------------------
--
-- this function checks that a value is required for the dimension
-- for this particular balance type. if so, the defined balance is returned.
--
function dimension_relevant (   p_balance_type_id      in number
                            ,   p_database_item_suffix in varchar2
                            )
return number is
  --
  l_defined_balance_id number;
  --
  cursor relevant   (   c_balance_type_id in number
                    ,   c_db_item_suffix  in varchar2
                    ) is
    select  pdb.defined_balance_id
    from    pay_defined_balances          pdb
    ,       pay_balance_dimensions        pbd
    where   pdb.balance_dimension_id      = pbd.balance_dimension_id
            and pbd.database_item_suffix  = c_db_item_suffix
            and pdb.balance_type_id       = c_balance_type_id;
    --
begin
  --
  open relevant (   p_balance_type_id
                ,   p_database_item_suffix
                );
  fetch relevant into l_defined_balance_id;
  close relevant;
  --
  return l_defined_balance_id;
  --
end dimension_relevant;

--------------------------------------------------------------------------------
--
--          get latest date (private)
--
--
--------------------------------------------------------------------------------
--
-- find out the effective date of the latest balance of a particular
-- assignment action.
--
function get_latest_date(p_assignment_action_id  number)
return date is
  --
  l_effective_date date;
  --
  cursor    c_bal_date is
    select  ppa.effective_date
    from    pay_payroll_actions           ppa
    ,       pay_assignment_actions        paa
    where   paa.payroll_action_id         = ppa.payroll_action_id
            and paa.assignment_action_id  = p_assignment_action_id;
  --
begin
  --
  open  c_bal_date;
  fetch c_bal_date into l_effective_date;
  if c_bal_date%notfound then
    l_effective_date := null;
    --       raise_application_error(-20000,'this assignment action is invalid');
  end if;
  close c_bal_date;
  --
  return l_effective_date;
end get_latest_date;
--
-------------------------------------------------------------------------------
--
--          get_expired_year_date (private)
--
-------------------------------------------------------------------------------
--
-- find out the expiry of the year of the assignment action's effective date,
-- for expiry checking in the main functions.
--
function get_expired_year_date( p_action_effective_date date
                              , p_start_dd_mm           varchar2)
return date is
  --
  l_expired_date    date;
  l_year_add_no     number;
  --
begin
  --
  if p_action_effective_date is not null then
    --
    if p_action_effective_date < to_date
                                (p_start_dd_mm || to_char
                                    (p_action_effective_date,'yyyy'),'dd-mm-yyyy'
                                )  then
      --
      l_year_add_no := 0;
    else
      l_year_add_no := 1;
    end if;
    --
    -- set expired date to the 1st of april next.
    --
    l_expired_date :=
      ( to_date
            (p_start_dd_mm || to_char
                (to_number
                    (
                    to_char(p_action_effective_date,'yyyy')
                    )+ l_year_add_no
                ),'dd-mm-yyyy'
            )
        );
    --
  end if;
  --
  return l_expired_date;
  --
end get_expired_year_date;
--
-----------------------------------------------------------------------------
--
--                          calc_all_balances
--    this is the generic overloaded function for calculating all balances
--    in assignment action mode.
-----------------------------------------------------------------------------
--
function calc_all_balances  (   p_assignment_action_id in number
                            ,   p_defined_balance_id   in number
                            )
return number is
  --
  --
begin
  --
  -- Bug 3181581
  -- Modified code to fetch balance by calling pay_balance_pkg.get_value
  --

  return pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID   => p_defined_balance_id
                                  ,P_ASSIGNMENT_ACTION_ID => p_assignment_action_id
                                  ,P_TAX_UNIT_ID          => null
                                  ,P_JURISDICTION_CODE    => null
                                  ,P_SOURCE_ID            => null
                                  ,P_SOURCE_TEXT          => null
                                  ,P_TAX_GROUP            => null
                                  ,P_DATE_EARNED          => null
                                  );
  --
end calc_all_balances;
--
-----------------------------------------------------------------------------
--
--                          calc_all_balances
--
--    this is the overloaded generic function for calculating all balances
--    in date mode.
--
-----------------------------------------------------------------------------
--
function calc_all_balances  (   p_effective_date       in date
                            ,   p_assignment_id        in number
                            ,   p_defined_balance_id   in number
                            )
  --
  return number
  is
  --
  l_assignment_action_id  pay_assignment_actions.assignment_action_id%TYPE;
  --
begin
  --
  -- Bug 3181581
  -- Modified code to fetch balance by calling pay_balance_pkg.get_value
  --

  l_assignment_action_id := get_latest_action_id( p_assignment_id, p_effective_date );
  --
  return pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID   => p_defined_balance_id
                                  ,P_ASSIGNMENT_ACTION_ID => l_assignment_action_id
                                  ,P_TAX_UNIT_ID          => null
                                  ,P_JURISDICTION_CODE    => null
                                  ,P_SOURCE_ID            => null
                                  ,P_SOURCE_TEXT          => null
                                  ,P_TAX_GROUP            => null
                                  ,P_DATE_EARNED          => null
                                  );
  --
end calc_all_balances;
--
--------------------------------------------------------------------------------
--
--                          calc_asg_ytd
--      calculate balances for assignment year to date
--
--------------------------------------------------------------------------------
--
-- assignment year -
--
-- this dimension is the total for an assignment within the processing
-- year of any payrolls he has been on this year. that is in the case
-- of a transfer the span will go back to the start of the processing
-- year he was on at the start of year.
--
-- this dimension should be used for the year dimension of balances
-- which are not reset to zero on transferring payroll.

-- if this has been called from the date mode function, the effective date
-- will be set, otherwise session date is used.
--
function calc_asg_ytd   (   p_assignment_action_id  in number
                        ,   p_balance_type_id       in number
                        ,   p_effective_date        in date default null
                        ,   p_assignment_id         in number
                        )
return number
is
  --
  l_balance                 number;
  l_defined_bal_id          pay_defined_balances.defined_balance_id%TYPE;
  --
begin
  --
  -- Bug 3181581
  -- Modified code to fetch balance by calling pay_balance_pkg.get_value
  --

  l_defined_bal_id := dimension_relevant(p_balance_type_id, '_ASG_YTD');
  --
  if l_defined_bal_id is not null then
    --
    l_balance := pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID   => l_defined_bal_id
                                  ,P_ASSIGNMENT_ACTION_ID => p_assignment_action_id
                                  ,P_TAX_UNIT_ID          => null
                                  ,P_JURISDICTION_CODE    => null
                                  ,P_SOURCE_ID            => null
                                  ,P_SOURCE_TEXT          => null
                                  ,P_TAX_GROUP            => null
                                  ,P_DATE_EARNED          => null
                                  );
    --
  else
    l_balance := null;
  end if;
  --
  return l_balance;
  --
end calc_asg_ytd;
--
-----------------------------------------------------------------------------
--
--
--                          calc_asg_ytd_action
--
--    this is the function for calculating assignment year to
--                      date in asg action mode
--
-----------------------------------------------------------------------------
--
function calc_asg_ytd_action(   p_assignment_action_id in number
                            ,   p_balance_type_id      in number
                            ,   p_effective_date       in date
                            )
return number
is
  --
  l_assignment_action_id  number;
  l_balance               number;
  l_assignment_id         number;
  l_effective_date        date;
  --
begin
  --
  l_assignment_id := get_correct_type(p_assignment_action_id);
  if l_assignment_id is null then
    --
    --  the assignment action is not a payroll or quickpay type, so return null
    --
    l_balance := null;
  else
    --
    l_balance := calc_asg_ytd   (   p_assignment_action_id  => p_assignment_action_id
                                ,   p_balance_type_id       => p_balance_type_id
                                ,   p_effective_date        => p_effective_date
                                ,   p_assignment_id         => l_assignment_id
                                );
  end if;
  --
  return l_balance;
  --
end calc_asg_ytd_action;
--
-----------------------------------------------------------------------------
---
--
--                          calc_asg_ytd_date
--
--    this is the function for calculating assignment year to
--              date in date mode
--
-----------------------------------------------------------------------------
--
function calc_asg_ytd_date  (   p_assignment_id        in number
                            ,   p_balance_type_id      in number
                            ,   p_effective_date       in date
                            )
return number
is
  --
  l_assignment_action_id  number;
  l_balance               number;
  l_end_date              date;
  l_action_eff_date       date;
  l_start_dd_mm           varchar2(9) ;
  --
begin
  --
  l_start_dd_mm := g_fin_year_start;
  l_assignment_action_id := get_latest_action_id( p_assignment_id, p_effective_date );
  if l_assignment_action_id is null then
    l_balance := 0;
  else
    --     start expiry chk now
    l_action_eff_date := get_latest_date(l_assignment_action_id);
    --
    --     is effective date (sess) later than the expiry of the financial year of the
    --     effective date.
    --
    if p_effective_date >= get_expired_year_date(l_action_eff_date, l_start_dd_mm) then  /*3072939*/
      l_balance := 0;
    else
      --
      l_balance := calc_asg_ytd (   p_assignment_action_id => l_assignment_action_id
                                ,   p_balance_type_id      => p_balance_type_id
                                ,   p_effective_date       => p_effective_date
                                ,   p_assignment_id        => p_assignment_id
                                );
    end if;
  end if;
  --
  return l_balance;
  --
end calc_asg_ytd_date;
--
--------------------------------------------------------------------------------
--
--                          calc_asg_hol_ytd
--      calculate balances for assignment anniversary year to date
--
--------------------------------------------------------------------------------
--
--
-- this dimension is the total for an assignment within the processing
-- year of any payrolls they have been on this year. that is in the case
-- of a transfer the span will go back to the start of the processing
-- year he was on at the start of year.
--
-- this dimension should be used for the year dimension of balances
-- which are not reset to zero on transferring payroll.

-- if this has been called from the date mode function, the effective date
-- will be set, otherwise session date is used.
--
function calc_asg_hol_ytd   (   p_assignment_action_id  in number
                            ,   p_balance_type_id       in number
                            ,   p_effective_date        in date default null
                            ,   p_assignment_id         in number
                            )
return number
is
  --
  l_balance                 number;
  l_defined_bal_id          pay_defined_balances.defined_balance_id%TYPE;
  --
begin
  --
  -- Bug 3181581
  -- Modified code to fetch balance by calling pay_balance_pkg.get_value
  --

  l_defined_bal_id := dimension_relevant(p_balance_type_id, '_ASG_HOL_YTD');
  --
  if l_defined_bal_id is not null then
    --
    l_balance := pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID   => l_defined_bal_id
                                  ,P_ASSIGNMENT_ACTION_ID => p_assignment_action_id
                                  ,P_TAX_UNIT_ID          => null
                                  ,P_JURISDICTION_CODE    => null
                                  ,P_SOURCE_ID            => null
                                  ,P_SOURCE_TEXT          => null
                                  ,P_TAX_GROUP            => null
                                  ,P_DATE_EARNED          => null
                                  );
    --
  else
    l_balance := null;
  end if;
  return l_balance;
  --
end calc_asg_hol_ytd;
--
-----------------------------------------------------------------------------
--
--
--                          calc_asg_hol_ytd_action
--
--    this is the function for calculating assignment anniversary year to
--                      date in asg action mode
--
-----------------------------------------------------------------------------
--
function calc_asg_hol_ytd_action(   p_assignment_action_id in number
                                ,   p_balance_type_id      in number
                                ,   p_effective_date       in date
                                )
return number
is
  --
  l_assignment_action_id      number;
  l_balance                   number;
  l_assignment_id             number;
  l_effective_date        date;
  --
begin
  --
  l_assignment_id := get_correct_type(p_assignment_action_id);
  if l_assignment_id is null then
    --
    --  the assignment action is not a payroll or quickpay type, so return null
    --
    l_balance := null;
  else
    --
    l_balance := calc_asg_hol_ytd   (   p_assignment_action_id  => p_assignment_action_id
                                    ,   p_balance_type_id       => p_balance_type_id
                                    ,   p_effective_date        => p_effective_date
                                    ,   p_assignment_id         => l_assignment_id
                                    );
  end if;
  --
  return l_balance;
  --
end calc_asg_hol_ytd_action;
--
-----------------------------------------------------------------------------
---
--
--                          calc_asg_hol_ytd_date
--
--    this is the function for calculating assignment anniversary year to
--              date in date mode
--
-----------------------------------------------------------------------------
--
function calc_asg_hol_ytd_date  (   p_assignment_id        in number
                                ,   p_balance_type_id      in number
                                ,   p_effective_date       in date
                                )
return number
is
  --
  l_assignment_action_id  number;
  l_balance               number;
  l_end_date              date;
  l_action_eff_date       date;
  l_start_dd_mm           varchar2(9);
  l_effective_date        date;
  -- Bug# 2097319    Added the following cursor

/* Bug:3043157 Modified the date track join for pay_payroll_actions */
/* Bug 4259438 Modified cursor for performance */
  CURSOR get_assgt_action_id ( c_assignment_id IN NUMBER
                             , v_ann_start     IN DATE
                             , v_ann_end       IN DATE
                             )
  IS
    SELECT to_number(substr(max(lpad(paa.action_sequence,15,'0')||paa.assignment_action_id),16))
      FROM pay_assignment_actions        paa
         , pay_payroll_actions           ppa
         , per_assignments_f             paf
         , pay_payrolls_f                ppf
         , per_time_periods              ptp
     WHERE paf.assignment_id             = c_assignment_id
       AND paf.assignment_id             = paa.assignment_id
       AND ppf.payroll_id                = ppa.payroll_id
       AND ppf.payroll_id                = paf.payroll_id
       AND ppa.payroll_id                = ptp.payroll_id
       AND ppf.payroll_id                = ptp.payroll_id
       AND ptp.time_period_id            = ppa.time_period_id
       AND ppa.effective_date            BETWEEN ptp.start_date
                                             AND ptp.end_date
       AND  ppa.effective_date           BETWEEN paf.effective_start_date
                                             AND paf.effective_end_date
       AND ppa.payroll_action_id         = paa.payroll_action_id
       AND ( ppa.effective_date         BETWEEN v_ann_start
                                            AND v_ann_end OR
             ppa.date_earned            BETWEEN v_ann_start
	                                    AND v_ann_end)
       AND ppa.action_type              IN ('R','Q','I','V','B');

/* Bug:3043157 Modified the name of the cursor */
/* Bug 4259438 Modified cursor for performance */
  CURSOR get_assgt_action_id_4 ( c_assignment_id IN NUMBER
                             , c_effective_date  IN DATE
                             )
  IS
   SELECT TO_NUMBER(SUBSTR(MAX(LPAD(paa.action_sequence,15,'0')||paa.assignment_action_id),16))
     FROM pay_assignment_actions          paa
        , pay_payroll_actions            ppa
        , per_assignments_f             paf
        , pay_payrolls_f                ppf
        , per_time_periods              ptp
    WHERE paf.assignment_id             = c_assignment_id
      AND paf.assignment_id             = paa.assignment_id
      AND ppf.payroll_id                = ppa.payroll_id
      AND ppf.payroll_id                = paf.payroll_id
      AND ppa.payroll_id                = ptp.payroll_id
      AND ppf.payroll_id                = ptp.payroll_id
      AND ptp.time_period_id            = ppa.time_period_id
      AND ppa.effective_date            BETWEEN ptp.start_date
                                            AND ptp.end_date
      AND  ppa.effective_date           BETWEEN paf.effective_start_date
                                            AND paf.effective_end_date
      AND ppa.payroll_action_id         = paa.payroll_action_id
      AND ( ppa.date_earned            <= c_effective_date
            or ppa.effective_date      <= c_effective_date )
      AND c_effective_date              BETWEEN paf.effective_start_date
                                            AND paf.effective_end_date
      AND ppa.action_type             IN ('R','Q','I','V','B');
  --
  -- Bug# 2097319 Added the cursor to get date_earned and effective_date

   cursor get_dates (c_assignment_action_id in number)
   is
     select ppa.date_earned,ppa.effective_date
     from pay_assignment_actions paa,
          pay_payroll_actions ppa
     where paa.assignment_action_id = c_assignment_action_id
          and ppa.payroll_action_id       = paa.payroll_action_id
          and ppa.action_type             in ('R','Q','I','V','B');

  -- Bug# 2203667 Added the following cursor
  -- Bug# 2264070 Added the join on payroll_action_id
  cursor get_pay_period_start_date(p_assignment_id in number) is
    SELECT TPERIOD.start_date FROM
  pay_payroll_actions                      PACTION
,       per_time_periods                         TPERIOD
,       per_time_period_types                    TPTYPE
where   PACTION.payroll_action_id           = (select max(paa.payroll_action_id)
            from pay_assignment_actions paa,pay_payroll_actions ppa
            where paa.assignment_id=p_assignment_id
            and ppa.action_type in ('R','Q')
            and ppa.payroll_action_id = paa.payroll_action_id )
and     PACTION.payroll_id                     = TPERIOD.payroll_id
and     PACTION.date_earned  between TPERIOD.start_date and TPERIOD.end_date
and     TPTYPE.period_type                     = TPERIOD.period_type;

 cursor get_next_pay_period_start_date(p_assignment_id in number,
                                        p_effective_date in date) is
      select MIN(ptp.start_date)
      from per_time_periods ptp,per_all_assignments_f paa
      where ptp.start_date > p_effective_date
      and   paa.assignment_id = p_assignment_id
      and   paa.payroll_id = ptp.payroll_id;

 /* Bug:3043157 Added the following cursor to get the end date of the
    financial years last pay period */
 cursor get_max_fin_year_end(c_assignment_id in number,
                             c_effective_date in date) is
 select MAX(ptp.end_date)
  from per_time_periods ptp,
       per_all_assignments_f paa
 where ptp.start_date >= add_months(c_effective_date+1,-12)
   and ptp.end_date   <= c_effective_date
   and paa.assignment_id = c_assignment_id
   and paa.payroll_id = ptp.payroll_id;


  l_date_earn date;
  l_eff_date date;
  l_cur_per_start_date date;
  l_count number := 1;
  total_balance number :=0;
  l_next_start_date date;
  v_ann_start  date;
  v_ann_end  date;
  v_fin_year_end date;

-- Bug# 2097319 Added a loop to calculate the advance leaves upto the holiday
--              anniversary date.
begin



  open get_pay_period_start_date(p_assignment_id);
  fetch get_pay_period_start_date into l_cur_per_start_date;
  close get_pay_period_start_date;

  hr_utility.trace('ven_gppst_date= '||to_char(l_cur_per_start_date));
  open get_next_pay_period_start_date(p_assignment_id,p_effective_date);
  fetch get_next_pay_period_start_date into l_next_start_date;
  close get_next_pay_period_start_date;

  hr_utility.trace('ven_nppst_date= '||to_char(l_next_start_date));

loop
   --* if the hol anniversary date is the first day of the pay period
   --* then set the effective date to last day of the previous pay period
   --* else set the effective date to the any day of the current pay period
   --* this is done so that we can get the assignment_action_id of the period
   --* in which the hol anniversary date falls.This way we calculate the leaves
   --* that are given in the month in which hol anniversary date falls(until)
 if l_count = 1 then
   if to_char(p_effective_date+1,'dd')<>to_char(l_cur_per_start_date,'dd')
   then
       l_effective_date:= l_next_start_date;
       hr_utility.trace('ven_if');
   else
       l_effective_date:=p_effective_date;
       l_count := 2;
       hr_utility.trace('ven_else');
   end if;
else
   if l_count = 2 then
      l_effective_date := p_effective_date;
      hr_utility.trace('ven_count=2');
   end if;
end if;

  /* Bug:3043157 Start */
  /*  For the Financial year in which p_effective_date lies, following
      cursor gets the last pay periods end date */
  open get_max_fin_year_end(p_assignment_id,p_effective_date);
  fetch get_max_fin_year_end into v_fin_year_end;
  close get_max_fin_year_end;

  /* l_count<>4 check is to avoid the new logic for Payroll offset case. */
  /* If Holiday Anniversary Date lies in between the pay period then
     One Financial year plus one extra pay period should be considered.
     In the following condition, 'IF' part is to determine the start
     date and end date for the complete financial year and
     'ELSE' part is for one extra pay period in which holiday anniversary
      date lies */

  if  (l_effective_date = p_effective_date and l_count <> 4)
  then
     v_ann_start := add_months(p_effective_date+1,-12);
     v_ann_end := v_fin_year_end;

  else
     v_ann_start := v_fin_year_end+1;
     v_ann_end   := l_effective_date-1;
  end if;

   /* To find out assignment action id for offset case(l_count=4),
      use the original cursor else, call the modified cursor */
   /* Changed th fetch and close as invalid cursor name is used */
   if l_count = 4 then
     open get_assgt_action_id_4(p_assignment_id,l_effective_date);
     fetch get_assgt_action_id_4 into l_assignment_action_id;
     close get_assgt_action_id_4;
   else
     open get_assgt_action_id(p_assignment_id,v_ann_start,v_ann_end);
     fetch get_assgt_action_id into l_assignment_action_id;
     close get_assgt_action_id;
   end if;

   /* Bug:3043157 End */

  if l_assignment_action_id is null then
    l_balance := 0;
  else
    --     start expiry chk now
    l_action_eff_date := get_latest_date(l_assignment_action_id);
    --
    --     is effective date (sess) later than the expiry of the financial year of the
    --     effective date.
    --
    l_start_dd_mm := to_char(hr_nz_routes.get_anniversary_date(l_assignment_action_id, l_action_eff_date),'dd-mm-');
    --
    if p_effective_date >= get_expired_year_date(l_action_eff_date, l_start_dd_mm) then  /*3072939*/
      l_balance := 0;
    else
      --
      l_balance := calc_asg_hol_ytd (   p_assignment_action_id => l_assignment_action_id
                                    ,   p_balance_type_id      => p_balance_type_id
                                    ,   p_effective_date       => p_effective_date
                                    ,   p_assignment_id        => p_assignment_id
                                    );
    end if;
  end if;
  --
  l_count := l_count +1 ;
  total_balance := total_balance+l_balance;

/* code to handle the case when offset is given */

  if l_count = 5 then exit; end if;

  --* get the date earned and effective date to determine the offsets
  open get_dates(l_assignment_action_id);
  fetch get_dates into l_date_earn,l_eff_date;
  close get_dates;

  if l_count = 3 then
    --* check whether the payroll has given offsets
    if l_date_earn <> l_eff_date then
       --* whether hol anniv date falls before the offset date
       if p_effective_date+1 <  l_eff_date then
          l_effective_date := add_months(p_effective_date,-1);
          l_count := 4;
       end if;
     end if;
  end if;
/* end */
  if l_count = 3 then exit; end if;
end loop;
  return total_balance;
  --
end calc_asg_hol_ytd_date;
--
-----------------------------------------------------------------------------
--
--
--                          calc_asg_fy_ytd_action
--
--    this is the function for calculating assignment fiscal year to
--                      date in asg action mode
--
-----------------------------------------------------------------------------
--
function calc_asg_fy_ytd_action (   p_assignment_action_id in number
                                ,   p_balance_type_id      in number
                                ,   p_effective_date       in date
                                )
return number
is
  --
  l_assignment_action_id      number;
  l_balance                   number;
  l_assignment_id             number;
  l_effective_date        date;
  --
begin
  --
  l_assignment_id := get_correct_type(p_assignment_action_id);
  if l_assignment_id is null then
    --
    --  the assignment action is not a payroll or quickpay type, so return null
    --
    l_balance := null;
  else
    --
    l_balance := calc_asg_fy_ytd(   p_assignment_action_id  => p_assignment_action_id
                                ,   p_balance_type_id       => p_balance_type_id
                                ,   p_effective_date        => p_effective_date
                                ,   p_assignment_id         => l_assignment_id
                                );
  end if;
  --
  return l_balance;
  --
end calc_asg_fy_ytd_action;
--
-----------------------------------------------------------------------------
---
--
--                          calc_asg_fy_ytd_date
--
--    this is the function for calculating assignment fiscal year to
--              date in date mode
--
-----------------------------------------------------------------------------
--
function calc_asg_fy_ytd_date   (   p_assignment_id        in number
                                ,   p_balance_type_id      in number
                                ,   p_effective_date       in date
                                )
return number
is
  --
  cursor csr_business_group(p_assignment_id number) is
  select business_group_id
  from   per_assignments_f
  where  assignment_id = p_assignment_id;
  --
  l_assignment_action_id    number;
  l_balance                 number;
  l_end_date                date;
  l_action_eff_date         date;
  l_start_dd_mm             varchar2(9);
  l_business_group_id       per_assignments_f.business_group_id%type;
  --
begin
  --
  l_assignment_action_id := get_latest_action_id(   p_assignment_id
                                                ,   p_effective_date
                                                );
  if l_assignment_action_id is null then
    l_balance := 0;
  else
    --     start expiry chk now
    l_action_eff_date := get_latest_date(l_assignment_action_id);
    --
    --     is effective date (sess) later than the expiry of the fiscal year of the
    --     effective date.
    --
    open csr_business_group(p_assignment_id);
    fetch csr_business_group into l_business_group_id;
    close csr_business_group;
    l_start_dd_mm := to_char(hr_nz_routes.get_fiscal_date(l_business_group_id),'dd-mm-');
    --
    if p_effective_date >= get_expired_year_date(l_action_eff_date, l_start_dd_mm) then  /*3072939*/
      l_balance := 0;
    else
      --
      l_balance := calc_asg_fy_ytd  (   p_assignment_action_id => l_assignment_action_id
                                    ,   p_balance_type_id      => p_balance_type_id
                                    ,   p_effective_date       => p_effective_date
                                    ,   p_assignment_id        => p_assignment_id
                                    );
    end if;
  end if;
  --
  return l_balance;
  --
end calc_asg_fy_ytd_date;
--
--------------------------------------------------------------------------------
--
--                          calc_asg_fy_ytd
--      calculate balances for assignment fiscal year to date
--
--------------------------------------------------------------------------------
--
-- assignment year -
--
-- this dimension is the total for an assignment within the processing
-- year of any payrolls he has been on this year. that is in the case
-- of a transfer the span will go back to the start of the processing
-- year he was on at the start of year.
--
-- this dimension should be used for the year dimension of balances
-- which are not reset to zero on transferring payroll.

-- if this has been called from the date mode function, the effective date
-- will be set, otherwise session date is used.
--
function calc_asg_fy_ytd(   p_assignment_action_id  in number
                        ,   p_balance_type_id       in number
                        ,   p_effective_date        in date default null
                        ,   p_assignment_id         in number
                        )
return number
is
  --
  l_balance                 number;
  l_defined_bal_id          pay_defined_balances.defined_balance_id%TYPE;
  --
begin
  --
  -- Bug 3181581
  -- Modified code to fetch balance by calling pay_balance_pkg.get_value
  --
  l_defined_bal_id := dimension_relevant(p_balance_type_id, '_ASG_FY_YTD');

  --
  if l_defined_bal_id is not null then
    --
    l_balance := pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID   => l_defined_bal_id
                                  ,P_ASSIGNMENT_ACTION_ID => p_assignment_action_id
                                  ,P_TAX_UNIT_ID          => null
                                  ,P_JURISDICTION_CODE    => null
                                  ,P_SOURCE_ID            => null
                                  ,P_SOURCE_TEXT          => null
                                  ,P_TAX_GROUP            => null
                                  ,P_DATE_EARNED          => null
                                  );
    --
  else
    l_balance := null;
  end if;
  --
  return l_balance;
  --
end calc_asg_fy_ytd;
-----------------------------------------------------------------------------
--
--
--                          calc_asg_fy_qtd_action
--
--    this is the function for calculating assignment fiscal quarter to
--                      to date in asg action mode
--
-----------------------------------------------------------------------------
--
function calc_asg_fy_qtd_action (   p_assignment_action_id in number
                                ,   p_balance_type_id      in number
                                ,   p_effective_date       in date
                                )
return number
is
  --
  l_assignment_action_id      number;
  l_balance                   number;
  l_assignment_id             number;
  l_effective_date        date;
  --
begin
  --
  l_assignment_id := get_correct_type(p_assignment_action_id);
  if l_assignment_id is null then
    --
    --  the assignment action is not a payroll or quickpay type, so return null
    --
    l_balance := null;
  else
    --
    l_balance := calc_asg_fy_qtd(   p_assignment_action_id  => p_assignment_action_id
                                ,   p_balance_type_id       => p_balance_type_id
                                ,   p_effective_date        => p_effective_date
                                ,   p_assignment_id         => l_assignment_id
                                );
  end if;
  --
  return l_balance;
  --
end calc_asg_fy_qtd_action;
--
-----------------------------------------------------------------------------
---
--
--                          calc_asg_fy_qtd_date
--
--    this is the function for calculating assignment fiscal quarter
--                      to date in date mode
--
-----------------------------------------------------------------------------
--
function calc_asg_fy_qtd_date   (   p_assignment_id        in number
                                ,   p_balance_type_id      in number
                                ,   p_effective_date       in date
                                )
return number
is
  --
  cursor csr_business_group(p_assignment_id number) is
  select business_group_id
  from   per_assignments_f
  where  assignment_id = p_assignment_id;
  --
  l_assignment_action_id    number;
  l_balance                 number;
  l_end_date                date;
  l_action_eff_date         date;
  l_business_group_id       per_assignments_f.business_group_id%type;
  --
begin
  --
  l_assignment_action_id := get_latest_action_id(   p_assignment_id
                                                ,   p_effective_date
                                                );
  if l_assignment_action_id is null then
    l_balance := 0;
  else
    --     start expiry chk now
    l_action_eff_date := get_latest_date(l_assignment_action_id);
    --
    open csr_business_group(p_assignment_id);
    fetch csr_business_group into l_business_group_id;
    close csr_business_group;
    --
    --     is effective date (sess) later than the expiry of the fiscal quarter ( the start of the
    --     next fiscal quarter) of the effective date.
    --
    if p_effective_date > hr_nz_routes.fiscal_span_start(add_months(l_action_eff_date,4),4,l_business_group_id) then
      l_balance := 0;
    else
      --
      l_balance := calc_asg_fy_qtd  (   p_assignment_action_id => l_assignment_action_id
                                    ,   p_balance_type_id      => p_balance_type_id
                                    ,   p_effective_date       => p_effective_date
                                    ,   p_assignment_id        => p_assignment_id
                                    );
    end if;
  end if;
  --
  return l_balance;
  --
end calc_asg_fy_qtd_date;
--
--------------------------------------------------------------------------------
--
--                          calc_asg_fy_qtd
--      calculate balances for assignment fiscal quarter to date
--
--------------------------------------------------------------------------------
--
-- assignment year -
--
--
-- this dimension should be used for the year dimension of balances
-- which are not reset to zero on transferring payroll.

-- if this has been called from the date mode function, the effective date
-- will be set, otherwise session date is used.
--
function calc_asg_fy_qtd(   p_assignment_action_id  in number
                        ,   p_balance_type_id       in number
                        ,   p_effective_date        in date default null
                        ,   p_assignment_id         in number
                        )
return number
is
  --
  l_balance                 number;
  l_defined_bal_id          pay_defined_balances.defined_balance_id%TYPE;
  --
begin
  --
  -- Bug 3181581
  -- Modified code to fetch balance by calling pay_balance_pkg.get_value
  --
  l_defined_bal_id := dimension_relevant(p_balance_type_id, '_ASG_FY_QTD');
  --
  if l_defined_bal_id is not null then
   --
    l_balance := pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID   => l_defined_bal_id
                                  ,P_ASSIGNMENT_ACTION_ID => p_assignment_action_id
                                  ,P_TAX_UNIT_ID          => null
                                  ,P_JURISDICTION_CODE    => null
                                  ,P_SOURCE_ID            => null
                                  ,P_SOURCE_TEXT          => null
                                  ,P_TAX_GROUP            => null
                                  ,P_DATE_EARNED          => null
                                  );
   --
  else
    l_balance := null;
  end if;
  --
  return l_balance;
  --
end calc_asg_fy_qtd;
--
-----------------------------------------------------------------------------
--
--
--                          calc_asg_4week_action
--
--    this is the function for calculating assignment for the
--                      previous 28 days in asg action mode
--
-----------------------------------------------------------------------------
--
function calc_asg_4week_action  (   p_assignment_action_id in number
                                ,   p_balance_type_id      in number
                                ,   p_effective_date       in date
                                )
return number
is
  --
  l_assignment_action_id  number;
  l_balance               number;
  l_assignment_id         number;
  l_effective_date        date;
  --
begin
  --
  l_assignment_id := get_correct_type(p_assignment_action_id);
  if l_assignment_id is null then
    --
    --  the assignment action is not a payroll or quickpay type, so return null
    --
    l_balance := null;
  else
    --
    l_balance := calc_asg_4week (   p_assignment_action_id  => p_assignment_action_id
                                ,   p_balance_type_id       => p_balance_type_id
                                ,   p_effective_date        => p_effective_date
                                ,   p_assignment_id         => l_assignment_id
                                );
  end if;
  --
  return l_balance;
end calc_asg_4week_action;
--
-----------------------------------------------------------------------------
---
--
--                          calc_asg_4week_date
--
--    this is the function for calculating assignment for the
--              previous 28 days in date mode
--
-----------------------------------------------------------------------------
--
function calc_asg_4week_date(   p_assignment_id        in number
                            ,   p_balance_type_id      in number
                            ,   p_effective_date       in date
                            )
return number
is
  --
  l_assignment_action_id  number;
  l_balance               number;
  l_end_date              date;
  l_action_eff_date       date;
  l_start_dd_mm           varchar2(9);
  --
begin
  --
  l_assignment_action_id := get_latest_action_id(   p_assignment_id
                                                ,   p_effective_date
                                                );
  if l_assignment_action_id is null then
    l_balance := 0;
  else
    --
    l_balance := calc_asg_4week   (   p_assignment_action_id => l_assignment_action_id
                                  ,   p_balance_type_id      => p_balance_type_id
                                  ,   p_effective_date       => p_effective_date
                                  ,   p_assignment_id        => p_assignment_id
                                  );
  end if;
  --
  return l_balance;
end calc_asg_4week_date;
--
--------------------------------------------------------------------------------
--
--                          calc_asg_4week
--      calculate balances for assignment previous 28 days
--
--------------------------------------------------------------------------------
--
-- assignment 4 weeks -
--
-- if this has been called from the date mode function, the effective date
-- will be set, otherwise session date is used.
--
function calc_asg_4week (   p_assignment_action_id  in number
                        ,   p_balance_type_id       in number
                        ,   p_effective_date        in date default null
                        ,   p_assignment_id         in number
                        )
return number
is
  --
  l_balance                 number;
  l_defined_bal_id       pay_defined_balances.defined_balance_id%TYPE;
  --
begin
  --
  -- Bug 3181581, modified to fetch balance by calling pay_balance_pkg.get_value
  --
  l_defined_bal_id := dimension_relevant(p_balance_type_id, '_ASG_4WEEK');
  --
  if l_defined_bal_id is not null then
    --
    l_balance := pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID   => l_defined_bal_id
                                  ,P_ASSIGNMENT_ACTION_ID => p_assignment_action_id
                                  ,P_TAX_UNIT_ID          => null
                                  ,P_JURISDICTION_CODE    => null
                                  ,P_SOURCE_ID            => null
                                  ,P_SOURCE_TEXT          => null
                                  ,P_TAX_GROUP            => null
                                  ,P_DATE_EARNED          => null
                                  );
    --
  else
    l_balance := null;
  end if;
  --
  return l_balance;
  --
end calc_asg_4week;
--
-----------------------------------------------------------------------------
--
--                          calc_asg_ptd_action
--
--         this is the function for calculating assignment
--          proc. period to date in assignment action mode
--
-----------------------------------------------------------------------------
--
function calc_asg_ptd_action(   p_assignment_action_id in number
                            ,   p_balance_type_id      in number
                            ,   p_effective_date       in date
                            )
return number
is
  --
  l_assignment_action_id      number;
  l_balance                   number;
  l_assignment_id             number;
  l_effective_date        date;
  --
begin
  --
  l_assignment_id := get_correct_type ( p_assignment_action_id );
  if l_assignment_id is null then
    --
    --  the assignment action is not a payroll or quickpay type, so return null
    --
    l_balance := null;
  else
  --
    l_balance := calc_asg_ptd   (   p_assignment_action_id   => p_assignment_action_id
                                ,   p_balance_type_id       => p_balance_type_id
                                ,   p_effective_date        => p_effective_date
                                ,   p_assignment_id         => l_assignment_id
                                );
  end if;
  --
  return l_balance;
end calc_asg_ptd_action;
--
-----------------------------------------------------------------------------
--
--
--                          calc_asg_ptd_date
--
--    this is the function for calculating assignment processing
--    period to date in date mode
--
-----------------------------------------------------------------------------
--
function calc_asg_ptd_date  (   p_assignment_id        in number
                            ,   p_balance_type_id      in number
                            ,   p_effective_date       in date
                            )
return number
is
  --
  l_assignment_action_id      number;
  l_balance                   number;
  l_end_date                  date;
  --
  -- has the processing time period expired
  --
  cursor expired_time_period (c_assignment_action_id number) is
    select  ptp.end_date
    from    per_time_periods            ptp
    ,       pay_payroll_actions         ppa
    ,       pay_assignment_actions      paa
    where   paa.assignment_action_id    = c_assignment_action_id
            and paa.payroll_action_id   = ppa.payroll_action_id
            and ppa.time_period_id      = ptp.time_period_id;
  --
begin
  --
  l_assignment_action_id := get_latest_action_id(   p_assignment_id
                                                ,   p_effective_date
                                                );
  if l_assignment_action_id is null then
    l_balance := 0;
  else
    open  expired_time_period(l_assignment_action_id);
    fetch expired_time_period into l_end_date;
    close expired_time_period;
    --
    if l_end_date < p_effective_date then
      l_balance := 0;
    else
      l_balance := calc_asg_ptd (   p_assignment_action_id => l_assignment_action_id
                                ,   p_balance_type_id      => p_balance_type_id
                                ,   p_effective_date       => p_effective_date
                                ,   p_assignment_id        => p_assignment_id
                                );
    end if;
  end if;
  --
  return l_balance;
end calc_asg_ptd_date;
--
-----------------------------------------------------------------------------
---
--
--                          calc_asg_ptd
--
--      calculate balances for assignment process period to date
--
-----------------------------------------------------------------------------
---
--
-- this dimension is the total for an assignment within the processing
-- period of his current payroll, or if the assignment has transferred
-- payroll within the current processing period, it is the total since
-- he joined the current payroll.
--
-- this dimension should be used for the period dimension of balances
-- which are reset to zero on transferring payroll.
--
function calc_asg_ptd   (   p_assignment_action_id  in number
                        ,   p_balance_type_id       in number
                        ,   p_effective_date        in date default null
                        ,   p_assignment_id         in number
                        )
--
return number
is
  --
  l_balance                 number;
  l_defined_bal_id          pay_defined_balances.defined_balance_id%TYPE;
  --
begin
  --
  -- Bug 3181581
  -- Modified code to fetch balance by calling pay_balance_pkg.get_value
  --

  l_defined_bal_id := dimension_relevant(p_balance_type_id, '_ASG_PTD');
  --
  if l_defined_bal_id is not null then
    --
    l_balance := pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID   => l_defined_bal_id
                                  ,P_ASSIGNMENT_ACTION_ID => p_assignment_action_id
                                  ,P_TAX_UNIT_ID          => null
                                  ,P_JURISDICTION_CODE    => null
                                  ,P_SOURCE_ID            => null
                                  ,P_SOURCE_TEXT          => null
                                  ,P_TAX_GROUP            => null
                                  ,P_DATE_EARNED          => null
                                  );
    --
  else
    l_balance := null;
  end if;
  --
  return l_balance;
  --
end calc_asg_ptd;
--
--
-----------------------------------------------------------------------------
--
--
--                          calc_asg_td_action
--
--         this is the function for calculating assignment
--         to date in assignment action mode
--
-----------------------------------------------------------------------------
--
function calc_asg_td_action (   p_assignment_action_id in number
                            ,   p_balance_type_id      in number
                            ,   p_effective_date       in date
                            )
return number
is
  --
  l_assignment_action_id    number;
  l_balance                 number;
  l_assignment_id           number;
  l_effective_date          date;
  --
begin
  --
  l_assignment_id := get_correct_type(p_assignment_action_id);
  if l_assignment_id is null then
    --
    --  the assignment action is not a payroll or quickpay type, so return null
    --
    l_balance := null;
  else
    --
    l_balance := calc_asg_td(   p_assignment_id         => l_assignment_id
                            ,   p_assignment_action_id  => p_assignment_action_id
                            ,   p_balance_type_id       => p_balance_type_id
                            ,   p_effective_date        => p_effective_date
                            );
  end if;
  --
  return l_balance;
  --
end calc_asg_td_action;
--
-----------------------------------------------------------------------------
--
--
--                          calc_asg_td_date
--
--    this is the function for calculating assignment to
--                      date in date mode
--
-----------------------------------------------------------------------------
--
function calc_asg_td_date   (   p_assignment_id        in number
                            ,   p_balance_type_id      in number
                            ,   p_effective_date       in date
                            )
return number
is
  --
  l_assignment_action_id      number;
  l_balance                   number;
  l_end_date                  date;
  --
begin
  --
  l_assignment_action_id := get_latest_action_id(   p_assignment_id
                                                ,   p_effective_date
                                                );
  if l_assignment_action_id is null then
    l_balance := 0;
  else
    l_balance := calc_asg_td(   p_assignment_id         => p_assignment_id
                            ,   p_assignment_action_id  => l_assignment_action_id
                            ,   p_balance_type_id       => p_balance_type_id
                            ,   p_effective_date        => p_effective_date
                            );
  end if;
  --
  return l_balance;
  --
end calc_asg_td_date;
--
-----------------------------------------------------------------------------
--
--
--                          calc_asg_td
--
--      calculate balances for assignment to date
--
-----------------------------------------------------------------------------
--
-- sum of all run items since inception.
--
function calc_asg_td(   p_assignment_action_id  in number
                    ,   p_balance_type_id       in number
                    ,   p_effective_date        in date default null
                    ,   p_assignment_id         in number
                    )
return number
is
  --
  l_balance                 number;
  l_defined_bal_id          pay_defined_balances.defined_balance_id%TYPE;
  --
begin
  --
  -- Bug 3181581
  -- Modified code to fetch balance by calling pay_balance_pkg.get_value
  --

  l_defined_bal_id := dimension_relevant(p_balance_type_id,'_ASG_TD');
  --
  if l_defined_bal_id is not null then
    --
    l_balance := pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID   => l_defined_bal_id
                                  ,P_ASSIGNMENT_ACTION_ID => p_assignment_action_id
                                  ,P_TAX_UNIT_ID          => null
                                  ,P_JURISDICTION_CODE    => null
                                  ,P_SOURCE_ID            => null
                                  ,P_SOURCE_TEXT          => null
                                  ,P_TAX_GROUP            => null
                                  ,P_DATE_EARNED          => null
                                  );
    --
  else
    l_balance := null;
  end if;
  --
  return l_balance;
  --
end calc_asg_td;
--
--
-----------------------------------------------------------------------------
---
--
--                          calc_asg_run_action
--
--         this is the function for calculating assignment
--                runs in assignment action mode
--
-----------------------------------------------------------------------------
--
function calc_asg_run_action(   p_assignment_action_id in number
                            ,   p_balance_type_id      in number
                            ,   p_effective_date       in date
                            )
return number
is
  --
  l_assignment_action_id      number;
  l_balance                   number;
  l_assignment_id             number;
  l_effective_date            date;
  --
begin
  --
  l_assignment_id := get_correct_type(p_assignment_action_id);
  if l_assignment_id is null then
    --
    --  the assignment action is not a payroll or quickpay type, so return null
    --
    l_balance := null;
  else
    --
    l_balance := calc_asg_run   (   p_assignment_action_id  => p_assignment_action_id
                                ,   p_balance_type_id       => p_balance_type_id
                                ,   p_effective_date        => p_effective_date
                                ,   p_assignment_id         => l_assignment_id
                                );
  end if;
  --
  return l_balance;
end calc_asg_run_action;
--
-----------------------------------------------------------------------------
---
--
--                          calc_asg_run_date
--
--    this is the function for calculating assignment run in
--                    date mode
--
-----------------------------------------------------------------------------
--
function calc_asg_run_date  (   p_assignment_id         in number
                            ,   p_balance_type_id       in number
                            ,   p_effective_date        in date
                            )
return number
is
  --
  l_assignment_action_id  number;
  l_balance           number;
  l_end_date          date;
  --
  cursor expired_time_period ( c_assignment_action_id in number ) is
  select    ptp.end_date
  from      per_time_periods            ptp
  ,         pay_payroll_actions         ppa
  ,         pay_assignment_actions      paa
  where     paa.assignment_action_id    = c_assignment_action_id
  and       paa.payroll_action_id       = ppa.payroll_action_id
  and       ppa.time_period_id          = ptp.time_period_id;
  --
begin
  --
  l_assignment_action_id := get_latest_action_id( p_assignment_id, p_effective_date );
  if l_assignment_action_id is null then
    l_balance := 0;
  else
    open expired_time_period(l_assignment_action_id);
    fetch expired_time_period into l_end_date;
    close expired_time_period;
    --
    if l_end_date < p_effective_date then
      l_balance := 0;
    else
      l_balance := calc_asg_run (   p_assignment_action_id => l_assignment_action_id
                                ,   p_balance_type_id      => p_balance_type_id
                                ,   p_effective_date       => p_effective_date
                                ,   p_assignment_id        => p_assignment_id
                                );
    end if;
  end if;
  --
  return l_balance;
end calc_asg_run_date;
--
-----------------------------------------------------------------------------
---
--
--                          calc_asg_run
--            calculate balances for assignment run
--
-----------------------------------------------------------------------------
--
-- run
--    the simplest dimension retrieves run values where the context
--    is this assignment action and this balance feed. balance is the
--    specified input value. the related payroll action determines the
--    date effectivity of the feeds
--
function calc_asg_run   (   p_assignment_action_id  in number
                        ,   p_balance_type_id       in number
                        ,   p_effective_date        in date default null
                        ,   p_assignment_id         in number
                        )
return number
is
  --
  l_balance           number;
  l_defined_bal_id    pay_defined_balances.defined_balance_id%TYPE;
  --
begin
  --
  -- Bug 3181581
  -- Modified code to fetch balance by calling pay_balance_pkg.get_value
  --

  l_defined_bal_id := dimension_relevant(p_balance_type_id, '_ASG_RUN');

  if l_defined_bal_id is not null then
    --
    l_balance := pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID   => l_defined_bal_id
                                  ,P_ASSIGNMENT_ACTION_ID => p_assignment_action_id
                                  ,P_TAX_UNIT_ID          => null
                                  ,P_JURISDICTION_CODE    => null
                                  ,P_SOURCE_ID            => null
                                  ,P_SOURCE_TEXT          => null
                                  ,P_TAX_GROUP            => null
                                  ,P_DATE_EARNED          => null
                                  );
    --
  else
    l_balance := null;
  end if;
  --
  return l_balance;
  --
end calc_asg_run;
--

-----------------------------------------------------------------------------
--
--
--                          calc_payment_action
--
--         this is the function for calculating payments
--                in assignment action mode
--
-----------------------------------------------------------------------------
--
function calc_payment_action(   p_assignment_action_id in number
                            ,   p_balance_type_id      in number
                            ,   p_effective_date       in date
                            )
return number
is
  --
  l_assignment_action_id        number;
  l_balance                     number;
  l_assignment_id               number;
  l_effective_date              date;
  --
begin
  --
  l_assignment_id := get_correct_type(p_assignment_action_id);
  if l_assignment_id is null then
    --
    --  the assignment action is not a payroll or quickpay type, so return null
    --
    l_balance := null;
  else
    --
    l_balance := calc_payment   (   p_assignment_action_id => p_assignment_action_id
                                ,   p_balance_type_id      => p_balance_type_id
                                ,   p_effective_date       => p_effective_date
                                ,   p_assignment_id        => l_assignment_id
                                );
  end if;
  --
  return l_balance;
end calc_payment_action;
--
-----------------------------------------------------------------------------
--
--
--                          calc_payment_date
--
--    this is the function for calculating payments in
--                            date mode
--
-----------------------------------------------------------------------------
--
function calc_payment_date  (   p_assignment_id        in number
                            ,   p_balance_type_id      in number
                            ,   p_effective_date       in date
                            )
return number
is
  --
  l_assignment_action_id      number;
  l_balance                   number;
  l_end_date                  date;
  --
  cursor expired_time_period( c_assignment_action_id in number ) is
    select  ptp.end_date
    from    per_time_periods            ptp
    ,       pay_payroll_actions         ppa
    ,       pay_assignment_actions      paa
    where   paa.assignment_action_id    = c_assignment_action_id
            and   paa.payroll_action_id = ppa.payroll_action_id
            and   ppa.time_period_id    = ptp.time_period_id;
  --
begin
  --
  l_assignment_action_id := get_latest_action_id( p_assignment_id, p_effective_date );
  if l_assignment_action_id is null then
    l_balance := 0;
  else
    open expired_time_period(l_assignment_action_id);
    fetch expired_time_period into l_end_date;
    close expired_time_period;
    --
    if l_end_date < p_effective_date then
      l_balance := 0;
    else
      l_balance := calc_payment (   p_assignment_action_id => l_assignment_action_id
                                ,   p_balance_type_id      => p_balance_type_id
                                ,   p_effective_date       => p_effective_date
                                ,   p_assignment_id        => p_assignment_id
                                );
    end if;
  end if;
  --
  return l_balance;
end calc_payment_date;
--
-----------------------------------------------------------------------------
--
--                          calc_payment
--                calculate balances for payments
--
-----------------------------------------------------------------------------
--
-- this dimension is used in the pre-payments process - that process
-- creates interlocks for the actions that are included and the payments
-- dimension uses those interlocks to decide which run results to sum
------------------------------------------------------------------------------
function calc_payment   (   p_assignment_action_id  in number
                        ,   p_balance_type_id       in number
                        ,   p_effective_date        in date default null
                        ,   p_assignment_id         in number
                        )
return number
is
  --
  l_balance                 number;
  l_defined_bal_id          pay_defined_balances.defined_balance_id%TYPE;
  --
begin
  --
  -- Bug 3181581
  -- Modified code to fetch balance by calling pay_balance_pkg.get_value
  --

  l_defined_bal_id := dimension_relevant(p_balance_type_id, '_PAYMENTS');
  --
  if l_defined_bal_id is not null then
    --
    l_balance := pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID   => l_defined_bal_id
                                  ,P_ASSIGNMENT_ACTION_ID => p_assignment_action_id
                                  ,P_TAX_UNIT_ID          => null
                                  ,P_JURISDICTION_CODE    => null
                                  ,P_SOURCE_ID            => null
                                  ,P_SOURCE_TEXT          => null
                                  ,P_TAX_GROUP            => null
                                  ,P_DATE_EARNED          => null
                                  );
    --
  else
    l_balance := null;
  end if;
  --
  return l_balance;
  --
end calc_payment;
--
--
------------------------------------------------------------------------------

--
--------------------------------------------------------------------------------
--
--                          balance
--  fastformula cover for evaluating balances based on assignment_action_id
--
--------------------------------------------------------------------------------
--
function balance(   p_assignment_action_id  in number
                ,   p_defined_balance_id    in number
                )
return number
is
 --
  l_balance                 number;
begin
  --
  l_balance := pay_balance_pkg.get_value(P_DEFINED_BALANCE_ID   => p_defined_balance_id
                                  ,P_ASSIGNMENT_ACTION_ID => p_assignment_action_id
                                  ,P_TAX_UNIT_ID          => null
                                  ,P_JURISDICTION_CODE    => null
                                  ,P_SOURCE_ID            => null
                                  ,P_SOURCE_TEXT          => null
                                  ,P_TAX_GROUP            => null
                                  ,P_DATE_EARNED          => null
                                  );
  return l_balance;
  --
end balance;
--
end hr_nzbal;

/
