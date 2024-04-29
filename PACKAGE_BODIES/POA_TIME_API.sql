--------------------------------------------------------
--  DDL for Package Body POA_TIME_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_TIME_API" AS
/* $Header: POAQTRSB.pls 115.5 2002/01/24 17:59:46 pkm ship      $  */

g_initialized_set1      BOOLEAN := FALSE;
g_initialized_set2      BOOLEAN := FALSE;
g_poa_fixed_date        DATE := NULL;
g_period_set_name       varchar2(80) := NULL;
g_period_type           varchar2(80) := NULL;

g_ent_cycq_start        DATE := NULL;
g_ent_cycq_end          DATE := NULL;
g_ent_lycq_start        DATE := NULL;
g_ent_lycq_end          DATE := NULL;
g_ent_cycq_today        DATE := NULL;
g_ent_lycq_today        DATE := NULL;
g_ent_cy_start          DATE := NULL;
g_ent_ly_start          DATE := NULL;
g_ent_cy_end            DATE := NULL;
g_ent_ly_end            DATE := NULL;

procedure init_set2  is
begin
  g_initialized_set2 := TRUE;

  g_period_set_name  := fnd_profile.value('POA_PERIOD_NAME');
  g_period_type  := fnd_profile.value('POA_PERIOD_TYPE');

  g_poa_fixed_date := to_date(fnd_profile.value('POA_FIXED_DATE'),
                              'MM-DD-YYYY');

  if (g_poa_fixed_date IS NULL) then
        g_poa_fixed_date := sysdate;
  end if;

exception
  when others then
  -- This error will generally occur when people did not
  -- follow the proper date format mask  of MM-DD-YYYY,
  -- in which case, we just ignore the profile
    g_poa_fixed_date := NULL;
end;

procedure init_set1 is

  x_no_data_found       EXCEPTION;
  x_null_value          EXCEPTION;

  cursor c1 is
  select min(per.start_date),
         max(per.end_date)
  from gl_periods per
  where per.period_set_name = g_period_set_name
  and per.period_type = g_period_type
  group by period_year, quarter_num
  having nvl(g_poa_fixed_date, sysdate)
  between min(per.start_date) and
          max(per.end_date);

  cursor c2 is
  select min(per.start_date),
         max(per.end_date)
  from gl_periods per
  where per.period_set_name = g_period_set_name
  and per.period_type = g_period_type
  group by period_year, quarter_num
  having add_months(nvl(g_poa_fixed_date, sysdate), -12)
  between min(per.start_date) and
          max(per.end_date);

  cursor c3 is
  select min(per.start_date),
         max(per.end_date)
  from gl_periods per
  where per.period_set_name = g_period_set_name
  and per.period_type = g_period_type
  group by period_year
  having nvl(g_poa_fixed_date, sysdate)
  between min(per.start_date) and
          max(per.end_date);

  cursor c4  is
  select min(per.start_date),
         max(per.end_date)
  from gl_periods per
  where per.period_set_name = g_period_set_name
  and per.period_type = g_period_type
  group by period_year
  having add_months(nvl(g_poa_fixed_date, sysdate), -12)
  between min(per.start_date) and
          max(per.end_date);


begin

  init_set2;

  OPEN c1;
  FETCH c1 into g_ent_cycq_start,
                g_ent_cycq_end;

  IF c1%NOTFOUND THEN
    CLOSE c1;
    RAISE x_no_data_found;
  END IF;

  OPEN c2;
  FETCH c2 into g_ent_lycq_start,
                g_ent_lycq_end;

  IF c2%NOTFOUND THEN
    CLOSE c2;
    RAISE x_no_data_found;
  END IF;

  CLOSE c2;

  OPEN c3;
  FETCH c3 into g_ent_cy_start,
                g_ent_cy_end;

  IF c3%NOTFOUND THEN
    CLOSE c3;
    RAISE x_no_data_found;
  END IF;

  CLOSE c3;

  OPEN c4;
  FETCH c4 into g_ent_ly_start,
                g_ent_ly_end;

  IF c4%NOTFOUND THEN
    CLOSE c4;
    RAISE x_no_data_found;
  END IF;

  CLOSE c4;

  IF (g_ent_cycq_start is NULL or
      g_ent_cycq_end is NULL or
      g_ent_lycq_start is NULL or
      g_ent_lycq_end is NULL or
      g_ent_cy_start is NULL or
      g_ent_cy_end is NULL or
      g_ent_ly_start is NULL or
      g_ent_ly_end is NULL) THEN
    RAISE x_null_value;
  END IF;

  g_initialized_set1 := TRUE;

