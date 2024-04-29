--------------------------------------------------------
--  DDL for Package Body PYGBEXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PYGBEXC" as
/* $Header: pygbexc.pkb 120.0.12010000.3 2009/07/30 09:44:08 jvaradra ship $ */
-- cache result of expiry check
   g_gb_owner_payroll_action_id    number;    -- run created balance.
   g_gb_user_payroll_action_id     number;    -- current run.
   g_gb_expiry_information         number;    -- dimension expired flag.
/*------------------------------ ASG_RUN_EC ----------------------------*/
/*
   NAME
      ASG_RUN_EC - Assignment Run to Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        GB Assignment-level Run To Date Balance Dimension
   NOTES
      The associated dimension is expiry checked at payroll action level
*/
procedure ASG_RUN_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information            out nocopy number     -- dimension expired flag.
) is

begin
   if p_user_payroll_action_id = p_owner_payroll_action_id then
      p_expiry_information := 0;
   else
      p_expiry_information := 1;
   end if;

end ASG_RUN_EC;

/*------------------------------ ASG_PROC_PTD_EC ----------------------------*/
/*
   NAME
      ASG_PROC_PTD_EC - Assignment Processing Period to Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        GB Assignment-level Process Period To Date Balance Dimension
   NOTES
      The associated dimension is expiry checked at payroll action level
*/
procedure ASG_PROC_PTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information            out nocopy number     -- dimension expired flag.
) is
   l_user_time_period_id number;
   l_owner_time_period_id number;
begin
   /*
    *  Select the period of the owning and using action and if they are
    *  the same then the dimension has expired - either a prior period
    *  or a different payroll
    */

   select time_period_id
   into l_user_time_period_id
   from pay_payroll_actions
   where payroll_action_id = p_user_payroll_action_id;

   select time_period_id
   into l_owner_time_period_id
   from pay_payroll_actions
   where payroll_action_id = p_owner_payroll_action_id;

   if l_user_time_period_id = l_owner_time_period_id then
      p_expiry_information := 0;
   else
      p_expiry_information := 1;
   end if;

end ASG_PROC_PTD_EC;

-- For 115.12

procedure ASG_PROC_PTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information            out nocopy date     -- dimension expired flag.
) is

begin

    hr_utility.set_location ('In Overloaded ASG_PROC_PTD_EC',10);
    hr_utility.set_location ('Namish:p_owner_payroll_action_id:'||p_owner_payroll_action_id,10);
    hr_utility.set_location ('Namish:p_owner_effective_date:'||p_owner_effective_date,10);

   SELECT ptp.end_date
   INTO   p_expiry_information
   FROM   per_time_periods    ptp
         ,pay_payroll_actions ppa
   WHERE  ppa.payroll_action_id = p_owner_payroll_action_id
     AND  ppa.time_period_id  = ptp.time_period_id;

    hr_utility.set_location ('p_expiry_information:'||p_expiry_information,10);
end ASG_PROC_PTD_EC;


/*------------------------------ ASG_PROC_YTD_EC ----------------------------*/
/*
   NAME
      ASG_PROC_YTD_EC - Assignment Processing Year to Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        GB Assignment-level Process Year To Date Balance Dimension
   NOTES
      The associated dimension is expiry checked at payroll action level
*/
procedure ASG_PROC_YTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information            out nocopy number     -- dimension expired flag.
) is
   l_tax_year_start  date;
   l_pay_year_start  date;
   l_user_payroll_id number;
   l_owning_regular_payment_date date;
