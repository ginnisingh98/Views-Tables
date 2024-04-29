--------------------------------------------------------
--  DDL for Package Body FII_TIME_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_TIME_API" AS
/* $Header: FIICAT1B.pls 120.19 2006/01/25 19:06:19 vkazhipu noship $  */

-- -------------------------------------------------------------------
-- Name: global_start_date
-- Desc: Returns the global start date of the
--       enterprise calendar.  Info is cached after initial access
-- Output: Global Start Date of the enterprise year.
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function global_start_date return DATE is
  l_date        date;
begin
  select min(start_date)
  into l_date
  from fii_time_ent_year;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: global_end_date
-- Desc: Returns the global end date of the
--       enterprise calendar.  Info is cached after initial access
-- Output: Global End Date of the enterprise year.
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function global_end_date return DATE is
  l_date        date;
begin
  select max(end_date)
  into l_date
  from fii_time_ent_year;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: ent_sd_lyr_beg
-- Desc: Returns the same day last year, count from year start date in the
--       enterprise calendar.  Info is cached after initial access
-- Output: Same date(as the pass in date) in previous enterprise year.
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_sd_lyr_beg(as_of_date date) return DATE is
  l_date      date;
  l_timespan  number;
  l_curr_year number;
  l_as_of_date date;
begin

  l_as_of_date := trunc(as_of_date);
  select l_as_of_date-start_date, sequence
  into l_timespan, l_curr_year
  from fii_time_ent_year
  where l_as_of_date between start_date and end_date;

  select start_date+l_timespan
  into l_date
  from fii_time_ent_year
  where sequence=l_curr_year-1;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: ent_sd_lyr_end
-- Desc: Returns the same day last year, count from year end date in the
--       enterprise calendar.  Info is cached after initial access
-- Output: Same date(as the pass in date) in previous enterprise year.
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_sd_lyr_end(as_of_date date) return DATE is
  l_date      date;
  l_timespan  number;
  l_curr_year number;
  l_as_of_date date;
begin

  l_as_of_date := trunc(as_of_date);
  select end_date-l_as_of_date, sequence
  into l_timespan, l_curr_year
  from fii_time_ent_year
  where l_as_of_date between start_date and end_date;

  select greatest(start_date, end_date-l_timespan)
  into l_date
  from fii_time_ent_year
  where sequence=l_curr_year-1;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: ent_sd_lysqtr_beg
-- Desc: Returns the same day last year same quarter, count from quarter start
--       date in the enterprise calendar.  Info is cached after initial access
-- Output: Same date(as the pass in date) same quarter in previous enterprise year.
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_sd_lysqtr_beg(as_of_date date) return DATE is
  l_date      date;
  l_timespan  number;
  l_curr_qtr  number;
  l_curr_year number;
  l_as_of_date date;
begin
  l_as_of_date := trunc(as_of_date);
  select l_as_of_date-start_date, sequence, ent_year_id
  into l_timespan, l_curr_qtr, l_curr_year
  from fii_time_ent_qtr
  where l_as_of_date between start_date and end_date;

  select least(end_date, start_date+l_timespan)
  into l_date
  from fii_time_ent_qtr
  where sequence=l_curr_qtr
  and ent_year_id=l_curr_year-1;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: ent_sd_lysqtr_end
-- Desc: Returns the same day last year same quarter, count from quarter end
--       date in the enterprise calendar.  Info is cached after initial access
-- Output: Same date(as the pass in date) same quarter in previous enterprise year.
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_sd_lysqtr_end(as_of_date date) return DATE is
  l_date      date;
  l_timespan  number;
  l_curr_qtr  number;
  l_curr_year number;
  l_as_of_date date;
begin
  l_as_of_date := trunc(as_of_date);
  select end_date-l_as_of_date, sequence, ent_year_id
  into l_timespan, l_curr_qtr, l_curr_year
  from fii_time_ent_qtr
  where l_as_of_date between start_date and end_date;

  select greatest(start_date, end_date-l_timespan)
  into l_date
  from fii_time_ent_qtr
  where sequence=l_curr_qtr
  and ent_year_id=l_curr_year-1;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: ent_sd_pqtr_beg
-- Desc: Returns the same day prior quarter, count from quarter start
--       date in the enterprise calendar.  Info is cached after initial access
-- Output: Same date(as the pass in date) in prior enterprise quarter.
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_sd_pqtr_beg(as_of_date date) return DATE is
  l_date      date;
  l_timespan  number;
  l_curr_qtr  number;
  l_curr_year number;
  l_as_of_date date;
begin
  l_as_of_date := trunc(as_of_date);
  select l_as_of_date-start_date, sequence, ent_year_id
  into l_timespan, l_curr_qtr, l_curr_year
  from fii_time_ent_qtr
  where l_as_of_date between start_date and end_date;

  if l_curr_qtr=1 then
    select least(end_date, start_date+l_timespan)
    into l_date
    from fii_time_ent_qtr
    where sequence=4
    and ent_year_id=l_curr_year-1;
  else
    select least(end_date, start_date+l_timespan)
    into l_date
    from fii_time_ent_qtr
    where sequence=l_curr_qtr-1
    and ent_year_id=l_curr_year;
  end if;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: ent_sd_pqtr_end
-- Desc: Returns the same day prior quarter, count from quarter end date
--       in the enterprise calendar.  Info is cached after initial access
-- Output: Same date(as the pass in date) in prior enterprise quarter.
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_sd_pqtr_end(as_of_date date) return DATE is
  l_date      date;
  l_timespan  number;
  l_curr_qtr  number;
  l_curr_year number;
  l_as_of_date date;
begin
  l_as_of_date := trunc(as_of_date);
  select end_date-l_as_of_date, sequence, ent_year_id
  into l_timespan, l_curr_qtr, l_curr_year
  from fii_time_ent_qtr
  where l_as_of_date between start_date and end_date;

  if l_curr_qtr=1 then
    select greatest(start_date, end_date-l_timespan)
    into l_date
    from fii_time_ent_qtr
    where sequence=4
    and ent_year_id=l_curr_year-1;
  else
    select greatest(start_date, end_date-l_timespan)
    into l_date
    from fii_time_ent_qtr
    where sequence=l_curr_qtr-1
    and ent_year_id=l_curr_year;
  end if;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: ent_sd_lysper_beg
