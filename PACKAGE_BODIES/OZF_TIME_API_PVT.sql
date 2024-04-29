--------------------------------------------------------
--  DDL for Package Body OZF_TIME_API_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_TIME_API_PVT" AS
/*$Header: ozfvtiab.pls 120.1 2005/09/26 16:41:28 mkothari noship $*/

g_debug_flag 	  VARCHAR2(1)  := 'Y';

FUNCTION get_period_start_date(p_time_id         number,
                               p_period_type_id  number)
         RETURN DATE IS
  l_time_id     number;
  l_curr_period number;
  l_curr_qtr    number;
  l_curr_year   number;
  l_start_date  date;
BEGIN
  l_time_id := p_time_id;

  IF p_period_type_id=1 THEN

      SELECT start_date INTO l_start_date
      FROM ozf_time_day
      WHERE report_date_julian=p_time_id;

  ELSIF p_period_type_id=16 THEN

      SELECT start_date INTO l_start_date
      FROM ozf_time_week
      WHERE week_id=p_time_id;

  ELSIF p_period_type_id=32 THEN

      SELECT start_date INTO l_start_date
      FROM ozf_time_ent_period
      WHERE ent_period_id=p_time_id;

  ELSIF p_period_type_id=64 THEN

      SELECT start_date INTO l_start_date
      FROM ozf_time_ent_qtr
      WHERE ent_qtr_id=p_time_id;

  ELSIF p_period_type_id=128 THEN

      SELECT start_date INTO l_start_date
      FROM ozf_time_ent_year
      WHERE ent_year_id=p_time_id;

  END IF;

  return l_start_date;

END get_period_start_date;

FUNCTION get_period_end_date(p_time_id         number,
                             p_period_type_id  number)
         RETURN DATE IS
  l_time_id     number;
  l_curr_period number;
  l_curr_qtr    number;
  l_curr_year   number;
  l_end_date    date;
BEGIN
  l_time_id := p_time_id;

  IF p_period_type_id=1 THEN

      SELECT end_date INTO l_end_date
      FROM ozf_time_day
      WHERE report_date_julian=p_time_id;

  ELSIF p_period_type_id=16 THEN

      SELECT end_date INTO l_end_date
      FROM ozf_time_week
      WHERE week_id=p_time_id;

  ELSIF p_period_type_id=32 THEN

      SELECT end_date INTO l_end_date
      FROM ozf_time_ent_period
      WHERE ent_period_id=p_time_id;

  ELSIF p_period_type_id=64 THEN

      SELECT end_date INTO l_end_date
      FROM ozf_time_ent_qtr
      WHERE ent_qtr_id=p_time_id;

  ELSIF p_period_type_id=128 THEN

      SELECT end_date INTO l_end_date
      FROM ozf_time_ent_year
      WHERE ent_year_id=p_time_id;

  END IF;

  return l_end_date;

END get_period_end_date;


FUNCTION get_period_name(p_time_id         number,
                         p_period_type_id  number)
         RETURN VARCHAR2 IS
  l_time_id     number;
  l_curr_period number;
  l_curr_qtr    number;
  l_curr_year   number;
  l_name        varchar2(100);
BEGIN
  l_time_id := p_time_id;

  IF p_period_type_id=1 THEN

      SELECT TO_CHAR(report_date) INTO l_name
      FROM ozf_time_day
      WHERE report_date_julian=p_time_id;

  ELSIF p_period_type_id=16 THEN

      SELECT name INTO l_name
      FROM ozf_time_week
      WHERE week_id=p_time_id;

  ELSIF p_period_type_id=32 THEN

      SELECT name INTO l_name
      FROM ozf_time_ent_period
      WHERE ent_period_id=p_time_id;

  ELSIF p_period_type_id=64 THEN

      SELECT name INTO l_name
      FROM ozf_time_ent_qtr
      WHERE ent_qtr_id=p_time_id;

  ELSIF p_period_type_id=128 THEN

      SELECT name INTO l_name
      FROM ozf_time_ent_year
      WHERE ent_year_id=p_time_id;

  END IF;

  return l_name;

END get_period_name;

