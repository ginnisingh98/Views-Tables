--------------------------------------------------------
--  DDL for Package Body BIM_IRES_COLLECTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_IRES_COLLECTION_PKG" AS
/* $Header: bimiresb.pls 115.1 2002/04/29 10:21:23 pkm ship        $*/

 g_pkg_name  CONSTANT  VARCHAR2(30) := 'BIM_IRES_COLLECTION_PKG';
 g_file_name CONSTANT  VARCHAR2(20) := 'bimiresb.pls';

---------------------------------------------------------------------
-- FUNCTION
--    calculate_days
-- NOTE
-- PARAMETER
--   p_start_date      IN  DATE,
--   p_end_date        IN  DATE,
--   p_aggregate       IN  VARCHAR2
--   p_period          IN  VARCHAR2
-- RETURN   NUMBER
---------------------------------------------------------------------

FUNCTION  calculate_days(
    p_start_date         DATE
   ,p_end_date           DATE
   ,p_aggregate          VARCHAR2
   ,p_period             VARCHAR2) return NUMBER
IS

l_date                   DATE;
l_days                   NUMBER;

l_day_code               VARCHAR2(30);
l_week_code              VARCHAR2(30);
l_month_code             VARCHAR2(30);
l_quarter_code           VARCHAR2(30);
l_year_code              VARCHAR2(30);

l_cur_period_start_date  DATE;
l_cur_period_end_date    DATE;
l_pre_period_start_date DATE;
l_pre_period_end_date   DATE;

l_period_start_date      DATE;
l_period_end_date        DATE;
l_temp_start_date        DATE;
l_temp_end_date          DATE;
l_org_id                 NUMBER;

BEGIN

   l_day_code      := 'DAY';
   l_week_code     := 'WEEK';
   l_month_code    := 'MONTH';
   l_quarter_code  := 'QUARTER';
   l_year_code     := 'YEAR';

   l_date := sysdate - 1;
   l_org_id := 0;

   IF (p_aggregate = l_day_code) THEN
     IF (p_period = 'Current') THEN
       IF (p_end_date >= l_date) THEN
         RETURN 1;
       ELSE
         RETURN 0;
       END IF;
     ELSE
       IF (p_end_date >= l_date - 1) THEN
         RETURN 1;
       ELSE
         RETURN 0;
       END IF;
     END IF;
   END IF;

   IF (p_aggregate = l_month_code) THEN
     l_cur_period_start_date := BIM_SET_OF_BOOKS.GET_FISCAL_MONTH_START(l_date, l_org_id);
     l_cur_period_end_date := BIM_SET_OF_BOOKS.GET_FISCAL_MONTH_END(l_date, l_org_id);
     IF (p_period = 'Previous') THEN
       l_pre_period_start_date := BIM_SET_OF_BOOKS.GET_FISCAL_MONTH_START(l_cur_period_start_date - 1, l_org_id);
       l_pre_period_end_date := BIM_SET_OF_BOOKS.GET_FISCAL_MONTH_END(l_cur_period_start_date - 1, l_org_id);
     END IF;
   ELSIF (p_aggregate = l_quarter_code) THEN
     l_cur_period_start_date := BIM_SET_OF_BOOKS.GET_FISCAL_QTR_START(l_date, l_org_id);
     l_cur_period_end_date := BIM_SET_OF_BOOKS.GET_FISCAL_QTR_END(l_date, l_org_id);
     IF (p_period = 'Previous') THEN
       l_pre_period_start_date := BIM_SET_OF_BOOKS.GET_FISCAL_QTR_START(l_cur_period_start_date - 1, l_org_id);
       l_pre_period_end_date := BIM_SET_OF_BOOKS.GET_FISCAL_QTR_END(l_cur_period_start_date - 1, l_org_id);
     END IF;
   ELSIF (p_aggregate = l_year_code) THEN
     l_cur_period_start_date := BIM_SET_OF_BOOKS.GET_FISCAL_ROLL_YEAR_START(l_date, l_org_id);
     l_cur_period_end_date := BIM_SET_OF_BOOKS.GET_FISCAL_QTR_END(l_date, l_org_id);
     IF (p_period = 'Previous') THEN
       l_pre_period_start_date := BIM_SET_OF_BOOKS.GET_PRE_FISCAL_ROLL_YEAR_START(l_date, l_org_id);
       l_pre_period_end_date := BIM_SET_OF_BOOKS.GET_PRE_FISCAL_ROLL_YEAR_END(l_date, l_org_id);
     END IF;
   ELSIF (p_aggregate = l_week_code) THEN
     l_cur_period_start_date := l_date-7;
     l_cur_period_end_date := l_date;
     IF (p_period = 'Previous') THEN
       l_pre_period_start_date := l_date-15;
       l_pre_period_end_date := l_date-8;
     END IF;
   END IF;

   /*

   here u have values for :>>

   1) What Increment-periodtype  u r calculating for : DAY, Week etc..
   2) ldate == date w.r.t. which u r calculating #ofDays
   3) ur period start date
   4) ur period end date
   5) previous period start date
   6) previous period end date

   */

   IF (p_period = 'Previous') THEN
     l_days := trunc(l_date) - trunc(l_cur_period_start_date);
     IF trunc(l_cur_period_end_date) = trunc(l_date) THEN
        l_period_end_date := l_pre_period_end_date;
     ELSE
        l_period_end_date := l_pre_period_start_date + l_days;
     END IF;
     l_period_start_date := l_pre_period_start_date;
   ELSE
     l_period_start_date := l_cur_period_start_date;
     l_period_end_date := l_date;
   END IF;

   --dbms_output.put_line('period_start_date   -- ' || l_period_start_date);
   --dbms_output.put_line('period_end_date   -- ' || l_period_end_date);

   --dbms_output.put_line('p_start_date  -- ' || p_start_date);
   --dbms_output.put_line('p_end_date   -- ' || p_end_date);

   l_days := 0;
   IF (p_start_date > l_period_end_date) THEN
      l_days := 0;
   ELSIF (p_end_date < l_period_start_date) THEN
      l_days := 0;
   ELSIF (p_start_date <= l_period_start_date) THEN
      l_temp_start_date := l_period_start_date;
      IF(p_end_date >= l_period_end_date) THEN
         l_temp_end_date := l_period_end_date;
      ELSE
         l_temp_end_date := p_end_date;
      END IF;
      l_days := trunc(l_temp_end_date) - trunc(l_temp_start_date) + 1;
   ELSIF (p_start_date > l_period_start_date) THEN
      l_temp_start_date := p_start_date;
      IF(p_end_date >= l_period_end_date) THEN
        l_temp_end_date := l_period_end_date;
      ELSE
        l_temp_end_date := p_end_date;
      END IF;
      l_days := trunc(l_temp_end_date) -  trunc(l_temp_start_date) + 1;
   END IF;

   --dbms_output.put_line('l_days   -- ' || l_days);

   RETURN (l_days);