-- Desc: Returns the same day last year same period, count from period start
--       date in the enterprise calendar.  Info is cached after initial access
-- Output: Same date(as the pass in date) same period in previous enterprise year.
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_sd_lysper_beg(as_of_date date) return DATE is
  l_date        date;
  l_timespan    number;
  l_curr_period number;
  l_curr_year   number;
  l_as_of_date date;
begin
  l_as_of_date := trunc(as_of_date);
  select l_as_of_date-p.start_date, p.sequence, p.ent_year_id
  into l_timespan, l_curr_period, l_curr_year
  from fii_time_ent_period p
  where l_as_of_date between p.start_date and p.end_date;

  select least(p.end_date, p.start_date+l_timespan)
  into l_date
  from fii_time_ent_period p
  where p.sequence=l_curr_period
  and p.ent_year_id=l_curr_year-1;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: ent_sd_lysper_end
-- Desc: Returns the same day last year same period, count from period end
--       date in the enterprise calendar.  Info is cached after initial access
-- Output: Same date(as the pass in date) same period in previous enterprise year.
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_sd_lysper_end(as_of_date date) return DATE is
  l_date        date;
  l_timespan    number;
  l_curr_period number;
  l_curr_year   number;
  l_as_of_date date;
begin
  l_as_of_date := trunc(as_of_date);
  select p.end_date-l_as_of_date, p.sequence, p.ent_year_id
  into l_timespan, l_curr_period, l_curr_year
  from fii_time_ent_period p
  where l_as_of_date between p.start_date and p.end_date;

  select greatest(p.start_date, p.end_date-l_timespan)
  into l_date
  from fii_time_ent_period p
  where p.sequence=l_curr_period
  and p.ent_year_id=l_curr_year-1;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: ent_sd_pper_beg
-- Desc: Returns the same day prior period, count from period start
--       date in the enterprise calendar.  Info is cached after initial access
-- Output: Same date(as the pass in date) in prior enterprise period.
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_sd_pper_beg(as_of_date date) return DATE is
  l_date        date;
  l_timespan    number;
  l_curr_period number;
  l_curr_year   number;
  l_as_of_date date;
  l_max_sequence number;
begin
  l_as_of_date := trunc(as_of_date);
  select l_as_of_date-p.start_date, p.sequence, p.ent_year_id
  into l_timespan, l_curr_period, l_curr_year
  from fii_time_ent_period p
  where l_as_of_date between p.start_date and p.end_date;

  if l_curr_period=1 then
    -- Bug 4002034
    select max(sequence) into l_max_sequence
    from fii_time_ent_period
    where ent_year_id = l_curr_year-1;

    select least(p.end_date, p.start_date+l_timespan)
    into l_date
    from fii_time_ent_period p
    where p.sequence=l_max_sequence
    and p.ent_year_id=l_curr_year-1;
  else
    select least(p.end_date, p.start_date+l_timespan)
    into l_date
    from fii_time_ent_period p
    where p.sequence=l_curr_period-1
    and p.ent_year_id=l_curr_year;
  end if;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: ent_sd_pper_end
-- Desc: Returns the same day prior period, count from period end date
--       in the enterprise calendar.  Info is cached after initial access
-- Output: Same date(as the pass in date) in prior enterprise period.
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_sd_pper_end(as_of_date date) return DATE is
  l_date        date;
  l_timespan    number;
  l_curr_period number;
  l_curr_year   number;
  l_as_of_date date;
  l_max_sequence number;
begin
  l_as_of_date := trunc(as_of_date);
  select p.end_date-l_as_of_date, p.sequence, p.ent_year_id
  into l_timespan, l_curr_period, l_curr_year
  from fii_time_ent_period p
  where l_as_of_date between p.start_date and p.end_date;

  if l_curr_period=1 then
    -- Bug 4002034
    select max(sequence) into l_max_sequence
    from fii_time_ent_period
    where ent_year_id = l_curr_year-1;

    select greatest(p.start_date, p.end_date-l_timespan)
    into l_date
    from fii_time_ent_period p
    where p.sequence=l_max_sequence
    and p.ent_year_id=l_curr_year-1;
  else
    select greatest(p.start_date, p.end_date-l_timespan)
    into l_date
    from fii_time_ent_period p
    where p.sequence=l_curr_period-1
    and p.ent_year_id=l_curr_year;
  end if;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: sd_lyswk
-- Desc: Returns the same day last year same week in the enterprise calendar.
--       Info is cached after initial access
-- Output: Same date(as the pass in date) same week in previous enterprise year.
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function sd_lyswk(as_of_date date) return DATE is
  l_date      date;
  l_timespan  number;
  l_curr_week number;
  l_curr_year number;
  l_as_of_date date;
  l_max_sequence number;
begin
  l_as_of_date := trunc(as_of_date);
  select l_as_of_date-w.start_date, w.sequence, p.year445_id
  into l_timespan, l_curr_week, l_curr_year
  from fii_time_week w, fii_time_p445 p
  where w.period445_id=p.period445_id
  and l_as_of_date between w.start_date and w.end_date;

  -- Bug 4099178. To find the maximum sequence of weeks in the
  -- current year.
  select max(w.sequence)
  into l_max_sequence
  from fii_time_week w, fii_time_p445 p
  where w.period445_id=p.period445_id
  and l_as_of_date between w.start_date and w.end_date;

  -- Bug 4099178. If current year has 53 weeks then look for previous years
  -- week 52, for current years week 52 look at week 51 .... for week 2 look at previous
  -- years week 1 and for week 1 look into week 1 of previous year.
  IF (l_max_sequence = 53) THEN
   IF (l_curr_week = 1) THEN
    -- If the sequence is 1 then look for the same week in the previous year
    select w.start_date+l_timespan
    into l_date
    from fii_time_week w, fii_time_p445 p
    where w.period445_id=p.period445_id
    and w.sequence=l_curr_week
    and p.year445_id=l_curr_year-1;

   ELSE
    -- If the sequence is between 2-53 then look for previous week in the previous year
    select w.start_date+l_timespan
    into l_date
    from fii_time_week w, fii_time_p445 p
    where w.period445_id=p.period445_id
    and w.sequence=l_curr_week - 1
    and p.year445_id=l_curr_year-1;

   END IF;
  ELSE
    -- When the maximum sequnce is not 53 then look for the same week in the previous year
    select w.start_date+l_timespan
    into l_date
    from fii_time_week w, fii_time_p445 p
    where w.period445_id=p.period445_id
    and w.sequence=l_curr_week
    and p.year445_id=l_curr_year-1;

   END IF;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: sd_pwk
