--------------------------------------------------------
--  DDL for Package Body PAY_AU_EXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_EXC" as
/* $Header: pyauexch.pkb 120.4 2007/08/13 06:11:16 dduvvuri noship $ */
--
-- Change List
-- ----------
-- DATE        Name            Vers     Bug No    Description
-- -----------+---------------+--------+--------+-----------------------+
-- 24-NOV-1999 sgoggin          1.0                 Created
-- 29-Jul-2002 Ragovind         1.1     2123970     Added Code for Balance Adjument Process Enhancement.
-- 30-Jul-2002 Ragovind         1.2     2123970     Modified the SQL Statement and written a cursor.
-- 03-Dec-2002 Ragovind         1.3     2689226     Added NOCOPY to the functions pyauexc.asg_ptd_ec,
--                                                  pyauexc.asg_span_ec.
-- 22-Mar-2004 jkarouza         1.0     3083198     Renamed file to pyauexch.pkb and package name to
--                                                  PAY_AU_EXC
-- 07-Apr-2004 puchil           1.1     3075319     changed the function
--                                                  asg_span_ec to use effective
--                                                  date.
-- 21-Jun-2004 punmehta        115.2    3583020     Nulled the PTD expiry chekcing code
-- 21-Jun-2004 punmehta        115.3    3583020     Removed GSCC warnings
-- 09-Aug-2004 abhkumar        115.4    2610141     Modfied the code to support LE level balances
-- 30-Nov-2005 avenkatk        115.5    4351318     Introduced procedure fbt_ytd_start.
-- 19-Jul-2007 vamittal        115.6    6159013     Changed Expiry Checking Procedure for
--                                                  _ASG_LE_TD and _ASG_TD Dimension
-- 13-Aug-2007 dduvvuri        115.8    6159013     Added Change History

--                                                  Comments
-- -----------+---------------+--------+--------+-----------------------+
--
--
g_fin_year_start  varchar2(6);
g_fbt_year_start  varchar2(6);
g_cal_year_start  varchar2(6);
--
--
-- get offset of fbt year start with reference to calender year in months and days
l_fbtyr_months_offset NUMBER(2);
l_fbtyr_days_offset   NUMBER(2);

-------------------------------- next_period ---------------------------------------------------
--
-- NAME        : next_period
-- DESCRIPTION : Given a date and a payroll action id, returns the date after the
--               end of the containing payroll action id's pay period.

   FUNCTION next_period ( p_payroll_action_id in number,
                          p_given_date in date )
                                               RETURN date is
   l_next_to_end_date date := NULL;
   BEGIN
   /* Get the date next to the end date of the given period,
      having the payroll action id */
     SELECT PTP.end_date+1
       INTO l_next_to_end_date
       FROM per_time_periods ptp,
            pay_payroll_actions pact
      WHERE pact.payroll_action_id = p_payroll_action_id
        AND pact.payroll_id    = ptp.payroll_id
        AND p_given_date between ptp.start_date and ptp.end_date;

     return l_next_to_end_date;

   END next_period;
------------------------------- next_month -----------------------------------------------------
--
-- NAME        : next_month
-- DESCRIPTION : Given a date returns the next month's start date.

   FUNCTION next_month (p_given_date in date )
                  RETURN date is
   BEGIN
   /* Return the next month's start date */
      RETURN trunc(add_months(p_given_date,1),'MM');
   END next_month;

-------------------------------  next_quarter --------------------------------------------------
--
-- NAME 	   : next_quarter
-- DESCRIPTION : Given a date returns the next quarter's start date.

   FUNCTION next_quarter (p_given_date in date)
                   RETURN date is
   BEGIN
   /* Return the next quarter's start date */
      RETURN trunc(add_months(p_given_date,3),'Q');
   END next_quarter;

------------------------------  next_year -----------------------------------------------------
--
-- NAME 	   : next_year
-- DESCRIPTION : Given a date returns the next year's start date.

   FUNCTION next_year (p_given_date in date)
                  RETURN date is
   BEGIN
   /* Return the next year's start date */
      RETURN trunc(add_months(p_given_date,12),'Y');
   END next_year;