FUNCTION get_lysp_period_name(p_time_id         number,
                              p_period_type_id  number)
         RETURN VARCHAR2 IS
  l_time_id     number;
  l_curr_period number;
  l_curr_qtr    number;
  l_curr_year   number;
  l_name        varchar2(100);
BEGIN
  l_time_id := get_lysp_id(p_time_id, p_period_type_id);

  IF p_period_type_id=1 OR p_period_type_id=16 THEN
     l_name := NULL;

  ELSIF p_period_type_id=32 THEN

      SELECT name INTO l_name
      FROM ozf_time_ent_period
      WHERE ent_period_id=l_time_id;

  ELSIF p_period_type_id=64 THEN

      SELECT name INTO l_name
      FROM ozf_time_ent_qtr
      WHERE ent_qtr_id=l_time_id;

  ELSIF p_period_type_id=128 THEN

      SELECT name INTO l_name
      FROM ozf_time_ent_year
      WHERE ent_year_id=l_time_id;

  END IF;

  return l_name;

END get_lysp_period_name;



FUNCTION GET_LYSP_ID(p_time_id         number,
                     p_period_type_id  number)
         RETURN NUMBER IS
  l_time_id     number;
  l_curr_period number;
  l_curr_qtr    number;
  l_curr_year   number;
BEGIN
  l_time_id := p_time_id;

  IF p_period_type_id=1 OR p_period_type_id=16 THEN
     l_time_id := NULL; -- if required think of this logic

  ELSIF p_period_type_id=32 THEN

      SELECT sequence, ent_year_id INTO l_curr_period, l_curr_year
      FROM ozf_time_ent_period
      WHERE ent_period_id=p_time_id;

      SELECT ent_period_id INTO l_time_id
      FROM ozf_time_ent_period
      WHERE sequence=l_curr_period
        AND ent_year_id=l_curr_year-1;

  ELSIF p_period_type_id=64 THEN

      SELECT sequence, ent_year_id INTO l_curr_qtr, l_curr_year
      FROM ozf_time_ent_qtr
      WHERE ent_qtr_id=p_time_id;

      SELECT ent_qtr_id INTO l_time_id
      FROM ozf_time_ent_qtr
      WHERE sequence=l_curr_qtr
        AND ent_year_id=l_curr_year-1;

  ELSIF p_period_type_id=128 THEN
      l_time_id := p_time_id-1;

  END IF;

  return l_time_id;

END GET_LYSP_ID;


FUNCTION GET_PERIOD_TBL(p_start_date     varchar2,
                        p_end_date       varchar2,
                        p_period_type_id number)
         RETURN G_PERIOD_TBL_TYPE IS

G_OZF_PARAMETER_NOT_SETUP EXCEPTION;
l_period_type_id          NUMBER := 0;
l_index                   NUMBER := 0;
l_period_tbl              G_PERIOD_TBL_TYPE;
l_start_date              date;
l_end_date                date;

Cursor get_year_ids_csr (l_start_date date,
                         l_end_date   date) IS
SELECT
ent_year_id
FROM ozf_time_ent_year
WHERE start_date >= l_start_date
AND end_date <= l_end_date;

Cursor get_qtr_ids_csr (l_start_date date,
                       l_end_date   date) IS
SELECT
ent_qtr_id
FROM ozf_time_ent_qtr
WHERE start_date >= l_start_date
AND end_date <= l_end_date;

Cursor get_month_ids_csr (l_start_date date,
                          l_end_date   date) IS
SELECT
ent_period_id
FROM ozf_time_ent_period
WHERE start_date >= l_start_date
AND end_date <= l_end_date;

Cursor get_week_ids_csr (l_start_date date,
                         l_end_date   date) IS
SELECT
week_id
FROM ozf_time_week
WHERE start_date >= l_start_date
AND end_date <= l_end_date;

BEGIN

if (p_start_date is NULL or p_end_date is NULL or p_period_type_id is NULL)
THEN
   raise G_OZF_PARAMETER_NOT_SETUP;
end if;

l_start_date := trunc(to_date(p_start_date,'YYYY/MM/DD HH24:MI:SS'));
l_end_date := trunc(to_date(p_end_date, 'YYYY/MM/DD HH24:MI:SS'));
l_period_type_id := p_period_type_id;