-- Desc: Returns the same day prior week in the enterprise calendar.
--       Info is cached after initial access
-- Output: Same date(as the pass in date) in prior week.
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function sd_pwk(as_of_date date) return DATE is
  l_date      date;
  l_timespan  number;
  l_curr_week number;
  l_curr_year number;
  l_as_of_date date;
begin
  l_as_of_date := trunc(as_of_date);
  select l_as_of_date-w.start_date, w.sequence, p.year445_id
  into l_timespan, l_curr_week, l_curr_year
  from fii_time_week w, fii_time_p445 p
  where w.period445_id=p.period445_id
  and l_as_of_date between w.start_date and w.end_date;

  if l_curr_week=1 then
    select max(w.sequence)+1
    into l_curr_week
    from fii_time_week w, fii_time_p445 p
    where w.period445_id=p.period445_id
    and p.year445_id=l_curr_year-1;

    l_curr_year := l_curr_year-1;
  end if;

  select w.start_date+l_timespan
  into l_date
  from fii_time_week w, fii_time_p445 p
  where w.period445_id=p.period445_id
  and w.sequence=l_curr_week-1
  and p.year445_id=l_curr_year;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: ent_cyr_start
-- Desc: Returns current enterprise year start date.
--       Info is cached after initial access
-- Output: Current Enterprise year start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_cyr_start(as_of_date date) return DATE is
  l_date date;
  l_as_of_date date;
begin
  l_as_of_date := trunc(as_of_date);
  select start_date
  into l_date
  from fii_time_ent_year
  where l_as_of_date between start_date and end_date;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: ent_cyr_end
-- Desc: Returns current enterprise year end date.
--       Info is cached after initial access
-- Output: Current Enterprise year end date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_cyr_end(as_of_date date) return DATE is
  l_date date;
  l_as_of_date date;
begin
  l_as_of_date := trunc(as_of_date);
  select end_date
  into l_date
  from fii_time_ent_year
  where l_as_of_date between start_date and end_date;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: ent_pyr_start
-- Desc: Returns previous enterprise year start date.
--       Info is cached after initial access
-- Output: Previous Enterprise year start date
-- Error: If any sql errors occurs, an exception is raised except no data found
-- --------------------------------------------------------------------
Function ent_pyr_start(as_of_date date) return DATE is
  l_date date;
  l_as_of_date date;
begin
  l_as_of_date := trunc(as_of_date);
-- Bug fix 4696282: Changed to catch No Data Found exception and return
--                  01/01/1900
  BEGIN
    select start_date
    into l_date
    from fii_time_ent_year
    where sequence =
    (select sequence -1
     from fii_time_ent_year
     where l_as_of_date between start_date and end_date);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_date := TO_DATE('01/01/1900', 'MM/DD/YYYY');
  END;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: ent_pyr_end
-- Desc: Returns previous enterprise year end date.
--       Info is cached after initial access
-- Output: Previous Enterprise year end date
-- Error: If any sql errors occurs, an exception is raised except no data found
-- --------------------------------------------------------------------
Function ent_pyr_end(as_of_date date) return DATE is
  l_date date;
  l_as_of_date date;
begin
  l_as_of_date := trunc(as_of_date);
-- Bug fix 4696282: Changed to catch No Data Found exception and return
--                  01/01/1900
  BEGIN
    select end_date
    into l_date
    from fii_time_ent_year
    where sequence =
    (select sequence -1
     from fii_time_ent_year
     where l_as_of_date between start_date and end_date);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_date := TO_DATE('01/01/1900', 'MM/DD/YYYY');
  END;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: ent_cqtr_start
-- Desc: Returns current enterprise quarter start date.
--       Info is cached after initial access
-- Output: Current Enterprise quarter start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_cqtr_start(as_of_date date) return DATE is
  l_date date;
  l_as_of_date date;
begin
  l_as_of_date := trunc(as_of_date);
  select start_date
  into l_date
  from fii_time_ent_qtr
  where l_as_of_date between start_date and end_date;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: ent_cqtr_end
-- Desc: Returns current enterprise quarter end date.
--       Info is cached after initial access
-- Output: Current Enterprise quarter end date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_cqtr_end(as_of_date date) return DATE is
  l_date date;
  l_as_of_date date;
begin
  l_as_of_date := trunc(as_of_date);
  select end_date
  into l_date
  from fii_time_ent_qtr
  where l_as_of_date between start_date and end_date;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: ent_lysqtr_start
-- Desc: Returns start date of same enterprise quarter in previous year.
--       Info is cached after initial access
-- Output: Last year same Enterprise quarter start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_lysqtr_start(as_of_date date) return DATE is
  l_date      date;
  l_curr_qtr  number;
  l_curr_year number;
  l_as_of_date date;
begin
  l_as_of_date := trunc(as_of_date);
  select sequence, ent_year_id
  into l_curr_qtr, l_curr_year
  from fii_time_ent_qtr
  where l_as_of_date between start_date and end_date;

  select start_date
  into l_date
  from fii_time_ent_qtr
  where sequence=l_curr_qtr
  and ent_year_id=l_curr_year-1;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: ent_lysqtr_end
-- Desc: Returns end date of same enterprise quarter in previous year.
--       Info is cached after initial access
-- Output: Last year same Enterprise quarter end date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_lysqtr_end(as_of_date date) return DATE is
  l_date      date;
  l_curr_qtr  number;
  l_curr_year number;
  l_as_of_date date;
begin
  l_as_of_date := trunc(as_of_date);
  select sequence, ent_year_id
  into l_curr_qtr, l_curr_year
  from fii_time_ent_qtr
  where l_as_of_date between start_date and end_date;

  select end_date
  into l_date
  from fii_time_ent_qtr
  where sequence=l_curr_qtr
  and ent_year_id=l_curr_year-1;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: ent_pqtr_start
-- Desc: Returns previous enterprise quarter start date.
--       Info is cached after initial access
-- Output: Previous enterprise quarter start date
-- Error: If any sql errors occurs, an exception is raised except no data found
--        when querying previous quarter
-- --------------------------------------------------------------------
Function ent_pqtr_start(as_of_date date) return DATE is
  l_date      date;
  l_curr_qtr  number;
  l_curr_year number;
  l_as_of_date date;
begin
  l_as_of_date := trunc(as_of_date);
  select sequence, ent_year_id
  into l_curr_qtr, l_curr_year
  from fii_time_ent_qtr
  where l_as_of_date between start_date and end_date;