------------------------------- next_fin_quarter -------------------------------------------
--
-- NAME 	   : next_fin_quarter
-- DESCRIPTION : Given a date returns the next fiscal quarter's start date.

   FUNCTION next_fin_quarter (p_beg_of_the_year in date, p_given_date in date )
                  RETURN date is

      -- get offset of fin year start with reference to calender year in months and days
      l_finyr_months_offset NUMBER(2);
      l_finyr_days_offset   NUMBER(2);

   BEGIN
      l_finyr_months_offset := to_char(p_beg_of_the_year,'MM') - 1;
      l_finyr_days_offset   := to_char(p_beg_of_the_year,'DD') - 1;

   /* Return the next fiscal quarter's start date */
      RETURN (add_months(next_quarter(add_months(p_given_date,-l_finyr_months_offset)
                                  -l_finyr_days_offset),l_finyr_months_offset)+ l_finyr_days_offset);
   END next_fin_quarter;

------------------------------- next_fin_year -------------------------------------------
--
-- NAME 	   : next_fin_year
-- DESCRIPTION : Given a date returns the next fiscal quarter's start date.

   FUNCTION next_fin_year ( p_beg_of_the_year in date, p_given_date in date )
                  RETURN date is

      -- get offset of fin year start with reference to calender year in months and days
      l_finyr_months_offset NUMBER(2);
      l_finyr_days_offset   NUMBER(2);
   BEGIN
      l_finyr_months_offset := to_char(p_beg_of_the_year,'MM') - 1;
      l_finyr_days_offset   := to_char(p_beg_of_the_year,'DD') - 1;

   /* Return the next fiscal quarter's start date */
      RETURN (add_months(next_year(add_months(p_given_date,-l_finyr_months_offset)
                                  -l_finyr_days_offset),l_finyr_months_offset)+ l_finyr_days_offset);
   END next_fin_year;

------------------------------- next_fbt_quarter -----------------------------------------
--
-- NAME 	    : next_fbt_quarter
-- DESCRIPTION  : Given a start of fbt year and a date returns the next fbt quarter's start date.

   FUNCTION next_fbt_quarter ( p_given_date in date )
                     RETURN date is

   BEGIN
   /* Return the next fbt quarter's start date */
      RETURN (add_months(next_quarter(add_months(p_given_date,-l_fbtyr_months_offset)
                                   -l_fbtyr_days_offset),l_fbtyr_months_offset)+ l_fbtyr_days_offset);
   END next_fbt_quarter;

------------------------------- next_fbt_year -----------------------------------------
--
-- NAME 	    : next_fbt_year
-- DESCRIPTION  : Given a start of fbt year and a date returns the next fbt year's start date.

   FUNCTION next_fbt_year ( p_given_date in date )
                     RETURN date is

   BEGIN
   /* Return the next fbt quarter's start date */
      RETURN (add_months(next_year(add_months(p_given_date,-l_fbtyr_months_offset)
                                   -l_fbtyr_days_offset),l_fbtyr_months_offset)+l_fbtyr_days_offset);

   END next_fbt_year;

-------------------------------- asg_ptd_ec ----------------------------------------------------
--
--  name
--     asg_ptd_ec - assignment processing period to date expiry check.
--  description
--     expiry checking code for the following:
--       au assignment-level process period to date balance dimension
--  notes
--     the associated dimension is expiry checked at payroll action level
--
procedure asg_ptd_ec
	(   p_owner_payroll_action_id    in     number      -- run created balance.
	,   p_user_payroll_action_id     in     number      -- current run.
	,   p_owner_assignment_action_id in     number      -- assact created balance.
	,   p_user_assignment_action_id  in     number      -- current assact..
	,   p_owner_effective_date       in     date        -- eff date of balance.
	,   p_user_effective_date        in     date        -- eff date of current run.
	,   p_dimension_name             in     varchar2    -- balance dimension name.
	,   p_expiry_information         out NOCOPY number      -- dimension expired flag.
	) is

 --
	cursor csr_time
	  ( p_payroll_action_id       number
	  , p_assignment_action_id    number
	  , p_effective_date          date) is
	  select  ptp.time_period_id
	  from    pay_payroll_actions         act
	  ,       per_time_periods            ptp
	  where   payroll_action_id           = p_payroll_action_id
				 and act.date_earned         between ptp.start_date and ptp.end_date
				 and act.payroll_id          = ptp.payroll_id
				 and act.effective_date      = p_effective_date;
	  --
	  l_user_time_period_id     number;
	  l_owner_time_period_id    number;
	  --