END calculate_days;

/*  Overloaded Function for MQY cost caclulation (number of days) */

FUNCTION  calculate_days(  --overloaded function
    p_start_date              DATE
   ,p_end_date                DATE
   ,p_aggregate               VARCHAR2
   ,p_period                  VARCHAR2
   ,p_date                    DATE
   ,p_cur_period_start_date   DATE
   ,p_cur_period_end_date     DATE
   ,p_prev_period_start_date  DATE
   ,p_prev_period_end_date    DATE) return NUMBER
IS

l_date                   DATE;
l_days                   NUMBER;

l_month_code             VARCHAR2(30);
l_quarter_code           VARCHAR2(30);
l_year_code              VARCHAR2(30);

l_cur_period_start_date  DATE;
l_cur_period_end_date    DATE;
l_pre_period_start_date DATE;
l_pre_period_end_date   DATE;

l_period_start_date      DATE;
l_period_end_date        DATE;
l_temp_start_date        DATE;
l_temp_end_date          DATE;
l_org_id                 NUMBER;

BEGIN

   l_month_code    := 'MONTH';
   l_quarter_code  := 'QUARTER';
   l_year_code     := 'YEAR';

   l_date := p_date;
   l_org_id := 0;

   l_cur_period_start_date  := p_cur_period_start_date;
   l_cur_period_end_date    := p_cur_period_end_date;

   IF (p_period = 'Previous') THEN
     l_pre_period_start_date := p_prev_period_start_date;
     l_pre_period_end_date   := p_prev_period_end_date;
   END IF;

   IF (p_period = 'Previous') THEN
     l_days := trunc(l_date) - trunc(l_cur_period_start_date);
     IF trunc(l_cur_period_end_date) = trunc(l_date) THEN
        l_period_end_date := l_pre_period_end_date;
     ELSE
        l_period_end_date := l_pre_period_start_date + l_days;
     END IF;
     l_period_start_date := l_pre_period_start_date;
   ELSE
     l_period_start_date := l_cur_period_start_date;
     l_period_end_date := l_date;
   END IF;

   --dbms_output.put_line('period_start_date   -- ' || l_period_start_date);
   --dbms_output.put_line('period_end_date   -- ' || l_period_end_date);

   --dbms_output.put_line('p_start_date  -- ' || p_start_date);
   --dbms_output.put_line('p_end_date   -- ' || p_end_date);

   l_days := 0;
   IF (p_start_date > l_period_end_date) THEN
      l_days := 0;
   ELSIF (p_end_date < l_period_start_date) THEN
      l_days := 0;
   ELSIF (p_start_date <= l_period_start_date) THEN
      l_temp_start_date := l_period_start_date;
      IF(p_end_date >= l_period_end_date) THEN
         l_temp_end_date := l_period_end_date;
      ELSE
         l_temp_end_date := p_end_date;
      END IF;
      l_days := trunc(l_temp_end_date) - trunc(l_temp_start_date) + 1;
   ELSIF (p_start_date > l_period_start_date) THEN
      l_temp_start_date := p_start_date;
      IF(p_end_date >= l_period_end_date) THEN
        l_temp_end_date := l_period_end_date;
      ELSE
        l_temp_end_date := p_end_date;
      END IF;
      l_days := trunc(l_temp_end_date) -  trunc(l_temp_start_date) + 1;
   END IF;

   -- dbms_output.put_line('l_days   -- ' || l_days);

   RETURN (l_days);
END calculate_days;
FUNCTION get_min_date return DATE IS
 l_date DATE;
BEGIN
  select min(start_date) into l_date
  from bim_rep_history
  where object='CAMPAIGN';
  return l_date;
END get_min_date;
END BIM_IRES_COLLECTION_PKG;

/