-- Bug fix 4696282: Changed to catch No Data Found exception and return
--                  01/01/1900
  BEGIN
    if l_curr_qtr=1 then
      select start_date
      into l_date
      from fii_time_ent_qtr
      where sequence=4
      and ent_year_id=l_curr_year-1;
    else
      select start_date
      into l_date
      from fii_time_ent_qtr
      where sequence=l_curr_qtr-1
      and ent_year_id=l_curr_year;
    end if;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_date := TO_DATE('01/01/1900', 'MM/DD/YYYY');
  END;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: ent_pqtr_end
-- Desc: Returns previous enterprise quarter end date.
--       Info is cached after initial access
-- Output: Previous enterprise quarter end date
-- Error: If any sql errors occurs, an exception is raised except no data found
--        when querying previous quarter
-- --------------------------------------------------------------------
Function ent_pqtr_end(as_of_date date) return DATE is
  l_date      date;
  l_curr_qtr  number;
  l_curr_year number;
  l_as_of_date date;
begin
  l_as_of_date := trunc(as_of_date);
  select sequence, ent_year_id
  into l_curr_qtr, l_curr_year
  from fii_time_ent_qtr
  where l_as_of_date between start_date and end_date;

-- Bug fix 4696282: Changed to catch No Data Found exception and return
--                  01/01/1900
  BEGIN
    if l_curr_qtr=1 then
      select end_date
      into l_date
      from fii_time_ent_qtr
      where sequence=4
      and ent_year_id=l_curr_year-1;
    else
      select end_date
      into l_date
      from fii_time_ent_qtr
      where sequence=l_curr_qtr-1
      and ent_year_id=l_curr_year;
    end if;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_date := TO_DATE('01/01/1900', 'MM/DD/YYYY');
  END;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: ent_cper_start
-- Desc: Returns current enterprise period start date.
--       Info is cached after initial access
-- Output: Current Enterprise period start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_cper_start(as_of_date date) return DATE is
  l_date date;
  l_as_of_date date;
begin
  l_as_of_date := trunc(as_of_date);
  select start_date
  into l_date
  from fii_time_ent_period
  where l_as_of_date between start_date and end_date;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: ent_cper_end
-- Desc: Returns current enterprise period end date.
--       Info is cached after initial access
-- Output: Current Enterprise period end date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_cper_end(as_of_date date) return DATE is
  l_date date;
  l_as_of_date date;
begin
  l_as_of_date := trunc(as_of_date);
  select end_date
  into l_date
  from fii_time_ent_period
  where l_as_of_date between start_date and end_date;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: ent_lysper_start
-- Desc: Returns start date of same enterprise period in previous year.
--       Info is cached after initial access
-- Output: Last year same Enterprise period start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_lysper_start(as_of_date date) return DATE is
  l_date        date;
  l_curr_period number;
  l_curr_year   number;
  l_as_of_date date;
begin
  l_as_of_date := trunc(as_of_date);
  select p.sequence, p.ent_year_id
  into l_curr_period, l_curr_year
  from fii_time_ent_period p
  where l_as_of_date between p.start_date and p.end_date;

  select p.start_date
  into l_date
  from fii_time_ent_period p
  where p.sequence=l_curr_period
  and p.ent_year_id=l_curr_year-1;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: ent_lysper_end
-- Desc: Returns end date of same enterprise period in previous year.
--       Info is cached after initial access
-- Output: Last year same Enterprise period end date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_lysper_end(as_of_date date) return DATE is
  l_date        date;
  l_curr_period number;
  l_curr_year   number;
  l_as_of_date date;
begin
  l_as_of_date := trunc(as_of_date);
  select p.sequence, p.ent_year_id
  into l_curr_period, l_curr_year
  from fii_time_ent_period p
  where l_as_of_date between p.start_date and p.end_date;

  select p.end_date
  into l_date
  from fii_time_ent_period p
  where p.sequence=l_curr_period
  and p.ent_year_id=l_curr_year-1;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: ent_pper_start
-- Desc: Returns previous enterprise period start date.
--       Info is cached after initial access
-- Output: Previous enterprise period start date
-- Error: If any sql errors occurs, an exception is raised except no data found
--        when querying previous period
-- --------------------------------------------------------------------
Function ent_pper_start(as_of_date date) return DATE is
  l_date        date;
  l_curr_period number;
  l_curr_year   number;
  l_as_of_date date;
  l_max_sequence number;
begin
  l_as_of_date := trunc(as_of_date);
  select p.sequence, p.ent_year_id
  into l_curr_period, l_curr_year
  from fii_time_ent_period p
  where l_as_of_date between p.start_date and p.end_date;

-- Bug fix 4696282: Changed to catch No Data Found exception and return
--                  01/01/1900
  BEGIN
    if l_curr_period=1 then
      -- Bug 4002034
      select max(sequence) into l_max_sequence
      from fii_time_ent_period
      where ent_year_id = l_curr_year-1;

      select p.start_date
      into l_date
      from fii_time_ent_period p
      where p.sequence=l_max_sequence
      and p.ent_year_id=l_curr_year-1;
    else
      select p.start_date
      into l_date
      from fii_time_ent_period p
      where p.sequence=l_curr_period-1
      and p.ent_year_id=l_curr_year;
    end if;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_date := TO_DATE('01/01/1900', 'MM/DD/YYYY');
  END;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: ent_pper_end
-- Desc: Returns previous enterprise period end date.
--       Info is cached after initial access
-- Output: Previous enterprise period end date
-- Error: If any sql errors occurs, an exception is raised except no data found
--        when querying previous period
-- --------------------------------------------------------------------
Function ent_pper_end(as_of_date date) return DATE is
  l_date        date;
  l_curr_period number;
  l_curr_year   number;
  l_as_of_date date;
  l_max_sequence number;
begin
  l_as_of_date := trunc(as_of_date);
  select p.sequence, p.ent_year_id
  into l_curr_period, l_curr_year
  from fii_time_ent_period p
  where l_as_of_date between p.start_date and p.end_date;

-- Bug fix 4696282: Changed to catch No Data Found exception and return
--                  01/01/1900
  BEGIN
    if l_curr_period=1 then
      -- Bug 4002034
      select max(sequence) into l_max_sequence
      from fii_time_ent_period
      where ent_year_id = l_curr_year-1;

      select p.end_date
      into l_date
      from fii_time_ent_period p
      where p.sequence=l_max_sequence
      and p.ent_year_id=l_curr_year-1;
    else
      select p.end_date
      into l_date
      from fii_time_ent_period p
      where p.sequence=l_curr_period-1
      and p.ent_year_id=l_curr_year;
    end if;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_date := TO_DATE('01/01/1900', 'MM/DD/YYYY');
  END;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: cwk_start