begin
  --Bug3583020 - Code removed as PTD balance values are now not stored in lates balances.
  null;
end asg_ptd_ec;
--
-------------------------------- asg_span_ec -----------------------------------------------
--
--  name
--     asg_span_ec - assignment processing year to date expiry check.
--  description
--     expiry checking code for the following:
--       au assignment-level process year to date balance dimension
--  notes
--     the associated dimension is expiry checked at payroll action level
--
-- Bug 3075319 - Changed the function to use effective date.
-- Bug 6159013 - Added Expiry Checking Code for _ASG_TD and _ASG_LE_TD
--               Dimensions

procedure asg_span_ec
	(   p_owner_payroll_action_id    in     number    -- run created balance.
	,   p_user_payroll_action_id     in     number    -- current run.
	,   p_owner_assignment_action_id in     number    -- assact created balance.
	,   p_user_assignment_action_id  in     number    -- current assact.
	,   p_owner_effective_date       in     date      -- eff date of balance.
	,   p_user_effective_date        in     date      -- eff date of current run.
	,   p_dimension_name             in     varchar2  -- balance dimension name.
	,   p_expiry_information         out NOCOPY number    -- dimension expired flag.
	) is
	  --
	  cursor  csr_get_business_group is
	  select  business_group_id
	  from    pay_assignment_actions_v
	  where   assignment_action_id = p_user_assignment_action_id;

	  --
	  l_user_span_start     date;
	  l_owner_start         date;
	  l_date_dd_mm          varchar2(11);
	  l_fy_user_span_start  date;
	  l_frequency           number;
	  l_dimension_name      pay_balance_dimensions.dimension_name%type;
	  l_business_group_id   pay_payroll_actions.business_group_id%type;
	  --
begin
  hr_utility.set_location('Entering: asg_span_ec', 1);
  l_dimension_name  := upper(p_dimension_name);
  -- Get the year component of the input date
  hr_utility.trace(' asg_span_ec: p_owner_payroll_action_id='||to_char(p_owner_payroll_action_id));
  hr_utility.trace(' asg_span_ec: p_user_payroll_action_id='||to_char(p_user_payroll_action_id));
  hr_utility.trace(' asg_span_ec: p_owner_assignment_action_id='||to_char(p_owner_assignment_action_id));
  hr_utility.trace(' asg_span_ec: p_user_assignment_action_id='||to_char(p_user_assignment_action_id));
  hr_utility.trace(' asg_span_ec: p_dimension_name ='||p_dimension_name );
  hr_utility.trace(' asg_span_ec: p_owner_effective_date='||to_char(p_owner_effective_date,'DD-MON-YYYY'));
  hr_utility.trace(' asg_span_ec: p_user_effective_date='||to_char(p_user_effective_date,'DD-MON-YYYY'));

  --
  -- select the start span for the using action.
  -- if the owning action associated with the latest balance, is
  -- before the start of the span for the using effective date
  -- then it has expired.
  --
/*6159013 These Two Dimension Never Expires hence Returning 0 as
expiry Date*/
  IF p_dimension_name in ('_ASG_TD','_ASG_LE_TD') THEN
     p_expiry_information := 0;
     RETURN;
