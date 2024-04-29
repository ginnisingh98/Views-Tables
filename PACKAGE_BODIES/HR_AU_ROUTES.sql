--------------------------------------------------------
--  DDL for Package Body HR_AU_ROUTES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_AU_ROUTES" as
  --  $Header: pyaurout.pkb 115.5 2003/10/20 02:13:44 puchil ship $

  --  Copyright (c) 1999 Oracle Corporation
  --  All rights reserved

  --  Date        Author   Bug/CR Num Notes
  --  -----------+--------+----------+-----------------------------------------
  --  20-Oct-2003 puchil   3198671    Made the calls to hr_utility as conditional.
  --  20-Oct-2003 puchil   3198671    Removed functions which were not
  --                                  used after BRA implementation.
  --  18 Jun 2003 Ragovind 3004966    Peformance Fix. Added /*+RULE */ to route code
  --  24 Mar 2003 Kaverma  2856638    Modified cursor cur_asg_td and added dbdrv commands
  --  18 Feb 2000 JTurner             Fixed problem with date format in
  --                                  get_fiscal_date function
  --  13-NOV-1999 sgoggin             Created

g_debug boolean := hr_utility.debug_enabled;
g_package  varchar2(33) := 'hr_au_routes.';
g_fin_year_start  constant varchar2(6) := '01-07-';
g_fbt_year_start  constant varchar2(6) := '01-04-';
g_cal_year_start  constant varchar2(6) := '01-01-';
--
------------------------------span_Start----------------------------------------
-- return the start of the span (year/quarter/month/week)
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
  if g_debug then
     hr_utility.set_location('Entering: hr_au_routes.span_start',1);
  end if;
  -- Get the year component of the input date
  l_year := to_number(to_char(p_input_date,'yyyy'));
  if g_debug then
     hr_utility.trace(' span_start: l_year='||to_char(l_year));
     hr_utility.trace(' span_start: p_frequency='||to_char(p_frequency));
     hr_utility.trace(' span_start: p_start_dd_mm='||p_start_dd_mm);
     hr_utility.trace(' span_start: p_input_date='||to_char(p_input_date,'DD-MON-YYYY'));
  end if;
  --
  if p_input_date >= to_date(p_start_dd_mm||to_char(l_year),'dd-mm-yyyy') then
    l_start := to_date(p_start_dd_mm||to_char(l_year),'dd-mm-yyyy');
  else
    l_start := to_date(p_start_dd_mm||to_char(l_year -1),'dd-mm-yyyy');
  end if;
  if g_debug then
     hr_utility.trace(' span_start: l_start='||to_char(l_year));
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
  if g_debug then
     hr_utility.trace(' span_start: l_start='||to_char(l_start,'DD-MON-YYYY'));
     hr_utility.set_location('Exiting: span_start',10);
  end if;
  return l_start;
  --
end span_start;
--
-------------------------------get_fiscal_date-------------------------------------
-- The fiscal year start date is stored in a flex field and is user definable.
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
-- Because the fiscal date is a flexfield we need a special wrapper to get the
-- span start date.
--
function fiscal_span_start( p_input_date            in date
                          , p_frequency             in number
                          , p_business_group_id     in number
                          )
return date is
  --
begin
  --
  return span_start( p_input_date, p_frequency, to_char(hr_au_routes.get_fiscal_date(p_business_group_id),'dd-mm-') );
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
  cursor  csr_ann_date is
  select  to_date(segment2,'YYYY/MM/DD HH24:MI:SS')
  from    hr_soft_coding_keyflex    hsck
  ,       per_all_assignments_f     paaf
  ,       pay_assignment_actions_v  paav
  where   p_effective_date  between paaf.effective_start_date and paaf.effective_end_date
          and paav.assignment_action_id   = p_assignment_action_id
          and paav.assignment_id          = paaf.assignment_id
          and paaf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id;
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
  return span_start(p_input_date, 1, to_char(hr_au_routes.get_anniversary_date(p_assignment_action_id, p_input_date), 'dd-mm-'));
  --
end anniversary_span_start;
--
end hr_au_routes;

/