-- Desc: Returns current week start date.
--       Info is cached after initial access
-- Output: Current Week start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function cwk_start(as_of_date date) return DATE is
  l_date      date;
  l_as_of_date date;
begin
  l_as_of_date := trunc(as_of_date);
  select start_date
  into l_date
  from fii_time_week
  where l_as_of_date between start_date and end_date;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: cwk_end
-- Desc: Returns current week end date.
--       Info is cached after initial access
-- Output: Current Week end date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function cwk_end(as_of_date date) return DATE is
  l_date      date;
  l_as_of_date date;
begin
  l_as_of_date := trunc(as_of_date);
  select end_date
  into l_date
  from fii_time_week
  where l_as_of_date between start_date and end_date;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: lyswk_start
-- Desc: Returns start date of same week in previous year.
--       Info is cached after initial access
-- Output: Last year same week start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function lyswk_start(as_of_date date) return DATE is
  l_date      date;
  l_curr_week number;
  l_curr_year number;
  l_as_of_date date;
begin
  l_as_of_date := trunc(as_of_date);
  select w.sequence, p.year445_id
  into l_curr_week, l_curr_year
  from fii_time_week w, fii_time_p445 p
  where w.period445_id=p.period445_id
  and l_as_of_date between w.start_date and w.end_date;

  select w.start_date
  into l_date
  from fii_time_week w, fii_time_p445 p
  where w.period445_id=p.period445_id
  and w.sequence=l_curr_week
  and p.year445_id=l_curr_year-1;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: lyswk_end
-- Desc: Returns end date of same week in previous year.
--       Info is cached after initial access
-- Output: Last year same week end date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function lyswk_end(as_of_date date) return DATE is
  l_date      date;
  l_curr_week number;
  l_curr_year number;
  l_as_of_date date;
begin
  l_as_of_date := trunc(as_of_date);
  select w.sequence, p.year445_id
  into l_curr_week, l_curr_year
  from fii_time_week w, fii_time_p445 p
  where w.period445_id=p.period445_id
  and l_as_of_date between w.start_date and w.end_date;

  select w.end_date
  into l_date
  from fii_time_week w, fii_time_p445 p
  where w.period445_id=p.period445_id
  and w.sequence=l_curr_week
  and p.year445_id=l_curr_year-1;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: pwk_start
-- Desc: Returns previous week start date.
--       Info is cached after initial access
-- Output: Previous Week start date
-- Error: If any sql errors occurs, an exception is raised except no data found
--        when querying previous week
-- --------------------------------------------------------------------
Function pwk_start(as_of_date date) return DATE is
  l_date      date;
  l_curr_week number;
  l_curr_year number;
  l_as_of_date date;
begin
  l_as_of_date := trunc(as_of_date);
  select w.sequence, p.year445_id
  into l_curr_week, l_curr_year
  from fii_time_week w, fii_time_p445 p
  where w.period445_id=p.period445_id
  and l_as_of_date between w.start_date and w.end_date;

-- Bug fix 4696282: Changed to catch No Data Found exception and return
--                  01/01/1900
  BEGIN
    if l_curr_week=1 then
      select max(w.sequence)+1
      into l_curr_week
      from fii_time_week w, fii_time_p445 p
      where w.period445_id=p.period445_id
      and p.year445_id=l_curr_year-1;

      l_curr_year := l_curr_year-1;
    end if;

    select w.start_date
    into l_date
    from fii_time_week w, fii_time_p445 p
    where w.period445_id=p.period445_id
    and w.sequence=l_curr_week-1
    and p.year445_id=l_curr_year;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_date := TO_DATE('01/01/1900', 'MM/DD/YYYY');
  END;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: pwk_end
-- Desc: Returns previous week end date.
--       Info is cached after initial access
-- Output: Previous Week end date
-- Error: If any sql errors occurs, an exception is raised except no data found
--        when querying previous week
-- --------------------------------------------------------------------
Function pwk_end(as_of_date date) return DATE is
  l_date      date;
  l_curr_week number;
  l_curr_year number;
  l_as_of_date date;
begin
  l_as_of_date := trunc(as_of_date);
  select w.sequence, p.year445_id
  into l_curr_week, l_curr_year
  from fii_time_week w, fii_time_p445 p
  where w.period445_id=p.period445_id
  and l_as_of_date between w.start_date and w.end_date;

-- Bug fix 4696282: Changed to catch No Data Found exception and return
--                  01/01/1900
  BEGIN
    if l_curr_week=1 then
      select max(w.sequence)+1
      into l_curr_week
      from fii_time_week w, fii_time_p445 p
      where w.period445_id=p.period445_id
      and p.year445_id=l_curr_year-1;

      l_curr_year := l_curr_year-1;
    end if;

    select w.end_date
    into l_date
    from fii_time_week w, fii_time_p445 p
    where w.period445_id=p.period445_id
    and w.sequence=l_curr_week-1
    and p.year445_id=l_curr_year;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_date := TO_DATE('01/01/1900', 'MM/DD/YYYY');
  END;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: rmth_start
-- Desc: Returns rolling month start date.
--       Info is cached after initial access
-- Output: Rolling Month start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function rmth_start(as_of_date date) return DATE is
  l_date date;
  l_as_of_date date;
begin
  l_as_of_date := trunc(as_of_date);

    select l_as_of_date - 29
    into l_date
    from dual;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: rqtr_start
-- Desc: Returns rolling quarter start date.
--       Info is cached after initial access
-- Output: Rolling Quarter start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function rqtr_start(as_of_date date) return DATE is
  l_date date;
  l_as_of_date date;
begin
  l_as_of_date := trunc(as_of_date);

    select l_as_of_date - 89
    into l_date
    from dual;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: ryr_start
-- Desc: Returns rolling year start date.
--       Info is cached after initial access
-- Output: Rolling Year start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ryr_start(as_of_date date) return DATE is
  l_date date;
  l_as_of_date date;
begin
  l_as_of_date := trunc(as_of_date);

    select l_as_of_date - 364
    into l_date
    from dual;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: rwk_start
-- Desc: Returns rolling week start date.
--       Info is cached after initial access
-- Output: Rolling Week start date
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function rwk_start(as_of_date date) return DATE is
  l_date date;
  l_as_of_date date;
begin
  l_as_of_date := trunc(as_of_date);

    select l_as_of_date-6
    into l_date
    from dual;

  return l_date;