-- ASG_YTD
  elsif lower(l_dimension_name) in ('_asg_ytd','_asg_le_ytd') then --2610141
    --
    l_frequency := 1;
    l_date_dd_mm := g_fin_year_start;
  --
  -- ASG_FY_YTD ASG_FY_QTD
  elsif lower(l_dimension_name) in ('_asg_fy_ytd','_asg_fy_qtd','_asg_le_fy_ytd', '_asg_le_fy_qtd') then --2610141
    -- Get the business group
    open csr_get_business_group;
    fetch csr_get_business_group into l_business_group_id;
    close csr_get_business_group;
    -- Lookup the fiscal start date for this business group
    l_fy_user_span_start := hr_au_routes.get_fiscal_date( l_business_group_id);
    -- Check if its a yearly or quarterly balance
    if lower(l_dimension_name) in ('_asg_fy_ytd','_asg_le_fy_ytd') then --2610141
      l_frequency := 1;
    else
      l_frequency := 4;
    end if;
    --
    l_date_dd_mm := to_char(l_fy_user_span_start,'dd-mm-');
  --
  -- ASG_MTD
  elsif lower(l_dimension_name) in ('_asg_mtd','_asg_le_mtd') then --2610141
    --
    l_frequency := 12;
    l_date_dd_mm := g_cal_YEAR_START;
  --
  -- ASG_QTD
  elsif lower(l_dimension_name) in ('_asg_qtd','_asg_le_qtd') then --2610141
    --
    l_frequency := 4;
    l_date_dd_mm := g_cal_YEAR_START;
  --
  -- ASG_CAL_YTD
  elsif lower(l_dimension_name) in ('_asg_cal_ytd','_asg_le_cal_ytd') then --2610141
    l_frequency := 1;
    l_date_dd_mm := g_cal_YEAR_START;
  --
  -- ASG_FBT_QTD
  elsif lower(l_dimension_name) = '_asg_fbt_qtd' then
    --
    l_frequency := 4;
    l_date_dd_mm := g_fbt_YEAR_START;
  --
  -- ASG_FBT_YTD
  elsif lower(l_dimension_name) in ('_asg_fbt_ytd','_asg_le_fbt_ytd') then --2610141
    --
    l_frequency := 1;
    l_date_dd_mm := g_fbt_YEAR_START;
  --
  end if;
  --
  -- Bug 3075319 - Changed the logic to use the effective_date
  l_user_span_start := hr_au_routes.span_start( p_user_effective_date
                                              , l_frequency
                                              , l_date_dd_mm);
  --
  hr_utility.trace(' asg_span_ec: l_user_span_start='||to_char(l_user_span_start,'DD-MON-YYYY'));
  --
  if p_owner_effective_date < l_user_span_start then
    p_expiry_information      := 1;
    hr_utility.set_location('  asg_span_ec: EXPIRED', 10);
  else
    p_expiry_information      := 0;
    hr_utility.set_location('  asg_span_ec: NOT EXPIRED', 10);
  end if;
  --
end asg_span_ec;

--
-------------------------------- asg_span_ec -----------------------------------------------
-------------------Over Loaded function for balance adjustment process----------------------
--
--  NAME           :  asg_span_ec
--  DESCRIPTION    :  Expiry checking code for the following:
--                    AU assignment-level process year to date balance dimension
--  NOTES          :  The associated dimension is expiry checked at payroll action level
--

PROCEDURE asg_span_ec
	(   p_owner_payroll_action_id    in     number    -- run created balance.
	,   p_user_payroll_action_id     in     number    -- current run.
	,   p_owner_assignment_action_id in     number    -- assact created balance.
	,   p_user_assignment_action_id  in     number    -- current assact.
	,   p_owner_effective_date       in     date      -- eff date of balance.
	,   p_user_effective_date        in     date      -- eff date of current run.
	,   p_dimension_name             in     varchar2  -- balance dimension name.
	,   p_expiry_information         out NOCOPY   date      -- dimension expired date.
	) is

      l_beg_of_fiscal_year date;
      l_user_le_start_date   date;
      cursor get_beg_of_fiscal_year(c_owner_payroll_action_id number)
       is
        SELECT fnd_date.canonical_to_date(org_information11)
        FROM   pay_payroll_actions PACT,
               hr_organization_information HOI
        WHERE  UPPER(HOI.org_information_context) = 'BUSINESS GROUP INFORMATION'
        AND    HOI.organization_id = PACT.business_group_id
        AND    PACT.payroll_action_id = c_owner_payroll_action_id;