begin
   -- if the payroll actions have not changed return stored result
   if (p_owner_payroll_action_id = g_gb_owner_payroll_action_id)
   and (p_user_payroll_action_id = g_gb_user_payroll_action_id) then
       p_expiry_information := g_gb_expiry_information;
      else  -- [ check expiry
   /* select the start of the financial year - if the owning action is
    * before this or for a different payroll then its expired
   */
   Select to_date('06-04-' || to_char( fnd_number.canonical_to_number(
          to_char( PTP.regular_payment_date,'YYYY'))
             +  decode(sign( PTP.regular_payment_date - to_date('06-04-'
                 || to_char(PTP.regular_payment_date,'YYYY'),'DD-MM-YYYY')),
           -1,-1,0)),'DD-MM-YYYY') finyear, BACT.payroll_id
   into l_tax_year_start, l_user_payroll_id
   from per_time_periods    PTP,
        pay_payroll_actions BACT
   where BACT.payroll_action_id = p_user_payroll_action_id
   and   PTP.time_period_id = BACT.time_period_id;
--
-- find the regular payment date for the owning action
--
        select  regular_payment_date
        into    l_owning_regular_payment_date
        from    pay_payroll_actions     PACT,
                per_time_periods        PTP
        where   PACT.payroll_action_id  = p_owner_payroll_action_id
        and     PTP.time_period_id      = PACT.time_period_id;
--
   if l_owning_regular_payment_date < l_tax_year_start then
      p_expiry_information := 1;
      g_gb_expiry_information := 1;
   else
      p_expiry_information := 0;
      g_gb_expiry_information := 0;
   end if;
   g_gb_owner_payroll_action_id := p_owner_payroll_action_id;
   g_gb_user_payroll_action_id :=  p_user_payroll_action_id;
   end if; -- ] end check expiry
--

end ASG_PROC_YTD_EC;


--For 115.12

procedure ASG_PROC_YTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information            out nocopy date     -- dimension expired flag.
) is
begin

    hr_utility.set_location ('In Overloaded ASG_PROC_YTD',10);
    hr_utility.set_location ('p_owner_payroll_action_id:'||p_owner_payroll_action_id,10);
    hr_utility.set_location ('p_owner_effective_date:'||p_owner_effective_date,10);
    hr_utility.set_location ('p_dimension_name:'||p_dimension_name,10);

    SELECT to_date('05-04-' ||to_char(fnd_number.canonical_to_number(
           to_char( PTP.regular_payment_date,'YYYY'))
           +  decode(sign( PTP.regular_payment_date -
           to_date('06-04-'|| to_char(PTP.regular_payment_date,'YYYY'),'DD-MM-YYYY')),
           -1,0,1)),'DD-MM-YYYY') finyear_end
    INTO p_expiry_information
    FROM per_time_periods    PTP,
         pay_payroll_actions BACT
    WHERE BACT.payroll_action_id = p_owner_payroll_action_id
      AND PTP.time_period_id = BACT.time_period_id;

    hr_utility.set_location ('p_expiry_information:'||p_expiry_information,10);

end ASG_PROC_YTD_EC;



-- For 115.11

/*------------------------------ ASG_PEN_YTD_EC ----------------------------*/
/*
   NAME
      ASG_PEN_YTD_EC - Assignment Processing Pension Year to Date expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        GB Assignment-level Process Pension Year To Date Balance Dimension
   NOTES
      The associated dimension is expiry checked at payroll action level
*/
procedure ASG_PEN_YTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information            out nocopy number     -- dimension expired flag.
) is
   l_tax_year_start  date;
   l_pay_year_start  date;
   l_user_payroll_id number;
   l_owning_regular_payment_date date;
begin
   -- if the payroll actions have not changed return stored result
   if (p_owner_payroll_action_id = g_gb_owner_payroll_action_id)
   and (p_user_payroll_action_id = g_gb_user_payroll_action_id) then
       p_expiry_information := g_gb_expiry_information;
      else  -- [ check expiry
   /* select the start of the financial year - if the owning action is
    * before this or for a different payroll then its expired
   */
   Select to_date('01-04-' || to_char( fnd_number.canonical_to_number(
          to_char( PTP.regular_payment_date,'YYYY'))
             +  decode(sign( PTP.regular_payment_date - to_date('01-04-'
                 || to_char(PTP.regular_payment_date,'YYYY'),'DD-MM-YYYY')),
           -1,-1,0)),'DD-MM-YYYY') finyear, BACT.payroll_id
   into l_tax_year_start, l_user_payroll_id
   from per_time_periods    PTP,
        pay_payroll_actions BACT
   where BACT.payroll_action_id = p_user_payroll_action_id
   and   PTP.time_period_id = BACT.time_period_id;
--
-- find the regular payment date for the owning action
--
        select  regular_payment_date
        into    l_owning_regular_payment_date
        from    pay_payroll_actions     PACT,
                per_time_periods        PTP
        where   PACT.payroll_action_id  = p_owner_payroll_action_id
        and     PTP.time_period_id      = PACT.time_period_id;
--
   if l_owning_regular_payment_date < l_tax_year_start then
      p_expiry_information := 1;
      g_gb_expiry_information := 1;
   else
      p_expiry_information := 0;
      g_gb_expiry_information := 0;
   end if;
   g_gb_owner_payroll_action_id := p_owner_payroll_action_id;
   g_gb_user_payroll_action_id :=  p_user_payroll_action_id;
   end if; -- ] end check expiry