end;

-- -------------------------------------------------------------------
-- Name: day_left_in_qtr
-- Desc: Returns number of days left in a quarter in a specific format.
--       Info is cached after initial access
-- Output: Number of days left in a quarter. e.g. given 08-Apr-2002, it returns
--         Q4 FY02 Day: -54
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function day_left_in_qtr(as_of_date date) return varchar2 is
  l_day_left varchar2(240);
  l_qtr      varchar2(240);
  l_yr       varchar2(240);
  l_label    varchar2(4000);
  l_as_of_date date;
begin
  l_as_of_date := trunc(as_of_date);

  select to_char(ent_cqtr_end(l_as_of_date)-l_as_of_date)
  into l_day_left
  from dual;

  select sequence
  into l_qtr
  from fii_time_ent_qtr
  where l_as_of_date between start_date and end_date;

  select to_char(to_date(ent_year_id,'yyyy'),'yy')
  into l_yr
  from fii_time_ent_year
  where l_as_of_date between start_date and end_date;

  --R12 Uptake on new messages (VKAZHIPU)

  if (l_day_left = 1) then
   fnd_message.set_name('FII', 'FII_DATE_LABEL');
  else
   fnd_message.set_name('FII', 'FII_DATE_LABEL_PLURAL');
  end if;

  fnd_message.set_token('DAYS',l_day_left,FALSE);
  fnd_message.set_token('QUARTER_NUMBER',l_qtr,FALSE);
  fnd_message.set_token('YEAR_NUMBER',l_yr,FALSE);
  l_label := fnd_message.get;

  return l_label;
end;

-- -------------------------------------------------------------------
-- Name: ent_lysper_id
-- Desc: Returns ID of same enterprise period in previous year.
--       Info is cached after initial access
-- Output: Last year same Enterprise period id
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_lysper_id(id number) return NUMBER is
  l_id          number;
  l_curr_period number;
  l_curr_year   number;

begin

  select sequence, ent_year_id
  into l_curr_period, l_curr_year
  from fii_time_ent_period
  where ent_period_id=id;

  select ent_period_id
  into l_id
  from fii_time_ent_period
  where sequence=l_curr_period
  and ent_year_id=l_curr_year-1;

  return l_id;
end;

--====================================================================--

-- -------------------------------------------------------------------
-- Name: check_missing_date
-- Desc: Check if there is any missing date in the time dimension
--       for the range (via two input parameters): (from_date, to_date).
--       It returns 1 boolean: has_missing_date
--       It also prints out message in the output file if there's gap;
--       in particular, the minimum and maximum of these missing dates.
--       This procedure requires the setup of files and directory
--       for fnd_file.
-- Output: true/false
-- Error: If any sql error occurs, will report it to the log file;
--        and an exception is raised.
-- --------------------------------------------------------------------
procedure check_missing_date (p_from_date        IN  date,
                              p_to_date          IN  date,
                              p_has_missing_date OUT NOCOPY boolean) IS
   l_day                date;
   l_has_missing_date   boolean;
   l_min_missing_date   date;
   l_max_missing_date   date;
   l_count              number;
   l_from_date		date;
   l_to_date		date;

begin
     l_from_date := trunc(p_from_date);
     l_to_date := trunc(p_to_date);

     fnd_message.set_name('FII','FII_DBI_CHECK_TIME_GAPS');
     fnd_message.set_token('FROM_DATE', fnd_date.date_to_displayDT(l_from_date));
     fnd_message.set_token('TO_DATE',   fnd_date.date_to_displayDT(l_to_date));
     fnd_file.put_line(FND_FILE.OUTPUT, fnd_message.get);
     fnd_file.put_line(FND_FILE.OUTPUT, '');

-- handle NULL dates input
   if (p_from_date is NULL) then
    raise_application_error(-20000,'Error in input for check_missing_date: ' ||
                                   'from_date can not be NULL');
   end if;

  if (p_to_date is NULL) then
    raise_application_error(-20001,'Error in input for check_missing_date: ' ||
                                   'to_date can not be NULL');
  end if;
-----

   -- ---------------------------------------------------------
   -- Variable initialization
   -- ---------------------------------------------------------
   l_day              := l_from_date;
   l_has_missing_date := false;
   l_min_missing_date := l_to_date;    -- set to maximum first
   l_max_missing_date := l_from_date;  -- set to minimum first

   while l_day <= p_to_date loop

-- check if the current day is loaded
     select count(*) into l_count
     from   fii_time_day
     where  report_date = trunc(l_day);

     if l_count = 0 then  --this day is not loaded
      l_has_missing_date := true;
      l_min_missing_date := least    (l_min_missing_date, l_day);
      l_max_missing_date := greatest (l_max_missing_date, l_day);
    end if;

-- move to the next day
     l_day := l_day+1;
   end loop;

   p_has_missing_date := l_has_missing_date;
   if p_has_missing_date then
     fnd_message.set_name('FII','FII_DBI_TIME_HAS_GAPS');
     fnd_message.set_token('FROM_DATE',
                           fnd_date.date_to_displayDT(l_min_missing_date));
     fnd_message.set_token('TO_DATE',
                           fnd_date.date_to_displayDT(l_max_missing_date));
     fnd_file.put_line(FND_FILE.OUTPUT, fnd_message.get);
     fnd_file.put_line(FND_FILE.OUTPUT, '');
   else
     fnd_message.set_name('FII','FII_DBI_NO_TIME_GAPS');
     fnd_file.put_line(FND_FILE.OUTPUT, fnd_message.get);
     fnd_file.put_line(FND_FILE.OUTPUT, '');
   end if;

exception
 when others then
   fnd_file.put_line(FND_FILE.LOG, 'Error occurred in procedure: check_missing_date...');
   fnd_file.put_line(FND_FILE.LOG, sqlcode || ' : ' || sqlerrm);
   raise;
end check_missing_date;

-- -------------------------------------------------------------------
-- Name: check_missing_date (overload version)
-- Desc: Check if there is any missing date in the time dimension
--       for the range (via two input parameters): (from_date, to_date).
--       It returns three output parameters: has_missing_date,
--       min_missing_date, max_missing_date.
--       No log will be generated.
-- Error: If any sql error occurs, will report it to the log file;
--        and an exception is raised.
-- --------------------------------------------------------------------
Procedure check_missing_date (p_from_date        IN  date,
                              p_to_date          IN  date,
                              p_has_missing_date OUT NOCOPY boolean,
                              p_min_missing_date OUT NOCOPY date,
                              p_max_missing_date OUT NOCOPY date) IS

   l_from_date          date;
   l_to_date            date;
   l_day                date;
   l_has_missing_date   boolean;
   l_min_missing_date   date;
   l_max_missing_date   date;
   l_count              number;