exception
  when x_no_data_found then
        raise_application_error(-20000, 'No data found');
  when x_null_value then
        raise_application_error(-20001, 'Null Values');
  when others then
        if c1%ISOPEN then
                close c1;
        end if;
        raise_application_error(-20002, 'Other Error');
end init_set1;

-- ----------------------------------------------------
-- ent_cycq_start
-- ----------------------------------------------------
FUNCTION get_today RETURN DATE IS
BEGIN
  IF (NOT g_initialized_set2) THEN
    init_set2;
  END IF;
  RETURN (trunc(nvl(g_poa_fixed_date, sysdate)));
END get_today;

-- ----------------------------------------------------
-- get_cqtr_start
-- ----------------------------------------------------
FUNCTION get_cqtr_start RETURN DATE IS
BEGIN
  IF (NOT g_initialized_set1) THEN
    init_set1;
  END IF;
  RETURN(g_ent_cycq_start);
END get_cqtr_start;


-- ----------------------------------------------------
-- get_cqtr_end
-- ----------------------------------------------------
FUNCTION get_cqtr_end RETURN DATE IS
BEGIN
  IF (NOT g_initialized_set1) THEN
    init_set1;
  END IF;

  RETURN(g_ent_cycq_end);
END get_cqtr_end;

-- ----------------------------------------------------
-- get_lycq_start
-- ----------------------------------------------------
FUNCTION get_lycq_start RETURN DATE IS
BEGIN
  IF (NOT g_initialized_set1) THEN
    init_set1;
  END IF;
  RETURN(g_ent_lycq_start);
END get_lycq_start;


-- ----------------------------------------------------
-- get_lycq_end
-- ----------------------------------------------------
FUNCTION get_lycq_end RETURN DATE IS
BEGIN
  IF (NOT g_initialized_set1) THEN
    init_set1;
  END IF;
  RETURN(g_ent_lycq_end);
END get_lycq_end;


-- ----------------------------------------------------
-- get_cy_start
-- ----------------------------------------------------
FUNCTION get_cy_start RETURN DATE IS
BEGIN
  IF (NOT g_initialized_set1) THEN
    init_set1;
  END IF;
  RETURN(g_ent_cy_start);
END get_cy_start;


-- ----------------------------------------------------
-- get_cy_end
-- ----------------------------------------------------
FUNCTION get_cy_end RETURN DATE IS
BEGIN
  IF (NOT g_initialized_set1) THEN
    init_set1;
  END IF;
  RETURN(g_ent_cy_end);
END get_cy_end;


-- ----------------------------------------------------
-- get_ly_start
-- ----------------------------------------------------
FUNCTION get_ly_start RETURN DATE IS
BEGIN
  IF (NOT g_initialized_set1) THEN
    init_set1;
  END IF;
  RETURN(g_ent_ly_start);
END get_ly_start;


-- ----------------------------------------------------
-- get_ly_end
-- ----------------------------------------------------
FUNCTION get_ly_end RETURN DATE IS
BEGIN
  IF (NOT g_initialized_set1) THEN
    init_set1;
  END IF;
  RETURN(g_ent_ly_end);
END get_ly_end;



-- ----------------------------------------------------
-- get_lycq_today
-- ----------------------------------------------------
FUNCTION get_lycq_today RETURN DATE IS
BEGIN
  IF (NOT g_initialized_set1) THEN
    init_set1;
  END IF;
  RETURN (g_ent_lycq_end - ( g_ent_cycq_end - trunc(nvl(g_poa_fixed_date,
                                                        sysdate)) ) );
END get_lycq_today;

end;

/
