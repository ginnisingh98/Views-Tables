--------------------------------------------------------
--  DDL for Package Body HR_AUBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_AUBAL" as
  --  $Header: pyaubal.pkb 120.0.12000000.3 2007/08/23 12:02:44 avenkatk noship $

  --  Copyright (c) 1999 Oracle Corporation
  --  All rights reserved

  --  Date        Author   Bug/CR Num Notes
  --  -----------+--------+----------+-----------------------------------------
  --  21-Aug-2007 avenkatk 5371102    Cursor get_latest_id modified for performance, added join on payroll ID.
  --  23-Mar-2007 ksingla  5371102    Added hint USE_NL(ppa,paa) to cursor get_latest_id to remove MJC
  --  23-Jun-2004 srrajago 3603495    Cursor 'get_latest_id' modified for
  --                                  Performance Fix.
  --  07-May-2004 avenkatk 3580487    Changed calls to pay_balance_pkg.get_value
  --  07-May-2004 avenkatk 3580487    Changed calls to pay_balance_pkg.get_value
  --                                  Resolved GSCC errors.
  --  28-Aug-2003 Puchil   3010965    Changed the public functions to use
  --                                  pay_balance_pkg.get_value
  --  28-Jul-2003 Vgsriniv 3057155    Replaced > than condition with >= for
  --                                  checking expired year date in all the
  --                                  relevant functions
  --  25-Jul-2003 Vgsriniv 3057155    Replaced > than condition with >= for
  --                                  checking expired year date in the
  --                                  function calc_asg_ytd
  --  10-Jul-2003 Apunekar 3019374    Performance fix in cursor get_latest_id
  --  03-Dec-2002 Ragovind 2689226    Added NOCOPY for the function get_owning_balance.
  --                                  Added DBDRV command also.
  --  20-oct-2000 sgoggin  1472624    Added qualifier to end_date.
  --  22 Feb 2000 JTurner             Added missing dimensions to
  --                                  calc_all_balances (date mode)
  --  24-NOV-1999 sgoggin             Created
g_tax_year_start  constant varchar2(6) := '01-07-';
g_fbt_year_start  constant varchar2(6) := '01-04-';
g_cal_year_start  constant varchar2(6) := '01-01-';
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
  /* Bug No: 3603495 - Performance Fix */
  /* Bug No 5371102 - Removed ORDERED and added join on Payroll ID */

  cursor get_latest_id  (   c_assignment_id in number
                        ,   c_effective_date in date
                        ) is
    select  to_number(substr(max(lpad(paa.action_sequence,15,'0')||paa.assignment_action_id),16))
    from    per_assignments_f           paf
    ,       pay_assignment_actions      paa
    ,       pay_payroll_actions         ppa
    where   paa.assignment_id           = c_assignment_id
            and paf.assignment_id       = paa.assignment_id
            and ppa.payroll_action_id   = paa.payroll_action_id
            and ppa.effective_date      <= c_effective_date
            and ppa.action_type         in ('R', 'Q', 'I', 'V', 'B')
            and paa.action_status='C'
            and ppa.payroll_id          = paf.payroll_id
            and ppa.effective_date      between paf.effective_start_date and paf.effective_end_date
            and ppa.action_status='C' ; /*Bug - 3019374 */
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
--
-- Bug 3010965 - Changed the function to use pay_balance_pkg.get_value
-----------------------------------------------------------------------------
--
function calc_all_balances  (   p_assignment_action_id in number
                            ,   p_defined_balance_id   in number
                            )
return number
is
  --
  --
begin
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
--    this is the overloaded generic function for calculating all balances
--    in date mode.
--
-- Bug 3010965 - Changed the function to use pay_balance_pkg.get_value
-----------------------------------------------------------------------------
--
function calc_all_balances  (   p_effective_date       in date
                            ,   p_assignment_id        in number
                            ,   p_defined_balance_id   in number
                            )
return number
is
  --
  l_assignment_action_id  pay_assignment_actions.assignment_action_id%TYPE;
  --
begin
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
-- Bug 3010965 - Changed the function to use pay_balance_pkg.get_value
--------------------------------------------------------------------------------
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
  l_start_dd_mm           varchar2(9);
  --