begin

-- handle NULL dates input
  if (p_from_date is NULL) then
    raise_application_error(-20000,'Error in input for check_missing_date: ' ||
                                   'from_date can not be NULL');
  end if;

  if (p_to_date is NULL) then
    raise_application_error(-20001,'Error in input for check_missing_date: ' ||
                                   'to_date can not be NULL');
  end if;
-----

   -- ---------------------------------------------------------
   -- Variable initialization
   -- ---------------------------------------------------------
   --l_from_date        := p_from_date;
   --l_to_date          := p_to_date;
   l_from_date := trunc(p_from_date);
   l_to_date := trunc(p_to_date);
   l_day              := l_from_date;
   l_has_missing_date := false;
   l_min_missing_date := trunc(p_to_date);    -- set to maximum first
   l_max_missing_date := trunc(p_from_date);  -- set to minimum first

   while l_day <= l_to_date loop

-- check if the current day is loaded
     select count(*) into l_count
     from   fii_time_day
     where  report_date = trunc(l_day);

     if l_count = 0 then  --this day is not loaded
      l_has_missing_date := true;
      l_min_missing_date := least    (l_min_missing_date, l_day);
      l_max_missing_date := greatest (l_max_missing_date, l_day);
    end if;

-- move to the next day
     l_day := l_day+1;
   end loop;

   p_has_missing_date := l_has_missing_date;
   if p_has_missing_date then
     p_min_missing_date := l_min_missing_date;
     p_max_missing_date := l_max_missing_date;
   end if;

exception
 when others then
   fnd_file.put_line(FND_FILE.LOG, 'Error occurred in procedure: check_missing_date...');
   fnd_file.put_line(FND_FILE.LOG, sqlcode || ' : ' || sqlerrm);
   raise;
end check_missing_date;

-----------------------------------------------------------------------
----- Following 5 APIs are from PJI team

 -- -------------------------------------------------------------------
 -- Name: cal_sd_lyr_end
 -- Desc: Returns the same day last year, count from year end date in the
 --       financial calendar.  Info is cached after initial access
 -- Output: Same date(as the pass in date) in previous financial year.
 -- Error: If any sql errors occurs, an exception is raised.
 -- --------------------------------------------------------------------
 Function cal_sd_lyr_end(as_of_date date, p_calendar_id number) return DATE is
   l_date      date;
   l_timespan  number;
   l_curr_year number;
   l_as_of_date date;
 begin
   l_as_of_date := trunc(as_of_date);
   select end_date-l_as_of_date, sequence
   into l_timespan, l_curr_year
   from fii_time_cal_year
   where l_as_of_date between start_date and end_date
   and calendar_id=p_calendar_id;

   select end_date-l_timespan
   into l_date
   from fii_time_cal_year
   where sequence=l_curr_year-1
   and calendar_id=p_calendar_id;

   return l_date;
 end;

 -- -------------------------------------------------------------------
 -- Name: cal_sd_lysqtr_end
 -- Desc: Returns the same day last year same quarter, count from quarter end
 --       date in the financial calendar.  Info is cached after initial access
 -- Output: Same date(as the pass in date) same quarter in previous financial year.
 -- Error: If any sql errors occurs, an exception is raised.
 -- --------------------------------------------------------------------
 Function cal_sd_lysqtr_end(as_of_date date, p_calendar_id number) return DATE is
   l_date      date;
   l_timespan  number;
   l_curr_qtr  number;
   l_curr_year number;
   l_as_of_date date;
 begin
   l_as_of_date := trunc(as_of_date);
   select end_date-l_as_of_date, sequence, cal_year_id
   into l_timespan, l_curr_qtr, l_curr_year
   from fii_time_cal_qtr
   where l_as_of_date between start_date and end_date
   and calendar_id=p_calendar_id;

   select greatest(start_date, end_date-l_timespan)
   into l_date
   from fii_time_cal_qtr
   where sequence=l_curr_qtr
   and cal_year_id=l_curr_year-1
   and calendar_id=p_calendar_id;

   return l_date;
 end;

 -- -------------------------------------------------------------------
 -- Name: cal_sd_lysper_end
 -- Desc: Returns the same day last year same period, count from period end
 --       date in the financial calendar.  Info is cached after initial access
 -- Output: Same date(as the pass in date) same period in previous financial year.
 -- Error: If any sql errors occurs, an exception is raised.
 -- --------------------------------------------------------------------
 Function cal_sd_lysper_end(as_of_date date, p_calendar_id number) return DATE is
   l_date        date;
   l_timespan    number;
   l_curr_period number;
   l_curr_year   number;
   l_as_of_date date;
 begin
   l_as_of_date := trunc(as_of_date);
   select p.end_date-l_as_of_date, p.sequence, q.cal_year_id
   into l_timespan, l_curr_period, l_curr_year
   from fii_time_cal_period p, fii_time_cal_qtr q
   where p.cal_qtr_id=q.cal_qtr_id
   and q.calendar_id=p_calendar_id
   and p.calendar_id=q.calendar_id
   and l_as_of_date between p.start_date and p.end_date;

   select greatest(p.start_date, p.end_date-l_timespan)
   into l_date
   from fii_time_cal_period p, fii_time_cal_qtr q
   where p.cal_qtr_id=q.cal_qtr_id
   and q.calendar_id=p_calendar_id
   and p.calendar_id=q.calendar_id
   and p.sequence=l_curr_period
   and q.cal_year_id=l_curr_year-1;

   return l_date;
 end;

 -- -------------------------------------------------------------------
 -- Name: cal_sd_pqtr_end
 -- Desc: Returns the same day prior quarter, count from quarter end date
 --       in the financial calendar.  Info is cached after initial access
 -- Output: Same date(as the pass in date) in prior financial quarter.
 -- Error: If any sql errors occurs, an exception is raised.
 -- --------------------------------------------------------------------
 Function cal_sd_pqtr_end(as_of_date date, p_calendar_id number) return DATE is
   l_date      date;
   l_timespan  number;
   l_curr_qtr  number;
   l_curr_year number;
   l_as_of_date date;
 begin
   l_as_of_date := trunc(as_of_date);
   select end_date-l_as_of_date, sequence, cal_year_id
   into l_timespan, l_curr_qtr, l_curr_year
   from fii_time_cal_qtr
   where l_as_of_date between start_date and end_date
   and calendar_id=p_calendar_id;

   if l_curr_qtr=1 then
     select end_date-l_timespan
     into l_date
     from fii_time_cal_qtr
     where sequence=4
     and calendar_id=p_calendar_id
     and cal_year_id=l_curr_year-1;
   else
     select end_date-l_timespan
     into l_date
     from fii_time_cal_qtr
     where sequence=l_curr_qtr-1
     and calendar_id=p_calendar_id
     and cal_year_id=l_curr_year;
   end if;

   return l_date;
 end;

 -- -------------------------------------------------------------------
 -- Name: cal_sd_pper_end
 -- Desc: Returns the same day prior period, count from period end date
 --       in the financial calendar.  Info is cached after initial access
 -- Output: Same date(as the pass in date) in prior financial period.
 -- Error: If any sql errors occurs, an exception is raised.
 -- --------------------------------------------------------------------
 Function cal_sd_pper_end(as_of_date date, p_calendar_id number) return DATE is
   l_date        date;
   l_timespan    number;
   l_curr_period number;
   l_curr_year   number;
   l_as_of_date date;
 begin
   l_as_of_date := trunc(as_of_date);
   select p.end_date-l_as_of_date, p.sequence -1 , q.cal_year_id
   into l_timespan, l_curr_period, l_curr_year
   from fii_time_cal_period p, fii_time_cal_qtr q
   where p.cal_qtr_id=q.cal_qtr_id
   and q.calendar_id=p_calendar_id
   and p.calendar_id=q.calendar_id
   and l_as_of_date between p.start_date and p.end_date;

   if l_curr_period=1 then
     l_curr_year:=l_curr_year-1;

     select count(cal_period_id)
     into l_curr_period
     from fii_time_cal_period p, fii_time_cal_qtr q
     where p.cal_qtr_id=q.cal_qtr_id
     and q.calendar_id=p_calendar_id
     and p.calendar_id=q.calendar_id
     and q.cal_year_id=l_curr_year;
   end if;

   select p.end_date-l_timespan
   into l_date
   from fii_time_cal_period p, fii_time_cal_qtr q
   where p.cal_qtr_id=q.cal_qtr_id
   and p.sequence=l_curr_period
   and q.calendar_id=p_calendar_id
   and p.calendar_id=q.calendar_id
   and q.cal_year_id=l_curr_year;

   return l_date;
 end;

