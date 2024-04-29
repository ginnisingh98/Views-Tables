--------------------------------------------------------
--  DDL for Package Body FII_TIME_WH_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_TIME_WH_API" AS
/* $Header: FIIQTRSB.pls 120.1 2003/08/25 12:39:11 sgautam noship $  */
VERSION  CONSTANT CHAR(80) := '$Header: FIIQTRSB.pls 120.1 2003/08/25 12:39:11 sgautam noship $';

g_initialized_set1	BOOLEAN := FALSE;
g_initialized_set2	BOOLEAN := FALSE;

g_curr_fqtr_start 	DATE := NULL;
g_curr_fqtr_end		DATE := NULL;

g_ent_cycq_start	DATE := NULL;
g_ent_cycq_end		DATE := NULL;
g_ent_lycq_start	DATE := NULL;
g_ent_lycq_end		DATE := NULL;
g_ent_lycq_today1	DATE := NULL;
g_ent_lycq_today2	DATE := NULL;
g_ent_cy_start	    DATE := NULL;
g_ent_cy_end		DATE := NULL;
g_ent_ly_start	    DATE := NULL;
g_ent_ly_end		DATE := NULL;
g_cycq_pk_key NUMBER := NULL;
g_cycm_pk_key NUMBER := NULL;

procedure init_set2 is
begin
  g_initialized_set2 := TRUE;
  exception
  when others then
  -- This error will generally occur when people did not
  -- follow the proper date format mask  of MM-DD-YYYY,
  -- in which case, we just ignore the profile
     NULL;
end;

procedure init_set1 is

  x_no_data_found	EXCEPTION;
  x_null_value		EXCEPTION;

  cursor c1 is
  select trunc(min(least(ecqr_start_date, cqtr_start_date))),
	 trunc(max(greatest(ecqr_end_date, cqtr_end_date))),
	 trunc(min(ecqr_start_date)),
	 trunc(max(ecqr_end_date)),
    trunc(min(ecyr_start_date)),
    trunc(max(ecyr_end_date))
  from	 edw_time_m
  where	 cday_calendar_date = trunc(sysdate);

  cursor c2 is
  select trunc(min(ecqr_start_date)),
	 trunc(max(ecqr_end_date)),
    trunc(min(ecyr_start_date)),
    trunc(max(ecyr_end_date))
  from	 edw_time_m
  where	 cday_calendar_date = add_months(trunc(sysdate), -12);

  cursor c3 is
  select cal_qtr_pk_key
  from edw_time_ep_cal_qtr_ltc
  where start_date = (
          select trunc(min(ecqr_start_date))
          from   edw_time_m
          where  cday_calendar_date = trunc(sysdate));

  cursor c4 is
  select month_pk_key
  from edw_time_month_ltc
  where start_date = (select trunc(min(mnth_start_date))
                      from edw_time_m
                      where  cday_calendar_date = trunc(sysdate));
begin

  init_set2;

  OPEN c1;
  FETCH c1 into	g_curr_fqtr_start,
		g_curr_fqtr_end,
		g_ent_cycq_start,
		g_ent_cycq_end,
      g_ent_cy_start,
      g_ent_cy_end;

  IF c1%NOTFOUND THEN
    CLOSE c1;
    RAISE x_no_data_found;
  END IF;

  CLOSE c1;

  OPEN c2;
  FETCH c2 into	g_ent_lycq_start,
		g_ent_lycq_end,
      g_ent_ly_start,
      g_ent_ly_end;

  IF c2%NOTFOUND THEN
    CLOSE c2;
    RAISE x_no_data_found;
  END IF;

  CLOSE c2;

  OPEN c3;
  FETCH c3 into g_cycq_pk_key;

  IF c3%NOTFOUND THEN
    CLOSE c3;
    RAISE x_no_data_found;
  END IF;

  CLOSE c3;

  OPEN c4;
  FETCH c4 into g_cycm_pk_key;

  IF c4%NOTFOUND THEN
    CLOSE c4;
    RAISE x_no_data_found;
  END IF;

  CLOSE c4;


  IF (g_curr_fqtr_start is NULL or
      g_curr_fqtr_end is NULL or
      g_ent_cycq_start is NULL or
      g_ent_cycq_end is NULL or
      g_ent_lycq_start is NULL or
      g_ent_lycq_end is NULL or
      g_ent_cy_start is NULL or
      g_ent_cy_end is NULL or
      g_ent_ly_start is NULL or
      g_ent_ly_end is NULL or
      g_cycq_pk_key is NULL or
      g_cycm_pk_key is NULL) THEN
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
FUNCTION ent_cycq_start RETURN DATE IS
BEGIN
  IF (NOT g_initialized_set1) THEN
    init_set1;
  END IF;
  RETURN(g_ent_cycq_start);
END ent_cycq_start;


-- ----------------------------------------------------
-- ent_cycq_end
-- ----------------------------------------------------
FUNCTION ent_cycq_end RETURN DATE IS
BEGIN
  IF (NOT g_initialized_set1) THEN
    init_set1;
  END IF;
  RETURN(g_ent_cycq_end);
END ent_cycq_end;