--

end ASG_PEN_YTD_EC;

-- For 115.12
-- Returns the Periods End date for the owner assignment_action_id

procedure ASG_PEN_YTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information            out nocopy date     -- dimension expired date.
) is
begin

    hr_utility.set_location ('In Overloaded ASG_PEN_YTD_EC',10);
    hr_utility.set_location ('p_owner_payroll_action_id:'||p_owner_payroll_action_id,10);
    hr_utility.set_location ('p_owner_effective_date:'||p_owner_effective_date,10);

    SELECT to_date('31-03-' ||to_char(fnd_number.canonical_to_number(
           to_char( PTP.regular_payment_date,'YYYY'))
           +  decode(sign( PTP.regular_payment_date -
           to_date('01-04-'|| to_char(PTP.regular_payment_date,'YYYY'),'DD-MM-YYYY')),
           -1,0,1)),'DD-MM-YYYY') finyear_end
    INTO p_expiry_information
    FROM per_time_periods    PTP,
         pay_payroll_actions BACT
    WHERE BACT.payroll_action_id = p_owner_payroll_action_id
      AND PTP.time_period_id = BACT.time_period_id;

    hr_utility.set_location ('p_expiry_information:'||p_expiry_information,10);

end ASG_PEN_YTD_EC;


/*------------------------------ ASG_STAT_YTD_EC ----------------------------*/
/*
   NAME
      ASG_STAT_YTD_EC - Assignment Statutory Year to DAte expiry check
   DESCRIPTION
      Expiry checking code for the following:
        GB Assignment-level Statutory Year to Date dimension
   NOTES
      The associated dimension is expiry checked at payroll action level
*/
procedure ASG_STAT_YTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information            out nocopy number     -- dimension expired flag.
) is
   l_tax_year_start  date;
begin
   select to_date('06-04-' || to_char( fnd_number.canonical_to_number(
          to_char( p_user_effective_date,'YYYY'))
             +  decode(sign( p_user_effective_date - to_date('06-04-'
                 || to_char( p_user_effective_date,'YYYY'),'DD-MM-YYYY')),
           -1,-1,0)),'DD-MM-YYYY')
   into l_tax_year_start
   from pay_payroll_actions BACT
   where BACT.payroll_action_id = p_user_payroll_action_id;
--
   if p_owner_effective_date < l_tax_year_start then
      p_expiry_information := 1;
   else
      p_expiry_information := 0;
   end if;

end ASG_STAT_YTD_EC;

-- For 115.12

procedure ASG_STAT_YTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information            out nocopy date     -- dimension expired flag.
) is
begin

    hr_utility.set_location ('In Overloaded ASG_STAT_YTD_EC',10);
    hr_utility.set_location ('Namish:p_owner_assignment_action_id:'||p_owner_assignment_action_id,10);
    hr_utility.set_location ('Namish:p_owner_effective_date:'||p_owner_effective_date,10);

 SELECT to_date('05-04-' ||to_char(fnd_number.canonical_to_number(
           to_char( p_owner_effective_date,'YYYY'))
           +  decode(sign(p_owner_effective_date -
           to_date('06-04-'|| to_char(p_owner_effective_date,'YYYY'),'DD-MM-YYYY')),
           -1,0,1)),'DD-MM-YYYY') finyear_end
    INTO p_expiry_information
  FROM dual;

   hr_utility.set_location ('p_expiry_information'||p_expiry_information,10);

end ASG_STAT_YTD_EC;

/*------------------------------ ASG_USER_EC ----------------------------*/
/*
   NAME
      ASG_USER_EC - Assignment user dimension expiry check.
   DESCRIPTION
      Expiry checking code for the following:
        GB Assignment-level user dimension
   NOTES
      The associated dimension is expiry checked at payroll action level
*/
procedure ASG_USER_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information            out nocopy number     -- dimension expired flag.
) is
   l_tax_year_start  date;
   l_pay_year_start  date;
   l_user_payroll_id number;

   l_user_regular_payment_date      date;
   l_business_group_id  number;
   l_owning_regular_payment_date    date;
   l_span_start         date;


begin