BEGIN

  hr_utility.trace('p_owner_payroll_action_id  :'||p_owner_payroll_action_id);
  hr_utility.trace('p_user_payroll_action_id :'||p_user_payroll_action_id);
  hr_utility.trace('p_owner_assignment_action_id :' ||p_owner_assignment_action_id);
  hr_utility.trace('p_user_assignment_action_id  :' ||p_user_assignment_action_id  );
  hr_utility.trace('p_owner_effective_date       :' ||p_owner_effective_date       );
  hr_utility.trace('p_user_effective_date        :' ||p_user_effective_date        );
  hr_utility.trace('p_dimension_name             :' ||p_dimension_name             );

  /*6159013 These Two Dimension Never Expires hence Returning 31-DEC-4712 as expiry Date*/
  IF p_dimension_name in ('_ASG_TD','_ASG_LE_TD') THEN
     p_expiry_information := fnd_date.canonical_to_date('4712/12/31');

 /* These balance dimensions never expire and hence considered as special cases
     return the p_owner_effective_date for these cases */
  ELSIF p_dimension_name in ('_ASG_RUN','_ASG_LE_RUN') THEN --2610141
     p_expiry_information := p_owner_effective_date;
     hr_utility.trace('p_expiry_information'||p_dimension_name||':'||p_expiry_information);

  /* The balance dimension '_ASG_MTD' is checking for feed using the normal calendar year
     so, we use next_month function to get the expiry date of the dimension */
  ELSIF p_dimension_name in ('_ASG_MTD','_ASG_LE_MTD') THEN --2610141
     p_expiry_information := next_month(p_owner_effective_date)-1;
     hr_utility.trace('p_expiry_information'||p_dimension_name||':'||p_expiry_information);

  /* The balance dimension '_ASG_QTD' is checking for feed using the normal calendar year
     so, we use next_quarter function to get the expiry date of the dimension */
  ELSIF p_dimension_name in ('_ASG_QTD','_ASG_LE_QTD') THEN --2610141
     p_expiry_information := next_quarter(p_owner_effective_date)-1;
     hr_utility.trace('p_expiry_information'||p_dimension_name||':'||p_expiry_information);

  /* The balance dimension '_ASG_CAL_YTD' is checking for feed using the normal calendar year
     so, we use next_year function to get the expiry date of the dimension */
  ELSIF p_dimension_name in ('_ASG_CAL_YTD','_ASG_LE_CAL_YTD') THEN --2610141
     p_expiry_information := next_year(p_owner_effective_date)-1;
     hr_utility.trace('p_expiry_information'||p_dimension_name||':'||p_expiry_information);

  /* The balance dimension '_ASG_YTD' is checking for feed using the financial year
     so, we use next_fin_year function to get the expiry date of the dimension */
  ELSIF p_dimension_name in ('_ASG_YTD','_ASG_LE_YTD') THEN --2610141
     p_expiry_information := next_fin_year(to_date(g_fin_year_start,'DD-MM-'), p_owner_effective_date)-1;
     hr_utility.trace('p_expiry_information'||p_dimension_name||':'||p_expiry_information);

  /* The balance dimension '_ASG_FY_QTD' is checking for feed using the financial year
     so, we use next_fin_quarter function to get the expiry date of the dimension */
  ELSIF p_dimension_name in ('_ASG_FY_QTD','_ASG_LE_FY_QTD') THEN --2610141
     open get_beg_of_fiscal_year(p_owner_payroll_action_id);
     fetch get_beg_of_fiscal_year into l_beg_of_fiscal_year;
     close get_beg_of_fiscal_year;

     hr_utility.trace('l_beg_of_fiscal_year :'||l_beg_of_fiscal_year);
     p_expiry_information := next_fin_quarter(l_beg_of_fiscal_year, p_owner_effective_date)-1;
     hr_utility.trace('p_expiry_information'||p_dimension_name||':'||p_expiry_information);

  /* The balance dimension '_ASG_FY_YTD' is checking for feed using the financial year
     so, we use next_fin_year function to get the expiry date of the dimension */
  ELSIF p_dimension_name in ('_ASG_FY_YTD','_ASG_LE_FY_YTD') THEN --2610141
     open get_beg_of_fiscal_year(p_owner_payroll_action_id);
     fetch get_beg_of_fiscal_year into l_beg_of_fiscal_year;
     close get_beg_of_fiscal_year;

     hr_utility.trace('l_beg_of_fiscal_year :'||l_beg_of_fiscal_year);
     p_expiry_information := next_fin_year(l_beg_of_fiscal_year, p_owner_effective_date)-1;
     hr_utility.trace('p_expiry_information'||p_dimension_name||':'||p_expiry_information);

  /* The balance dimension '_ASG_FBT_YTD' is checking for feed using the fbt year
     so, we use next_fbt_year function to get the expiry date of the dimension */
  ELSIF p_dimension_name in ('_ASG_FBT_YTD','_ASG_LE_FBT_YTD') THEN --2610141
     p_expiry_information := next_fbt_year(p_owner_effective_date)-1;
     hr_utility.trace('p_expiry_information'||p_dimension_name||':'||p_expiry_information);

  ELSE
     hr_utility.set_message(801, 'NO_EXP_CHECK_FOR_THIS_DIMENSION');
     hr_utility.raise_error;
  END IF;