-- ----------------------------------------------------
-- ent_lycq_start
-- ----------------------------------------------------
FUNCTION ent_lycq_start RETURN DATE IS
BEGIN
  IF (NOT g_initialized_set1) THEN
    init_set1;
  END IF;
  RETURN(g_ent_lycq_start);
END ent_lycq_start;


-- ----------------------------------------------------
-- ent_lycq_end
-- ----------------------------------------------------
FUNCTION ent_lycq_end RETURN DATE IS
BEGIN
  IF (NOT g_initialized_set1) THEN
    init_set1;
  END IF;
  RETURN(g_ent_lycq_end);
END ent_lycq_end;


-- ----------------------------------------------------
-- ent_cy_start
-- ----------------------------------------------------
FUNCTION ent_cy_start RETURN DATE IS
BEGIN
  IF (NOT g_initialized_set1) THEN
    init_set1;
  END IF;
  RETURN(g_ent_cy_start);
END ent_cy_start;


-- ----------------------------------------------------
-- ent_cy_end
-- ----------------------------------------------------
FUNCTION ent_cy_end RETURN DATE IS
BEGIN
  IF (NOT g_initialized_set1) THEN
    init_set1;
  END IF;
  RETURN(g_ent_cy_end);
END ent_cy_end;


-- ----------------------------------------------------
-- ent_ly_start
-- ----------------------------------------------------
FUNCTION ent_ly_start RETURN DATE IS
BEGIN
  IF (NOT g_initialized_set1) THEN
    init_set1;
  END IF;
  RETURN(g_ent_ly_start);
END ent_ly_start;


-- ----------------------------------------------------
-- ent_ly_end
-- ----------------------------------------------------
FUNCTION ent_ly_end RETURN DATE IS
BEGIN
  IF (NOT g_initialized_set1) THEN
    init_set1;
  END IF;
  RETURN(g_ent_ly_end);
END ent_ly_end;


-- ----------------------------------------------------
-- ent_lycq_today1
-- ----------------------------------------------------
FUNCTION ent_lycq_today1 RETURN DATE IS
BEGIN
  IF (NOT g_initialized_set1) THEN
    init_set1;
  END IF;
  RETURN (g_ent_lycq_end - ( g_ent_cycq_end - trunc(sysdate) ) );
END ent_lycq_today1;


-- ----------------------------------------------------
-- ent_lycq_today2
-- ----------------------------------------------------
FUNCTION ent_lycq_today2 RETURN DATE IS
BEGIN
  IF (NOT g_initialized_set1) THEN
    init_set1;
  END IF;
  RETURN (g_ent_lycq_start + (trunc(sysdate) - g_ent_cycq_start));
END ent_lycq_today2;


-- ----------------------------------------------------
-- today
-- ----------------------------------------------------
FUNCTION today RETURN DATE IS
BEGIN
  IF (NOT g_initialized_set2) THEN
    init_set2;
  END IF;
  RETURN (trunc(sysdate));
END today;


-- ----------------------------------------------------
-- todaytime
-- ----------------------------------------------------
FUNCTION todaytime RETURN DATE IS
BEGIN
  IF (NOT g_initialized_set2) THEN
    init_set2;
  END IF;
  RETURN (sysdate);
END todaytime;


-- ----------------------------------------------------
-- get_fqtr_start
-- ----------------------------------------------------
FUNCTION get_fqtr_start RETURN DATE IS
BEGIN
  IF (NOT g_initialized_set1) THEN
    init_set1;
  END IF;
  RETURN(g_curr_fqtr_start);
END get_fqtr_start;


-- ----------------------------------------------------
-- get_fqtr_end
-- ----------------------------------------------------
FUNCTION get_fqtr_end RETURN DATE IS
BEGIN
  IF (NOT g_initialized_set1) THEN
    init_set1;
  END IF;
  RETURN(g_curr_fqtr_end);
END get_fqtr_end;


-- ----------------------------------------------------
-- get_curr_eqtr_start
-- ----------------------------------------------------
FUNCTION get_curr_eqtr_start RETURN DATE IS
BEGIN
  RETURN(ent_cycq_start);
END get_curr_eqtr_start;


-- ----------------------------------------------------
-- get_curr_eqtr_end
-- ----------------------------------------------------
FUNCTION get_curr_eqtr_end RETURN DATE IS
BEGIN
  RETURN(ent_cycq_end);
END get_curr_eqtr_end;

-- ----------------------------------------------------
-- get_cycq_pk_key
-- ----------------------------------------------------
FUNCTION get_cycq_pk_key RETURN NUMBER  IS
BEGIN
  IF (NOT g_initialized_set1) THEN
    init_set1;
  END IF;
  RETURN(g_cycq_pk_key);
END get_cycq_pk_key;


-- ----------------------------------------------------
-- get_cycm_pk_key
-- ----------------------------------------------------
FUNCTION get_cycm_pk_key RETURN NUMBER  IS
BEGIN
  IF (NOT g_initialized_set1) THEN
    init_set1;
  END IF;
  RETURN(g_cycm_pk_key);
END get_cycm_pk_key;

-- ----------------------------------------------------
-- ent_today
-- ----------------------------------------------------
FUNCTION ent_today RETURN DATE IS
BEGIN
  IF (NOT g_initialized_set2) THEN
    init_set2;
  END IF;
  RETURN trunc(sysdate);
END ent_today;

end;

/