-- find the regular payment date for the using action
      select      regular_payment_date, BACT.business_group_id
      into  l_user_regular_payment_date, l_business_group_id
        from      pay_payroll_actions     BACT,
            per_time_periods  PTP
      where       BACT.payroll_action_id  = p_user_payroll_action_id
      and   PTP.time_period_id      = BACT.time_period_id;

-- find the regular payment date for the owning action
      select      regular_payment_date
      into  l_owning_regular_payment_date
        from      pay_payroll_actions     PACT,
            per_time_periods  PTP
      where       PACT.payroll_action_id  = p_owner_payroll_action_id
      and   PTP.time_period_id      = PACT.time_period_id;

-- find when the dimension last cleared down
l_span_start := hr_gbbal.dimension_reset_date(  p_dimension_name,
                                    l_user_regular_payment_date,
                                    l_business_group_id);


-- is the user action since this date
--
--
   if l_owning_regular_payment_date < l_span_start then
      p_expiry_information := 1;
   else
      p_expiry_information := 0;
   end if;
--

end ASG_USER_EC;

--For 115.12

procedure ASG_USER_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information            out nocopy date     -- dimension expired flag.
) is


  l_owning_regular_payment_date     date;

  l_start_dd_mon    VARCHAR2(7);
  l_frequency   NUMBER;
  l_start_reset   NUMBER;

begin

    hr_utility.set_location ('In Overloaded ASG_USER_EC',10);
    hr_utility.set_location ('p_owner_payroll_action_id:'||p_owner_payroll_action_id,10);
    hr_utility.set_location ('p_owner_effective_date:'||p_owner_effective_date,10);

    -- find the regular payment date for the owning action
    select regular_payment_date
      into l_owning_regular_payment_date
      from pay_payroll_actions      PACT,
           per_time_periods   PTP
     where PACT.payroll_action_id   = p_owner_payroll_action_id
       and PTP.time_period_id = PACT.time_period_id;

  IF SUBSTR(p_dimension_name,31,8) = 'USER-REG' THEN

    l_start_reset := INSTR(p_dimension_name,'RESET',30);

    l_start_dd_mon := SUBSTR(p_dimension_name, l_start_reset - 6, 5);

    l_frequency := FND_NUMBER.CANONICAL_TO_NUMBER(SUBSTR
                                     (p_dimension_name, l_start_reset + 6, 2));

    p_expiry_information := hr_gbbal.span_end(l_owning_regular_payment_date
                                              ,l_frequency
                                              ,l_start_dd_mon);
  END IF;

  hr_utility.set_location ('p_expiry_information:'||p_expiry_information,10);


end ASG_USER_EC;

/*------------------------------ ASG_PROC_TWO_YTD_EC ----------------------------*/
/*
   NAME
      ASG_PROC_TWO_YTD_EC - Assignment Processing Year to Date expiry check
                            for 2 yearly balance.
   DESCRIPTION
      Expiry checking code for the following:
            GB Assignment level Last Two Years to Date
   NOTES
      The associated dimension is expiry checked at payroll action level
*/
procedure ASG_PROC_TWO_YTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy    number     -- dimension expired flag.
) is
   l_tax_year_start  date;
   l_regular_payment_date  date;
   l_pay_year_start  date;
   l_tax_yyyy_start  number;
   l_user_payroll_id number;