begin
  --
  l_start_dd_mm  := g_tax_year_start;
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
    if p_effective_date >= get_expired_year_date(l_action_eff_date, l_start_dd_mm) then
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
--                          calc_asg_mtd
--      calculate balances for assignment month to date
--
-- Bug 3010965 - Changed the function to use pay_balance_pkg.get_value
--------------------------------------------------------------------------------
--
-- will be set, otherwise session date is used.
--
function calc_asg_mtd   (   p_assignment_action_id  in number
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
  l_defined_bal_id := dimension_relevant(p_balance_type_id, '_ASG_MTD');
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
end calc_asg_mtd;
--
-----------------------------------------------------------------------------
--
--
--                          calc_asg_mtd_action
--
--    this is the function for calculating assignment year to
--                      date in asg action mode
--
-----------------------------------------------------------------------------
--
function calc_asg_mtd_action
(p_assignment_action_id in number
,p_balance_type_id      in number
,p_effective_date       in date default null)
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
    l_balance := calc_asg_mtd   (   p_assignment_action_id  => p_assignment_action_id
                                ,   p_balance_type_id       => p_balance_type_id
                                ,   p_effective_date        => p_effective_date
                                ,   p_assignment_id         => l_assignment_id
                                );
  end if;
  --
  return l_balance;
  --
end calc_asg_mtd_action;
--
-----------------------------------------------------------------------------
---
--
--                          calc_asg_mtd_date
--
--    this is the function for calculating assignment year to
--              date in date mode
--
-----------------------------------------------------------------------------
--
function calc_asg_mtd_date  (   p_assignment_id        in number
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
  l_start_dd_mm := g_tax_year_start;
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
    if p_effective_date >= get_expired_year_date(l_action_eff_date, l_start_dd_mm) then
      l_balance := 0;
    else
      --
      l_balance := calc_asg_mtd (   p_assignment_action_id => l_assignment_action_id
                                ,   p_balance_type_id      => p_balance_type_id
                                ,   p_effective_date       => p_effective_date
                                ,   p_assignment_id        => p_assignment_id
                                );
    end if;
  end if;
  --
  return l_balance;
  --
end calc_asg_mtd_date;
--
--------------------------------------------------------------------------------
--
--                          calc_asg_qtd
--      calculate balances for assignment month to date
--
-- Bug 3010965 - Changed the function to use pay_balance_pkg.get_value
--------------------------------------------------------------------------------
--
-- will be set, otherwise session date is used.
--
function calc_asg_qtd   (   p_assignment_action_id  in number
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
  l_defined_bal_id := dimension_relevant(p_balance_type_id, '_ASG_QTD');
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
end calc_asg_qtd;
--
-----------------------------------------------------------------------------
--
--
--                          calc_asg_qtd_action
--
--    this is the function for calculating assignment year to
--                      date in asg action mode
--
-----------------------------------------------------------------------------
--
function calc_asg_qtd_action
(p_assignment_action_id in number
,p_balance_type_id      in number
,p_effective_date       in date default null)
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
    l_balance := calc_asg_qtd   (   p_assignment_action_id  => p_assignment_action_id
                                ,   p_balance_type_id       => p_balance_type_id
                                ,   p_effective_date        => p_effective_date
                                ,   p_assignment_id         => l_assignment_id
                                );
  end if;
  --
  return l_balance;
  --
end calc_asg_qtd_action;
--
-----------------------------------------------------------------------------
--
--                          calc_asg_qtd_date
--    this is the function for calculating assignment year to
--              date in date mode
--
-----------------------------------------------------------------------------
--
function calc_asg_qtd_date
(p_assignment_id        in number
,p_balance_type_id      in number
,p_effective_date       in date)
return number is
  l_fn_name               constant varchar2(61) := 'hr_aubal.calc_asg_qtd_date' ;
  --
  l_assignment_action_id  number;
  l_balance               number;
  l_end_date              date;
  l_action_eff_date       date;
  l_start_dd_mm           varchar2(9);
  --
begin
  --
  l_start_dd_mm := g_tax_year_start;
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
    if p_effective_date >= get_expired_year_date(l_action_eff_date, l_start_dd_mm) then
      l_balance := 0;
    else
      --
      l_balance := calc_asg_qtd
                   (p_assignment_action_id => l_assignment_action_id
                   ,p_balance_type_id      => p_balance_type_id
                   ,p_effective_date       => p_effective_date
                   ,p_assignment_id        => p_assignment_id);
    end if;
  end if;
  --
  return l_balance;
  --
end calc_asg_qtd_date;
--
--------------------------------------------------------------------------------
--
--                          calc_asg_cal_ytd
--      calculate balances for assignment year to date
--
-- Bug 3010965 - Changed the function to use pay_balance_pkg.get_value
--------------------------------------------------------------------------------
--
function calc_asg_cal_ytd(   p_assignment_action_id  in number
                         ,   p_balance_type_id       in number
                         ,   p_effective_date        in date default null
                         ,   p_assignment_id         in number
                         )
return number
is
  --
  l_balance              number;
  l_defined_bal_id       pay_defined_balances.defined_balance_id%TYPE;
  --
begin
  --
  l_defined_bal_id := dimension_relevant(p_balance_type_id, '_ASG_CAL_YTD');
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
end calc_asg_cal_ytd;
--
-----------------------------------------------------------------------------
--
--                          calc_asg_cal_ytd_action
--    this is the function for calculating assignment year to
--                      date in asg action mode
--
-----------------------------------------------------------------------------
--
function calc_asg_cal_ytd_action
(p_assignment_action_id in number
,p_balance_type_id      in number
,p_effective_date       in date default null)
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
    l_balance := calc_asg_cal_ytd   (   p_assignment_action_id  => p_assignment_action_id
                                ,   p_balance_type_id       => p_balance_type_id
                                ,   p_effective_date        => p_effective_date
                                ,   p_assignment_id         => l_assignment_id
                                );
  end if;
  --
  return l_balance;
  --
end calc_asg_cal_ytd_action;
--
-----------------------------------------------------------------------------
--
--                          calc_asg_cal_ytd_date
--    this is the function for calculating assignment year to
--              date in date mode
--
-----------------------------------------------------------------------------
--
function calc_asg_cal_ytd_date
(p_assignment_id        in number
,p_balance_type_id      in number
,p_effective_date       in date)
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
  l_start_dd_mm := g_cal_year_start;
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
    if p_effective_date > get_expired_year_date(l_action_eff_date, l_start_dd_mm) then
      l_balance := 0;
    else
      --
      l_balance := calc_asg_cal_ytd (   p_assignment_action_id => l_assignment_action_id
                                ,   p_balance_type_id      => p_balance_type_id
                                ,   p_effective_date       => p_effective_date
                                ,   p_assignment_id        => p_assignment_id
                                );
    end if;
  end if;
  --
  return l_balance;
  --
end calc_asg_cal_ytd_date;
--
--------------------------------------------------------------------------------
--
--                          calc_asg_fbt_ytd
--      calculate balances for FBT year to date
--
-- Bug 3010965 - Changed the function to use pay_balance_pkg.get_value
--------------------------------------------------------------------------------
--
function calc_asg_fbt_ytd( p_assignment_action_id  in number
                         , p_balance_type_id       in number
                         , p_effective_date        in date default null
                         , p_assignment_id         in number)
return number
is
  --
  l_balance                 number;
  l_defined_bal_id          pay_defined_balances.defined_balance_id%TYPE;
  --
begin
  --
  l_defined_bal_id := dimension_relevant(p_balance_type_id, '_ASG_FBT_YTD');
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
end calc_asg_fbt_ytd;
--
-----------------------------------------------------------------------------
--
--
--                          calc_asg_fbt_ytd_action
--
--    this is the function for calculating assignment anniversary year to
--                      date in asg action mode
--
-----------------------------------------------------------------------------
--
function calc_asg_fbt_ytd_action
(p_assignment_action_id in number
,p_balance_type_id      in number
,p_effective_date       in date default null)
return number is
  l_fn_name                 constant varchar2(61) := 'hr_aubal.calc_asg_fbt_ytd_action' ;
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
    l_balance := calc_asg_fbt_ytd   (   p_assignment_action_id  => p_assignment_action_id
                                    ,   p_balance_type_id       => p_balance_type_id
                                    ,   p_effective_date        => p_effective_date
                                    ,   p_assignment_id         => l_assignment_id
                                    );
  end if;
  --
  return l_balance;
  --
end calc_asg_fbt_ytd_action;
--
-----------------------------------------------------------------------------
---
--
--                          calc_asg_fbt_ytd_date
--
--    this is the function for calculating assignment anniversary year to
--              date in date mode
--
-----------------------------------------------------------------------------
--
function calc_asg_fbt_ytd_date
(p_assignment_id        in number
,p_balance_type_id      in number
,p_effective_date       in date)
return number is

  l_fn_name                       constant varchar2(61) := 'hr_aubal.calc_asg_fbt_ytd_date' ;
  l_assignment_action_id          number;
  l_balance                       number;
  l_end_date                      date;
  l_action_eff_date               date;

begin

  hr_utility.trace('In: ' || l_fn_name) ;
  hr_utility.trace('  p_balance_type_id:' || to_char(p_balance_type_id)) ;
  hr_utility.trace('  p_effective_date:' || to_char(p_effective_date,'dd Mon yyyy')) ;
  hr_utility.trace('  p_assignment_id:' || to_char(p_assignment_id)) ;

  hr_utility.set_location(l_fn_name, 10) ;
  l_assignment_action_id := get_latest_action_id
                            (p_assignment_id
                            ,p_effective_date);
  hr_utility.trace('  l_assignment_action_id:' || to_char(l_assignment_action_id)) ;

  if l_assignment_action_id is null
  then
    hr_utility.set_location(l_fn_name, 20) ;
    l_balance := 0;
  else
    hr_utility.set_location(l_fn_name, 30) ;
    --     start expiry chk now
    l_action_eff_date := get_latest_date(l_assignment_action_id);
    hr_utility.trace('  l_action_eff_date:' || to_char(l_action_eff_date, 'dd Mon yyyy')) ;

    --     is effective date (sess) later than the expiry of the FBT year of the
    --     effective date.

    if p_effective_date >= get_expired_year_date(l_action_eff_date, g_fbt_year_start)
    then
      hr_utility.set_location(l_fn_name, 40) ;
      l_balance := 0;
    else
      hr_utility.set_location(l_fn_name, 50) ;
      l_balance := calc_asg_fbt_ytd
                   (p_assignment_action_id => l_assignment_action_id
                   ,p_balance_type_id      => p_balance_type_id
                   ,p_effective_date       => p_effective_date
                   ,p_assignment_id        => p_assignment_id);
    end if;
  end if;

  hr_utility.trace(l_fn_name || ' return:' || to_char(l_balance)) ;
  hr_utility.trace('Out: ' || l_fn_name) ;
  return l_balance;

end calc_asg_fbt_ytd_date;
--
--------------------------------------------------------------------------------
--
--                          calc_asg_fy_ytd
--      calculate balances for assignment fiscal year to date
--
-- Bug 3010965 - Changed the function to use pay_balance_pkg.get_value
--------------------------------------------------------------------------------
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
    l_start_dd_mm := to_char(hr_AU_routes.get_fiscal_date(l_business_group_id),'dd-mm-');
    --
    if p_effective_date >= get_expired_year_date(l_action_eff_date, l_start_dd_mm) then
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
--                          calc_asg_fy_qtd
--      calculate balances for assignment fiscal quarter to date
--
-- Bug 3010965 - Changed the function to use pay_balance_pkg.get_value
--------------------------------------------------------------------------------
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
-----------------------------------------------------------------------------
--
--                          calc_asg_fy_qtd_action
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
--
--                          calc_asg_fy_qtd_date
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
    if p_effective_date > hr_AU_routes.fiscal_span_start(add_months(l_action_eff_date,4),4,l_business_group_id) then
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
-----------------------------------------------------------------------------
--
--                          calc_asg_ptd
--      calculate balances for assignment process period to date
--
-- Bug 3010965 - Changed the function to use pay_balance_pkg.get_value
-----------------------------------------------------------------------------
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
--
--
--                          calc_asg_td
--
--      calculate balances for assignment to date
--
-- Bug 3010965 - Changed the function to use pay_balance_pkg.get_value
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
-----------------------------------------------------------------------------
--
--                          calc_asg_td_action
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
--                          calc_asg_td_date
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
---
--
--                          calc_asg_run
--            calculate balances for assignment run
--
-- Bug 3010965 - Changed the function to use pay_balance_pkg.get_value
-----------------------------------------------------------------------------
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
--                          calc_asg_run_action
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
--
--                          calc_asg_run_date
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
--
--                          calc_payment
--                calculate balances for payments
--
-- Bug 3010965 - Changed the function to use pay_balance_pkg.get_value
-----------------------------------------------------------------------------
--
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
-----------------------------------------------------------------------------
--
--                          calc_payment_action
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
--                          calc_payment_date
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
------------------------------------------------------------------------------
--
end hr_aubal;

/