END asg_span_ec;

-------------------------------- asg_ptd_ec ----------------------------------------------------
-------------------Over Loaded function for balance adjustment process--------------------------
--
--  NAME        :  asg_ptd_ec
--  DESCRIPTION :  Expiry checking code for the following:
--                 AU assignment-level process period to date balance dimension
--  NOTES       :  The associated dimension is expiry checked at payroll action level
--
PROCEDURE asg_ptd_ec
	(   p_owner_payroll_action_id    in     number      -- run created balance.
	,   p_user_payroll_action_id     in     number      -- current run.
	,   p_owner_assignment_action_id in     number      -- assact created balance.
	,   p_user_assignment_action_id  in     number      -- current assact..
	,   p_owner_effective_date       in     date        -- eff date of balance.
	,   p_user_effective_date        in     date        -- eff date of current run.
	,   p_dimension_name             in     varchar2    -- balance dimension name.
	,   p_expiry_information         out NOCOPY   date        -- dimension expired flag.
	) is
BEGIN
  --Bug3583020 - Code removed as PTD balance values are now not stored in lates balances.
  null;

END asg_ptd_ec;

/* Bug 4351318 - Procedure introduced */
/* -------------------------------- fbt_ytd_start ------------------------------------------
-------------------Procedure to return the START_DATE for FBT dimension--------------------
--  NAME           : fbt_ytd_start
--  DESCRIPTION    : This procedure finds the start date based on the    --
--                   effective date for the dimension name _ASG_LE_FBT_YTD
--  NOTES          : The associated dimension is expiry checked for Run balances using the
--                   Start Date returned.
*/
PROCEDURE fbt_ytd_start( p_effective_date  IN  DATE     ,
                         p_start_date      OUT NOCOPY DATE,
                         p_start_date_code IN  VARCHAR2 DEFAULT NULL,
                         p_payroll_id      IN  NUMBER   DEFAULT NULL,
                         p_bus_grp         IN  NUMBER   DEFAULT NULL,
                         p_action_type     IN  VARCHAR2 DEFAULT NULL,
                         p_asg_action      IN  NUMBER   DEFAULT NULL)
AS

l_year NUMBER(4);

BEGIN
  p_start_date :=NULL;
  l_year := TO_NUMBER (TO_CHAR(p_effective_date,'YYYY'));

  IF p_effective_date >= TO_DATE('01-04-'||TO_CHAR(l_year),'DD-MM-YYYY') THEN
     p_start_date:=TO_DATE('01-04-'||TO_CHAR(l_year),'DD-MM-YYYY');
  ELSE
     p_start_date:=TO_DATE('01-04-'||TO_CHAR(l_year-1),'DD-MM-YYYY');
  END IF;
END fbt_ytd_start;

begin
	g_fin_year_start  := '01-07-';
	g_fbt_year_start  := '01-04-';
	g_cal_year_start  := '01-01-';
	--
	-- get offset of fbt year start with reference to calender year in months and days
	l_fbtyr_months_offset := to_char(to_date(g_fbt_year_start,'DD-MM-'), 'MM') - 1;
	l_fbtyr_days_offset   := to_char(to_date(g_fbt_year_start,'DD-MM-'), 'DD') - 1;
end pay_au_exc;


/