------------------------------------------------------------------

-- -------------------------------------------------------------------
-- Name: ent_rolling_start_date
-- Desc: Returns the start date of the first rolling period/quarter/year in
--       enterprise calendar.  Info is cached after initial access
-- Output: Start date of the first rolling period/quarter/year in enteprise calendar.
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function ent_rolling_start_date(as_of_date date, period_type varchar2) return DATE is
  l_date date;
  l_curr_year number;
  l_as_of_date date;
begin
  l_as_of_date := trunc(as_of_date);
  if(period_type = 'FII_TIME_ENT_YEAR') then
    select sequence
    into l_curr_year
    from fii_time_ent_year
    where l_as_of_date between start_date and end_date;

    select min(start_date)
    into l_date
    from fii_time_ent_year
    where sequence>=l_curr_year-3;
  end if;

  if(period_type = 'FII_TIME_ENT_QTR') then
    select min(start_date)
    into l_date
    from
    (select *
     from fii_time_ent_qtr
     where start_date <= l_as_of_date
     order by start_date desc)
    where rownum < 5;
  end if;

  if(period_type = 'FII_TIME_ENT_PERIOD') then
    select min(start_date)
    into l_date
    from
    (select *
     from fii_time_ent_period
     where start_date <= l_as_of_date
     order by start_date desc)
    where rownum < 14;
    -- Bug 4002034
  end if;

  if(period_type = 'FII_TIME_WEEK') then
   select start_date-7*12
   into l_date
   from fii_time_week
   where l_as_of_date between start_date and end_date;
  end if;

  return l_date;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return bis_common_parameters.get_global_start_date;
end;

-- -------------------------------------------------------------------
-- Name: next_period_end_date
-- Desc: Returns the end date of the next week/period/quarter/year.
--       Info is cached after initial access
-- Output: End date of the next week/period/quarter/year.
-- Error: If any sql errors occurs, an exception is raised.
-- --------------------------------------------------------------------
Function next_period_end_date(as_of_date date, period_type varchar2) return DATE is
  l_date date;
  l_as_of_date date;
  l_max_sequence number;
begin
  l_as_of_date := trunc(as_of_date);
  if(period_type = 'FII_TIME_ENT_YEAR') then
    select end_date
    into l_date
    from fii_time_ent_year
    where sequence =
    (select sequence + 1
     from fii_time_ent_year
     where l_as_of_date between start_date and end_date);
  end if;

  if(period_type = 'FII_TIME_ENT_QTR') then
    select end_date
    into l_date
    from fii_time_ent_qtr next,
    (select sequence, ent_year_id
     from fii_time_ent_qtr
     where l_as_of_date between start_date and end_date) curr
    where next.sequence = decode(curr.sequence, 4, 1, curr.sequence + 1)
    and next.ent_year_id = decode(curr.sequence, 4, curr.ent_year_id+1, curr.ent_year_id);
  end if;

  if(period_type = 'FII_TIME_ENT_PERIOD') then
    -- Bug 4002034
    select max(sequence) into l_max_sequence
    from fii_time_ent_period
    where ent_year_id = (select ent_year_id
			 from fii_time_ent_period
			 where l_as_of_date between start_date and end_date);

    select end_date
    into l_date
    from fii_time_ent_period next,
    (select sequence, ent_year_id
     from fii_time_ent_period
     where l_as_of_date between start_date and end_date) curr
    where next.sequence = decode(curr.sequence, l_max_sequence, 1, curr.sequence + 1)
    and next.ent_year_id = decode(curr.sequence, l_max_sequence, curr.ent_year_id+1, curr.ent_year_id);
  end if;

  if(period_type = 'FII_TIME_WEEK') then
   select end_date+7
   into l_date
   from fii_time_week
   where l_as_of_date between start_date and end_date;
  end if;

  return l_date;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
-- Bug fix 4696282: Changed to return 12/31/9999 instead of max. end date
--    return global_end_date;
    return TO_DATE('12/31/9999', 'MM/DD/YYYY');
end;

end;

/