begin
   --
   -- select the start of the financial year - if the owning action is
   -- before this or for a different payroll then its expired
   --
   -- If the tax year is even the the even dimension should expire
   -- else if the tax year is odd then the odd dimension should expire.
   -- Hence get the start of the tax year for this year or last year based
   -- on the logic given below
   --
   -- skutteti added _PER_TD_ODD_TWO_YTD into the if clause below as the
   -- same procedure is used for the expiry checking of the person level
   -- latest balances on 11/mar/02.
   --
   if p_dimension_name IN ('_ASG_TD_ODD_TWO_YTD','_PER_TD_ODD_TWO_YTD') then
   --
      Select to_date('06-04-' || to_char( fnd_number.canonical_to_number(
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
      into l_tax_year_start, l_user_payroll_id
      from per_time_periods    PTP,
           pay_payroll_actions BACT
      where BACT.payroll_action_id = p_user_payroll_action_id
      and   PTP.time_period_id = BACT.time_period_id;
   --
   elsif p_dimension_name in ('_ASG_TD_EVEN_TWO_YTD','_PER_TD_EVEN_TWO_YTD') then
   --
      Select to_date('06-04-' || to_char( fnd_number.canonical_to_number(
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
       into l_tax_year_start, l_user_payroll_id
       from per_time_periods    PTP,
            pay_payroll_actions BACT
       where BACT.payroll_action_id = p_user_payroll_action_id
       and   PTP.time_period_id = BACT.time_period_id;

   end if;
   --
   Select min(TP.start_date)
   into l_pay_year_start
   from   per_time_periods TP
   where    TP.payroll_id = l_user_payroll_id
   and    TP.regular_payment_date  >= l_tax_year_start;
   --
   --
   if p_owner_effective_date < l_pay_year_start then
      p_expiry_information := 1;
   else
      p_expiry_information := 0;
   end if;
   --
   --
end ASG_PROC_TWO_YTD_EC;
--
--For 115.12

procedure ASG_PROC_TWO_YTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_expiry_information         out nocopy    date     -- dimension expired flag.
) is

   l_tax_year_start  date;
   l_adjust number;

begin

  hr_utility.set_location ('IN ASG_PROC_TWO_YTD_EC',10);
  hr_utility.set_location ('p_dimension_name'||p_dimension_name,10);
  hr_utility.set_location ('p_owner_payroll_action_id'||p_owner_payroll_action_id,10);

   Select to_date('06-04-' || to_char( fnd_number.canonical_to_number(
          to_char( PTP.regular_payment_date,'YYYY'))
             +  decode(sign( PTP.regular_payment_date - to_date('06-04-'
                 || to_char(PTP.regular_payment_date,'YYYY'),'DD-MM-YYYY')),
           -1,-1,0)),'DD-MM-YYYY') finyear
   into l_tax_year_start
   from per_time_periods    PTP,
        pay_payroll_actions BACT
   where BACT.payroll_action_id = p_owner_payroll_action_id
   and   PTP.time_period_id = BACT.time_period_id;


   IF p_dimension_name IN ('_ASG_TD_EVEN_TWO_YTD','_PER_TD_EVEN_TWO_YTD')
   THEN
--
     IF mod(to_number(to_char(l_tax_year_start,'yyyy')),2) = 1 THEN
        -- The start of tax year is ODD, so add 2 to get the no action.
        l_adjust := 2;
     ELSE
        -- The start of tax year is in an EVEN year, must add 1
        l_adjust := 1;
     END IF;

  ELSIF p_dimension_name IN ('_ASG_TD_ODD_TWO_YTD','_PER_TD_ODD_TWO_YTD')
  THEN

     IF mod(to_number(to_char(l_tax_year_start,'yyyy')),2) = 0 THEN
        -- The start of tax year is EVEN, so add 2 to get the no action.
        l_adjust := 2;
     ELSE
        -- The start of tax year is in an ODD year, must add 1
        l_adjust := 1;
     END IF;
  --
  END IF;

  p_expiry_information := to_date('06-04-' || to_char(fnd_number.canonical_to_number(
                          to_char(l_tax_year_start,'yyyy')) + l_adjust)
                          ,'DD-MM-YYYY') - 1;

  hr_utility.set_location ('p_expiry_information:'||p_expiry_information,10);

end ASG_PROC_TWO_YTD_EC;



/*---------------------------- PER_TD_STAT_PTD_EC ----------------------------*/
/*
   NAME
      PER_TD_STAT_PTD_EC Person level TD Stat Expiry Checking
   DESCRIPTION
      Expiry checking code for the following:
        GB PERSON level TD Statutory Period Dimension
   NOTES
      The associated dimension is expiry checked at ASSIGNMENT Action level
      hence extra parameter.
*/
procedure PER_TD_STAT_PTD_EC
(
   p_owner_payroll_action_id    in     number,    -- run created balance.
   p_user_payroll_action_id     in     number,    -- current run.
   p_owner_assignment_action_id in     number,    -- assact created balance.
   p_user_assignment_action_id  in     number,    -- current assact..
   p_owner_effective_date       in     date,      -- eff date of balance.
   p_user_effective_date        in     date,      -- eff date of current run.
   p_dimension_name             in     varchar2,  -- balance dimension name.
   p_balance_context_values     in     varchar2,  -- list of context values
   p_expiry_information            out nocopy number     -- dimension expired flag.
) is
l_span_start date;
l_owning_regular_payment_date date;
--
begin
--
-- find the regular payment date for the owning action
--
        select  regular_payment_date
        into    l_owning_regular_payment_date
        from    pay_payroll_actions     PACT,
                per_time_periods        PTP
        where   PACT.payroll_action_id  = p_owner_payroll_action_id
        and     PTP.time_period_id      = PACT.time_period_id;
--
-- check that the beginning of the Person Level Period is before the
-- using action. This could be a different period size so call the
-- period span start with the using action id.
--
   l_span_start :=
       hr_gbnidir.PAYE_STAT_PERIOD_START_DATE(p_user_assignment_action_id);
--
   IF l_owning_regular_payment_date < l_span_start then
      p_expiry_information := 1;
   ELSE
      p_expiry_information := 0;
   END IF;
--
end PER_TD_STAT_PTD_EC;
-----------------------------------------------------------------------
-- Procedure: PROC_YTD_START
-- Description: used by YTD Dimensions for Run Level Balances only.
--    This procedure accepts a date and assignment action and other
--    params, and returns the start date of that Tax Year, depending
--    on the regular payment date of the payroll action (similar to
--    above expiry checks).
-----------------------------------------------------------------------
--
procedure proc_ytd_start(p_period_type     in            varchar2 default null,
                         p_effective_date  in            date     default null,
                         p_start_date         out nocopy date,
                         p_start_date_code in            varchar2 default null,
                         p_payroll_id      in            number,
                         p_bus_grp         in            number   default null,
                         p_action_type     in            varchar2 default null,
                         p_asg_action      in            number)
is
l_tax_year_start date;
begin
   select to_date('06-04-' || to_char( fnd_number.canonical_to_number(
          to_char( PTP.regular_payment_date,'YYYY'))
             +  decode(sign( PTP.regular_payment_date - to_date('06-04-'
                 || to_char(PTP.regular_payment_date,'YYYY'),'DD-MM-YYYY')),
           -1,-1,0)),'DD-MM-YYYY') finyear
   into l_tax_year_start
   from per_time_periods    PTP,
        pay_payroll_actions ppa,
        pay_assignment_actions paa
   where ppa.payroll_action_id = paa.payroll_action_id
   and   paa.assignment_action_id = p_asg_action
   and   ppa.payroll_id = p_payroll_id
   and   PTP.time_period_id = ppa.time_period_id;
--
  p_start_date := l_tax_year_start;
--
end proc_ytd_start;
----------------------------------------------------------------------
-- Procedure: PROC_ODD_YTD_START
-- Description: used by ODD_YTD Dimensions for Run Level Balances only.
--    This procedure accepts a date and assignment action and other
--    params, and returns the start date of the Last previous ODD
--    Tax Year, depending
--    on the regular payment date of the payroll action (similar to
--    above expiry checks). For 2 year balance dimensions.
-----------------------------------------------------------------------
--
procedure proc_odd_ytd_start(p_period_type     in            varchar2 default null,
                         p_effective_date  in            date     default null,
                         p_start_date         out nocopy date,
                         p_start_date_code in            varchar2 default null,
                         p_payroll_id      in            number,
                         p_bus_grp         in            number   default null,
                         p_action_type     in            varchar2 default null,
                         p_asg_action      in            number)
is
l_tax_year_start date;
l_odd_tax_year_start date;
l_odd_adjust number;
begin
   select to_date('06-04-' || to_char( fnd_number.canonical_to_number(
          to_char( PTP.regular_payment_date,'YYYY'))
             +  decode(sign( PTP.regular_payment_date - to_date('06-04-'
                 || to_char(PTP.regular_payment_date,'YYYY'),'DD-MM-YYYY')),
           -1,-1,0)),'DD-MM-YYYY') finyear
   into l_tax_year_start
   from per_time_periods    PTP,
        pay_payroll_actions ppa,
        pay_assignment_actions paa
   where ppa.payroll_action_id = paa.payroll_action_id
   and   paa.assignment_action_id = p_asg_action
   and   ppa.payroll_id = p_payroll_id
   and   PTP.time_period_id = ppa.time_period_id;
--
  IF mod(to_number(to_char(l_tax_year_start,'yyyy')),2) = 1 THEN
     -- The start of tax year is ODD, no action.
     l_odd_adjust := 0;
  ELSE
     -- The start of tax year is in an EVEN year, must subtract 1
     l_odd_adjust := 1;
  END IF;
  --
  l_odd_tax_year_start := to_date('06-04-' || to_char(fnd_number.canonical_to_number(
                          to_char(l_tax_year_start,'yyyy')) - l_odd_adjust)
                          ,'DD-MM-YYYY');
  p_start_date := l_odd_tax_year_start;
--
end proc_odd_ytd_start;
----------------------------------------------------------------------
-- Procedure: PROC_EVEN_YTD_START
-- Description: used by EVEN_YTD Dimensions for Run Level Balances only.
--    This procedure accepts a date and assignment action and other
--    params, and returns the start date of the Last previous EVEN
--    Tax Year, depending
--    on the regular payment date of the payroll action (similar to
--    above expiry checks). For 2 year balance dimensions.
-----------------------------------------------------------------------
--
procedure proc_even_ytd_start(p_period_type     in            varchar2 default null,
                         p_effective_date  in            date     default null,
                         p_start_date         out nocopy date,
                         p_start_date_code in            varchar2 default null,
                         p_payroll_id      in            number,
                         p_bus_grp         in            number   default null,
                         p_action_type     in            varchar2 default null,
                         p_asg_action      in            number)
is
l_tax_year_start date;
l_even_tax_year_start date;
l_even_adjust number;
begin
   select to_date('06-04-' || to_char( fnd_number.canonical_to_number(
          to_char( PTP.regular_payment_date,'YYYY'))
             +  decode(sign( PTP.regular_payment_date - to_date('06-04-'
                 || to_char(PTP.regular_payment_date,'YYYY'),'DD-MM-YYYY')),
           -1,-1,0)),'DD-MM-YYYY') finyear
   into l_tax_year_start
   from per_time_periods    PTP,
        pay_payroll_actions ppa,
        pay_assignment_actions paa
   where ppa.payroll_action_id = paa.payroll_action_id
   and   paa.assignment_action_id = p_asg_action
   and   ppa.payroll_id = p_payroll_id
   and   PTP.time_period_id = ppa.time_period_id;
--
  IF mod(to_number(to_char(l_tax_year_start,'yyyy')),2) = 0 THEN
     -- The start of tax year is EVEN, no action.
     l_even_adjust := 0;
  ELSE
     -- The start of tax year is in an ODD year, must subtract 1
     l_even_adjust := 1;
  END IF;
  --
  l_even_tax_year_start := to_date('06-04-' || to_char(fnd_number.canonical_to_number(
                          to_char(l_tax_year_start,'yyyy')) - l_even_adjust)
                          ,'DD-MM-YYYY');
  p_start_date := l_even_tax_year_start;
--
end proc_even_ytd_start;

--For 115.11
-----------------------------------------------------------------------
-- Procedure: PROC_PEN_YTD_START
-- Description: used by YTD Dimensions for Run Level Balances only.
--    This procedure accepts a date and assignment action and other
--    params, and returns the start date of that Pension Year, depending
--    on the regular payment date of the payroll action (similar to
--    above expiry checks).
-----------------------------------------------------------------------
--
procedure proc_pen_ytd_start(p_period_type     in            varchar2 default null,
                         p_effective_date  in            date     default null,
                         p_start_date         out nocopy date,
                         p_start_date_code in            varchar2 default null,
                         p_payroll_id      in            number,
                         p_bus_grp         in            number   default null,
                         p_action_type     in            varchar2 default null,
                         p_asg_action      in            number)
is
l_tax_year_start date;
begin
   select to_date('01-04-' || to_char( fnd_number.canonical_to_number(
          to_char( PTP.regular_payment_date,'YYYY'))
             +  decode(sign( PTP.regular_payment_date - to_date('01-04-'
                 || to_char(PTP.regular_payment_date,'YYYY'),'DD-MM-YYYY')),
           -1,-1,0)),'DD-MM-YYYY') finyear
   into l_tax_year_start
   from per_time_periods    PTP,
        pay_payroll_actions ppa,
        pay_assignment_actions paa
   where ppa.payroll_action_id = paa.payroll_action_id
   and   paa.assignment_action_id = p_asg_action
   and   ppa.payroll_id = p_payroll_id
   and   PTP.time_period_id = ppa.time_period_id;
--
  p_start_date := l_tax_year_start;
--
end proc_pen_ytd_start;

-----------------------------------------------------------------------
end pygbexc;

/
