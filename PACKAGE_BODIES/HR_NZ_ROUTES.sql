--------------------------------------------------------
--  DDL for Package Body HR_NZ_ROUTES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NZ_ROUTES" as
  --  $Header: pynzrout.pkb 120.1 2005/09/01 21:54:17 snekkala noship $

  --  Copyright (c) 1999 Oracle Corporation
  --  All rights reserved

  --  Date        Author   Bug/CR Num Notes
  --  -----------+--------+----------+-----------------------------------------
  --  23 Jun 2003 puchil   3019293    Same as the previous one. Added comments
  --  23 Jun 2003 puchil   3019293    Changed the route cursors to use RBO
  --  24 Mar 2003 srrajago 2856694    Performance issue - Modified cursor cur_asg_td and added dbdrv commands.
  --  22 Feb 2000 jturner  1200795    updated date format in get_fiscal_date fn
  --  24-Sep-1999 sclarke  1003064
  --  13-Aug-1999 sclarke             Created
  --  03-Mar-2004 sshankar 3480748    Changed Rule Hint to CBO hint in all cursors using route codes.
  --  04-Aug-2004 sshankar 3181581    Removed functions which use route code to fetch balances, instead
  --                                  pay_balance_pkg.get_value will be used to fetch balance values.
  --                                  The functions are as following:
  --                                      _ASG_4WEEK
  --                                      _ASG_FY_QTD
  --                                      _ASG_FY_YTD
  --                                      _ASG_HOL_YTD
  --                                      _ASG_PAYMENT
  --                                      _ASG_PTD
  --                                      _ASG_RUN
  --                                      _ASG_TD
  --                                      _ASG_YTD
  --  01-Aug-2005 snekkala 4259438    Modified cursor csr_ann_date  for performance

--
-- financial year start date for nz
--
g_fin_year_start  constant varchar2(6) := '01-04-';
--
--------------------------------------------------------------------------------
--
--return the start of the span (year/quarter/week)
--
function span_start (   p_input_date    date
                    ,   p_frequency     number default 1
                    ,   p_start_dd_mm   varchar2
                    )
return date is
  l_year  number(4);
  l_start date;
  --
begin
  l_year := to_number(to_char(p_input_date,'yyyy'));
  --
  if p_input_date >= to_date(p_start_dd_mm||to_char(l_year),'dd-mm-yyyy') then
    l_start := to_date(p_start_dd_mm||to_char(l_year),'dd-mm-yyyy');
  else
    l_start := to_date(p_start_dd_mm||to_char(l_year -1),'dd-mm-yyyy');
  end if;
  --
  -- cater for weekly based frequency based on 52 per annum
  --
  if p_frequency in (52,26,13) then
    l_start := p_input_date - mod(p_input_date - l_start,7 * 52/p_frequency);
  else
    -- cater for monthly based frequency based on 12 per annum
    l_start := add_months(l_start, (12/p_frequency) * trunc(months_between(
    p_input_date,l_start)/(12/p_frequency)));
  end if;
  --
  return l_start;
  --
end span_start;
--
-------------------------------get_fiscal_date-------------------------------------
--
function get_fiscal_date( p_business_group_id   in number)
return date is
  --
  cursor  csr_fiscal_start is
  select  to_date(hoi.org_information11,'yyyy/mm/dd hh24:mi:ss')
  from    hr_organization_information         hoi
  where   lower(hoi.org_information_context)  = 'business group information'
          and hoi.organization_id             = p_business_group_id;
  --
  l_fiscal_start    varchar2(11);
  --
begin
  --
  open  csr_fiscal_start;
  fetch csr_fiscal_start
  into  l_fiscal_start;
  close csr_fiscal_start;
  --
  return l_fiscal_start;
  --
end get_fiscal_date;
--
-------------------------------fiscal_span_start------------------------------------
--
function fiscal_span_start( p_input_date            in date
                          , p_frequency             in number
                          , p_business_group_id     in number
                          )
return date is
  --
begin
  --
  return span_start( p_input_date, p_frequency, to_char(hr_nz_routes.get_fiscal_date(p_business_group_id),'dd-mm-') );
  --
end fiscal_span_start;
--
------------------------------get_anniversary_date--------------------------------
--
function get_anniversary_date ( p_assignment_action_id in number
                              , p_effective_date      in date
                              )
return date is
  --
  /* Bug 4259438 : Modified Cursor as part of performance fix */
  CURSOR  csr_ann_date
  IS
    SELECT to_date(segment2,'YYYY/MM/DD HH24:MI:SS')
      FROM hr_soft_coding_keyflex    hsck
         , per_assignments_f         paaf
         , pay_assignment_actions    paav
     WHERE p_effective_date  BETWEEN paaf.effective_start_date AND paaf.effective_end_date
       AND paav.assignment_action_id   = p_assignment_action_id
       AND paav.assignment_id          = paaf.assignment_id
       AND paaf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id;
  --
  l_anniversary_date varchar2(11);
  --
begin
  --
  -- get the anniversary hire date
  --
  open csr_ann_date;
  fetch csr_ann_date into l_anniversary_date;
  close csr_ann_date;
  --
  return l_anniversary_date;
  --
end get_anniversary_date;
--
------------------------------anniversary_span_start--------------------------------
--
function anniversary_span_start
( p_assignment_action_id  number
, p_input_date            date
)
return date is
  --
begin
  --
  -- calculate the span start of the anniversary date
  --
  return span_start(p_input_date, 1, to_char(hr_nz_routes.get_anniversary_date(p_assignment_action_id, p_input_date), 'dd-mm-'));
  --
end anniversary_span_start;
--
---------------------------------------------------------------------------
--
end hr_nz_routes;

/