if g_debug_flag = 'Y' then
   OZF_TP_UTIL_PVT.put_line('OZF_TIME_API_PVT.GET_PERIOD_TBL: Finding Time_ids of PeriodTypeId '
                           || l_period_type_id ||' From '||l_start_date||' to '||l_end_date);
end if;

IF l_period_type_id = 128 THEN
 FOR l_period_rec in get_year_ids_csr(l_start_date, l_end_date)
 LOOP
    l_period_tbl(l_index) := l_period_rec.ent_year_id;
    l_index := l_index + 1;
 END LOOP;

ELSIF l_period_type_id = 64 THEN
 FOR l_period_rec in get_qtr_ids_csr(l_start_date, l_end_date)
 LOOP
    l_period_tbl(l_index) := l_period_rec.ent_qtr_id;
    l_index := l_index + 1;
 END LOOP;

ELSIF l_period_type_id = 32 THEN
 FOR l_period_rec in get_month_ids_csr(l_start_date, l_end_date)
 LOOP
    l_period_tbl(l_index) := l_period_rec.ent_period_id;
    l_index := l_index + 1;
 END LOOP;

ELSIF l_period_type_id = 16 THEN
 FOR l_period_rec in get_week_ids_csr(l_start_date, l_end_date)
 LOOP
    l_period_tbl(l_index) := l_period_rec.week_id;
    l_index := l_index + 1;
 END LOOP;

END IF;

return l_period_tbl;

EXCEPTION

 WHEN G_OZF_PARAMETER_NOT_SETUP THEN
  if g_debug_flag = 'Y' then
    OZF_TP_UTIL_PVT.put_line(fnd_message.get_string('OZF', 'OZF_TP_INVALID_PARAM_TXT'));
  end if;
 WHEN OTHERS THEN
    rollback;
    if g_debug_flag = 'Y' then
        OZF_TP_UTIL_PVT.put_line(sqlcode||' : '||sqlerrm);
    end if;
END GET_PERIOD_TBL;


FUNCTION Is_Quarter_Allowed(p_start_date     DATE,
                            p_end_date       DATE)
RETURN CHAR IS

Cursor is_qtr_present_csr (l_start_date date,
                           l_end_date   date) IS
 SELECT 'Y'
   FROM DUAL
 WHERE TRUNC(l_start_date) IN (SELECT DISTINCT START_DATE FROM OZF_TIME_ENT_QTR)
   AND TRUNC(l_end_date) IN (SELECT DISTINCT END_DATE FROM OZF_TIME_ENT_QTR);

l_return_value       CHAR := 'N';

BEGIN

   BEGIN
      IF (p_start_date is NULL or p_end_date is NULL)
      THEN
         l_return_value := 'N';
      ELSE
         OPEN is_qtr_present_csr (p_start_date, p_end_date);
         FETCH is_qtr_present_csr into l_return_value;
         CLOSE is_qtr_present_csr;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         l_return_value := 'N';
   END;

   IF l_return_value IS NULL THEN
      l_return_value := 'N';
   END IF;

   return l_return_value;

END Is_Quarter_Allowed;



FUNCTION Is_Period_Range_Valid(p_start_date     DATE,
                               p_end_date       DATE)
RETURN CHAR IS

Cursor no_of_periods_csr (l_start_date date,
                          l_end_date   date) IS
  SELECT COUNT(ent_period_id)
    FROM OZF_TIME_ENT_PERIOD
   WHERE START_DATE >= TRUNC(p_start_date)
     AND END_DATE <= TRUNC(p_end_date);

l_return_value       NUMBER := 13;

BEGIN

   BEGIN
      IF (p_start_date is NULL or p_end_date is NULL)
      THEN
         l_return_value := 13;
      ELSE
         OPEN no_of_periods_csr (p_start_date, p_end_date);
         FETCH no_of_periods_csr into l_return_value;
         CLOSE no_of_periods_csr;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         l_return_value := 13;
   END;

   IF l_return_value IS NULL OR l_return_value > 12 THEN
      return 'N';
   ELSE
      return 'Y';
   END IF;

END Is_Period_Range_Valid;


END OZF_TIME_API_PVT;

/
